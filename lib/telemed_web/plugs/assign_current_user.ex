defmodule TelemedWeb.AssignCurrentUserPlug do
  @moduledoc """
  Plug to add additional user data (like notification count).
  The current_user is already assigned by UserAuth.fetch_current_user
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # Le current_user est déjà assigné par UserAuth.fetch_current_user
    user = conn.assigns[:current_user]

    if user do
      # Récupérer le compteur de notifications non lues
      unread_count = Telemed.Notifications.unread_notifications_count(user.id)

      conn
      |> assign(:unread_notifications_count, unread_count)
    else
      conn
      |> assign(:unread_notifications_count, 0)
    end
  end
end
