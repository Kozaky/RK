defmodule RkBackend.Auth.SignIn do
  alias RkBackend.Repo.Auth.Users
  alias RkBackend.Repo.Auth.Schemas.User
  alias Argon2
  alias Phoenix.Token
  alias RkBackend.Repo
  alias RkBackend.Auth.SessionService

  @moduledoc """
  Provides functions related with the user's login
  """

  @salt "RKApplicationDefaultSalt"
  @max_age 7200
  @secret Application.compile_env(:rk_backend, RkBackendWeb.Endpoint)[:secret_key_base]

  @doc """
  Verify if the token provided is valid

  ## Examples

      iex> is_valid_token(token)
      {:ok, user_id}

      iex> is_valid_token(token)
      {:error, reason}
  """
  def is_valid_token(auth_token) do
    Token.verify(@secret, @salt, auth_token, max_age: @max_age)
  end

  @doc """
  Sign in the user using its email and password. Returns the token.

  ## Examples

      iex> sign_in(email, password)
      {:ok, token}

      iex> sign_in(email, password)
      {:error, reason}
  """
  def sign_in(email, password) do
    with {:ok, user} <- Users.find_user_by_email(email),
         {:ok, user} <- Argon2.check_pass(user, password) do
      token = Token.sign(@secret, @salt, user.id)

      user = Repo.preload(user, :role)

      case SessionService.lookup({SessionService, user.id}) do
        {:ok, pid} -> refresh_token(pid, user, token)
        {:error, :not_found} -> assign_token(user, token)
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp refresh_token(pid, user, token) do
    SessionService.update_token(pid, %{token: token})
    {:ok, Map.merge(user, %{token: token})}
  end

  defp assign_token(user, token) do
    case SessionService.start(user, token) do
      {:ok, _} -> {:ok, Map.merge(user, %{token: token})}
      {:ok, _, _} -> {:ok, Map.merge(user, %{token: token})}
      _err -> {:error, "Could not start a new SessionService"}
    end
  end

  @doc """
  Sign the user out.

  ## Examples

      iex> sign_out(user_id)
      {:ok, :signed_out}

      iex> sign_out(wrong_args)
      {:error, reason}
  """
  def sign_out(user_id) do
    case SessionService.lookup({SessionService, user_id}) do
      {:ok, pid} ->
        SessionService.delete_session(pid)
        {:ok, :signed_out}

      error ->
        error
    end
  end

  @doc """
  Returns the current signed in user.

  ## Examples

      iex> resolve_user(user_id)
      {:ok, %User{}}

       iex> resolve_user(user_id)
      {:error, reason}
  """
  def resolve_user(user_id) do
    case Repo.get(User, user_id) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :not_found}
    end
  end

  @spec get_max_age :: 7200
  def get_max_age(), do: @max_age
end
