defmodule Telegraph.DotDashTest do
  use ExUnit.Case

  alias Telegraph.DotDash

  test "dot" do
    pid = create_dot_dash()
    send(pid, gpio_message(100, 1))
    send(pid, gpio_message(100 + dash_millis() - 1, 0))
    assert_receive {:morse_element, :.}
  end

  test "dash" do
    pid = create_dot_dash()
    send(pid, gpio_message(100, 1))
    send(pid, gpio_message(100 + dash_millis(), 0))
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
    send(pid, gpio_message(10, 1))
    send(pid, gpio_message(20, 0))
    send(pid, gpio_message(30, 1))
    send(pid, gpio_message(40, 0))
    send(pid, gpio_message(50, 1))
    send(pid, gpio_message(60, 0))

    assert_receive {:morse_element, :.}
    assert_receive {:morse_element, :.}
    assert_receive {:morse_element, :.}
    assert_receive :morse_end_of_character, TelegraphSettings.config().char_pause_millis() + 100

    refute_receive _
  end

  test "update settings" do
    pid = create_dot_dash()
    Events.broadcast(:telegraph_setting_updates, %TelegraphSettings{dot_millis: 30})
    assert :sys.get_state(pid).dot_nanos == 30_000_000
  end

  test "sends through end of word" do
    pid = create_dot_dash()
    send(pid, :morse_end_of_word)
    assert_receive :morse_end_of_word
  end

  defp create_dot_dash do
    {:ok, pid} = DotDash.start_link(self())
    pid
  end

  defp gpio_message(millis, value) do
    {:gpio, 21, millis * 1_000_000, value}
  end

  defp dash_millis() do
    TelegraphSettings.config().dash_millis
  end
end
