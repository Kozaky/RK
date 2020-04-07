defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers.TopicResolvers do
  alias RkBackend.Repo
  alias RkBackend.Utils
  alias RkBackendWeb.Schema
  alias RkBackend.Repo.Complaint.Topics
  alias RkBackend.Repo.Complaint.Schemas.Topic

  @moduledoc """
  Module with resolvers for Topic queries and mutations
  """

  def store_topic(args, _info) do
    args.topic_details
    |> Schema.put_upload(file_bytes: :image, filename: :image_name)
    |> Topics.store_topic()
    |> case do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def update_topic(args, _info) do
    args.update_topic_details
    |> Schema.put_upload(file_bytes: :image, filename: :image_name)
    |> Topics.update_topic()
    |> case do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def delete_topic(%{id: id}, _info) do
    case Repo.get(Topic, id) do
      %Topic{} = topic ->
        Repo.delete(topic)

      nil ->
        {:error, :not_found}
    end
  end

  def get_topic(%{id: id} = _args, _info) do
    case Repo.get(Topic, id) do
      %Topic{} = topic ->
        {:ok, topic}

      nil ->
        {:error, :not_found}
    end
  end

  def list_topics(_args, _info) do
    {:ok, Repo.all(Topic)}
  end
end
