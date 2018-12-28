defmodule Game do
  defstruct name: "",
            deck: [],
            players: []

  use Vex.Struct

  validates(:name, presence: [message: "required"])
end
