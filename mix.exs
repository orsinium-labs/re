defmodule Re.MixProject do
  use Mix.Project

  def project do
    [
      app: :re,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: "Write readable regular expressions in functional style.",
      source_url: "https://github.com/orsinium-labs/re",
      homepage_url: "https://github.com/orsinium-labs/re",
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # https://hex.pm/docs/publish
  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/orsinium-labs/re"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
