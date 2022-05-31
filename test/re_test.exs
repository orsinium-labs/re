defmodule ReTest do
  require Re.Chars
  use ExUnit.Case
  doctest Re

  describe "raw" do
    test "explicit string" do
      assert "hello?" |> Re.raw() |> Re.to_string() == "hello?"
    end

    test "explicit Regex" do
      assert ~r"hello?" |> Re.raw() |> Re.to_string() == "hello?"
    end

    test "explicit string is statically expanded" do
      ast = quote do: "hello?" |> Re.raw() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "hello?"
    end
  end

  describe "text" do
    test "explicit string" do
      assert "hello?" |> Re.text() |> Re.to_string() == ~S"hello\?"
      assert ?h |> Re.text() |> Re.to_string() == "h"
      assert ?h |> Re.text() |> Re.group() |> Re.to_string() == "h"
      assert "h" |> Re.text() |> Re.group() |> Re.to_string() == "h"
    end

    test "explicit string is statically expanded" do
      ast = quote do: "hello?" |> Re.text() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == ~S"hello\?"
    end
  end

  describe "any_of" do
    test "explicit list" do
      assert ["a", "b"] |> Re.any_of() |> Re.to_string() == "[ab]"
      assert 'abcd' |> Re.any_of() |> Re.to_string() == "[abcd]"
      assert ["a", "b", "c", "d"] |> Re.any_of() |> Re.to_string() == "[abcd]"
      assert ["ab", "cd"] |> Re.any_of() |> Re.to_string() == "ab|cd"
      assert ["ab", "cd", "ef"] |> Re.any_of() |> Re.to_string() == "ab|cd|ef"
    end

    test "explicit list is statically expanded" do
      ast = quote do: ["a", "b"] |> Re.any_of() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "[ab]"
    end
  end

  describe "none_of" do
    test "explicit list" do
      assert 'ab' |> Re.none_of() |> Re.to_string() == "[^ab]"
      assert 'abcd' |> Re.none_of() |> Re.to_string() == "[^abcd]"
    end

    test "explicit list is statically expanded" do
      ast = quote do: 'ab' |> Re.none_of() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "[^ab]"
    end
  end

  describe "in_range" do
    test "explicit strings" do
      assert Re.in_range("a", "z") |> Re.to_string() == "[a-z]"
      assert Re.in_range('a', 'z') |> Re.to_string() == "[a-z]"
      assert Re.in_range(?a, ?z) |> Re.to_string() == "[a-z]"
    end

    test "explicit string is statically expanded" do
      ast = quote do: Re.in_range("a", "z") |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "[a-z]"
    end
  end

  describe "zero_or_more" do
    test "explicit string" do
      assert ?a |> Re.zero_or_more() |> Re.to_string() == "a*"
      assert "abc" |> Re.zero_or_more() |> Re.to_string() == "(?:abc)*"
      assert 'abc' |> Re.any_of() |> Re.zero_or_more() |> Re.to_string() == "[abc]*"
    end
  end

  describe "optional" do
    test "explicit string" do
      assert ?a |> Re.optional() |> Re.to_string() == "a?"
      assert "abc" |> Re.optional() |> Re.to_string() == "(?:abc)?"
    end
  end

  describe "repeated" do
    test "explicit string" do
      assert Re.repeated("a", 5) |> Re.to_string() == "a{5}"
      assert Re.repeated("a", 5, 10) |> Re.to_string() == "a{5,10}"
    end
  end

  describe "group" do
    test "explicit string" do
      assert "a" |> Re.group() |> Re.to_string() == "a"
      assert ?a |> Re.group() |> Re.to_string() == "a"
      assert "abc" |> Re.group() |> Re.to_string() == "(?:abc)"
    end

    test "explicit string is statically expanded" do
      ast = quote do: Re.to_string(Re.group("abc"))
      assert Macro.expand(ast, __ENV__) == "(?:abc)"
    end

    test "explicit string with pipes is statically expanded" do
      ast = quote do: "abc" |> Re.group() |> Re.to_string()
      assert Macro.expand(ast, __ENV__) == "(?:abc)"
    end

    test "variable" do
      var = "abc"
      assert Re.group(var) |> Re.to_string() == "(?:abc)"
    end
  end

  describe "capture" do
    test "explicit string" do
      assert Re.capture("a") |> Re.to_string() == "(a)"
      assert Re.capture("a", "hello") |> Re.to_string() == "(?P<hello>a)"
    end
  end

  describe "lazy" do
    test "explicit string" do
      assert ?a |> Re.one_or_more() |> Re.lazy() |> Re.to_string() == "a+?"
    end
  end
end
