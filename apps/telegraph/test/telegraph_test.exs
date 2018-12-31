defmodule TelegraphTest do
  use ExUnit.Case
  doctest Telegraph

  test "greets the world" do
    assert Telegraph.hello() == :world
  end
end
