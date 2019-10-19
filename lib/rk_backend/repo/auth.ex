defmodule RkBackend.Repo.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Repo.Auth.Role
  alias RkBackend.Repo.Auth.Token

  require Logger

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(_root, _args, _info) do
    try do
      {:ok, Repo.all(User)}
    rescue
      Ecto.NoResultsError ->
        {:error, :rescued}
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Get a single user.

  ## Examples

      iex> get_user!(123)
      {:ok, %User{}}

      iex> get_user!(456)
      {:error, "ID: id not found"}

  """
  def get_user(_root, %{id: id} = _args, _info) do
    try do
      {:ok, get_user!(id)}
    rescue
      Ecto.NoResultsError ->
        {:error, "ID: #{id} not found"}
    end
  end

  @doc """
  Check if user has any of the roles in the roles list

  ## Examples

      iex> user_has_any_role?(1, ["ADMIN"])
      true

      iex> user_has_any_role?(1, [])
      false

  """
  def user_has_any_role?(user_id, roles) when is_integer(user_id) and is_list(roles) do
    user =
      Repo.all(
        from user in User,
          join: role in assoc(user, :role),
          where: role.type in ^roles and user.id == ^user_id,
          preload: [role: role]
      )

    case user do
      [%User{}] -> true
      [] -> false
      _ -> false
    end
  end

  @doc """
  Creates an user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates an user.

  ## Examples

      iex> create_user(_, %{field: value}, _)
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, :string}

  """
  def create_user(_root, args, _info) do
    case create_user(args.user_details) do
      {:ok, user} ->
        {:ok, user}

      {:error, changeset} ->
        errors = RkBackend.Utils.changeset_errors_to_string(changeset)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset_update(attrs)
    |> Repo.update()
  end

  @doc """
  Updates an user.

  ## Examples

      iex> update_user(_, %{field: value}, _)
      {:ok, %User{}}

      iex> update_user(%{field: bad_value})
      {:error, :string}

  """
  def update_user(%{user_update_details: user_update_details}, _info) do
    try do
      with user = %User{} <- Repo.get(User, user_update_details.id),
           {:ok, user} <- update_user(user, user_update_details) do
        {:ok, user}
      else
        nil ->
          {:error, "ID: #{user_update_details.id} not found"}

        {:error, changeset} ->
          errors = RkBackend.Utils.changeset_errors_to_string(changeset)
          Logger.error(errors)
          {:error, errors}
      end
    rescue
      ArgumentError ->
        Logger.error("Invalid argument given")
        {:error, "Invalid argument given"}
    end
  end

  @doc """
  Deletes an User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns an `%Auth.User{}` with the selected email.

  ## Examples

      iex> find_user_by_email(email)
      {:ok, user}

      iex> find_user_by_email(email)
      {:error, reason}

  """
  def find_user_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles(_root, _args, _info) do
    try do
      {:ok, Repo.all(Role)}
    rescue
      Ecto.NoResultsError ->
        {:error, :rescued}
    end
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(_, %{field: value}, _)
      {:ok, %Role{}}

      iex> create_role(_, %{field: bad_value}, _)
      {:error, :string}

  """
  def create_role(_root, args, _info) do
    case create_role(args) do
      {:ok, changeset} ->
        {:ok, changeset}

      {:error, changeset} ->
        errors = RkBackend.Utils.changeset_errors_to_string(changeset)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{source: %Role{}}

  """
  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end

  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Auth.Token{}` with the selected token.

  ## Examples

      iex> find_token(token)
      {:ok, %Auth.Token{}}

      iex> find_token(token)
      {:error, "Token Not Found"}

  """
  def find_token(token) when is_binary(token) do
    case Repo.get_by(Token, token: token) do
      token = %Token{} -> {:ok, token}
      nil -> {:error, "Token Not Found"}
    end
  end

  @doc """
  Delete a `%Auth.Token{}`.

  ## Examples

      iex> delete_token(user_id)
      {:ok, "Session Deleted"}

      iex> delete_token(user_id)
      {:error, reason}

  """
  def delete_token(user_id) when is_integer(user_id) do
    with token = %Token{} <- find_token_by_user(user_id) do
      case Repo.delete(token) do
        {:ok, _schema} ->
          {:ok, "Session Deleted"}

        {:error, changeset} ->
          errors = RkBackend.Utils.changeset_errors_to_string(changeset)
          Logger.error(errors)
          {:error, errors}
      end
    else
      nil -> {:error, "No Token found for this user"}
    end
  end

  @doc """
  Find a `%Auth.Token{} by its user_id`.

  ## Examples

      iex> find_token_by_user(user_id)
      %Token{}

      iex> find_token_by_user(user_id)
      nil

  """
  def find_token_by_user(user_id) when is_integer(user_id) do
    Repo.get_by(Token, user_id: user_id)
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update_token(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update_token(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_token(%Token{} = token, attrs) do
    token
    |> Token.changeset(attrs)
    |> Repo.update()
  end
end
