defmodule App.GameServer do
  use GenServer

  alias App.{Game, Player, Card}

  @deck_size 50
  @hand_size 10

  # Client
  def start_link(opts) do
    GenServer.start_link(__MODULE__, %Game{players: [], deck: load_words()}, opts)
  end

  def start_link(_) do
    {:error, :bad_input}
  end

  def discard(pid, card) do
    GenServer.cast(pid, {:discard, card})
  end

  def draw_card(pid) do
    GenServer.call(pid, :draw_card)
  end

  def draw_hand(pid) do
    GenServer.call(pid, :draw_hand)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def get_player(pid, name) do
    GenServer.call(pid, {:get_player, name})
  end

  def get_leaders(pid) do
    GenServer.call(pid, :get_leaders)
  end

  def get_score(pid, name) do
    GenServer.call(pid, {:get_score, name})
  end

  def add_player(pid, name) do
    GenServer.call(pid, :draw_hand)
    |> case do
      [] ->
        {:reply, :out_of_cards}

      hand ->
        GenServer.cast(pid, {:add_player, %Player{name: name, cards: hand}})
    end
  end

  def meld_card(pid, name, word) do
    GenServer.cast(pid, {:meld_card, name, word})
  end

  def upvote(pid, name) do
    GenServer.cast(pid, {:upvote, name})
  end

  def downvote(pid, name) do
    GenServer.cast(pid, {:downvote, name})
  end

  # Callbacks

  @impl true
  def init(game) do
    {:ok, game}
  end

  # Deck

  @impl true
  def handle_call(:draw_card, _from, %Game{deck: []} = game) do
    {:reply, :no_cards, game}
  end

  @impl true
  def handle_call(:draw_card, _from, %Game{deck: [card | tail], players: players}) do
    {:reply, card, %Game{deck: tail, players: players}}
  end

  def handle_call({:get_player, name}, _from, %Game{players: players} = game) do
    player = players |> Enum.filter(&(&1.name == name)) |> List.first()
    {:reply, player, game}
  end

  @impl true
  def handle_call(:draw_hand, _from, %Game{deck: deck, players: players} = _game) do
    {hand, rest} = Enum.split(deck, @hand_size)
    {:reply, hand, %Game{deck: rest, players: players}}
  end

  @impl true
  def handle_call(:get, _from, %Game{} = game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call({:get_score, name}, _from, %Game{players: players} = game) do
    score = players |> find_player(name) |> Map.get(:meld) |> Enum.map(& &1.points) |> Enum.sum()

    {:reply, score, game}
  end

  @impl true
  def handle_call(:get_leaders, _from, %Game{players: players} = game) do
    results =
      players
      |> Enum.group_by(& &1.score)
      |> Map.to_list()
      |> Enum.sort_by(&(&1 |> elem(0)))
      |> List.last()
      |> elem(1)
      |> Enum.map(& &1.name)

    {:reply, results, game}
  end

  @impl true
  def handle_cast({:discard, card}, %Game{deck: deck} = game) do
    {:noreply, %Game{game | deck: [card | deck]}}
  end

  @impl true
  def handle_cast({:add_player, player}, %Game{players: players} = game) do
    {:noreply, %Game{game | players: [player | players]}}
  end

  @impl true
  def handle_cast({:upvote, name}, %Game{players: players} = game) do
    player = players |> find_player(name)
    player = %Player{player | score: player.score + 1}

    {:noreply, %Game{game | players: [player | players |> Enum.filter(&(&1.name != name))]}}
  end

  @impl true
  def handle_cast({:downvote, name}, %Game{players: players} = game) do
    player = players |> find_player(name)
    player = %Player{player | score: player.score - 1}

    {:noreply, %Game{game | players: [player | players |> Enum.filter(&(&1.name != name))]}}
  end

  @impl true
  def handle_cast({:meld_card, name, word}, %Game{players: players} = game) do
    %Player{cards: cards, meld: meld} = players |> find_player(name)

    cards
    |> Enum.split_with(&(&1.word == word))
    |> case do
      {[], _cards} ->
        {:noreply, game}

      {c, cards} ->
        player = %Player{name: name, cards: cards, meld: [c |> List.first() | meld]}

        {:noreply, %Game{game | players: [player | players |> Enum.filter(&(&1.name != name))]}}
    end
  end

  # Private

  defp load_words() do
    {:ok, file} = File.read("words.txt")

    file
    |> String.split("\r\n")
    |> Enum.dedup()
    |> Enum.take(@deck_size)
    |> Enum.map(&create_card/1)
  end

  defp create_card(str) do
    %Card{word: str, points: String.length(str) * 5}
  end

  defp find_player(players, name) do
    players |> Enum.filter(&(&1.name == name)) |> List.first()
  end
end
