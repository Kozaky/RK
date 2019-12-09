defmodule RkBackend.Repo.Auth do
  @moduledoc """
  Provide functions to manage Auth entities.
  """

  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Repo.Auth.Role

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
  Stores an user.

  Users will have the role 'USER' by default.

  ## Examples

      iex> store_user(%{field: value})
      {:ok, %User{}}

      iex> store_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_user(attrs \\ %{}) do
    users_role = Repo.get_by!(Role, type: "USER")
    attrs = Map.put(attrs, :role_id, users_role.id)

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Stores an user.

  ## Examples

      iex> store_user(_, %{field: value}, _)
      {:ok, %User{}}

      iex> store_user(%{field: bad_value})
      {:error, :string}

  """
  def store_user(_root, args, _info) do
    case store_user(args.user_details) do
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
  def update_user(user_update, _info) do
    try do
      with user_update = %{} <- get_user_update(user_update),
           user = %User{} <- Repo.get(User, user_update.id),
           {:ok, user} <- update_user(user, user_update) do
        {:ok, user}
      else
        nil ->
          {:error, "ID: #{user_update.id} not found"}

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

  defp get_user_update(%{user_update_details: user_update}) do
    user_update
  end

  defp get_user_update(%{user_update_role: user_update}) do
    user_update
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
  Stores a role.

  ## Examples

      iex> store_role(%{field: value})
      {:ok, %Role{}}

      iex> store_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Stores a role.

  ## Examples

      iex> store_role(_, %{field: value}, _)
      {:ok, %Role{}}

      iex> store_role(_, %{field: bad_value}, _)
      {:error, :string}

  """
  def store_role(_root, args, _info) do
    case store_role(args) do
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
end
