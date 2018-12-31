defmodule Telegraph.Pipeline do
  @moduledoc """
  Sets up the all the processes responsible for detecting the telgraph key,
  to decoding the morse.
  """
  use GenServer

  alias Telegraph.{GpioKey, Debounce}

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    {:ok, debounce} = Debounce.start_link(self())
    {:ok, _pid} = GpioKey.start_link(key_pin(), debounce)
    {:ok, {}}
  end

  def handle_info(msg, s) do
    Events.broadcast(:morse, msg)
    {:noreply, s}
  end

  defp key_pin do
    Application.get_env(:telegraph, :key_pin)
  end
end
