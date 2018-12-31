defmodule Telegraph.GpioKey do
  @moduledoc """
  Behaviour that sets up a GpioKey for detecting key up and down events.

  Implemented as a genuine thing on when compiled to :prod, and as a fake thing
  in :test and :dev
  """

  @callback start_link(pos_integer(), pid()) :: :ignore | {:error, any()} | {:ok, pid()}

  @implementation if Mix.env() == :prod, do: Telegraph.RealGpioKey, else: Telegraph.FakeGpioKey

  @spec start_link(pos_integer(), pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(key, event_receiver) do
    @implementation.start_link(key, event_receiver)
  end
end
