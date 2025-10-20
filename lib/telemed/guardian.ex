defmodule Telemed.Guardian do
  @moduledoc """
  Guardian JWT implementation pour authentification API
  """
  use Guardian, otp_app: :telemed

  alias Telemed.Accounts

  @doc "Encode user dans JWT token"
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  @doc "Decode user depuis JWT token"
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end

