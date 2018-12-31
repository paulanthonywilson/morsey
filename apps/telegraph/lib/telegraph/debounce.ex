defmodule Telegraph.Debounce do
  @moduledoc """
  Remove the bounce caused by closing the telegraph key. Doing it in
  software so we don't have to mess with capacitors. Ignores events that occur
  within 40ms of each other. Sends events that are not followed by another after 50 milliseconds.


  See https://en.wikipedia.org/wiki/Switch#Contact_bounce
  """

  use GenServer

  @debounce_time 40

  defstruct receiver: nil, last_message: nil
  @type t :: %__MODULE__{receiver: pid, last_message: any()}

  @doc """
  Pass in the pid that receives events
  """
  @spec start_link(pid()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(events_receiver) do
    GenServer.start_link(__MODULE__, events_receiver)
  end

  def init(receiver) do
    {:ok, %__MODULE__{receiver: receiver}}
  end

  def handle_info(:timeout, s) do
    %{receiver: receiver, last_message: message} = s
    send(receiver, message)
    {:noreply, s}
  end
  def handle_info(message, s) do

    {:noreply, %{s | last_message: message}, @debounce_time}
  end
end
