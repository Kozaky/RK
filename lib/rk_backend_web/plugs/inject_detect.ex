defmodule Plugs.InjectDetect do
  @behaviour Plug

  import Plug.Conn

  alias RkBackend.Auth.SignIn
  alias RkBackend.Auth.SessionService

  @moduledoc """
  Plug that take introduces the user's id in the context, if it is authenticated
  """

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      {:error, reason} when is_atom(reason) ->
        put_private(conn, :absinthe, %{})
    end
  end

  def build_context(conn) do
    with ["Bearer " <> auth_token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- authorize(auth_token) do
      {:ok, %{user_id: user_id}}
    else
      auth when is_list(auth) -> {:ok, %{}}
      error -> error
    end
  end

  def authorize(auth_token) do
    with {:ok, user_id} <- SignIn.is_valid_token(auth_token),
         {:ok, _pid} <- SessionService.lookup({SessionService, user_id}) do
      {:ok, user_id}
    else
      error -> error
    end
  end
end
