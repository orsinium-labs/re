defmodule ReCharsTest do
  require Re
  use ExUnit.Case
  # doctest Re.Chars

  describe "any_digit" do
    test "string" do
      assert Re.Chars.any_digit() |> Re.to_string() == ~S"\d"
    end

    test "string is statically expanded" do
      ast = quote do: Re.Chars.any_digit() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == ~S"\d"
    end
  end
end
