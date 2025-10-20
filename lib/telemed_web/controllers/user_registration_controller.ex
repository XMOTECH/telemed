defmodule TelemedWeb.UserRegistrationController do
  use TelemedWeb, :controller

  alias Telemed.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # Essayer d'envoyer l'email de confirmation (optionnel)
        Accounts.deliver_user_confirmation_instructions(
          user,
          &url(~p"/users/confirm/#{&1}")
        )

        conn
        |> put_flash(:info, "Compte créé avec succès ! Connectez-vous maintenant.")
        |> redirect(to: ~p"/users/log_in")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Erreur lors de la création du compte. Vérifiez les informations saisies.")
        |> redirect(to: ~p"/users/register")
    end
  end
end

