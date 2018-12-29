defmodule App do
  use Application

  def start(_type, _args) do
    App.Supervisor.start_link()
  end

  def hello do
    :world
  end
end
