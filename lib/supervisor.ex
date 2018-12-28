defmodule App.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {App.Registry, name: Registry},
      Supervisor.child_spec({App.GameServer, name: GameServer}, id: :game1),
      Supervisor.child_spec({App.GameServer, name: GameServer2}, id: :game2)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
