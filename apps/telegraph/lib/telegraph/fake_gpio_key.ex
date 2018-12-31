defmodule Telegraph.FakeGpioKey do
  @moduledoc """
  Just pretends to be a fake gpio key so it will run on host.
  """
  use GenServer

  @behaviour Telegraph.GpioKey

  def start_link(pin, event_receiver) do
    GenServer.start_link(__MODULE__, {pin, event_receiver})
  end

  def init(s) do
    {:ok, s}
  end
end
