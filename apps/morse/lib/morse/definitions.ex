defmodule Morse.Definitions do
  @moduledoc """
  Maps dots and dashes to letters.
  """

  @definitions [
    {"A", ".-"},
    {"B", "-..."},
    {"C", "-.-."},
    {"D", "-.."},
    {"E", "."},
    {"F", "..-."},
    {"G", "--."},
    {"H", "...."},
    {"I", ".."},
    {"J", ".---"},
    {"K", "-.-"},
    {"L", ".-.."},
    {"M", "--"},
    {"N", "-."},
    {"O", "---"},
    {"P", ".--."},
    {"Q", "--.-"},
    {"R", ".-."},
    {"S", "..."},
    {"T", "-"},
    {"U", "..-"},
    {"V", "...-"},
    {"W", ".--"},
    {"X", "-..-"},
    {"Y", "-.--"},
    {"Z", "--.."},
    {"1", ".----"},
    {"2", "..---"},
    {"3", "...--"},
    {"4", "....-"},
    {"5", "....."},
    {"6", "-...."},
    {"7", "--..."},
    {"8", "---.."},
    {"9", "----."},
    {"0", "-----"}
  ]

  defmacro decodes do
    for {char, morse} <- @definitions do
      morse_atoms =
        morse
        |> String.codepoints()
        |> Enum.map(&String.to_atom(&1))

      quote do
        def decode(unquote(morse_atoms)) do
          unquote(char)
        end
      end
    end
  end
end
