defmodule GuessPokemon.Cache do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :id, autogenerate: true}
  schema "pokemons" do
    field :name, :string
    field :api_id, :integer
    field :sprite, :string
    field :cached_at, :utc_datetime

    timestamps()
  end

  def changeset(pokemon, attrs) do
    pokemon
    |> cast(attrs, [:name, :api_id, :sprite, :cached_at])
    |> validate_required([:name, :api_id])
    |> unique_constraint(:api_id)
  end

  def save(pokemon_data) do
    changeset = changeset(%__MODULE__{}, %{
      name: pokemon_data["name"],
      api_id: pokemon_data["id"],
      sprite: pokemon_data["sprites"]["front_default"],
      cached_at: DateTime.utc_now()
    })

    case GuessPokemon.Repo.insert(changeset) do
      {:ok, pokemon} -> pokemon
      {:error, _changeset} -> nil
    end
  end

  def fetch(api_id) do
    query = from p in __MODULE__,
      where: p.api_id == ^api_id

    GuessPokemon.Repo.one(query)
  end
end
