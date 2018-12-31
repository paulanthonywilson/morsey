defmodule Slacking do
  @moduledoc false

  alias Slacking.BotWrapper

  @spec send_slack_message(String.t) :: :ok | {:error, String.t}
  def send_slack_message(message) do
    BotWrapper.send_slack_message(message)
  end
end
