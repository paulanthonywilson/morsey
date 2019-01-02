defmodule Telegraph.Pipeline do
  @moduledoc """
  Sets up the all the processes responsible for detecting the telgraph key,
  to decoding the morse.
  """
  use GenServer

  alias Telegraph.{
    GpioKey,
    Debounce,
    DetectEndOfWord,
    DotDash,
    GroupIntoCharacters,
    GroupIntoWords,
    MorseDecode
  }

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, word_group} = GroupIntoWords.start_link(self())
    {:ok, morse_decode} = MorseDecode.start_link(word_group)
    {:ok, groups_into_characters} = GroupIntoCharacters.start_link(morse_decode)
    {:ok, dotdash} = DotDash.start_link(groups_into_characters)
    {:ok, detect_end_of_word} = DetectEndOfWord.start_link(dotdash)
    {:ok, debounce} = Debounce.start_link(detect_end_of_word)
    {:ok, _pid} = GpioKey.start_link(key_pin(), debounce)
    {:ok, {}}
  end

  def handle_info({:telegraph_word, word}, s) do
    Events.broadcast(:morse, word)
    {:noreply, s}
  end

  def handle_info(msg, s) do
    Events.broadcast(:morse, msg)
    {:noreply, s}
  end

  defp key_pin do
    Application.get_env(:telegraph, :key_pin)
  end
end
