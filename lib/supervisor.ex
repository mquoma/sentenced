defmodule App.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: :game_supervisor)
  end

  def init(:ok) do
    children = [
      {App.GameServer, name: GameServer}

      # Supervisor.child_spec({App.GameServer, name: GameServer}, id: :game1),
      # Supervisor.child_spec({App.GameServer, name: GameServer2}, id: :game2)
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end

  def start_game(name) do
    Supervisor.start_child(:game_supervisor, [name])
  end
end
