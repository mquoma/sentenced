defmodule Player do
  defstruct name: "",
            cards: [],
            meld: [],
            score: 0

  use Vex.Struct
  validates(:name, string: true)
end
