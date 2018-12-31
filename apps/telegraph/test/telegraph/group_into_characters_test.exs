defmodule Telegraph.GroupIntoCharactersTest do
  use ExUnit.Case

  alias Telegraph.GroupIntoCharacters

  test "passes morse_end_of_word on" do
    pid = create_group_into_characters()
    send(pid, :morse_end_of_word)
    assert_receive :morse_end_of_word
  end

  test "groups characters and passes on" do
    pid = create_group_into_characters()
    send(pid, {:morse_element, :.})
    send(pid, {:morse_element, :-})
    send(pid, :morse_end_of_character)
    assert_receive {:morse_character, [:., :-]}
  end

  test "multiple characters" do
    pid = create_group_into_characters()
    send(pid, {:morse_element, :.})
    send(pid, :morse_end_of_character)
    assert_receive {:morse_character, [:.]}

    send(pid, {:morse_element, :-})
    send(pid, :morse_end_of_character)
    assert_receive {:morse_character, [:-]}
  end

  defp create_group_into_characters do
    {:ok, pid} = GroupIntoCharacters.start_link(self())
    pid
  end
end
