defmodule Telegraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegraph,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Telegraph.Application, []}
    ]
  end

  defp deps do
    [
      {:circuits_gpio, github: "elixir-circuits/circuits_gpio"},
      {:events, in_umbrella: true}
    ]
  end
end
