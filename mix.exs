defmodule Exns.Mixfile do
  use Mix.Project

  def project do
    [app: :exns,
     version: "0.0.1-alpha",
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
    [applications: [:logger, :enm, :msgpax, :poolboy],
     mod: {Exns, []},
     env: [pool_size: 10,
           pool_name: :exns_workers,
           service_address: "ipc:///tmp/exns.sock",
           service_timeout: 1000]]
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
    [{:enm, git: "https://github.com/basho/enm"},
     {:msgpax, "~> 0.8"},
     {:uuid, "~> 1.0.0"},
     {:poolboy, "~>1.5.1"}]
  end
end
