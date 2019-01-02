defmodule Telegraph.Pipeline do
  @moduledoc """
  Sets up the all the processes responsible for detecting the telgraph key,
  to decoding the morse.
  """
  use GenServer

  alias Telegraph.{GpioKey, Debounce, DotDash, GroupIntoCharacters, MorseDecode}

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, morse_decode} = MorseDecode.start_link(self())
    {:ok, groups_into_characters} = GroupIntoCharacters.start_link(morse_decode)
    {:ok, dotdash} = DotDash.start_link(groups_into_characters)
    {:ok, debounce} = Debounce.start_link(dotdash)
    {:ok, _pid} = GpioKey.start_link(key_pin(), debounce)
    {:ok, {}}
  end

  def handle_info({:telegraph_character, character}, s) do
    Events.broadcast(:morse, character)
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
