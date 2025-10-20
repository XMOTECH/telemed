defmodule Telemed.Video.Presence do
  @moduledoc """
  Phoenix Presence pour tracker les participants en temps réel.

  Avantages Erlang Distribution:
  - Sync automatique entre serveurs
  - Détection déconnexion < 1 seconde
  - Résistant aux network partitions
  - CRDT (Conflict-free Replicated Data Type) natif

  Chaque participant est tracké avec:
  - device_info
  - connection_quality
  - audio/video status
  - dernière activité
  """

  use Phoenix.Presence,
    otp_app: :telemed,
    pubsub_server: Telemed.PubSub

  # Cette implémentation est DISTRIBUÉE automatiquement
  # Si vous avez 5 serveurs Phoenix, Presence sync entre tous !
end
