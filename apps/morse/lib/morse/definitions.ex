defmodule Morse.Definitions do
  @moduledoc """
  Maps dots and dashes to letters.
  """

  @definitions [
    {".-", "A"},
    {"-...", "B"},
    {"-.-.", "C"},
    {"-..", "D"},
    {".", "E"}
  ]

  defmacro decodes do
    for {morse, char} <- @definitions do
      morse_atoms = morse
      |> String.codepoints()
      |> Enum.map(& String.to_atom(&1))
      quote do
        def decode(unquote(morse_atoms)) do
          unquote(char)
        end
      end
    end
  end
end
