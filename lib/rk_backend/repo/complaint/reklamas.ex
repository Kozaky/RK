defmodule RkBackend.Repo.Complaint.Reklamas do
  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint.Schemas.Reklama
  alias RkBackend.Repo.Complaint.Schemas.Topic

  @moduledoc """
  Provide functions to manage Reklamas.
  """

  @doc """
  Stores a reklama.

  ## Examples

      iex> store_reklama(%{field: value})
      {:ok, %Reklama{}}

      iex> store_reklama(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_reklama(args) when is_map(args) do
    args =
      args
      |> Map.pop(:category)
      |> put_topic_id()

    %Reklama{}
    |> Reklama.changeset(args)
    |> Repo.insert()
  end

  def store_reklama({:error, reason}) do
    {:error, reason}
  end

  defp put_topic_id({nil, args}) do
    %{id: topic_id} = Repo.get_by!(Topic, title: "General")
    put_topic_id(topic_id, args)
  end

  defp put_topic_id({category, args}) when is_binary(category) do
    %{id: topic_id} = Repo.get_by!(Topic, title: category)
    put_topic_id(topic_id, args)
  end

  defp put_topic_id(topic_id, args) when is_integer(topic_id) do
    Map.put(args, :topic_id, topic_id)
  end

  @doc """
  Returns a list of reklamas.

  ## Examples

      iex> list_reklamas()
      [%PaginatedReklama{}, ...]

  """
  def list_reklamas(args) do
    Repo.pageable_select(Reklama, :reklamas, args, &filter_with/2)
  end

  defp filter_with(query, filter) do
    Enum.reduce(filter, query, fn
      {:id, id}, query ->
        from q in query, where: q.id == ^id

      {:title, title}, query ->
        from q in query, where: ilike(q.title, ^"%#{title}%")

      {:topic_id, topic_id}, query ->
        from q in query, where: q.topic_id == ^topic_id

      {:location_id, location_id}, query ->
        from q in query, where: q.location_id == ^location_id

      {:inserted_before, date}, query ->
        from q in query, where: q.inserted_at <= ^date

      {:inserted_after, date}, query ->
        from q in query, where: q.inserted_at >= ^date

      {:current_user_id, user_id}, query ->
        from q in query, where: q.user_id == ^user_id
    end)
  end

  @doc """
  Updates a reklama

  ## Examples

      iex> update_reklama(%{field: value})
      {:ok, %Reklama{}}

      iex> update_reklama(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reklama(args) do
    {id, args} = Map.pop(args, :id)
    {current_user, args} = Map.pop(args, :current_user)

    case Repo.get(Reklama, id) do
      %Reklama{user_id: ^current_user} = reklama ->
        reklama
        |> Repo.dynamically_preload(args)
        |> Reklama.changeset(args)
        |> Repo.update()

      %Reklama{} ->
        {:error, :resource_not_owned}

      nil ->
        {:error, :not_found}
    end
  end
end
