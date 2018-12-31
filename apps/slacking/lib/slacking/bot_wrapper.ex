defmodule Slacking.BotWrapper do
  @moduledoc """
  Wraps the Bot process, so that its pid is known.

  Waits 1 second to start to prevent thrashing if we can not start.
  """
  use GenServer
  require Logger

  import Slacking, only: [slack_channel: 0]

  alias Slacking.BotHandler

  @name __MODULE__
  @connect_delay 1_000

  defstruct bot_pid: nil
  @type t :: %__MODULE__{bot_pid: pid()}

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: @name)
  end

  def init(_) do
    Process.send_after(self(), :connect, @connect_delay)
    {:ok, %__MODULE__{}}
  end

  @doc """
  Send a message to the configured channel
  """
  @spec send_slack_message(String.t()) :: :ok | {:error, String.t()}
  def send_slack_message(message) do
    GenServer.call(@name, {:send_slack_message, message})
  end

  def handle_info(:connect, s) do
    case Slack.Bot.start_link(BotHandler, [], slack_token()) do
      {:ok, pid} ->
        {:noreply, %{s | bot_pid: pid}}

      {:error, reason} ->
        Logger.warn(fn -> "Could not connect to Slack: #{inspect(reason)}" end)
        {:stop, :no_slack, s}
    end
  end

  def handle_call(_, _from, s = %{bot_pid: nil}) do
    {:reply, {:error, "Not connected to slack"}, s}
  end

  def handle_call({:send_slack_message, message}, _from, s = %{bot_pid: bot_pid}) do
    send(bot_pid, {:send_slack_message, slack_channel(), message})
    {:reply, :ok, s}
  end

  defp slack_token, do: Application.get_env(:slacking, :slack_token)
end
