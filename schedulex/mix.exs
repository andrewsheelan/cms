defmodule Schedulex.Mixfile do
  use Mix.Project

  def project do
    [app: :schedulex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :exq, :ecto, :postgrex, :httpoison, :inflex],
    mod: {Schedulex.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:exq, "~> 0.9.0"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:httpoison, "~> 0.13"},
      {:mandrill, "~> 0.4"},
      {:iteraptor, "~> 0.1.0"},
      {:timex, "~> 3.1"},
      {:inflex, "~> 1.8.1"}
    ]
  end
end
