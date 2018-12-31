defmodule Wifi.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Wifi.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  defp ntp_servers do
    Application.fetch_env!(:wifi, :ntp_servers)
  end

  defp children() do
    [
      supervisor(Wifi.NetworkWrapperSupervisor, []),
      worker(Wifi.Ntp, [ntp_servers()])
    ]
  end
end
