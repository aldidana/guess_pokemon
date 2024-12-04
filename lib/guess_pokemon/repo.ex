defmodule GuessPokemon.Repo do
  use Ecto.Repo,
    otp_app: :guess_pokemon,
    adapter: Ecto.Adapters.Postgres
end
