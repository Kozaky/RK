defmodule RkBackend.Middlewares.Auth do
  @behaviour Absinthe.Middleware

  @moduledoc """
  Middleware used to detect if an user is authenticated and has enough privileges
  """

  alias RkBackend.Logic.Auth.SessionService

  def init(opts) do
    opts
  end

  def call(%{context: %{user_id: _user_id}} = resolution, []) do
    resolution
  end

  def call(%{context: %{user_id: user_id}} = resolution, config) do
    {:ok, pid} = SessionService.lookup({SessionService, user_id})

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
