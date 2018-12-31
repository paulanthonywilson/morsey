defmodule Telegraph.DotDash do
  @moduledoc """
  Takes GPIO key up / key down messsages and converts them to dot dash
  """
  use GenServer

  @dot_duration_nanos 60_000_000
  @dash_duration_nanos @dot_duration_nanos * 3
  @character_pause_millis div(@dash_duration_nanos, 1_000_000)
  @word_pause_nanos @dot_duration_nanos * 7

  defstruct receiver: nil, last_key_down: nil, last_key_up: nil
  @type t :: %__MODULE__{receiver: pid, last_key_down: pos_integer(), last_key_up: pos_integer()}

  @spec start_link(pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    {:ok, %__MODULE__{receiver: receiver}}
  end

  def handle_info({:gpio, _pin, timestamp, 1}, s = %{last_key_up: nil}) do
    {:noreply, %{s | last_key_down: timestamp}}
  end

  def handle_info(
        {:gpio, _pin, timestamp, 1},
        s = %{last_key_up: last_key_up, receiver: receiver}
      ) do
    if timestamp - last_key_up > word_pause_nanos() do
      send(receiver, :morse_end_of_word)
    end

    {:noreply, %{s | last_key_down: timestamp}}
  end

  def handle_info({:gpio, _pin, _timestamp, 0}, s = %{last_key_down: nil}) do
    {:noreply, s}
  end

  def handle_info(
        {:gpio, _pin, timestamp, 0},
        s = %{last_key_down: last_key_down, receiver: receiver}
      ) do
    if timestamp - last_key_down < dash_duration_nanos() do
      send_dot(receiver)
    else
      send_dash(receiver)
    end

    {:noreply, %{s | last_key_up: timestamp}, character_pause_millis()}
  end

  def handle_info(:timeout, s = %{receiver: receiver}) do
    send(receiver, :morse_end_of_character)
    {:noreply, s}
  end

  defp send_dot(receiver), do: send(receiver, {:morse_element, :.})
  defp send_dash(receiver), do: send(receiver, {:morse_element, :-})

  # defp dot_duration_nanos, do: @dot_duration_nanos
  defp dash_duration_nanos, do: @dash_duration_nanos
  defp character_pause_millis, do: @character_pause_millis
  defp word_pause_nanos, do: @word_pause_nanos
end
