defmodule Telegraph.GroupIntoWordsTest do
  use ExUnit.Case

  alias Telegraph.GroupIntoWords

  test "groups into words" do
    {:ok, pid} = GroupIntoWords.start_link(self())

    for char <- String.codepoints("HELLO") do
      send(pid, {:telegraph_character, char})
    end

    send(pid, :morse_end_of_word)

    for char <- String.codepoints("MATEY") do
      send(pid, {:telegraph_character, char})
    end

    send(pid, :morse_end_of_word)

    for char <- String.codepoints("BOY") do
      send(pid, {:telegraph_character, char})
    end

    assert_receive {:telegraph_word, "HELLO"}
    assert_receive {:telegraph_word, "MATEY"}
    refute_receive {:telegraph_word, "BOY"}
  end
end
