defmodule Telemed.Video.QualityMonitor do
  @moduledoc """
  Process dédié qui monitore la qualité réseau d'une consultation.

  Collecte les métriques WebRTC et adapte automatiquement:
  - Résolution vidéo
  - Bitrate
  - Frame rate

  Comme WhatsApp: adaptation transparente sans interruption.
  """

  use GenServer
  require Logger

  defstruct [
    :room_id,
    :last_check,
    metrics: %{},
    quality_level: :excellent,  # :excellent, :good, :fair, :poor
    consecutive_poor: 0
  ]

  # ========== CLIENT API ==========

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, room_id)
  end

  @doc "Mise à jour des métriques depuis le client"
  def update_metrics(pid, metrics) when is_pid(pid) do
    GenServer.cast(pid, {:update_metrics, metrics})
  end

  @doc "Récupérer la qualité actuelle"
  def get_quality(pid) when is_pid(pid) do
    GenServer.call(pid, :get_quality)
  end

  # ========== SERVER CALLBACKS ==========

  @impl true
  def init(room_id) do
    Logger.info("📊 QualityMonitor started for room: #{room_id}")

    # Vérifier la qualité toutes les 2 secondes
    schedule_quality_check()

    state = %__MODULE__{
      room_id: room_id,
      last_check: DateTime.utc_now()
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:update_metrics, metrics}, state) do
    new_state = %{state |
      metrics: Map.merge(state.metrics, metrics),
      last_check: DateTime.utc_now()
    }

    # Calculer le niveau de qualité
    quality_level = calculate_quality_level(metrics)

    # Si changement de qualité
    if quality_level != state.quality_level do
      Logger.info("Quality changed: #{state.quality_level} → #{quality_level}")

      new_state = %{new_state | quality_level: quality_level}

      # Notifier la room
      Phoenix.PubSub.broadcast(
        Telemed.PubSub,
        "instant:#{state.room_id}",
        {:quality_changed, quality_level}
      )

      # Si qualité pauvre, suggérer adaptation
      new_state = handle_quality_change(new_state, quality_level)
      {:noreply, new_state}
    else
      {:noreply, new_state}
    end
  end

  @impl true
  def handle_call(:get_quality, _from, state) do
    {:reply, state.quality_level, state}
  end

  @impl true
  def handle_info(:check_quality, state) do
    # Vérifier si métriques trop vieilles (pas de update depuis 10s)
    seconds_since_update = DateTime.diff(DateTime.utc_now(), state.last_check)

    # Log seulement si très ancien (1 minute) pour éviter spam
    if seconds_since_update > 60 do
      Logger.debug("No quality metrics received for #{seconds_since_update}s in room #{state.room_id}")
    end

    schedule_quality_check()
    {:noreply, state}
  end

  # ========== PRIVATE FUNCTIONS ==========

  defp calculate_quality_level(metrics) do
    # Calcul basé sur packet_loss, latency, jitter, bandwidth
    packet_loss = Map.get(metrics, "packet_loss", 0)
    latency = Map.get(metrics, "latency", 0)
    jitter = Map.get(metrics, "jitter", 0)

    # Score sur 100
    score =
      (100 - packet_loss * 3) * 0.5 +
      max(0, 100 - latency / 5) * 0.3 +
      max(0, 100 - jitter * 2) * 0.2

    cond do
      score >= 85 -> :excellent
      score >= 70 -> :good
      score >= 50 -> :fair
      true -> :poor
    end
  end

  defp handle_quality_change(state, :poor) do
    # Incrémenter compteur
    new_consecutive = state.consecutive_poor + 1

    # Si 3 checks consécutifs en "poor"
    if new_consecutive >= 3 do
      Logger.warning("Quality consistently poor, suggesting audio-only mode")

      Phoenix.PubSub.broadcast(
        Telemed.PubSub,
        "instant:#{state.room_id}",
        {:suggest_audio_only, %{
          message: "Connexion faible détectée. Passer en audio seul ?",
          packet_loss: state.metrics["packet_loss"],
          latency: state.metrics["latency"]
        }}
      )
    end

    %{state | consecutive_poor: new_consecutive}
  end

  defp handle_quality_change(state, _quality) do
    # Reset compteur si qualité s'améliore
    %{state | consecutive_poor: 0}
  end

  defp schedule_quality_check do
    Process.send_after(self(), :check_quality, 2_000)  # Toutes les 2s
  end
end
