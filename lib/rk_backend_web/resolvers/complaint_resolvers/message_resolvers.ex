defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers.MessageResolvers do
  alias RkBackend.Repo
  alias RkBackend.Utils
  alias RkBackend.Repo.Complaint.Messages
  alias RkBackend.Repo.Complaint.Schemas.Message

  @moduledoc """
  Module with resolvers for Message queries and mutations
  """

  def store_message(args, %{context: %{user_id: user_id}}) do
    args.message_details
    |> Map.put(:user_id, user_id)
    |> Messages.store_message()
    |> case do
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
