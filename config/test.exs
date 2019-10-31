use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rk_backend, RkBackendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rk_backend, RkBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "database-test",
  hostname: "localhost",
  username: "rk",
  password: "D4N60",
  pool: Ecto.Adapters.SQL.Sandbox
