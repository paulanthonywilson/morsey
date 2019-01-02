defmodule Telegraph.DetectEndOfWordTest do
  use ExUnit.Case

  alias Telegraph.DetectEndOfWord

  test "passes through events" do
    pid = create_detect_end_of_word()
    send(pid, {:gpio, 21, 10_000_000, 1})

    assert_receive {:gpio, 21, 10_000_000, 1}
  end

  test "detects end of words on sufficient key up pause" do
    pid = create_detect_end_of_word()
    send(pid, {:gpio, 21, 10_000_000, 0})
    assert_receive :morse_end_of_word, end_of_word_timeout() + 100
  end

  test "no end of word detected on long key down" do
    pid = create_detect_end_of_word()
    send(pid, {:gpio, 21, 10_000_000, 0})
    send(pid, {:gpio, 21, 20_000_000, 1})
    refute_receive :morse_end_of_word, end_of_word_timeout() + 100
  end

  test "settings changed" do
    pid = create_detect_end_of_word()
    Events.broadcast(:telegraph_setting_updates, %TelegraphSettings{word_pause_millis: 1_000})
    assert :sys.get_state(pid).end_of_word_timeout == 1_000
  end

  defp create_detect_end_of_word() do
    {:ok, pid} = DetectEndOfWord.start_link(self())
    pid
  end

  defp end_of_word_timeout() do
    TelegraphSettings.config().word_pause_millis
  end
end
