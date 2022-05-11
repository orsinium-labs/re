defmodule ReExampleTest do
  use ExUnit.Case
  doctest Re

  test "any subdomain of example.com" do
    regex =
      Re.sequence([
        Re.one_or_more(Re.any_of([Re.any_ascii(), Re.any_of('.-_')])),
        Re.text(".example.com")
      ])
      |> Re.compile()

    assert Regex.source(regex) == ~S"(?:[\\0-\x7f]|[.-_])+\.example\.com"
    assert Regex.match?(regex, "hello.example.com")
    assert Regex.match?(regex, "hello.world.example.com")
    assert not Regex.match?(regex, "hello.orsinium.dev")
  end
end
