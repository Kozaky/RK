defmodule RkBackend.Middlewares.Auth do
  @behaviour Absinthe.Middleware

  alias RkBackend.Repo.Auth

  def init(opts) do
    opts
  end

  def call(resolution = %{context: %{user_id: user_id}}, config) do
    case Auth.user_has_any_role?(user_id, config) do
      true ->
        resolution

      false ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "Not enough privileges"})
    end
  end

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({:error, "Not authenticated"})
  end
end
