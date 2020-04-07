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

  @doc """
  Returns a list of users.

  ## Examples

      iex> list_users()
      [%PaginatedUser{}, ...]

  """
  def list_users(args) do
    {page, args} = Map.pop(args, :page)
    {per_page, args} = Map.pop(args, :per_page)

    query =
      args
      |> Enum.reduce(User, fn
        {:order, %{order_asc: field}}, query ->
          field = String.to_existing_atom(field)
          query |> order_by(asc: ^field)

        {:order, %{order_desc: field}}, query ->
          field = String.to_existing_atom(field)
          query |> order_by(desc: ^field)

        {:filter, filter}, query ->
          query |> filter_with(filter)
      end)

    users =
      query
      |> limit(^per_page)
      |> offset((^page - 1) * ^per_page)
      |> Repo.all()

    total_results = query |> count_total_results
    total_pages = count_total_pages(total_results, per_page)

    %{
      users: users,
      metadata: %{
        page: page,
        total_pages: total_pages,
        total_results: total_results
      }
    }
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

  defp count_total_results(query) do
    Repo.aggregate(query, :count, :id)
  end

  defp count_total_pages(total_results, per_page) do
    total_pages = ceil(total_results / per_page)

    if total_pages > 0, do: total_pages, else: 1
  end
end
