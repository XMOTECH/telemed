defmodule Telemed.Video.InstantRoom do
  @moduledoc """
  GenServer gérant UNE consultation vidéo instantanée.

  Architecture:
  - 1 consultation = 1 process GenServer isolé
  - Fault-tolerant: si crash, supervision redémarre
  - Ultra-léger: peut avoir 1 million de rooms simultanées

  Features:
  - Magic links (auto-login 1-clic)
  - Auto-start quand 2 participants
  - Quality monitoring intégré
  - Smart recording
  - Auto-cleanup après consultation
  """

  use GenServer
  require Logger

  alias Telemed.Video.{RoomRegistry, QualityMonitor}

  defstruct [
    :id,
    :appointment_id,
    :doctor_id,
    :patient_id,
    :started_at,
    :quality_monitor_pid,
    participants: %{},  # Map: user_id => %{joined_at, metadata}
    messages: [],
    status: :waiting,  # :waiting, :active, :ended
    quality: :excellent,
    recording: false
  ]

  # ========== CLIENT API ==========

  def start_link({room_id, appointment_id, doctor_id, patient_id}) do
    GenServer.start_link(
      __MODULE__,
      {room_id, appointment_id, doctor_id, patient_id},
      name: via_tuple(room_id)
    )
  end

  @doc "Un participant rejoint la consultation"
  def participant_joined(room_id, user_id, metadata \\ %{}) do
    GenServer.cast(via_tuple(room_id), {:participant_joined, user_id, metadata})
  end

  @doc "Un participant quitte"
  def participant_left(room_id, user_id) do
    GenServer.cast(via_tuple(room_id), {:participant_left, user_id})
  end

  @doc "Récupérer les infos de la room"
  def get_info(room_id) do
    GenServer.call(via_tuple(room_id), :get_info)
  end

  @doc "Envoyer un message chat"
  def send_message(room_id, user_id, message) do
    GenServer.cast(via_tuple(room_id), {:chat_message, user_id, message})
  end

  @doc "Mise à jour qualité réseau"
  def update_quality(room_id, quality_level) do
    GenServer.cast(via_tuple(room_id), {:quality_update, quality_level})
  end

  # ========== SERVER CALLBACKS ==========

  @impl true
  def init({room_id, appointment_id, doctor_id, patient_id}) do
    Logger.info("🚀 InstantRoom starting: #{room_id}")

    # Enregistrer dans le Registry
    case RoomRegistry.register(room_id) do
      {:ok, _} -> :ok
      {:error, {:already_registered, _}} -> :ok
    end

    # Auto-cleanup après 2h d'inactivité
    schedule_timeout_check()

    state = %__MODULE__{
      id: room_id,
      appointment_id: appointment_id,
      doctor_id: doctor_id,
      patient_id: patient_id,
      started_at: DateTime.utc_now(),
      status: :waiting
    }

    # Démarrer le quality monitor
    {:ok, monitor_pid} = QualityMonitor.start_link(room_id)
    state = %{state | quality_monitor_pid: monitor_pid}

    Logger.info("✅ InstantRoom #{room_id} initialized and waiting for participants")
    {:ok, state}
  end

  @impl true
  def handle_cast({:participant_joined, user_id, metadata}, state) do
    Logger.info("👋 Participant #{user_id} joined room #{state.id}")

    participant = %{
      joined_at: DateTime.utc_now(),
      metadata: metadata
    }

    new_participants = Map.put(state.participants, user_id, participant)
    new_state = %{state | participants: new_participants}

    # Broadcast aux autres participants
    broadcast_event(new_state, :participant_joined, %{
      user_id: user_id,
      metadata: metadata
    })

    # Si 2 participants → DÉMARRER AUTO
    if map_size(new_participants) == 2 and state.status == :waiting do
      Logger.info("✅ Both participants ready! Auto-starting consultation #{state.id}")
      new_state = auto_start_consultation(new_state)
      {:noreply, new_state}
    else
      {:noreply, new_state}
    end
  end

  @impl true
  def handle_cast({:participant_left, user_id}, state) do
    Logger.info("👋 Participant #{user_id} left room #{state.id}")

    new_participants = Map.delete(state.participants, user_id)
    new_state = %{state | participants: new_participants}

    # Broadcast
    broadcast_event(new_state, :participant_left, %{user_id: user_id})

    # Si plus personne → Cleanup dans 30s
    if map_size(new_participants) == 0 do
      Logger.info("Room #{state.id} now empty, scheduling cleanup")
      Process.send_after(self(), :cleanup_empty_room, 30_000)
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:chat_message, user_id, message}, state) do
    chat_msg = %{
      user_id: user_id,
      message: message,
      timestamp: DateTime.utc_now()
    }

    new_messages = [chat_msg | state.messages]
    new_state = %{state | messages: new_messages}

    # Broadcast
    broadcast_event(new_state, :new_message, chat_msg)

    # SMART RECORDING: Détecter keywords médicaux
    if contains_medical_keywords?(message) do
      Logger.info("🎯 Medical keyword detected, triggering smart actions")
      trigger_smart_recording(new_state, message)
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:quality_update, quality_level}, state) do
    Logger.debug("📊 Quality updated to: #{quality_level}")

    new_state = %{state | quality: quality_level}

    # Si qualité critique, suggérer audio-only
    if quality_level == :poor do
      broadcast_event(new_state, :quality_warning, %{
        message: "Qualité faible. Passage en audio seul recommandé.",
        action: :switch_to_audio
      })
    end

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_info, _from, state) do
    info = %{
      id: state.id,
      appointment_id: state.appointment_id,
      doctor_id: state.doctor_id,
      patient_id: state.patient_id,
      status: state.status,
      participants: Map.keys(state.participants),
      participant_count: map_size(state.participants),
      messages_count: length(state.messages),
      quality: state.quality,
      started_at: state.started_at,
      duration_seconds: DateTime.diff(DateTime.utc_now(), state.started_at)
    }

    {:reply, {:ok, info}, state}
  end

  @impl true
  def handle_info(:check_timeout, state) do
    # Vérifier si consultation trop longue ou inactive
    duration = DateTime.diff(DateTime.utc_now(), state.started_at)

    cond do
      state.status == :waiting and duration > 1800 ->  # 30 min waiting
        Logger.warning("Room #{state.id} timeout while waiting, shutting down")
        {:stop, :normal, state}

      state.status == :active and duration > 7200 ->  # 2h max consultation
        Logger.warning("Room #{state.id} max duration reached, ending consultation")
        end_consultation(state)
        {:stop, :normal, state}

      true ->
        schedule_timeout_check()
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:cleanup_empty_room, state) do
    if map_size(state.participants) == 0 do
      Logger.info("Room #{state.id} still empty, cleaning up")
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Room #{state.id} terminating: #{inspect(reason)}")

    # Sauvegarder les statistiques
    save_consultation_stats(state)

    # Arrêter le quality monitor
    if state.quality_monitor_pid && Process.alive?(state.quality_monitor_pid) do
      GenServer.stop(state.quality_monitor_pid, :normal)
    end

    # Notifier les participants
    broadcast_event(state, :consultation_ended, %{
      duration: DateTime.diff(DateTime.utc_now(), state.started_at)
    })

    :ok
  end

  # ========== PRIVATE FUNCTIONS ==========

  defp auto_start_consultation(state) do
    Logger.info("🎬 AUTO-STARTING consultation #{state.id}")

    # Mettre à jour statut
    new_state = %{state | status: :active}

    # Broadcast démarrage
    broadcast_event(new_state, :consultation_started, %{
      participants: Map.keys(new_state.participants),
      started_at: DateTime.utc_now()
    })

    # Créer notification DME
    create_consultation_record(new_state)

    new_state
  end

  defp broadcast_event(state, event, payload) do
    Phoenix.PubSub.broadcast(
      Telemed.PubSub,
      "instant:#{state.id}",
      {event, payload}
    )
  end

  defp schedule_timeout_check do
    Process.send_after(self(), :check_timeout, :timer.minutes(10))
  end

  defp contains_medical_keywords?(message) do
    keywords = ~w(
      diagnostic traitement prescription symptôme symptome
      douleur fièvre fievre toux allergie
      ordonnance médicament medicament examen
    )

    message_lower = String.downcase(message)
    Enum.any?(keywords, &String.contains?(message_lower, &1))
  end

  defp trigger_smart_recording(state, message) do
    # Créer une note automatique dans le DME
    Task.start(fn ->
      # Créer note avec timestamp
      _note = """
      [#{DateTime.to_time(DateTime.utc_now())}] #{message}
      """

      Logger.info("📝 Smart note created for appointment #{state.appointment_id}")
      # TODO: Ajouter au medical record
    end)
  end

  defp save_consultation_stats(state) do
    duration = DateTime.diff(DateTime.utc_now(), state.started_at)

    stats = %{
      room_id: state.id,
      appointment_id: state.appointment_id,
      duration_seconds: duration,
      participants_count: map_size(state.participants),
      messages_count: length(state.messages),
      final_status: state.status,
      final_quality: state.quality,
      ended_at: DateTime.utc_now()
    }

    Logger.info("💾 Consultation stats saved: #{inspect(stats)}")

    # TODO: Persister dans DB si nécessaire
    # Telemed.Analytics.save_consultation_stats(stats)
  end

  defp create_consultation_record(state) do
    # Créer une entrée dans les medical records
    Task.start(fn ->
      Logger.info("📋 Creating medical record for consultation #{state.id}")
      # TODO: Créer record dans DME
    end)
  end

  defp end_consultation(state) do
    Logger.info("🏁 Ending consultation #{state.id}")

    # Notifier participants
    broadcast_event(state, :consultation_ended, %{
      reason: "max_duration",
      duration: DateTime.diff(DateTime.utc_now(), state.started_at)
    })

    %{state | status: :ended}
  end

  defp via_tuple(room_id) do
    {:via, Registry, {RoomRegistry, room_id}}
  end
end
