defmodule Telegraph.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Telegraph.Pipeline
    ]

    opts = [
      strategy: :one_for_one,
      name: Telegraph.Supervisor,
      max_restarts: 1_000_000,
      max_seconds: 1
    ]

    Supervisor.start_link(children, opts)
  end
end
