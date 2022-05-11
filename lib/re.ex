defmodule Re do
  @moduledoc """
  Documentation for `Re`.
  """

  # Types of input and output:
  # + `{:re_expr, string}` for something that needs to be grouped
  # + `{:re_group, string}` for something that is already grouped
  # + a random AST for something that must be handled in runtime.

  @doc """
  Hello world.

  ## Examples

      iex> Re.hello()
      :world

  """
  def hello do
    :world
  end

  defmacrop eager(params, do: block) do
    quote do
      if Macro.quoted_literal?(unquote(params)) do
        {term, _} = unquote(block) |> Code.eval_quoted()
        Macro.escape(term)
      else
        unquote(block)
      end
    end
  end

  defmacro to_string(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        case unquote(expr) do
          {t, result} when is_atom(t) ->
            result

          result ->
            result
        end
      end
    end
  end

  defmacro group(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do: "(?:#{unquote(expr)})"
    end
  end

  defmacro beginning_of_line, do: "^"
  defmacro end_of_line, do: "$"
  defmacro anything, do: "."
  defmacro literal(expr), do: {:re_expr, expr}

  defmacro text(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:expr, Regex.escape(unquote(expr))}
      end
    end
  end

  defmacro sequence(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        Enum.join(unquote(expr), "")
      end
    end
  end

  defmacro any_of(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        Enum.join(unquote(expr), "|")
      end
    end
  end

  defmacro none_of(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        "[^#{unquote(expr)}]"
      end
    end
  end

  defmacro in_range(expr1, expr2) do
    expr1 = Macro.expand(expr1, __ENV__)
    expr2 = Macro.expand(expr2, __ENV__)

    eager [expr1, expr2] do
      quote do
        "#{unquote(expr1)}-#{unquote(expr2)}"
      end
    end
  end

  defmacro zero_or_more(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        "#{unquote(expr)}*"
      end
    end
  end

  defmacro one_or_more(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        "#{unquote(expr)}+"
      end
    end
  end

  defmacro maybe(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        "#{unquote(expr)}?"
      end
    end
  end

  defmacro repeated(expr, n) do
    expr = Macro.expand(expr, __ENV__)
    n = Macro.expand(n, __ENV__)

    eager [expr, n] do
      quote do
        "#{unquote(expr)}{#{unquote(n)}}"
      end
    end
  end

  defmacro repeated(expr, at_least, at_most) do
    expr = Macro.expand(expr, __ENV__)
    at_least = Macro.expand(at_least, __ENV__)
    at_most = Macro.expand(at_most, __ENV__)

    eager [expr, at_least, at_most] do
      quote do
        "#{unquote(expr)}{#{unquote(at_least)},#{unquote(at_most)}}"
      end
    end
  end

  defmacro capture(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        "(#{unquote(expr)})"
      end
    end
  end

  defmacro capture(expr, name) do
    expr = Macro.expand(expr, __ENV__)
    name = Macro.expand(name, __ENV__)

    eager [expr, name] do
      quote do
        "(?P<#{unquote(name)}>#{unquote(expr)})"
      end
    end
  end

  defmacro lazy(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        "#{unquote(expr)}?"
      end
    end
  end
end
