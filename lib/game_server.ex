defmodule GameServer do
  use GenServer

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

  def add_player(pid, name) do
    GenServer.call(pid, :draw_hand)
    |> case do
      [] ->
        {:reply, :out_of_cards}

      hand ->
        GenServer.cast(pid, {:add_player, %Player{name: name, cards: hand}})
    end
  end

  def meld_card(pid, name, card) do
    GenServer.cast(pid, {:meld_card, name, card})
  end

  def get_player(pid, name) do
    GenServer.call(pid, {:get_player, name})
  end

  # Callbacks

  @impl true
  def init(game) do
    {:ok, game}
  end

  # Deck

  @impl true
  def handle_call(:draw_card, _from, %Game{deck: [], players: players} = game) do
    {:reply, :no_cards, game}
  end

  @impl true
  def handle_call(:draw_card, _from, %Game{deck: [card | tail], players: players}) do
    {:reply, card, %Game{deck: tail, players: players}}
  end

  @impl true
  def handle_cast({:discard, card}, %Game{deck: deck, players: players}) do
    {:noreply, %Game{players: players, deck: [card | deck]}}
  end

  # Player

  @impl true
  def handle_cast({:add_player, player}, %Game{deck: deck, players: players}) do
    {:noreply, %Game{players: [player | players], deck: deck}}
  end

  def handle_cast({:meld_card, name, card}, %Game{players: players, deck: deck} = game) do
    %Player{cards: cards, meld: meld} = players |> Enum.filter(&(&1.name == name)) |> List.first()

    cards
    |> Enum.split_with(&(&1 == card))
    |> case do
      {[], cards} ->
        {:noreply, game}

      {c, cards} ->
        player = %Player{name: name, cards: cards, meld: [c |> List.first() | meld]}

        {:noreply,
         %Game{deck: deck, players: [player | players |> Enum.filter(&(&1.name != name))]}}
    end
  end

  def handle_call({:get_player, name}, _from, %Game{players: players} = game) do
    player = players |> Enum.filter(&(&1.name == name)) |> List.first()
    {:reply, player, game}
  end

  @impl true
  def handle_call(:draw_hand, _from, %Game{deck: deck, players: players} = game) do
    {hand, rest} = Enum.split(deck, @hand_size)
    {:reply, hand, %Game{deck: rest, players: players}}
  end

  # Game

  @impl true
  def handle_call(:get, _from, %Game{} = game) do
    {:reply, game, game}
  end

  # Private

  defp load_words() do
    {:ok, file} = File.read("words.txt")

    file
    |> String.split("\r\n")
    |> Enum.dedup()
    |> Enum.take(@deck_size)
  end
end
