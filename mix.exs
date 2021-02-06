defmodule RkBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :rk_backend,
      version: "0.1.0",
      elixir: "~> 1.11.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {RkBackend.Application, []},
      extra_applications: [:logger, :runtime_tools, :absinthe_plug]
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
      {:phoenix, "~> 1.5.7"},
      {:phoenix_pubsub, "~> 2.0.0"},
      {:phoenix_ecto, "~> 4.2"},
      {:ecto_sql, "~> 3.5.0"},
      {:postgrex, ">= 0.15.0"},
      {:gettext, "~> 0.18.0"},
      {:plug_cowboy, "~> 2.4.0"},
      {:absinthe, "~> 1.6.2"},
      {:dataloader, "~> 1.0.0"},
      {:absinthe_plug, "~> 1.5.5"},
      {:jason, "~> 1.2.2"},
      {:logger_file_backend, "~> 0.0.11"},
      {:argon2_elixir, "~> 2.4.0"},
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:corsica, "~> 1.1.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
