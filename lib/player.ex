defmodule Player do
  defstruct name: "",
    cards: []

  use Vex.Struct
  validates(:name, string: true)
end
