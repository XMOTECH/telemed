defmodule Telemed.Video.RoomSupervisor do
  @moduledoc """
  DynamicSupervisor pour les salles de consultation.

  Chaque consultation = 1 process GenServer isolé.
  Si un process crash → Supervision redémarre automatiquement.

  Peut gérer MILLIONS de consultations simultanées grâce à BEAM VM.
  """

  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Logger.info("🚀 RoomSupervisor started - Ready for millions of consultations!")
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 10, max_seconds: 5)
  end

  @doc """
  Démarre une consultation instantanée.

  ## Exemples

      iex> RoomSupervisor.start_instant_consultation(123, doctor_id, patient_id)
      {:ok, #PID<...>, "instant_abc123", %{doctor_link: "...", patient_link: "..."}}
  """
  def start_instant_consultation(appointment_id, doctor_id, patient_id) do
    room_id = generate_room_id()

    Logger.info("Creating instant room: #{room_id} for appointment #{appointment_id}")

    spec = {
      Telemed.Video.InstantRoom,
      {room_id, appointment_id, doctor_id, patient_id}
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
            # Générer les magic links
            # En mode test, skip_notifications pour éviter Ecto.OwnershipError
            test_mode = Mix.env() == :test
            links = Telemed.Video.MagicLinks.generate_links(room_id, doctor_id, patient_id, skip_notifications: test_mode)

        Logger.info("✅ Instant room created: #{room_id}")
        {:ok, pid, room_id, links}

      {:error, {:already_started, pid}} ->
        Logger.warning("Room #{room_id} already exists")
        {:ok, pid, room_id, %{}}

      error ->
        Logger.error("Failed to start room: #{inspect(error)}")
        error
    end
  end

  @doc "Arrête une consultation"
  def stop_consultation(room_id) do
    case Telemed.Video.RoomRegistry.lookup(room_id) do
      {:ok, pid} ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      {:error, :not_found} ->
        Logger.warning("Cannot stop room #{room_id}: not found")
        :ok
    end
  end

  @doc "Liste toutes les consultations actives"
  def list_active_consultations do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} ->
      if Process.alive?(pid) do
        GenServer.call(pid, :get_info)
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc "Statistiques du supervisor"
  def stats do
    children = DynamicSupervisor.count_children(__MODULE__)

    %{
      active_consultations: children.active,
      total_started: children.active + children.workers,
      restarts: children.supervisors,
      node: Node.self()
    }
  end

  # ========== PRIVATE ==========

  defp generate_room_id do
    # Format: instant_TIMESTAMP_RANDOM
    timestamp = System.system_time(:millisecond)
    random = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
    "instant_#{timestamp}_#{random}"
  end
end
