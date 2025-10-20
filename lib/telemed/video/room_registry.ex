defmodule Telemed.Video.RoomRegistry do
  @moduledoc """
  Registry pour suivre toutes les salles de consultation actives.

  Utilise Registry Erlang natif pour:
  - Lookup ultra-rapide (O(1))
  - Distribution automatique
  - Fault-tolerance
  """

  def child_spec(_opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__,
      partitions: System.schedulers_online()  # Auto-partition selon CPU
    )
  end

  @doc "Trouve une room par son ID"
  def lookup(room_id) do
    case Registry.lookup(__MODULE__, room_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  @doc "Enregistre une room"
  def register(room_id) do
    Registry.register(__MODULE__, room_id, %{
      started_at: DateTime.utc_now(),
      node: Node.self()
    })
  end

  @doc "Compte les rooms actives"
  def count_rooms do
    Registry.count(__MODULE__)
  end

  @doc "Liste toutes les rooms actives"
  def list_all_rooms do
    Registry.select(__MODULE__, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
  end
end
