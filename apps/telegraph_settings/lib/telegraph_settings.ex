defmodule TelegraphSettings do
  @moduledoc """
  Holds settings for things like dot length and pauses between characters and words.
  """

  if Mix.env() == :prod do
    @settings_file "/root/telegraph_settings.txt"
  else
    @settings_file "/#{System.tmp_dir!()}telegraph_settings.txt"
  end

  @default_wpm 13
  @default_dot_millis div(1_200, @default_wpm)
  defstruct dot_millis: @default_dot_millis,
            char_pause_millis: 3 * @default_dot_millis,
            word_pause_millis: 7 * @default_dot_millis,
            dash_millis: 3 * @default_dot_millis

  @type t :: %__MODULE__{
          dot_millis: pos_integer(),
          dash_millis: pos_integer(),
          char_pause_millis: pos_integer(),
          word_pause_millis: pos_integer()
        }

  @spec config(String.t()) :: t
  def config(file \\ @settings_file) do
    with {:ok, binary} <- File.read(file),
         result = %__MODULE__{} <- decode_file_contents(binary) do
      result
    else
      _ ->
        %__MODULE__{}
    end
  end

  @spec set_dot_millis(String.t(), pos_integer()) :: :ok
  def set_dot_millis(file \\ @settings_file, value) do
    update_values(file, dot_millis: value, dash_millis: value * 3)
  end

  def set_char_pause_millis(file \\ @settings_file, value) do
    update_values(file, char_pause_millis: value)
  end

  def set_word_pause_millis(file \\ @settings_file, value) do
    update_values(file, word_pause_millis: value)
  end

  def reset_defaults(file \\ @settings_file) do
    File.rm(file)
  end

  defp update_values(file, updates) do
    current = config(file)
    updated = struct(current, updates)
    save(file, updated)
  end

  defp save(file, updated) do
    binary = :erlang.term_to_binary(updated)
    File.write!(file, binary)
    Events.broadcast(:telegraph_setting_updates, updated)
  end

  defp decode_file_contents(binary) do
    try do
      :erlang.binary_to_term(binary)
    rescue
      ArgumentError ->
        :error
    end
  end
end
