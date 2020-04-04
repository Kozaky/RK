defmodule RkBackend.Repo.Auth do
  @moduledoc """
  Provide functions to manage Auth entities.
  """

  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Repo.Auth.Role

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
  Updates an user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(args) do
    {id, args} = Map.pop(args, :id)

    case Repo.get(User, id) do
      %User{} = user ->
        user
        |> Repo.dynamically_preload(args)
        |> User.changeset(args)
        |> Repo.update()

      nil ->
        {:error, :not_found}
    end
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
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

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
  def update_role(args) do
    {id, args} = Map.pop(args, :id)

    case Repo.get(Role, id) do
      %Role{} = role ->
        role
        |> Repo.dynamically_preload(args)
        |> Role.changeset(args)
        |> Repo.update()

      nil ->
        {:error, :not_found}
    end
  end
end
