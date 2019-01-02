defmodule Morse do
  @moduledoc """
  Decodes Morse elements, as a list of dots and dashes, to characters.
  """

  alias Morse.Definitions
  require Definitions
  @type dot :: :.
  @type dash :: :-

  @doc """
  Decodes a list of dots and dashes into a character. Return `?` if unknown
  eg
  iex> Morse.decode([:.])
  "E"

  iex> Morse.decode([:., :-])
  "A"

  iex> Morse.decode([])
  "?"
  """
  @spec decode(list(dot | dash)) :: <<_::8>>
  def decode(element)
  Definitions.decodes()
  def decode(_), do: "?"
end
