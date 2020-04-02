defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint
  alias RkBackend.Repo.Complaint.Reklama
  alias RkBackend.Repo.Complaint.Topic
  alias RkBackend.Repo.Complaint.Message
  alias RkBackend.Utils

  @moduledoc """
  Module with resolvers for Complaint queries and mutations
  """

  def store_reklama(args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.reklama_details, :user_id, user_id)

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
    case Complaint.update_reklama(args.update_reklama_details) do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def store_topic(args, _info) do
    case Complaint.store_topic(args.topic_details) do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def update_topic(args, _info) do
    case Complaint.update_topic(args.update_topic_details) do
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
end
