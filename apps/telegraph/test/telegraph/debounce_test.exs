defmodule Telegraph.DebounceTest do
  use ExUnit.Case
  alias Telegraph.Debounce

  test "debounces" do
    {:ok, pid} = Debounce.start_link(self())

    send(pid, :ignore)
    send(pid, :ignore)
    send(pid, :ignore)
    send(pid, :final_message)

    assert_receive :final_message
    refute_receive :ignore
  end
end
