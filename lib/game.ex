defmodule Game do
  defstruct name: nil,
            deck: [],
            players: []

  use Vex.Struct
end
