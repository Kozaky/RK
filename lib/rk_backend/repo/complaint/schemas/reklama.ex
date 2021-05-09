defmodule RkBackend.Repo.Complaint.Schemas.Reklama do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias RkBackend.Repo.Auth.Schemas.User
  alias RkBackend.Repo.Complaint.Schemas.Topic
  alias RkBackend.Repo.Complaint.Schemas.Message
  alias RkBackend.Repo.Complaint.Schemas.Reklama.ReklamaImage
  alias RkBackend.Repo.Complaint.Schemas.Location

  @moduledoc """
  Reklama Entity and basic functions
  """

  schema "reklamas" do
    field :title, :string
    field :content, :string

    belongs_to :user, User
    belongs_to :topic, Topic
    belongs_to :location, Location
    has_many :messages, Message
    has_many :images, ReklamaImage, on_replace: :delete

    timestamps()
  end

  @required [:title, :content, :user_id, :topic_id, :location_id]
  @optional []
  @doc false
  def changeset(reklama, args) do
    reklama
    |> cast(args, @required ++ @optional)
    |> cast_assoc(:images, required: false)
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:location_id)
    |> validate_required(@required)
  end
end
