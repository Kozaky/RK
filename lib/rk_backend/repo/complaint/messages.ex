defmodule RkBackend.Repo.Complaint.Messages do
  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint.Schemas.Message

  @moduledoc """
  Provide functions to manage Messages.
  """

  @doc """
  Stores a message.

  ## Examples

      iex> store_message(%{field: value})
      {:ok, %Message{}}

      iex> store_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_message(args) do
    %Message{}
    |> Message.changeset(args)
    |> Repo.insert()
  end
end
