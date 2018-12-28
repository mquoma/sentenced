defmodule Card do
  defstruct word: "",
            points: 5

  use Vex.Struct

  validates(:word, presence: [message: "required"])

  validates(:points, number: [message: "non-negative", min: 0])
end
