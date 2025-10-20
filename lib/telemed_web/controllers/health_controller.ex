defmodule TelemedWeb.HealthController do
  use TelemedWeb, :controller

  def check(conn, _params) do
    # Vérifier DB
    db_status = case Ecto.Adapters.SQL.query(Telemed.Repo, "SELECT 1", []) do
      {:ok, _} -> "healthy"
      _ -> "unhealthy"
    end

    status = if db_status == "healthy", do: :ok, else: :service_unavailable

    conn
    |> put_status(status)
    |> json(%{
      status: db_status,
      version: "1.0.0",
      timestamp: DateTime.utc_now()
    })
  end
end

