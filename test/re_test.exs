defmodule ReTest do
  use ExUnit.Case
  doctest Re

  describe "literal" do
    test "explict string" do
      assert Re.literal("hello?") == "hello?"
    end
  end

  describe "text" do
    test "explict string" do
      assert Re.text("hello?") == ~S"hello\?"
    end
  end

  describe "any_of" do
    test "explict list" do
      assert Re.any_of(["a", "b"]) == "a|b"
    end
  end

  describe "in_range" do
    test "explict strings" do
      assert Re.in_range("a", "z") == "a-z"
    end
  end

  describe "zero_or_more" do
    test "explict string" do
      assert Re.zero_or_more("a") == "a*"
    end
  end
end
