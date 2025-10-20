defmodule TelemedWeb.ConsultationChannel do
  @moduledoc """
  Channel Phoenix pour consultations vidéo WebRTC
  Gère signaling WebRTC + chat temps réel
  """
  use TelemedWeb, :channel

  alias Telemed.Appointments

  @doc "Join consultation room"
  def join("consultation:" <> appointment_id, _payload, socket) do
    user = socket.assigns.current_user

    # Vérifier que user a accès à cette consultation
    case Appointments.get_appointment(appointment_id) do
      {:ok, appointment} ->
        if can_join?(user, appointment) do
          send(self(), :after_join)
          {:ok, assign(socket, :appointment_id, appointment_id)}
        else
          {:error, %{reason: "unauthorized"}}
        end

      {:error, _} ->
        {:error, %{reason: "appointment_not_found"}}
    end
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", %{})

    # Notifier autres participants
    broadcast!(socket, "user_joined", %{
      user_id: socket.assigns.current_user.id,
      role: socket.assigns.current_user.role,
      timestamp: DateTime.utc_now()
    })

    {:noreply, socket}
  end

  # WebRTC Offer
  def handle_in("webrtc_offer", %{"offer" => offer}, socket) do
    broadcast_from!(socket, "webrtc_offer", %{
      from: socket.assigns.current_user.id,
      offer: offer
    })

    {:noreply, socket}
  end

  # WebRTC Answer
  def handle_in("webrtc_answer", %{"answer" => answer}, socket) do
    broadcast_from!(socket, "webrtc_answer", %{
      from: socket.assigns.current_user.id,
      answer: answer
    })

    {:noreply, socket}
  end

  # WebRTC ICE Candidate
  def handle_in("webrtc_ice_candidate", %{"candidate" => candidate}, socket) do
    broadcast_from!(socket, "webrtc_ice_candidate", %{
      from: socket.assigns.current_user.id,
      candidate: candidate
    })

    {:noreply, socket}
  end

  # Chat messages
  def handle_in("chat_message", %{"message" => message}, socket) do
    broadcast!(socket, "chat_message", %{
      from: socket.assigns.current_user.id,
      from_name: socket.assigns.current_user.email,
      message: message,
      timestamp: DateTime.utc_now()
    })

    {:noreply, socket}
  end

  # Toggle audio/video
  def handle_in("media_toggle", %{"audio" => audio, "video" => video}, socket) do
    broadcast_from!(socket, "media_state", %{
      user_id: socket.assigns.current_user.id,
      audio: audio,
      video: video
    })

    {:noreply, socket}
  end

  # Screen sharing
  def handle_in("screen_share", %{"sharing" => sharing}, socket) do
    broadcast_from!(socket, "screen_share_state", %{
      user_id: socket.assigns.current_user.id,
      sharing: sharing
    })

    {:noreply, socket}
  end

  # Helpers privés
  defp can_join?(user, appointment) do
    user.id == appointment.patient_id or
    user.id == appointment.doctor_id or
    user.role == "admin"
  end
end
