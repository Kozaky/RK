# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :rk_backend, RkBackend.Repo,
  database: "rk_backend_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :rk_backend,
  ecto_repos: [RkBackend.Repo]

# Configures the endpoint
config :rk_backend, RkBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NbyO8hHIS93Gbo1GFICgUVzacXHELFUoQjnd3VVtD2MZtXXYUk80cm2FIznNd7uC",
  render_errors: [view: RkBackendWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: RkBackend.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger,
  backends: [{LoggerFileBackend, :error_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}],
  format: "[$level] $message\n"

config :logger, :error_log,
  format: "[$date][$time][$level] $message\n",
  path: "/Users/julio/Temp/Logs/Rk.log",
  level: :debug

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
