defmodule Telemed.Guardian.AuthPipeline do
  @moduledoc """
  Pipeline Guardian pour authentifier requêtes API
  """
  use Guardian.Plug.Pipeline,
    otp_app: :telemed,
    module: Telemed.Guardian,
    error_handler: Telemed.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug :assign_current_user

  defp assign_current_user(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    Plug.Conn.assign(conn, :current_user, current_user)
  end
end

