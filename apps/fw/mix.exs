defmodule Fw.MixProject do
  use Mix.Project

  # @target System.get_env("MIX_TARGET") || "host"

  @target (case(Mix.env()) do
             :prod -> "rpi0"
             _ -> "host"
           end)

  System.put_env("MIX_TARGET", @target)

  def project do
    [
      app: :fw,
      version: "0.1.0",
      elixir: "~> 1.6",
      target: @target,
      archives: [nerves_bootstrap: "~> 1.0"],
      deps_path: "../../deps/#{@target}",
      build_path: "../../_build/#{@target}",
      config_path: "../../config/config.exs",
      lockfile: "../../mix.lock.#{@target}",
      start_permanent: Mix.env() == :prod,
      build_embedded: @target != "host",
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Fw.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 1.3", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:slacking, in_umbrella: true},
      {:wifi, in_umbrella: true},
      {:events, in_umbrella: true},
      {:telegraph, in_umbrella: true}
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  defp deps("host"), do: []

  defp deps(target) do
    [
      {:nerves_runtime, "~> 0.6"},
      {:nerves_init_gadget, ">= 0.0.0"}
    ] ++ system(target)
  end

  defp system("rpi"), do: [{:nerves_system_rpi, "~> 1.5", runtime: false}]
  defp system("rpi0"), do: [{:nerves_system_rpi0, "~> 1.5", runtime: false}]
  defp system("rpi2"), do: [{:nerves_system_rpi2, "~> 1.5", runtime: false}]
  defp system("rpi3"), do: [{:nerves_system_rpi3, "~> 1.5", runtime: false}]
  defp system("bbb"), do: [{:nerves_system_bbb, "~> 2.0", runtime: false}]
  defp system("x86_64"), do: [{:nerves_system_x86_64, "~> 1.5", runtime: false}]
  defp system(target), do: Mix.raise("Unknown MIX_TARGET: #{target}")
end
