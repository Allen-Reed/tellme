defmodule Tellme.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TellmeWeb.Telemetry,
      Tellme.Repo,
      {DNSCluster, query: Application.get_env(:tellme, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tellme.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tellme.Finch},
      # Start a worker by calling: Tellme.Worker.start_link(arg)
      # {Tellme.Worker, arg},
      # Start to serve requests, typically the last entry
      TellmeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tellme.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TellmeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
