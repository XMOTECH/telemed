defmodule TelemedWeb.VideoChannel do
  use TelemedWeb, :channel
  require Logger

  @impl true
  def join("video:" <> room_id, payload, socket) do
    user_name = Map.get(payload, "user_name", "Utilisateur")
    user_id = generate_user_id()
    
    send(self(), :after_join)
    
    {:ok, 
     %{user_id: user_id, room_id: room_id},
     socket
     |> assign(:user_id, user_id)
     |> assign(:user_name, user_name)
     |> assign(:room_id, room_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    # Notifier les autres qu'un utilisateur a rejoint
    broadcast_from!(socket, "user_joined", %{
      user_id: socket.assigns.user_id,
      user_name: socket.assigns.user_name
    })
    
    # Envoyer la liste des utilisateurs actuels
    push(socket, "presence_state", %{users: get_room_users(socket)})
    
    Logger.info("User #{socket.assigns.user_name} joined room #{socket.assigns.room_id}")
    {:noreply, socket}
  end

  @impl true
  def handle_in("offer", %{"offer" => offer, "to" => to_user_id}, socket) do
    # Envoyer l'offre à un utilisateur spécifique
    broadcast_from!(socket, "offer", %{
      offer: offer,
      from: socket.assigns.user_id,
      from_name: socket.assigns.user_name,
      to: to_user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("answer", %{"answer" => answer, "to" => to_user_id}, socket) do
    # Envoyer la réponse à un utilisateur spécifique
    broadcast_from!(socket, "answer", %{
      answer: answer,
      from: socket.assigns.user_id,
      from_name: socket.assigns.user_name,
      to: to_user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("ice_candidate", %{"candidate" => candidate, "to" => to_user_id}, socket) do
    # Envoyer le candidat ICE à un utilisateur spécifique
    broadcast_from!(socket, "ice_candidate", %{
      candidate: candidate,
      from: socket.assigns.user_id,
      to: to_user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("chat_message", %{"message" => message}, socket) do
    # Diffuser un message de chat
    broadcast!(socket, "chat_message", %{
      message: message,
      from: socket.assigns.user_id,
      from_name: socket.assigns.user_name,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("toggle_audio", %{"enabled" => enabled}, socket) do
    # Notifier les autres du changement de statut audio
    broadcast_from!(socket, "user_audio_changed", %{
      user_id: socket.assigns.user_id,
      audio_enabled: enabled
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("toggle_video", %{"enabled" => enabled}, socket) do
    # Notifier les autres du changement de statut vidéo
    broadcast_from!(socket, "user_video_changed", %{
      user_id: socket.assigns.user_id,
      video_enabled: enabled
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("start_screen_share", _payload, socket) do
    # Notifier les autres du début de partage d'écran
    broadcast_from!(socket, "user_screen_share_started", %{
      user_id: socket.assigns.user_id,
      user_name: socket.assigns.user_name
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("stop_screen_share", _payload, socket) do
    # Notifier les autres de l'arrêt du partage d'écran
    broadcast_from!(socket, "user_screen_share_stopped", %{
      user_id: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    # Notifier les autres qu'un utilisateur a quitté
    broadcast_from!(socket, "user_left", %{
      user_id: socket.assigns.user_id,
      user_name: socket.assigns.user_name
    })
    
    Logger.info("User #{socket.assigns.user_name} left room #{socket.assigns.room_id}")
    :ok
  end

  defp generate_user_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end

  defp get_room_users(_socket) do
    # Récupérer la liste des utilisateurs dans la salle
    # Note: Dans une version production, utilisez Phoenix.Presence
    []
  end
end
