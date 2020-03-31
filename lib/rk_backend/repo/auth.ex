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
  Stores an user.

  Users will have the role 'USER' by default.

  ## Examples

      iex> store_user(%{field: value})
      {:ok, %User{}}

      iex> store_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_user(args) do
    users_role = Repo.get_by!(Role, type: "USER")
    args = Map.put(args, :role_id, users_role.id)

    %User{}
    |> User.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, args) do
    user
    |> User.update_changeset(args)
    |> Repo.update()
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
  def store_role(args) do
    %Role{}
    |> Role.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, args) do
    role
    |> Role.changeset(args)
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
end
