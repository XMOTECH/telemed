defmodule TelemedWeb.NotificationController do
  use TelemedWeb, :controller

  alias Telemed.Notifications

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    notifications = if user do
      Notifications.list_user_notifications(user.id)
    else
      []
    end
    render(conn, :index, notifications: notifications)
  end

  def mark_as_read(conn, %{"id" => id}) do
    notification = Notifications.get_notification!(id)
    case Notifications.update_notification(notification, %{read: true}) do
      {:ok, _notification} ->
        conn
        |> put_flash(:info, "Notification marquée comme lue.")
        |> redirect(to: ~p"/notifications")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erreur lors de la mise à jour de la notification.")
        |> redirect(to: ~p"/notifications")
    end
  end

  def mark_all_as_read(conn, _params) do
    user = conn.assigns[:current_user]
    if user do
      Notifications.mark_all_as_read(user.id)
    end
    conn
    |> put_flash(:info, "Toutes les notifications ont été marquées comme lues.")
    |> redirect(to: ~p"/notifications")
  end

  def delete(conn, %{"id" => id}) do
    notification = Notifications.get_notification!(id)
    {:ok, _notification} = Notifications.delete_notification(notification)
    conn
    |> put_flash(:info, "Notification supprimée.")
    |> redirect(to: ~p"/notifications")
  end
end
