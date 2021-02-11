use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rk_backend, RkBackendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
if url = System.get_env("DATABASE_URL") do
  config :rk_backend, RkBackend.Repo, url: url, pool: Ecto.Adapters.SQL.Sandbox
else
  config :rk_backend, RkBackend.Repo,
    database: "database_test",
    hostname: "localhost",
    username: "rk",
    password: "D4N60",
    pool: Ecto.Adapters.SQL.Sandbox
end

config :rk_backend, RkBackend.Categorization,
  protocol: "http",
  address: "127.0.0.1",
  port: "3030"
