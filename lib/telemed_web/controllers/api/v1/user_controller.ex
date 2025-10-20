defmodule TelemedWeb.API.V1.UserController do
  use TelemedWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Telemed.Accounts
  alias TelemedWeb.Schemas

  action_fallback TelemedWeb.API.FallbackController

  tags ["Users"]

  operation :show_current,
    summary: "👤 Profil utilisateur courant",
    description: """
    Récupère les informations du compte connecté.

    ### Authentification requise
    Bearer token JWT dans le header Authorization.
    """,
    responses: [
      ok: {"✅ Profil récupéré", "application/json", Schemas.User.UserResponse},
      unauthorized: {"🔒 Auth requise", "application/json", Schemas.Common.UnauthorizedResponse}
    ],
    security: [%{"bearer" => []}]

  def show_current(conn, _params) do
    user = conn.assigns.current_user

    json(conn, %{
      data: %{
        id: user.id,
        email: user.email,
        role: user.role,
        confirmed_at: user.confirmed_at,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      }
    })
  end

  @doc "Modifier profil utilisateur courant"
  def update_current(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user(user, user_params) do
      {:ok, updated_user} ->
        json(conn, %{
          data: %{
            id: updated_user.id,
            email: updated_user.email,
            role: updated_user.role,
            updated_at: updated_user.updated_at
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: %{message: "Erreur de validation", details: format_errors(changeset)}})
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
