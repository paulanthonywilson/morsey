defmodule Telegraph.MorseDecodeTest do
  use ExUnit.Case

  alias Telegraph.MorseDecode

  test "decodes" do
    {:ok, pid} = MorseDecode.start_link(self())
    send(pid, {:morse_character, [:.]})
    assert_receive {:telegraph_character, "E"}
  end

  test "passes through :morse_end_of_word" do
    {:ok, pid} = MorseDecode.start_link(self())
    send(pid, :morse_end_of_word)
    assert_receive :morse_end_of_word
  end
end
