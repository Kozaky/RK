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
  Returns an `%Auth.User{}` with the given email and the selected columns.

  ## Examples

      iex> find_user_by_email(email)
      {:ok, user}

      iex> find_user_by_email(email, [:full_name, :email])
      {:ok, user}

      iex> find_user_by_email(email)
      {:error, reason}

  """
  def find_user_by_email(email, select \\ []) when is_binary(email) and is_list(select) do
    build_find_user_by_email_query(email, select)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  defp build_find_user_by_email_query(email, []) do
    from User, where: [email: ^email]
  end

  defp build_find_user_by_email_query(email, select) do
    from User, where: [email: ^email], select: ^select
  end

  @doc """
  Returns a list of users.

  ## Examples

      iex> list_users()
      [%PaginatedUser{}, ...]

  """
  def list_users(args) do
    Repo.pageable_select(User, :users, args, &filter_with/2)
  end

  defp filter_with(query, filter) do
    Enum.reduce(filter, query, fn
      {:id, id}, query ->
        from q in query, where: q.id == ^id

      {:email, email}, query ->
        from q in query, where: ilike(q.email, ^"%#{email}%")

      {:full_name, full_name}, query ->
        from q in query, where: ilike(q.full_name, ^"%#{full_name}%")

      {:role, role}, query ->
        from q in query,
          join: r in assoc(q, :role),
          where: ilike(r.type, ^"%#{role}%")

      {:inserted_before, date}, query ->
        from q in query, where: q.inserted_at <= ^date

      {:inserted_after, date}, query ->
        from q in query, where: q.inserted_at >= ^date
    end)
  end
end
