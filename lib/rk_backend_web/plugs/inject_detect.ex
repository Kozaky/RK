defmodule Plugs.InjectDetect do
  @behaviour Plug

  @moduledoc """
  Plug that take introduces the user's id in the context, if it is authenticated
  """

  import Plug.Conn

  alias RkBackend.Logic.Auth.SignIn
  alias RkBackend.Logic.Auth.SessionService

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
        conn |> send_resp(403, Atom.to_string(reason)) |> halt()

      _ ->
        conn |> send_resp(400, "Bad request") |> halt()
    end
  end

  def build_context(conn) do
    with ["Bearer " <> auth_token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- authorize(auth_token) do
      {:ok, %{user_id: user_id}}
    else
      [] -> {:ok, %{}}
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
