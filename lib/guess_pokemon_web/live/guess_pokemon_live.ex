defmodule GuessPokemonWeb.GuessPokemonLive do
  use Phoenix.LiveView
  alias GuessPokemon.PokeAPI

  def mount(_params, _session, socket) do
    socket = assign(socket,
      loading: true,
      score: 0,
      answered: false,
      help_level: "8",
      reveal: false,
      images: %{"8" => "", "6" => "", "4" => "", "2" => "", "original" => ""},
      choices: [],
      correct_answer: "",
      result_message: nil,
      guessed: nil,
      pokemon: nil
    )
    send(self(), :load_pokemon)
    {:ok, socket}
  end

  def handle_info(:load_pokemon, socket) do
    if socket.assigns.loading do
      case PokeAPI.get_random_pokemon() do
        nil ->
          {:noreply, assign(socket, loading: false)}

        pokemon ->
          choices = PokeAPI.get_random_choices(pokemon.name)

          {:noreply, assign(socket,
            pokemon: pokemon,
            choices: choices,
            correct_answer: pokemon.name,
            guessed: nil,
            result_message: nil,
            images: pokemon.images,
            help_level: "8",
            reveal: false,
            loading: false,
            answered: false
          )}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("guess", %{"choice" => choice}, socket) do
    if socket.assigns.answered do
      {:noreply, socket}
    else
      is_correct = choice == socket.assigns.correct_answer
      message = if is_correct, do: "Correct! 🎉", else: "Incorrect. The correct answer is #{socket.assigns.correct_answer}."
      new_score = if is_correct, do: socket.assigns.score + 1, else: socket.assigns.score

      {:noreply, assign(socket,
        guessed: choice,
        result_message: message,
        score: new_score,
        reveal: true,
        answered: true
      )}
    end
  end

  def handle_event("help", _params, socket) do
    # reduce blur level
    new_help_level = case socket.assigns.help_level do
      "8" -> "6"
      "6" -> "4"
      "4" -> "2"
      "2" -> "original"
      _ -> "original"
    end

    {:noreply, assign(socket, help_level: new_help_level)}
  end

  def handle_event("next_pokemon", _params, socket) do
    socket = assign(socket, loading: true)
    send(self(), :load_pokemon)
    {:noreply, socket}
  end
end
