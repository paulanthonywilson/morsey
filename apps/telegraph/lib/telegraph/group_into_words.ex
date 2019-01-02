defmodule Telegraph.GroupIntoWords do
  @moduledoc """
  Collects `{:telegraph_character, list(<<_::8>>)}` events into
  `{:telegraph_word, String.t}`

  Words are detected by the `:morse_end_of_word` event.
  """
  use GenServer

  defstruct receiver: nil, current_word: []
  @type t :: %__MODULE__{receiver: pid(), current_word: list(String.t())}

  @spec start_link(pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    {:ok, %__MODULE__{receiver: receiver}}
  end

  def handle_info({:telegraph_character, char}, s) do
    new_state = Map.update!(s, :current_word, fn word ->
      [char | word]
     end)
    {:noreply, new_state}
  end

  def handle_info(:morse_end_of_word, s = %{receiver: receiver, current_word: word}) do
    word_string = word
    |> Enum.reverse()
    |> Enum.join()
    send(receiver, {:telegraph_word, word_string})
    {:noreply, %{s | current_word: []}}
  end
end
