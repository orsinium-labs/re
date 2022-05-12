defmodule Re.Chars do
  @moduledoc """
  Character types definitions for Re.

  The module defines constants that match a specific set of characters,
  like "all letters", "all digits", "anything except whitespace", and so on.
  """

  @typedoc """
  internal Re representation of regular expressions.
  """
  @opaque re_ast :: {:re_expr, String.t()} | {:re_group, String.t()}

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

  By default, doesn't match newline.

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
  Match any horizontal whitespace symbol.

  PCRE: `\\h`.
  """
  @spec any_hspace :: re_ast()
  defmacro any_hspace, do: {:re_group, ~S"\h"}

  @doc """
  Match any symbol except horizontal whitespaces.

  PCRE: `\\H`.
  """
  @spec not_hspace :: re_ast()
  defmacro not_hspace, do: {:re_group, ~S"\H"}

  @doc """
  Match any vertical whitespace symbol.

  PCRE: `\\v`.
  """
  @spec any_vspace :: re_ast()
  defmacro any_vspace, do: {:re_group, ~S"\v"}

  @doc """
  Match any symbol except vertical whitespaces.

  PCRE: `\\V`.
  """
  @spec not_vspace :: re_ast()
  defmacro not_vspace, do: {:re_group, ~S"\V"}

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

    iex> "a" =~ Re.compile(Re.Chars.any_ascii)
    true
    iex> "\\x50" =~ Re.compile(Re.Chars.any_ascii)
    true
    iex> "\\x90" =~ Re.compile(Re.Chars.any_ascii)
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
  Matches at a word boundary.

  In PCRE, it's called "simple assertion" because it doesn't consume any symbols.

  PCRE: `\\b`.
  """
  @spec word_boundary :: re_ast()
  defmacro word_boundary, do: {:re_group, ~S"\b"}

  @doc """
  Matches when not at a word boundary.

  In PCRE, it's called "simple assertion" because it doesn't consume any symbols.

  PCRE: `\\B`.
  """
  @spec not_word_boundary :: re_ast()
  defmacro not_word_boundary, do: {:re_group, ~S"\B"}

  @doc """
  Matches letters and digits.

  PCRE: `[[:alnum:]]`.
  """
  @spec any_alnum :: re_ast()
  defmacro any_alnum, do: {:re_group, "[[:alnum:]]"}

  @doc """
  Matches any letters.

  PCRE: `[[:alpha:]]`.
  """
  @spec any_alpha :: re_ast()
  defmacro any_alpha, do: {:re_group, "[[:alpha:]]"}

  @doc """
  Matches lowercase letters.

  PCRE: `[[:lower:]]`.
  """
  @spec any_lower :: re_ast()
  defmacro any_lower, do: {:re_group, "[[:lower:]]"}

  @doc """
  Matches uppercase letters.

  PCRE: `[[:upper:]]`.
  """
  @spec any_upper :: re_ast()
  defmacro any_upper, do: {:re_group, "[[:upper:]]"}

  @doc """
  Matches hexadecimal digits.

  PCRE: `[[:hex:]]`.
  """
  @spec any_hex :: re_ast()
  defmacro any_hex, do: {:re_group, "[[:xdigit:]]"}
end
