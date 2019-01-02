defmodule Telegraph.DotDash do
  @moduledoc """
  Takes GPIO key up / key down messsages and converts them to dot dash
  """
  use GenServer

  defstruct receiver: nil,
            last_key_down: nil,
            last_key_up: nil,
            dot_nanos: nil,
            dash_nanos: nil,
            char_pause_millis: nil

  @type milliseconds :: pos_integer()
  @type nanoseconds :: pos_integer()

  @type t :: %__MODULE__{
          receiver: pid,
          last_key_down: nanoseconds(),
          last_key_up: nanoseconds(),
          dot_nanos: nanoseconds(),
          dash_nanos: nanoseconds(),
          char_pause_millis: milliseconds()
        }

  @spec start_link(pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    Events.subscribe(:telegraph_setting_updates)
    state = with_settings(%__MODULE__{receiver: receiver}, TelegraphSettings.config())
    {:ok, state}
  end

  def handle_info({:telegraph_setting_updates, new_config}, s) do
    {:noreply, with_settings(s, new_config)}
  end

  def handle_info({:gpio, _pin, timestamp, 1}, s) do
    {:noreply, %{s | last_key_down: timestamp}}
  end

  def handle_info({:gpio, _pin, _timestamp, 0}, s = %{last_key_down: nil}) do
    {:noreply, s}
  end

  def handle_info(
        {:gpio, _pin, timestamp, 0},
        s = %{
          last_key_down: last_key_down,
          receiver: receiver,
          dash_nanos: dash_nanos,
          char_pause_millis: char_pause_millis
        }
      ) do
    if timestamp - last_key_down < dash_nanos do
      send_dot(receiver)
    else
      send_dash(receiver)
    end

    {:noreply, %{s | last_key_up: timestamp}, char_pause_millis}
  end

  def handle_info(:timeout, s = %{receiver: receiver}) do
    send(receiver, :morse_end_of_character)
    {:noreply, s}
  end

  def handle_info(msg, s = %{receiver: receiver}) do
    send(receiver, msg)
    {:noreply, s}
  end

  defp send_dot(receiver), do: send(receiver, {:morse_element, :.})
  defp send_dash(receiver), do: send(receiver, {:morse_element, :-})

  defp with_settings(state, settings) do
    struct!(state,
      dot_nanos: 1_000_000 * settings.dot_millis,
      dash_nanos: 1_000_000 * settings.dash_millis,
      char_pause_millis: settings.char_pause_millis
    )
  end
end
