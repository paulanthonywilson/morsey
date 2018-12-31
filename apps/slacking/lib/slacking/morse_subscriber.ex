defmodule Slacking.MorseSubscriber do
  @moduledoc """
  Sends morse events to Slack
  """

  use GenServer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    Events.subscribe(:morse)
    {:ok, {}}
  end

  def handle_info({:morse, msg}, s) do
    Slacking.send_slack_message(inspect(msg))
    {:noreply, s}
  end
end
