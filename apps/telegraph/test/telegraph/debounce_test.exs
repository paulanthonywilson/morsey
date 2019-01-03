defmodule Telegraph.DebounceTest do
  use ExUnit.Case
  alias Telegraph.Debounce

  test "debounce sends last state with first timestamp" do
    {:ok, pid} = Debounce.start_link(self())

    send(pid, {:gpio, 19, 10_000, 0})
    send(pid, {:gpio, 19, 10_000, 0})
    send(pid, {:gpio, 19, 20_000, 0})
    send(pid, {:gpio, 19, 30_000, 1})

    assert_receive {:gpio, 19, 10_000, 1}
    refute_receive _
  end

  test "first timestamp is reset" do
    {:ok, pid} = Debounce.start_link(self())
    send(pid, {:gpio, 19, 10_000, 0})
    assert_receive {:gpio, 19, 10_000, 0}

    send(pid, {:gpio, 19, 30_000, 1})
    assert_receive {:gpio, 19, 30_000, 1}

    refute_receive _
  end
end
