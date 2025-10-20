defmodule TelemedWeb.SettingsController do
  use TelemedWeb, :controller

  alias Telemed.Accounts

  def profile(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_profile(user)

    render(conn, :profile, changeset: changeset, page_title: "Paramètres du Profil")
  end

  def update_profile(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_profile(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profil mis à jour avec succès ! 🎉")
        |> redirect(to: ~p"/dashboard")

      {:error, changeset} ->
        render(conn, :profile, changeset: changeset, page_title: "Paramètres du Profil")
    end
  end
end
