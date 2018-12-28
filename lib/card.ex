defmodule Card do
  defstruct word: "",
            points: 5

  use Vex.Struct
  validates(:points, integer: true)
end
