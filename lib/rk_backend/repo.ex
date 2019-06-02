defmodule RkBackend.Repo do
  use Ecto.Repo,
    otp_app: :rk_backend,
    adapter: Ecto.Adapters.Postgres
end
