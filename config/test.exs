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
  username: "rk",
  password: "D4N60",
  database: "rk",
  hostname: "localhost",
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox
