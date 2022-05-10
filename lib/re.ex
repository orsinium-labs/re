defmodule Re do
  @moduledoc """
  Documentation for `Re`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Re.hello()
      :world

  """
  def hello do
    :world
  end

  defmacro beginning_of_line, do: "^"
  defmacro end_of_line, do: "$"
  defmacro anything, do: "."
  defmacro literal(expr), do: expr

  defmacro text(expr) when is_bitstring(expr), do: Regex.escape(expr)

  defmacro text(expr) do
    quote do
      Regex.escape(unquote(expr))
    end
  end

  defmacro sequence(expr) when is_list(expr), do: Enum.join(expr, "")

  defmacro sequence(expr) do
    quote do
      Enum.join(unquote(expr), "")
    end
  end

  defmacro any_of(expr) when is_list(expr), do: Enum.join(expr, "|")

  defmacro any_of(expr) do
    quote do
      Enum.join(unquote(expr), "|")
    end
  end

  defmacro none_of(expr) when is_bitstring(expr), do: "[^#{expr}]"

  defmacro none_of(expr) do
    quote do
      "[^#{unquote(expr)}]"
    end
  end

  defmacro in_range(expr1, expr2) when is_bitstring(expr1) and is_bitstring(expr2) do
    "#{expr1}-#{expr2}"
  end

  defmacro in_range(expr1, expr2) do
    quote do
      "#{unquote(expr1)}-#{unquote(expr2)}"
    end
  end

  defmacro zero_or_more(expr) do
    quote do
      "#{unquote(expr)}*"
    end
  end

  defmacro one_or_more(expr) do
    quote do
      "#{unquote(expr)}+"
    end
  end

  defmacro maybe(expr) do
    quote do
      "#{unquote(expr)}?"
    end
  end

  defmacro repeated(expr, n) do
    quote do
      "#{unquote(expr)}{#{unquote(n)}}"
    end
  end

  defmacro repeated(expr, at_least, at_most) do
    quote do
      "#{unquote(expr)}{#{unquote(at_least)},#{unquote(at_most)}}"
    end
  end

  defmacro group(expr) do
    quote do
      "(?:#{unquote(expr)})"
    end
  end

  defmacro capture(expr) do
    quote do
      "(#{unquote(expr)})"
    end
  end

  defmacro capture(expr, name) do
    quote do
      "(?P<#{unquote(name)}>#{unquote(expr)})"
    end
  end

  defmacro lazy(expr) do
    quote do
      "#{unquote(expr)}?"
    end
  end
end
