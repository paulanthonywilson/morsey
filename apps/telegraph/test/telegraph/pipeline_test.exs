defmodule Telegraph.PipelineTest do
  use ExUnit.Case
  alias Telegraph.Pipeline

  test "decodes" do
    Events.subscribe(:morse)
    pid = Process.whereis(Pipeline)
    send(pid, {:morse_character, [:.]})
    assert_receive {:morse, "E"}
  end
end
