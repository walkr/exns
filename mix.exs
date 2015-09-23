defmodule Exns.Mixfile do
  use Mix.Project

  def project do
    [app: :exns,
     version: "0.2.0-beta",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Exns, []},
     applications: [:logger, :enm, :msgpax, :poolboy]]
  end

  defp description do
    "A library for writing clients to communicate with " <>
    "Python nanoservices via nanomsg."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     contributors: ["Tony Walker"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/walkr/exns"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options

  defp deps do
    [{:enm, git: "https://github.com/walkr/enm"},
     {:msgpax, "~> 0.8"},
     {:uuid, "~> 1.0.0"},
     {:poolboy, "~>1.5.1"}]
  end
end
