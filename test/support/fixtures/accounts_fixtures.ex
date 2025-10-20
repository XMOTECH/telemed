defmodule Telemed.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Telemed.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      role: "patient"  # Rôle par défaut pour les tests
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Telemed.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    # La fonction retourne directement le token, pas un email
    case fun.(&"[TOKEN]#{&1}[TOKEN]") do
      {:ok, captured_email} when is_map(captured_email) ->
        # Ancien format avec email
        [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
        token

      token when is_binary(token) ->
        # Nouveau format : token direct
        token
    end
  end
end
