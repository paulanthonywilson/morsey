defmodule Slacking.BotHandler do
  @moduledoc """
  Slack handler.

  Can also send messages to a channel.
  """

  use Slack

  import Slacking, only: [slack_channel: 0]
  require Logger

  def handle_connect(_slack, state) do
    Logger.info(fn -> "Connected to Slack" end)
    {:ok, hostname} = :inet.gethostname()

    Process.send_after(
      self(),
      {:send_slack_message, slack_channel(), "Connected from #{hostname}"},
      250
    )

    {:ok, state}
  end

  def handle_close(reason, _slack, state) do
    Logger.info(fn -> "Disconnecting from Slack: #{inspect(reason)}" end)
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    if message.text == "Hi" do
      send_message("Hello to you too! #{message.channel} ", message.channel, slack)
    end

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:send_slack_message, channel, content}, slack, state) do
    send_message(content, channel, slack)
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}
end
