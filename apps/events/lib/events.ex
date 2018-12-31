defmodule Events do
  @moduledoc """
  Subscribe to and broadcast events.
  """

  @doc """
  Subscribe the current process to receive events on a topic. Events will be of the form
  `{topic, message}`
  """
  @spec subscribe(atom()) :: {:error, {:already_registered, pid()}} | {:ok, pid()}
  def subscribe(topic) do
    Registry.register(Events.Registry, topic, [])
  end


  @doc """
  Broadcast a message to all subscribers to a topic. Events will be of the form
  `{topic, message}`
  """
  @spec broadcast(atom(), any()) :: :ok
  def broadcast(topic, message) do
    Registry.dispatch(Events.Registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {topic, message})
    end)
  end
end
