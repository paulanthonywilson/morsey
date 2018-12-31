defmodule EventsTest do
  use ExUnit.Case
  doctest Events

  test "subscribing and receiving events" do
    Events.subscribe(:test_topic)

    Events.broadcast(:test_topic, :a_message)

    assert_receive {:test_topic, :a_message}
  end
end
