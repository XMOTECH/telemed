defmodule Telemed.Repo do
  use Ecto.Repo,
    otp_app: :telemed,
    adapter: Ecto.Adapters.Postgres
end
