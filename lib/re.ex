defmodule Re do
  @moduledoc """
  Documentation for `Re`.
  """

  @typedoc """
  internal Re representation of regular expressions.
  """
  @opaque re_ast :: {:re_expr, String.t()} | {:re_group, String.t()}

  @spec is_re(any) :: any
  defguard is_re(v)
           when is_tuple(v) and tuple_size(v) == 2 and
                  (elem(v, 0) == :re_expr or elem(v, 0) == :re_group)

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

  @spec to_string(re_ast() | String.t()) :: String.t()
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

  @spec group(re_ast | String.t()) :: re_ast()
  defmacro group(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        case unquote(expr) do
          {:re_expr, val} -> {:re_group, "(?:#{val})"}
          {:re_group, val} = expr -> expr
          val -> {:re_group, "(?:#{val})"}
        end
      end
    end
  end

  @spec beginning_of_line :: re_ast()
  defmacro beginning_of_line, do: {:re_group, "^"}
  @spec end_of_line :: re_ast()
  defmacro end_of_line, do: {:re_group, "$"}
  @spec anything :: re_ast()
  defmacro anything, do: {:re_group, "."}
  @spec literal(any) :: re_ast()
  defmacro literal(expr), do: {:re_expr, expr}

  @spec text(any) :: re_ast()
  defmacro text(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_expr, Regex.escape(unquote(expr))}
      end
    end
  end

  @spec sequence(any) :: re_ast()
  defmacro sequence(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_expr, Enum.join(unquote(expr), "")}
      end
    end
  end

  @spec any_of(any) :: re_ast()
  defmacro any_of(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_expr, Enum.join(unquote(expr), "|")}
      end
    end
  end

  @spec none_of(any) :: re_ast()
  defmacro none_of(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "[^#{unquote(expr)}]"}
      end
    end
  end

  @spec in_range(any, any) :: re_ast()
  defmacro in_range(expr1, expr2) do
    expr1 = Macro.expand(expr1, __ENV__)
    expr2 = Macro.expand(expr2, __ENV__)

    eager [expr1, expr2] do
      quote do
        {:re_expr, "#{unquote(expr1)}-#{unquote(expr2)}"}
      end
    end
  end

  @spec zero_or_more(any) :: re_ast()
  defmacro zero_or_more(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "#{unquote(expr)}*"}
      end
    end
  end

  @spec one_or_more(any) :: re_ast()
  defmacro one_or_more(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "#{unquote(expr)}+"}
      end
    end
  end

  @spec maybe(any) :: re_ast()
  defmacro maybe(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "#{unquote(expr)}?"}
      end
    end
  end

  @spec repeated(any, any) :: re_ast()
  defmacro repeated(expr, n) do
    expr = Macro.expand(expr, __ENV__)
    n = Macro.expand(n, __ENV__)

    eager [expr, n] do
      quote do
        {:re_group, "#{unquote(expr)}{#{unquote(n)}}"}
      end
    end
  end

  @spec repeated(any, any, any) :: re_ast()
  defmacro repeated(expr, at_least, at_most) do
    expr = Macro.expand(expr, __ENV__)
    at_least = Macro.expand(at_least, __ENV__)
    at_most = Macro.expand(at_most, __ENV__)

    eager [expr, at_least, at_most] do
      quote do
        {:re_group, "#{unquote(expr)}{#{unquote(at_least)},#{unquote(at_most)}}"}
      end
    end
  end

  @spec capture(any) :: re_ast()
  defmacro capture(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "(#{unquote(expr)})"}
      end
    end
  end

  @spec capture(any, any) :: re_ast()
  defmacro capture(expr, name) do
    expr = Macro.expand(expr, __ENV__)
    name = Macro.expand(name, __ENV__)

    eager [expr, name] do
      quote do
        {:re_group, "(?P<#{unquote(name)}>#{unquote(expr)})"}
      end
    end
  end

  @spec lazy(re_ast()) :: re_ast()
  defmacro lazy(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        {:re_group, value} = Re.group(unquote(expr))
        {:re_group, "#{value}?"}
      end
    end
  end
end
