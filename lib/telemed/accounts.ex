defmodule Telemed.Accounts do
  import Ecto.Query, warn: false
  alias Telemed.Repo
  alias Telemed.Accounts.User

  # Liste tous les utilisateurs
  def list_users do
    Repo.all(User)
  end

  # Liste tous les médecins
  def list_doctors do
    from(u in User, where: u.role == "doctor")
    |> Repo.all()
  end

  # Récupère un utilisateur par ID
  def get_user!(id), do: Repo.get!(User, id)

  # Récupère un utilisateur par ID (retourne nil si not found)
  def get_user(id), do: Repo.get(User, id)

  # Récupère un utilisateur par email
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  # Authentifie un utilisateur par email et mot de passe
  def get_user_by_email_and_password(email, password) do
    user = get_user_by_email(email)
    if user && User.valid_password?(user, password), do: user, else: nil
  end

  # Prépare un changeset pour l'inscription
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  # Inscrit un nouvel utilisateur
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # Prépare un changeset pour modifier le mot de passe
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs)
  end

  # Authentifie un utilisateur (retourne {:ok, user} ou :error)
  def authenticate_user(email, password) do
    case get_user_by_email_and_password(email, password) do
      nil -> :error
      user -> {:ok, user}
    end
  end

  # === SYSTÈME D'AUTHENTIFICATION COMPLET ===

  alias Telemed.Accounts.{User, UserToken}
  # UserNotifier sera utilisé plus tard pour les emails
  # alias Telemed.Accounts.UserNotifier

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.
  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      # UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
      {:ok, encoded_token}
    end
  end

  @doc """
  Confirms a user by the given token.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.
  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    # UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
    {:ok, encoded_token}
  end

  @doc """
  Gets the user by reset password token.
  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.
  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Change email

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.
  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.
  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset = User.email_changeset(user, %{email: email})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.
  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")
    Repo.insert!(user_token)
    # UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
    {:ok, encoded_token}
  end

  ## Change password

  @doc """
  Updates the user password.
  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Profile Management

  @doc """
  Returns a changeset for changing the user profile.
  """
  def change_user_profile(%User{} = user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  @doc """
  Updates a user profile.
  """
  def update_user_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user (generic function).
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  ## Consentements RGPD

  @doc """
  Enregistre un consentement RGPD
  Pour l'instant juste un stub - TODO: créer table consents
  """
  def grant_consent(_user, _consent_type, _ip \\ nil) do
    # TODO: Implémenter table consents comme dans roadmap
    {:ok, :stub}
  end
end
