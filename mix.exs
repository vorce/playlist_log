defmodule PlaylistLog.MixProject do
  use Mix.Project

  def project do
    [
      app: :playlist_log,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      elixirc_options: [warnings_as_errors: true],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PlaylistLog.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.1"},
      {:cubdb, "~> 0.17"},
      {:ecto, "~> 3.3"},
      {:phoenix_ecto, "~> 4.0"},
      {:spotify_ex, "~> 2.0.9"},
      {:httpoison, "~> 1.0"},
      {:phoenix_live_view, "~> 0.12"},
      {:floki, ">= 0.0.0", only: :test},
      {:navigation_history, "~> 0.3"},
      {:con_cache, "~> 0.14"},
      {:uuid, "~> 1.1"},
      {:bypass, "~> 1.0", only: :test},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.10", only: :dev, runtime: false},
      {:mock, "~> 0.3", only: :test}
    ]
  end
end
