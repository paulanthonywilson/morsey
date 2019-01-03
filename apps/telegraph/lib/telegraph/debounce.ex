defmodule Telegraph.Debounce do
  @moduledoc """
  Remove the bounce caused by closing the telegraph key. Doing it in
  software so we don't have to mess with capacitors. Ignores events that occur
  within 40ms of each other. Sends events that are not followed by another after 50 milliseconds.


  See https://en.wikipedia.org/wiki/Switch#Contact_bounce
  """

  use GenServer

  @debounce_time 40

  @type pin :: non_neg_integer()
  @type timestamp :: non_neg_integer()
  @type pin_state :: 0 | 1
  @type gpio_message :: {:gpio, pin, timestamp, pin_state}

  defstruct receiver: nil, last_message: nil, first_timestamp: nil

  @type t :: %__MODULE__{
          receiver: pid,
          last_message: gpio_message(),
          first_timestamp: timestamp()
        }

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

  def handle_info(
        :timeout,
        s = %{receiver: receiver, last_message: last_message, first_timestamp: timestamp}
      ) do
    {:gpio, pin, _, pin_state} = last_message
    send(receiver, {:gpio, pin, timestamp, pin_state})
    {:noreply, %{s | last_message: nil, first_timestamp: nil}}
  end

  def handle_info(message = {_, _, timestamp, _}, s = %{first_timestamp: nil}) do
    {:noreply, %{s | last_message: message, first_timestamp: timestamp}, @debounce_time}
  end

  def handle_info(message, s) do
    {:noreply, %{s | last_message: message}, @debounce_time}
  end
end
