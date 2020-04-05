defmodule RkBackend.Repo.Complaint.Topics do
  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint.Schemas.Topic

  @moduledoc """
  Provide functions to manage Topics.
  """

  @doc """
  Stores a topic.

  ## Examples

      iex> store_topic(%{field: value})
      {:ok, %Topic{}}

      iex> store_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_topic(args) do
    %Topic{}
    |> Topic.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Updates a topic

  ## Examples

      iex> update_topic(%{field: value})
      {:ok, %Topic{}}

      iex> update_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(args) do
    {id, args} = Map.pop(args, :id)

    case Repo.get(Topic, id) do
      %Topic{} = topic ->
        topic
        |> Repo.dynamically_preload(args)
        |> Topic.changeset(args)
        |> Repo.update()

      nil ->
        {:error, :not_found}
    end
  end
end
