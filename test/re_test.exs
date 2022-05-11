defmodule ReTest do
  use ExUnit.Case
  doctest Re

  # describe "literal" do
  #   test "explict string" do
  #     assert Re.to_string(Re.literal("hello?")) == "hello?"
  #   end
  # end

  # describe "text" do
  #   test "explict string" do
  #     assert Re.to_string(Re.text("hello?")) == ~S"hello\?"
  #   end
  # end

  # describe "any_of" do
  #   test "explict list" do
  #     assert Re.to_string(Re.any_of(["a", "b"])) == "a|b"
  #   end
  # end

  # describe "in_range" do
  #   test "explict strings" do
  #     assert Re.to_string(Re.in_range("a", "z")) == "a-z"
  #   end
  # end

  # describe "zero_or_more" do
  #   test "explict string" do
  #     assert Re.to_string(Re.zero_or_more("a")) == "a*"
  #   end
  # end

  # describe "maybe" do
  #   test "explict string" do
  #     assert Re.to_string(Re.maybe("a")) == "a?"
  #   end
  # end

  # describe "repeated" do
  #   test "explict string" do
  #     assert Re.to_string(Re.repeated("a", 5)) == "a{5}"
  #     assert Re.to_string(Re.repeated("a", 5, 10)) == "a{5,10}"
  #   end
  # end

  describe "group" do
    # test "explict string" do
    #   assert "a" |> Re.group() |> Re.to_string() == "(?:a)"
    # end

    test "explict string is statically expanded" do
      ast = quote do: Re.to_string(Re.group("a"))
      assert Macro.expand(ast, __ENV__) == "(?:a)"
    end

    #   test "variable" do
    #     var = "a"
    #     assert Re.to_string(Re.group(var)) == "(?:a)"
    #   end
  end

  # describe "capture" do
  #   test "explict string" do
  #     assert Re.to_string(Re.capture("a")) == "(a)"
  #     assert Re.to_string(Re.capture("a", "hello")) == "(?P<hello>a)"
  #   end
  # end

  # describe "lazy" do
  #   test "explict string" do
  #     assert Re.to_string(Re.lazy(Re.one_or_more("a"))) == "a+?"
  #   end
  # end
end
