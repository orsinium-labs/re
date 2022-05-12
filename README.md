# Re

Elixir library for writing regular expressions in functional style.

Features:

* Readable and human-friendly.
* Less error-prone.
* 100% compile-time, no overhead in runtime.
* But will fallback to runtime if needed (if you use dynamic content like variables).
* Well documented with lots of examples.
* Optimized and readable output.

## Installation

The package can be installed by adding `re` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:re, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> require Re
iex> require Re.Chars
iex> regex =
...>   Re.sequence([
...>     Re.one_or_more(Re.any_of([Re.Chars.any_ascii, Re.any_of('.-_')])),
...>     Re.text(".example.com")
...>   ]) |> Re.compile()
~r/(?:[\\0-\x7f]|\.|\-|_)+\.example\.com/
iex> "hello.example.com" =~ regex
true
```

**Documentation**: [hexdocs.pm/re/](https://hexdocs.pm/re/Re.html)
