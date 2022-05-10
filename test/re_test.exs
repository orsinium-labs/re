defmodule ReTest do
  use ExUnit.Case
  doctest Re

  test "greets the world" do
    assert Re.hello() == :world
  end
end
