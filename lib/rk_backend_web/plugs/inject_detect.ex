defmodule Plugs.InjectDetect do
  @behaviour Plug

  import Plug.Conn

  alias RkBackend.Repo.Auth
  alias RkBackend.Logic.Auth.SignIn

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      {:error, reason} ->
        conn |> send_resp(403, reason) |> halt()

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
    with {:ok, _} <- Auth.find_token(auth_token),
         {:ok, user_id} <- SignIn.is_valid_token(auth_token) do
      {:ok, user_id}
    else
      {:error, :expired} ->
        {:error, "Session Expired"}

      {:error, :invalid} ->
        {:error, "Invalid Token"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
