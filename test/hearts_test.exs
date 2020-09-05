defmodule HeartsTest do
  use ExUnit.Case
  doctest Hearts

  test "greets the world" do
    assert Hearts.hello() == :world
  end
end
