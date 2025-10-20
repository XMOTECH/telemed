defmodule TelemedWeb.UserSocket do
  use Phoenix.Socket

  alias Telemed.Guardian

  # Channels pour API
  channel "video:*", TelemedWeb.VideoChannel
  channel "consultation:*", TelemedWeb.ConsultationChannel
  channel "notifications:*", TelemedWeb.NotificationChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    # Authentifier via JWT Guardian
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} ->
            {:ok, assign(socket, :current_user, user)}
          {:error, _} ->
            :error
        end
      {:error, _} ->
        :error
    end
  end

  # Fallback pour anciens channels sans token
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(socket) do
    if socket.assigns[:current_user] do
      "user_socket:#{socket.assigns.current_user.id}"
    else
      nil
    end
  end
end
