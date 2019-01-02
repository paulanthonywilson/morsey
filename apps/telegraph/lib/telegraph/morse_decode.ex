defmodule Telegraph.MorseDecode do
  @moduledoc """
  Decodes `{:morse_character, list(:- | :.)}` events into events with alphanumeric characters
  `{:telegraph_character, <<_::8>>}` events are sent to the receiver.
  """
  use GenServer

  defstruct receiver: nil, new_word_timeout: nil
  @type t :: %__MODULE__{receiver: pid()}

  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    {:ok, %__MODULE__{receiver: receiver}}
  end

  def handle_info({:morse_character, elements}, s = %{receiver: receiver}) do
    char = Morse.decode(elements)
    send(receiver, {:telegraph_character, char})
    {:noreply, s}
  end

  def handle_info(msg, s = %{receiver: receiver}) do
    send(receiver, msg)
    {:noreply, s}
  end
end
