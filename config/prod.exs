import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
host = System.get_env("PHX_HOST")
port = String.to_integer(System.get_env("PORT") || "4000")

config :guess_pokemon, GuessPokemonWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  url: [host: host, port: 443, scheme: "https"],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: port
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: GuessPokemonWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: GuessPokemon.PubSub,
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT")],
  server: true,
  check_origin: [System.get_env("HOSTNAME")]

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: GuessPokemon.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
