defmodule Telemed.Guardian.AuthErrorHandler do
  @moduledoc """
  Gestion erreurs authentification JWT
  """
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: to_string(type), code: "UNAUTHORIZED"}})
  end
end

