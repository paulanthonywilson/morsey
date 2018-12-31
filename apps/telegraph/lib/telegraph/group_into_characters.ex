defmodule Telegraph.GroupIntoCharacters do
  @moduledoc """
  Receives `{:morse_element, :.}`, `{:morse_element, :-}`,
  `:morse_end_of_character`, `:morse_end_of_word` messages an groups into
  morse_character messages to send ot the receiver. `:morse_end_of_word` messages
  are passsed through
  """
  use GenServer

  @type dot_dash :: :. | :-

  defstruct receiver: nil, elements: []
  @type t :: %__MODULE__{receiver: pid(), elements: list(dot_dash())}

  @spec start_link(pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    {:ok, %__MODULE__{receiver: receiver}}
  end

  def handle_info(msg = :morse_end_of_word, s = %{receiver: receiver}) do
    send(receiver, msg)
    {:noreply, s}
  end

  def handle_info(:morse_end_of_character, s = %{receiver: receiver, elements: elements}) do
    send(receiver, {:morse_character, Enum.reverse(elements)})

    {:noreply, %{s | elements: []}}
  end

  def handle_info({:morse_element, element}, s = %{elements: elements}) do
    {:noreply, %{s | elements: [element | elements]}}
  end
end
