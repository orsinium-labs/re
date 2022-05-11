defmodule Re do
  @moduledoc """
  Write readable regular expressions in functional style.

  ## Examples

  Match subdomains of `example.com`:

    iex> regex =
    ...>   Re.sequence([
    ...>     Re.one_or_more(Re.any_of([Re.any_ascii(), Re.any_of('.-_')])),
    ...>     Re.text(".example.com")
    ...>   ]) |> Re.compile()
    ~r/(?:[\\\\0-\\x7f]|[.-_])+\\.example\\.com/
    iex> Regex.match?(regex, "hello.example.com")
    true
    iex> Regex.match?(regex, "hello.world.example.com")
    true
    iex> Regex.match?(regex, "hello.orsinium.dev")
    false

  """

  @typedoc """
  internal Re representation of regular expressions.
  """
  @opaque re_ast :: {:re_expr, String.t()} | {:re_group, String.t()}

  @doc """
  Guard for matching the internal Re AST representation.

  ## Examples

      iex> Re.is_re(Re.text("hello"))
      true
      iex> Re.is_re("something else")
      false
      iex> Re.is_re(~r"hi")
      false
  """
  @spec is_re(any) :: any
  defguard is_re(v)
           when is_tuple(v) and tuple_size(v) == 2 and
                  (elem(v, 0) == :re_expr or elem(v, 0) == :re_group)

  # Internal macros that evaluates quoted expression if all params are static literals.
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

  ## Examples

    iex> Re.to_string(Re.any_digit)
    "\\\\d"
    iex> Re.to_string(Re.any_ascii)
    "[\\\\\\\\0-\\\\x7f]"
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

  The result can be used with any functions from the Regex module.

  https://hexdocs.pm/elixir/1.13/Regex.html#compile!/2

  ## Examples

    iex> "1" =~ Re.compile(Re.any_digit)
    true
    iex> "a" =~ Re.compile(Re.any_digit)
    false
  """
  @spec compile(re_ast() | String.t(), binary() | [term()]) :: any()
  defmacro compile(expr, options \\ "") do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        unquote(expr) |> Re.to_string() |> Regex.compile!(unquote(options))
      end
    end
  end

  @doc """
  Group (but not capture) the pattern if needed.

  Usually, you don't need to call this function.
  All other functions call this one when needed.

  PCRE: `(?:X)`

  ## Examples

    iex> 'abc' |> Re.raw |> Re.group |> Re.to_string
    "(?:abc)"
  """
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

  @doc """
  Match the beginning of each line.

  PCRE: `^`
  """
  @spec beginning_of_line :: re_ast()
  defmacro beginning_of_line, do: {:re_group, "^"}

  @doc """
  Match the end of each line.

  PCRE: `$`
  """
  @spec end_of_line :: re_ast()
  defmacro end_of_line, do: {:re_group, "$"}

  @doc """
  Match the beginning of the whole string.

  PCRE: `\\A`
  """
  @spec beginning_of_string :: re_ast()
  defmacro beginning_of_string, do: {:re_group, "\A"}

  @doc """
  Match the end of the whole string.

  PCRE: `\\z`
  """
  @spec end_of_string :: re_ast()
  defmacro end_of_string, do: {:re_group, "\z"}

  @doc """
  Match any symbol.

  PCRE: `.`

  ## Examples

    iex> "a" =~ Re.compile(Re.anything)
    true
    iex> "?" =~ Re.compile(Re.anything)
    true

  """
  @spec anything :: re_ast()
  defmacro anything, do: {:re_group, "."}

  @doc """
  Match only space and nothing else.

  PCRE: ` `.
  """
  @spec space :: re_ast()
  defmacro space, do: {:re_group, " "}

  @doc """
  Match the tab symbol and nothing else.

  PCRE: `\\t`.
  """
  @spec tab :: re_ast()
  defmacro tab, do: {:re_group, ~S"\t"}

  @doc """
  Match decimal digit.

  PCRE: `\\d`.
  """
  @spec any_digit :: re_ast()
  defmacro any_digit, do: {:re_group, ~S"\d"}

  @doc """
  Match any symbol except digit.

  PCRE: `\\D`.
  """
  @spec not_digit :: re_ast()
  defmacro not_digit, do: {:re_group, ~S"\D"}

  @doc """
  Match any whitespace symbol like space, tab, unicode spaces etc.

  PCRE: `\\s`.
  """
  @spec any_space :: re_ast()
  defmacro any_space, do: {:re_group, ~S"\s"}

  @doc """
  Match any symbol except whitespace symbols.

  PCRE: `\\S`.
  """
  @spec not_space :: re_ast()
  defmacro not_space, do: {:re_group, ~S"\S"}

  @doc """
  Match any word symbol like letters, numbers etc.

  PCRE: `\\w`.
  """
  @spec any_word :: re_ast()
  defmacro any_word, do: {:re_group, ~S"\w"}

  @doc """
  Match any symbol except word symbols (letters, numbers etc).

  PCRE: `\\W`.
  """
  @spec not_word :: re_ast()
  defmacro not_word, do: {:re_group, ~S"\W"}

  @doc """
  Match any ASCII symbol (code points from 0 to 127).

  PCRE: `[\\\\0-\\x7f]`.

  ## Examples

    iex> "a" =~ Re.compile(Re.any_ascii)
    true
    iex> "\\x50" =~ Re.compile(Re.any_ascii)
    true
    iex> "\\x90" =~ Re.compile(Re.any_ascii)
    false

  """
  @spec any_ascii :: re_ast()
  defmacro any_ascii, do: {:re_group, ~S"[\\0-\x7f]"}

  @doc """
  Match any Latin-1 symbol (code points from 0 to 255).

  PCRE: `[\\\\0-\\xff]`.
  """
  @spec any_latin1 :: re_ast()
  defmacro any_latin1, do: {:re_group, ~S"[\\0-\xff]"}

  @doc """
  Include a raw regex as is into the resulting pattern.

  Can be dangerous. Don't let untrusted users to pass values there.
  Use `Re.text` if you need the input text to be escaped.

  ## Examples

    iex> "example.com" =~ Re.raw("example.com") |> Re.compile()
    true
    iex> "examplescom" =~ Re.raw("example.com") |> Re.compile()
    true
    iex> "examplscom" =~ Re.raw("example.com") |> Re.compile()
    false

  """
  @spec raw(String.t() | Regex.t()) :: re_ast()
  defmacro raw(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        case unquote(expr) do
          %Regex{} = val -> {:re_expr, Regex.source(val)}
          val -> {:re_expr, val}
        end
      end
    end
  end

  @doc """
  Include a text into the resulting pattern.
  All unsafe symbols will be escaped if necessary.

  ## Examples

    iex> "example.com" =~ Re.text("example.com") |> Re.compile()
    true
    iex> "examplescom" =~ Re.text("example.com") |> Re.compile()
    false

  """
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

  @doc """
  Chain multiple patterns together.

  PCRE: `XY`
  """
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

  @doc """
  Match any of the given patters or symbols.

  PCRE: `[XY]` and `X|Y`
  """
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

  @doc """
  Match anything except the given symbols.

  PCRE: `[^XY]`

  ## Examples

    iex> "a" =~ Re.none_of('abc') |> Re.compile()
    false
    iex> "d" =~ Re.none_of('abc') |> Re.compile()
    true

  """
  @spec none_of(list(char())) :: re_ast()
  defmacro none_of(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        {:re_group, "[^#{unquote(expr)}]"}
      end
    end
  end

  @doc """
  Match any symbol in the given range.

  PCRE: `X-Y`
  """
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

  @doc """
  Match zero or more repetitions of the pattern.

  PCRE: `X*`
  """
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

  @doc """
  Match one or more repetitions of the pattern.

  PCRE: `X+`
  """
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

  @doc """
  Match zero or one repetition of the pattern.

  PCRE: `X?`
  """
  @spec optional(any) :: re_ast()
  defmacro optional(expr) do
    expr = Macro.expand(expr, __ENV__)

    eager [expr] do
      quote do
        require Re
        {:re_group, value} = Re.group(unquote(expr))
        {:re_group, "#{value}?"}
      end
    end
  end

  @doc """
  Match exactly N repetitions of the pattern.

  PCRE: `X{N}`
  """
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

  @doc """
  Match from at_least to at_most repetitions of the pattern.

  PCRE: `X{N,M}`
  """
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

  @doc """
  Capture the pattern.

  https://hexdocs.pm/elixir/1.13/Regex.html#module-captures

  PCRE: `(X)`
  """
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

  @doc """
  Named capture of the pattern.

  https://hexdocs.pm/elixir/1.13/Regex.html#module-captures

  PCRE: `(?P<N>X)`
  """
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

  @doc """
  "Ungreedy" the pattern.

  By default, all patterns greedy and try to match as much as possbile.
  This function reverts this behavior for the given pattern,
  making it match as less as possible.

  https://hexdocs.pm/elixir/1.13/Regex.html#module-captures

  PCRE: `X?`
  """
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
