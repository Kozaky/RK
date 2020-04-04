defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint
  alias RkBackend.Repo.Complaint.Reklama
  alias RkBackend.Repo.Complaint.Topic
  alias RkBackend.Repo.Complaint.Message
  alias RkBackend.Utils
  alias RkBackendWeb.Schema

  @moduledoc """
  Module with resolvers for Complaint queries and mutations
  """

  def store_reklama(args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.reklama_details, :user_id, user_id)
    args = put_images(args)

    case Complaint.store_reklama(args) do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def delete_reklama(%{id: id}, _info) do
    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        Repo.delete(reklama)

      nil ->
        {:error, :not_found}
    end
  end

  def list_reklamas(args, _info) do
    reklamas = Complaint.list_reklamas(args)
    {:ok, reklamas}
  end

  def get_reklama(%{id: id} = _args, _info) do
    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        {:ok, reklama}

      nil ->
        {:error, :not_found}
    end
  end

  def update_reklama(args, _info) do
    args.update_reklama_details
    |> put_images()
    |> Complaint.update_reklama()
    |> case do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def store_topic(args, _info) do
    args.topic_details
    |> Schema.put_upload(file_bytes: :image, filename: :image_name)
    |> Complaint.store_topic()
    |> case do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def update_topic(args, _info) do
    args.topic_details
    |> Schema.put_upload(file_bytes: :image, filename: :image_name)
    |> Complaint.update_topic()
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

  def store_message(args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.message_details, :user_id, user_id)

    case Complaint.store_message(args) do
      {:ok, message} ->
        {:ok, message}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def delete_message(%{id: id}, _info) do
    case Repo.get(Message, id) do
      %Message{} = message ->
        Repo.delete(message)

      nil ->
        {:error, :not_found}
    end
  end

  def put_images(%{images: images} = args) do
    args
    |> Map.put(
      :images,
      Enum.map(images, &Schema.put_upload(&1, file_bytes: :image, filename: :name))
    )
  end

  def put_images(args) do
    args
  end
end
