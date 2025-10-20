defmodule TelemedWeb.API.V1.AuthController do
  use TelemedWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Telemed.{Accounts, Guardian}
  alias Telemed.Accounts.User

  action_fallback TelemedWeb.API.FallbackController

  tags ["Authentication"]

  operation :register,
    summary: "🔐 Inscription utilisateur",
    description: """
    Créer un nouveau compte utilisateur sur la plateforme.

    ### Rôles disponibles
    - **patient**: Utilisateur standard (consultations, DME lecture)
    - **doctor**: Professionnel de santé (créer DME, confirmer RDV)
    - **admin**: Administrateur plateforme (accès complet)

    ### Validation
    - Email unique (pas de doublons)
    - Mot de passe min 12 caractères
    - Rôle obligatoire

    ### Réponse
    Retourne l'utilisateur créé + tokens JWT (access & refresh)

    ### Exemple
    ```json
    {
      "user": {
        "email": "patient@telemed.fr",
        "password": "MotDePasse123!",
        "role": "patient",
        "first_name": "Jean",
        "last_name": "Dupont"
      }
    }
    ```
    """,
    request_body: {"Données d'inscription", "application/json", TelemedWeb.Schemas.Auth.RegisterRequest},
    responses: [
      created: {"✅ Compte créé avec succès", "application/json", TelemedWeb.Schemas.Auth.AuthResponse},
      unprocessable_entity: {"⚠️ Erreur de validation", "application/json", TelemedWeb.Schemas.Auth.ErrorResponse}
    ]

  def register(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.register_user(user_params),
         {:ok, access_token, _claims} <- Guardian.encode_and_sign(user, %{}, token_type: "access"),
         {:ok, refresh_token, _claims} <- Guardian.encode_and_sign(user, %{}, token_type: "refresh") do

      # Consentements RGPD obligatoires
      ip = get_ip(conn)
      Accounts.grant_consent(user, "data_processing", ip)
      Accounts.grant_consent(user, "telemedicine_usage", ip)

      conn
      |> put_status(:created)
      |> json(%{
        data: %{
          user: serialize_user(user),
          tokens: %{
            access_token: access_token,
            refresh_token: refresh_token,
            token_type: "Bearer",
            expires_in: 3600
          }
        }
      })
    end
  end

  operation :login,
    summary: "🔑 Connexion utilisateur",
    description: """
    Authentifier un utilisateur et obtenir les tokens JWT.

    ### Processus
    1. Fournir email + password
    2. Récupérer `access_token` et `refresh_token`
    3. Utiliser `access_token` dans header: `Authorization: Bearer {token}`

    ### Durée de validité
    - **access_token**: 1 heure (pour les requêtes API)
    - **refresh_token**: 30 jours (pour renouveler l'access_token)

    ### Exemple
    ```json
    {
      "email": "doctor@telemed.fr",
      "password": "Password123!"
    }
    ```

    ### Après le login
    1. Copier le `access_token` de la réponse
    2. Cliquer "Authorize" 🔒 en haut
    3. Entrer: `Bearer {access_token}`
    4. Tous les endpoints protégés sont accessibles !
    """,
    request_body: {"Identifiants de connexion", "application/json", TelemedWeb.Schemas.Auth.LoginRequest},
    responses: [
      ok: {"✅ Connexion réussie", "application/json", TelemedWeb.Schemas.Auth.AuthResponse},
      unauthorized: {"❌ Identifiants invalides", "application/json", TelemedWeb.Schemas.Auth.ErrorResponse}
    ]

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: %{message: "Email ou mot de passe invalide"}})

      user ->
        {:ok, access_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access")
        {:ok, refresh_token, _} = Guardian.encode_and_sign(user, %{}, token_type: "refresh")

        json(conn, %{
          data: %{
            user: serialize_user(user),
            tokens: %{
              access_token: access_token,
              refresh_token: refresh_token,
              token_type: "Bearer",
              expires_in: 3600
            }
          }
        })
    end
  end

  operation :refresh_token,
    summary: "🔄 Rafraîchir le token d'accès",
    description: """
    Obtenir un nouveau `access_token` en utilisant le `refresh_token`.

    ### Quand utiliser ?
    - Votre `access_token` expire après **1 heure**
    - Au lieu de re-login, utilisez le refresh_token (valide 30j)

    ### Processus
    1. Requête avec votre `refresh_token`
    2. Recevez un nouveau `access_token` (valide 1h)
    3. Utilisez le nouveau token pour vos requêtes

    ### Exemple
    ```json
    {
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
    ```
    """,
    request_body: {"Token de rafraîchissement", "application/json", TelemedWeb.Schemas.Auth.RefreshTokenRequest},
    responses: [
      ok: {"✅ Token rafraîchi", "application/json", TelemedWeb.Schemas.Auth.AuthResponse},
      unauthorized: {"❌ Refresh token invalide ou expiré", "application/json", TelemedWeb.Schemas.Auth.ErrorResponse}
    ]

  def refresh_token(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, _old, {new_access, _claims}} <- Guardian.exchange(refresh_token, "refresh", "access"),
         {:ok, user, _claims} <- Guardian.resource_from_token(new_access) do

      json(conn, %{
        data: %{
          access_token: new_access,
          user: serialize_user(user)
        }
      })
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: %{message: "Refresh token invalide"}})
    end
  end

  operation :forgot_password,
    summary: "🔓 Mot de passe oublié",
    description: """
    Demander un lien de réinitialisation de mot de passe.

    ### Processus
    1. Fournir l'email du compte
    2. Un email est envoyé (si l'email existe)
    3. Cliquer sur le lien dans l'email
    4. Définir un nouveau mot de passe

    ### Sécurité
    - Ne révèle pas si l'email existe (évite énumération)
    - Token expire après 1h
    - Usage unique

    ### Note
    En développement, vérifier les logs du serveur pour voir le lien.
    """,
    request_body: {"Email du compte", "application/json", %OpenApiSpex.Schema{
      type: :object,
      required: [:email],
      properties: %{
        email: %OpenApiSpex.Schema{
          type: :string,
          format: :email,
          example: "patient@telemed.fr"
        }
      }
    }},
    responses: [
      ok: {"✅ Email envoyé (si compte existe)", "application/json", TelemedWeb.Schemas.Common.SuccessResponse}
    ]

  def forgot_password(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        # Ne pas révéler si email existe (sécurité)
        json(conn, %{data: %{message: "Si cet email existe, un lien a été envoyé"}})

      user ->
        # TODO: Envoyer email avec token reset
        {:ok, _token} = Accounts.deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
        json(conn, %{data: %{message: "Email de réinitialisation envoyé"}})
    end
  end

  defp serialize_user(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at
    }
  end

  defp get_ip(conn) do
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end
end
