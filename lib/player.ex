defmodule Player do
  defstruct name: "",
            cards: [],
            meld: []

  use Vex.Struct
  validates(:name, string: true)
end
