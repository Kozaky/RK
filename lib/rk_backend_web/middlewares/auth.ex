defmodule RkBackend.Middlewares.Auth do
  @behaviour Absinthe.Middleware

  alias RkBackend.Logic.Auth.SessionService

  def init(opts) do
    opts
  end

  def call(resolution = %{context: %{user_id: _user_id}}, []) do
    resolution
  end

  def call(resolution = %{context: %{user_id: user_id}}, config) do
    {:ok, pid} = SessionService.lookup("user" <> Integer.to_string(user_id))

    case SessionService.has_any_role?(pid, config) do
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
