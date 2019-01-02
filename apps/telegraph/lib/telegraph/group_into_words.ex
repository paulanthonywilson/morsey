defmodule Telegraph.GroupIntoWords do
  @moduledoc """
  Collects `{:telegraph_character, list(<<_::8>>)}` events into
  words are delimited by `:morse_end_of_word` events.

  Words are detected by the length of time between characters, calculated
  as the `word_pause_millis` - `char_pause_millis`, as the character pause
  will have already happened.
  """
  use GenServer

  defstruct receiver: nil, new_word_timeout: nil
  @type t :: %__MODULE__{receiver: pid(), new_word_timeout: pos_integer()}

  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
  end
end
