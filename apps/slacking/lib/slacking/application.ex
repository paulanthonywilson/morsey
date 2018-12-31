defmodule Slacking.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Slacking.BotWrapper,
      Slacking.MorseSubscriber
    ]

    # Not going down if we can not connect to Slack
    opts = [
      strategy: :one_for_one,
      name: Slacking.Supervisor,
      max_restarts: 2_000,
      max_seconds: 1
    ]

    Supervisor.start_link(children, opts)
  end
end
