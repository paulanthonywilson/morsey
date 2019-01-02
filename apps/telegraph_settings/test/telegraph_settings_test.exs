defmodule TelegraphSettingsTest do
  use ExUnit.Case
  doctest TelegraphSettings

  setup do
    settings_file = "#{System.tmp_dir!()}telegraph_test_settings.txt"

    on_exit(fn ->
      File.rm(settings_file)
    end)

    {:ok, settings_file: settings_file}
  end

  test "default settings", %{settings_file: file} do
    assert TelegraphSettings.config(file).dot_millis == 92
    assert TelegraphSettings.config(file).dash_millis == 276
    assert TelegraphSettings.config(file).char_pause_millis == 276
    assert TelegraphSettings.config(file).word_pause_millis == 644
  end

  test "change settings", %{settings_file: file} do
    TelegraphSettings.set_dot_millis(file, 60)
    TelegraphSettings.set_char_pause_millis(file, 250)
    TelegraphSettings.set_word_pause_millis(file, 600)

    assert TelegraphSettings.config(file).dot_millis == 60
    assert TelegraphSettings.config(file).dash_millis == 180
    assert TelegraphSettings.config(file).char_pause_millis == 250
    assert TelegraphSettings.config(file).word_pause_millis == 600
  end

  test "update notifications", %{settings_file: file} do
    Events.subscribe(:telegraph_setting_updates)
    TelegraphSettings.set_dot_millis(file, 60)
    assert_receive {:telegraph_setting_updates, %{dot_millis: 60}}
  end
end
