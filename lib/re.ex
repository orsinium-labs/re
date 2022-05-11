defmodule Re do
  @moduledoc """
  Documentation for `Re`.
  """

  @typedoc """
  internal Re representation of regular expressions.
  """
  @opaque re_ast :: {:re_expr, String.t()} | {:re_group, String.t()}

  @doc """
  Guard for matching the internal Re AST representation.
  """
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

  @doc """
  Convert the given Re AST into a string.
  """
  @spec to_string(re_ast() | String.t() | char()) :: String.t()
  defmacro to_string(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        case unquote(expr) do
          {t, result} when is_atom(t) ->
            result

          result when is_integer(result) ->
            to_string([result])

          result when is_bitstring(result) ->
            result
        end
      end
    end
  end

  @doc """
  Compile Re AST (or string) into native Regex type.

  https://hexdocs.pm/elixir/1.13/Regex.html#compile!/2
  """
  @spec compile(re_ast() | String.t(), binary() | [term()]) :: any()
  defmacro compile(expr, options \\ "") do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        unquote(expr) |> Re.to_string() |> Regex.compile!(unquote(options)) |> Macro.escape()
      end
    end
  end

  @spec group(re_ast() | String.t()) :: re_ast()
  defmacro group(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        case unquote(expr) do
          {:re_expr, val} -> {:re_group, "(?:#{val})"}
          {:re_group, val} = expr -> expr
          val when is_integer(val) -> {:re_group, to_string([val])}
          val when byte_size(val) == 1 -> {:re_group, to_string([val])}
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

  @spec text(String.t() | integer()) :: re_ast()
  defmacro text(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        case unquote(expr) do
          val when is_integer(val) -> {:re_group, Regex.escape(to_string([val]))}
          val when byte_size(val) == 1 -> {:re_group, Regex.escape(val)}
          val -> {:re_expr, Regex.escape(val)}
        end
      end
    end
  end

  @spec sequence([re_ast() | String.t()]) :: re_ast()
  defmacro sequence(exprs) do
    exprs = Macro.expand(exprs, __ENV__)

    eager exprs do
      quote do
        require Re
        result = unquote(exprs) |> Enum.map(&Re.to_string/1) |> Enum.join()
        {:re_expr, result}
      end
    end
  end

  @spec any_of([re_ast() | String.t()]) :: re_ast()
  defmacro any_of(exprs) do
    exprs = Macro.expand(exprs, __ENV__)

    eager exprs do
      quote do
        require Re
        strings = unquote(exprs) |> Enum.map(&Re.to_string/1)

        if strings |> Enum.all?(&(byte_size(&1) == 1)) do
          {:re_group, "[#{Enum.join(strings)}]"}
        else
          {:re_expr, Enum.join(strings, "|")}
        end
      end
    end
  end

  @spec none_of(list(char())) :: re_ast()
  defmacro none_of(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "[^#{unquote(expr)}]"}
      end
    end
  end

  @spec in_range(char(), char()) :: re_ast()
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
        require Re
        {:re_group, value} = Re.group(unquote(expr))
        {:re_group, "#{value}*"}
      end
    end
  end

  @spec one_or_more(any) :: re_ast()
  defmacro one_or_more(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        {:re_group, value} = Re.group(unquote(expr))
        {:re_group, "#{value}+"}
      end
    end
  end

  @spec maybe(any) :: re_ast()
  defmacro maybe(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        {:re_group, value} = Re.group(unquote(expr))
        {:re_group, "#{value}?"}
      end
    end
  end

  @spec repeated(any, any) :: re_ast()
  defmacro repeated(expr, n) do
    expr = Macro.expand(expr, __ENV__)
    n = Macro.expand(n, __ENV__)

    eager [expr, n] do
      quote do
        require Re
        {:re_group, val} = unquote(expr) |> Re.group()
        {:re_group, "#{val}{#{unquote(n)}}"}
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
        require Re
        {:re_group, val} = unquote(expr) |> Re.group()
        {:re_group, "#{val}{#{unquote(at_least)},#{unquote(at_most)}}"}
      end
    end
  end

  @spec capture(any) :: re_ast()
  defmacro capture(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        val = unquote(expr) |> Re.to_string()
        {:re_group, "(#{val})"}
      end
    end
  end

  @spec capture(any, any) :: re_ast()
  defmacro capture(expr, name) do
    expr = Macro.expand(expr, __ENV__)
    name = Macro.expand(name, __ENV__)

    eager [expr, name] do
      quote do
        require Re
        val = unquote(expr) |> Re.to_string()
        {:re_group, "(?P<#{unquote(name)}>#{val})"}
      end
    end
  end

  @spec lazy(re_ast()) :: re_ast()
  defmacro lazy(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        {:re_group, value} = unquote(expr)
        {:re_group, "#{value}?"}
      end
    end
  end
end
