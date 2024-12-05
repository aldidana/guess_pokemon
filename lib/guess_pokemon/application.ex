defmodule GuessPokemon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GuessPokemonWeb.Telemetry,
      GuessPokemon.Repo,
      {DNSCluster, query: Application.get_env(:guess_pokemon, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GuessPokemon.PubSub},
      # Start the Finch HTTP client for sending emails
      # {Finch, name: GuessPokemon.Finch},
      # Start a worker by calling: GuessPokemon.Worker.start_link(arg)
      # {GuessPokemon.Worker, arg},
      # Start to serve requests, typically the last entry
      GuessPokemonWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GuessPokemon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GuessPokemonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
