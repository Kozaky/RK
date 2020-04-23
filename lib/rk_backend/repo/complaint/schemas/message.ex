defmodule RkBackend.Repo.Complaint.Schemas.Message do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias RkBackend.Repo.Auth.Schemas.User
  alias RkBackend.Repo.Complaint.Schemas.Reklama

  @moduledoc """
  Message Entity and basic functions
  """

  schema "messages" do
    field :content, :string

    belongs_to :user, User
    belongs_to :reklama, Reklama

    timestamps()
  end

  @required [:content, :user_id, :reklama_id]
  @optional []
  @doc false
  def changeset(message, args) do
    message
    |> cast(args, @required ++ @optional)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:reklama_id)
    |> validate_required(@required)
  end
end
