defmodule App.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: :game_supervisor)
  end

  def init(:ok) do
    children = [
      worker(App.GameServer, [])
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end

  def start_game(name) do
    Supervisor.start_child(:game_supervisor, [name])
  end

  def list_games() do
    Supervisor.which_children(:game_supervisor)
    |> Enum.map(fn {_, pid, _, _} ->
      pid
      |> :gproc.info()
      |> List.first()
      |> (fn {key, [{{_, _, {:game, a}}, _} | _]} -> a end).()
    end)
  end
end
