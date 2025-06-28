defmodule TelemedWeb.VideoChannel do
  use TelemedWeb, :channel

  @impl true
  def join("video:lobby", _payload, socket) do
    {:ok, assign(socket, :user_id, generate_user_id())}
  end

  @impl true
  def handle_in("offer", %{"offer" => offer}, socket) do
    # Transmettre l'offre à tous les autres utilisateurs dans la salle
    broadcast_from!(socket, "offer", %{
      offer: offer,
      from: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("answer", %{"answer" => answer}, socket) do
    # Transmettre la réponse à tous les autres utilisateurs
    broadcast_from!(socket, "answer", %{
      answer: answer,
      from: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("ice_candidate", %{"candidate" => candidate}, socket) do
    # Transmettre les candidats ICE aux autres utilisateurs
    broadcast_from!(socket, "ice_candidate", %{
      candidate: candidate,
      from: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("user_joined", _payload, socket) do
    # Notifier les autres utilisateurs qu'un nouveau participant a rejoint
    broadcast_from!(socket, "user_joined", %{
      user_id: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("user_left", _payload, socket) do
    # Notifier les autres utilisateurs qu'un participant a quitté
    broadcast_from!(socket, "user_left", %{
      user_id: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "user_joined", payload: payload}, socket) do
    # Réagir quand un autre utilisateur rejoint
    push(socket, "user_joined", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "user_left", payload: payload}, socket) do
    # Réagir quand un autre utilisateur quitte
    push(socket, "user_left", payload)
    {:noreply, socket}
  end

  defp generate_user_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end
end
