defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint
  alias RkBackend.Repo.Complaint.Reklama
  alias RkBackend.Repo.Complaint.Topic
  alias RkBackend.Repo.Complaint.Message
  alias RkBackend.Utils

  require Logger

  def store_reklama(args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.reklama_details, :user_id, user_id)

    case Complaint.store_reklama(args) do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def delete_reklama(%{id: id}, _info) do
    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        Repo.delete(reklama)

      nil ->
        {:error, "Reklama not found"}
    end
  end

  def list_reklamas(args, _info) do
    case validate_args(args) do
      {:ok, args} ->
        reklamas = Complaint.list_reklamas(args)
        {:ok, reklamas}

      {:error, msg} ->
        {:error, msg}
    end
  end

  def get_reklama(%{id: id} = _args, _info) do
    case Repo.get(Reklama, id) do
      {:ok, reklama} ->
        {:ok, reklama}

      nil ->
        {:error, "This reklama could not be found"}
    end
  end

  def update_reklama(args, _info) do
    case Complaint.update_reklama(args.update_reklama_details) do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def store_topic(args, _info) do
    case Complaint.store_topic(args.topic_details) do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def update_topic(args, _info) do
    case Complaint.update_topic(args.update_topic_details) do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def delete_topic(%{id: id}, _info) do
    case Repo.get(Topic, id) do
      %Topic{} = topic ->
        Repo.delete(topic)

      nil ->
        {:error, "Topic not found"}
    end
  end

  def store_message(args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.message_details, :user_id, user_id)

    case Complaint.store_message(args) do
      {:ok, message} ->
        {:ok, message}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def delete_message(%{id: id}, _info) do
    case Repo.get(Message, id) do
      %Message{} = message ->
        Repo.delete(message)

      nil ->
        {:error, "Message not found"}
    end
  end

  defp validate_args(args) do
    errors =
      []
      |> validate_page(args)

    if Enum.empty?(errors), do: {:ok, args}, else: {:error, errors}
  end

  defp validate_page(errors, %{page: page}) when page > 0 do
    errors
  end

  defp validate_page(errors, _args) do
    ["Page: must be bigger than 0" | errors]
  end
end
