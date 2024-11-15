defmodule Chesster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChessterWeb.Telemetry,
      Chesster.Repo,
      {DNSCluster, query: Application.get_env(:chesster, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chesster.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chesster.Finch},
      # Start a worker by calling: Chesster.Worker.start_link(arg)
      # {Chesster.Worker, arg},
      # Start to serve requests, typically the last entry
      ChessterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chesster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChessterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
