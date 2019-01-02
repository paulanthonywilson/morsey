defmodule Telegraph.DetectEndOfWord do
  @moduledoc """
  Sends through GPIO key up and down messages and through to receiver process.
  Also detects "end of word" events by waiting for a sufficient pause between a key-up and a key-down.
  """

  defstruct receiver: nil, end_of_word_timeout: nil
  @type t :: %__MODULE__{receiver: pid(), end_of_word_timeout: pos_integer()}

  @spec start_link(pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    Events.subscribe(:telegraph_setting_updates)
    {:ok, state(receiver, TelegraphSettings.config())}
  end

  def handle_info(:timeout, s = %{receiver: receiver}) do
    send(receiver, :morse_end_of_word)
    {:noreply, s}
  end

  def handle_info(msg = {:gpio, _, _, 0}, s = %{receiver: receiver, end_of_word_timeout: timeout}) do
    send(receiver, msg)
    {:noreply, s, timeout}
  end

  def handle_info({:telegraph_setting_updates, settings}, %{receiver: receiver}) do
    {:noreply, state(receiver, settings)}
  end

  def handle_info(msg, s = %{receiver: receiver}) do
    send(receiver, msg)
    {:noreply, s}
  end

  defp state(receiver, %{word_pause_millis: end_of_word_timeout}) do
    %__MODULE__{receiver: receiver, end_of_word_timeout: end_of_word_timeout}
  end
end
