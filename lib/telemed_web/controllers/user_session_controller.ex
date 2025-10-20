defmodule TelemedWeb.UserSessionController do
  use TelemedWeb, :controller

  alias Telemed.Accounts
  alias TelemedWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_flash(:error, "Email ou mot de passe invalide.")
        |> redirect(to: ~p"/users/log_in")

      user ->
        UserAuth.log_in_user(conn, user, user_params)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Déconnexion réussie.")
    |> UserAuth.log_out_user()
  end
end

