defmodule Telegraph.RealGpioKey do
  @moduledoc """
  Simply sets up a GPIO pin, pulled down, and sends both key up and key down
  events to the configured process.

  """

  use GenServer

  alias Circuits.GPIO

  @spec start_link(pos_integer(), pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(key_pin, receives_events) do
    GenServer.start_link(__MODULE__, {key_pin, receives_events})
  end

  def init({key_pin, receives_events}) do
    {:ok, pin_pid} = GPIO.open(key_pin, :input)
    :ok = GPIO.set_pull_mode(pin_pid, :pulldown)
    :ok = GPIO.set_edge_mode(pin_pid, :both, receiver: receives_events)
    {:ok, {}}
  end
end
