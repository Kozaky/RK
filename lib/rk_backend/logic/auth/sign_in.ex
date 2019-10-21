defmodule RkBackend.Logic.Auth.SignIn do
  alias RkBackend.Repo.Auth
  alias Argon2
  alias Phoenix.Token

  @salt "RKApplicationDefaultSalt"
  @max_age 7200
  @secret Application.get_env(:rk_backend, RkBackendWeb.Endpoint)[:secret_key_base]

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
  def sign_in(%{email: email, password: password}, _info) do
    with {:ok, user} <- Auth.find_user_by_email(email),
         {:ok, user} <- Argon2.check_pass(user, password) do
      token_value = Token.sign(@secret, @salt, user.id)

      case Auth.find_token_by_user(user.id) do
        nil -> Auth.create_token(%{token: token_value, user_id: user.id})
        token -> Auth.update_token(token, %{token: token_value})
      end

      {:ok, token_value}
    end
  end

  @doc """
  Sign the user out.

  ## Examples

      iex> sign_out(_args, %{context: %{user_id: user_id}})
      {:ok, "Session Deleted"}

      iex> sign_out(email, password)
      {:error, reason}
  """
  def sign_out(_args, %{context: %{user_id: user_id}}) do
    user_id |> Auth.delete_token()
  end

  @doc """
  Returns the current signed in user.

  ## Examples

      iex> resolve_user(_arg, %{context: %{user_id: user_id}})
      {:ok, %User{}}

      iex> resolve_user(_arg, %{context: %{user_id: user_id}})
      {:error, "Not Authenticated"}

      iex> resolve_user(_arg, %{context: %{user_id: user_id}})
      throws
  """
  def resolve_user(_args, %{context: %{user_id: user_id}}) do
    {:ok, Auth.get_user!(user_id)}
  end

  def resolve_user(_args, _context), do: {:error, "Not Authenticated"}
end
