defmodule GuessPokemon.PokeAPI do
  alias Mogrify
  require Logger

  @api_url "https://pokeapi.co/api/v2/pokemon"

  def get_random_pokemon do
    pokemon_id = Enum.random(1..898)
    url = "#{@api_url}/#{pokemon_id}"

    Logger.info("Fetching Pokémon with ID: #{pokemon_id}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        pokemon_data = Jason.decode!(body)
        image_url = pokemon_data["sprites"]["front_default"]

        if image_url do
          identifier = :crypto.strong_rand_bytes(8) |> Base.encode16()
          images = download_and_blur_image_in_memory(image_url)

          %{
            name: pokemon_data["name"],
            images: images,
            identifier: identifier
          }
        else
          Logger.error("Image URL is missing for Pokémon ID #{pokemon_id}")
          nil
        end

      {:ok, %HTTPoison.Response{status_code: status}} ->
        Logger.error("Failed to fetch Pokémon data. Status code: #{status}")
        nil

      {:error, reason} ->
        Logger.error("Failed to fetch Pokémon data: #{inspect(reason)}")
        nil
    end
  end

  defp download_and_blur_image_in_memory(image_url) do
    case HTTPoison.get(image_url, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} when not is_nil(body) ->
        original_path = "/tmp/original_image_#{:os.system_time(:millisecond)}.png"
        File.write!(original_path, body)

        original_base64 = Base.encode64(body)

        # Create blurred images at levels 8, 6, 4, and 2
        blurred_images = for level <- [8, 6, 4, 2] do
          blurred_path = "/tmp/blurred_image_#{level}_#{:os.system_time(:millisecond)}.png"

          blurred_base64 =
            Mogrify.open(original_path)
            |> Mogrify.custom("blur", "0x#{level}")
            |> Mogrify.format("png")
            |> Mogrify.save(path: blurred_path)
            |> Map.get(:path)
            |> File.read!()
            |> Base.encode64()

          File.rm(blurred_path)
          {Integer.to_string(level), "data:image/png;base64,#{blurred_base64}"}
        end
        |> Enum.into(%{})

        File.rm(original_path)

        Map.put(blurred_images, "original", "data:image/png;base64,#{original_base64}")

      {:ok, %HTTPoison.Response{status_code: status}} ->
        Logger.error("Failed to fetch image. Status code: #{status}")
        %{"original" => "data:image/png;base64,", "8" => "data:image/png;base64,", "6" => "data:image/png;base64,", "4" => "data:image/png;base64,", "2" => "data:image/png;base64,"}

      {:error, reason} ->
        Logger.error("Failed to fetch image: #{inspect(reason)}")
        %{"original" => "data:image/png;base64,", "8" => "data:image/png;base64,", "6" => "data:image/png;base64,", "4" => "data:image/png;base64,", "2" => "data:image/png;base64,"}
    end
  end

  def get_random_choices(correct_answer) do
    choices = [correct_answer]

    Stream.repeatedly(&get_random_pokemon_name/0)
    |> Enum.reduce_while(choices, fn name, acc ->
      if name && !Enum.member?(acc, name) do
        updated_choices = [name | acc]
        if length(updated_choices) == 4, do: {:halt, updated_choices}, else: {:cont, updated_choices}
      else
        {:cont, acc}
      end
    end)
    |> Enum.shuffle()
  end

  defp get_random_pokemon_name do
    pokemon_id = Enum.random(1..1025)
    url = "#{@api_url}/#{pokemon_id}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        pokemon_data = Jason.decode!(body)
        pokemon_data["name"]

      {:error, reason} ->
        Logger.error("Failed to fetch Pokémon name: #{inspect(reason)}")
        nil
    end
  end
end
