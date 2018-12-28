defmodule Player do
  defstruct name: "",
            cards: [],
            meld: [],
            score: 0

  use Vex.Struct

  validates(:name,
    presence: [message: "required"],
    length: [min: 3, message: "at least three chars"]
  )

  validates(:score, number: true)
end
