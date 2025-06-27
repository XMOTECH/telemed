defmodule Telemed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TelemedWeb.Telemetry,
      Telemed.Repo,
      {DNSCluster, query: Application.get_env(:telemed, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Telemed.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Telemed.Finch},
      # Start a worker by calling: Telemed.Worker.start_link(arg)
      # {Telemed.Worker, arg},
      # Start to serve requests, typically the last entry
      TelemedWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Telemed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TelemedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
