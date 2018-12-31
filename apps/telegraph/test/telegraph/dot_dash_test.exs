defmodule Telegraph.DotDashTest do
  use ExUnit.Case

  alias Telegraph.DotDash

  test "dot" do
    pid = create_dot_dash()
    send(pid, gpio_message(100, 1))
    send(pid, gpio_message(150, 0))
    assert_receive {:morse_element, :.}
  end

  test "dash" do
    pid = create_dot_dash()
    send(pid, gpio_message(100, 1))
    send(pid, gpio_message(300, 0))
    assert_receive {:morse_element, :-}
  end

  test "keyup without keydown" do
    pid = create_dot_dash()
    send(pid, gpio_message(300, 0))
    refute_receive {_, _}
  end

  test "keydown without keyup" do
    pid = create_dot_dash()
    send(pid, gpio_message(300, 1))
    refute_receive {_, _}
  end

  test "end of character" do
    pid = create_dot_dash()
    send(pid, gpio_message(50, 1))
    send(pid, gpio_message(100, 0))
    send(pid, gpio_message(150, 1))
    send(pid, gpio_message(200, 0))
    send(pid, gpio_message(250, 1))
    send(pid, gpio_message(300, 0))

    assert_receive {:morse_element, :.}
    assert_receive {:morse_element, :.}
    assert_receive {:morse_element, :.}
    assert_receive :morse_end_of_character, 500
  end

  test "end of word" do
    pid = create_dot_dash()
    send(pid, gpio_message(50, 1))
    send(pid, gpio_message(100, 0))
    assert_receive {:morse_element, :.}

    send(pid, gpio_message(600, 1))
    assert_receive :morse_end_of_word
  end

  defp create_dot_dash do
    {:ok, pid} = DotDash.start_link(self())
    pid
  end

  defp gpio_message(millis, value) do
    {:gpio, 21, millis * 1_000_000, value}
  end
end
