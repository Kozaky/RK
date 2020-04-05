defmodule RkBackend.Repo.Auth.Users do
  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.Schemas.User
  alias RkBackend.Repo.Auth.Schemas.Role

  @moduledoc """
  Provide functions to manage Users.
  """

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
end
