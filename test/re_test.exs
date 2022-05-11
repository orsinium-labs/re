defmodule ReTest do
  use ExUnit.Case
  doctest Re

  describe "literal" do
    test "explict string" do
      assert "hello?" |> Re.literal() |> Re.to_string() == "hello?"
    end

    test "explict string is statically expanded" do
      ast = quote do: "hello?" |> Re.literal() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "hello?"
    end
  end

  describe "text" do
    test "explict string" do
      assert "hello?" |> Re.text() |> Re.to_string() == ~S"hello\?"
    end

    test "explict string is statically expanded" do
      ast = quote do: "hello?" |> Re.text() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == ~S"hello\?"
    end
  end

  describe "any_of" do
    test "explict list" do
      assert ["a", "b"] |> Re.any_of() |> Re.to_string() == "a|b"
    end

    test "explict list is statically expanded" do
      ast = quote do: ["a", "b"] |> Re.any_of() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "a|b"
    end
  end

  describe "in_range" do
    test "explict strings" do
      assert Re.in_range("a", "z") |> Re.to_string() == "a-z"
    end
  end

  describe "zero_or_more" do
    test "explict string" do
      assert "a" |> Re.zero_or_more() |> Re.to_string() == "a*"
    end
  end

  describe "maybe" do
    test "explict string" do
      assert "a" |> Re.maybe() |> Re.to_string() == "a?"
    end
  end

  describe "repeated" do
    test "explict string" do
      assert Re.repeated("a", 5) |> Re.to_string() == "a{5}"
      assert Re.repeated("a", 5, 10) |> Re.to_string() == "a{5,10}"
    end
  end

  describe "group" do
    test "explict string" do
      assert "a" |> Re.group() |> Re.to_string() == "(?:a)"
    end

    test "explict string is statically expanded" do
      ast = quote do: Re.to_string(Re.group("a"))
      assert Macro.expand(ast, __ENV__) == "(?:a)"
    end

    test "explict string with pipes is statically expanded" do
      ast = quote do: "a" |> Re.group() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "(?:a)"
    end

    test "variable" do
      var = "a"
      assert Re.group(var) |> Re.to_string() == "(?:a)"
    end
  end

  describe "capture" do
    test "explict string" do
      assert Re.capture("a") |> Re.to_string() == "(a)"
      assert Re.capture("a", "hello") |> Re.to_string() == "(?P<hello>a)"
    end
  end

  describe "lazy" do
    test "explict string" do
      assert "a" |> Re.one_or_more() |> Re.lazy() |> Re.to_string() == "a+?"
    end
  end
end
