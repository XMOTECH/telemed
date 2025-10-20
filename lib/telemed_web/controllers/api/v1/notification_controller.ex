defmodule TelemedWeb.API.V1.NotificationController do
  use TelemedWeb, :controller

  alias Telemed.Notifications

  action_fallback TelemedWeb.API.FallbackController

  @doc "Liste notifications utilisateur courant"
  def index(conn, _params) do
    user = conn.assigns.current_user
    notifications = Notifications.list_user_notifications(user.id)

    json(conn, %{
      data: Enum.map(notifications, &serialize_notification/1)
    })
  end

  @doc "Marquer notification comme lue"
  def mark_as_read(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    case Notifications.get_notification(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: %{message: "Notification non trouvée"}})

      notification ->
        if notification.user_id == user.id do
          case Notifications.mark_as_read(notification) do
            {:ok, updated_notification} ->
              json(conn, %{data: serialize_notification(updated_notification)})

            {:error, _} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{error: %{message: "Erreur lors de la mise à jour"}})
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: %{message: "Accès interdit"}})
        end
    end
  end

  defp serialize_notification(notification) do
    %{
      id: notification.id,
      user_id: notification.user_id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      read: notification.read,
      inserted_at: notification.inserted_at
    }
  end
end

