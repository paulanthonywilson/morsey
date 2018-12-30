defmodule Slacking do
  @moduledoc false

  alias Slacking.BotWrapper

  def send_slack_message(message) do
    BotWrapper.send_slack_message(message)
  end
end
