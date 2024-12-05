defmodule GuessPokemon.Repo.Migrations.CreatePokemons do
  use Ecto.Migration

  def change do
    create table(:pokemons) do
      add :name, :string
      add :api_id, :integer
      add :sprite, :string
      add :cached_at, :utc_datetime

      timestamps()
    end

    create unique_index(:pokemons, [:api_id])
  end
end
