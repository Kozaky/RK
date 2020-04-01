defmodule RkBackend.Repo.Complaint.Reklama do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Reklama Entity and basic functions
  """

  schema "reklamas" do
    field :title, :string
    field :content, :string

    belongs_to :user, RkBackend.Repo.Auth.User
    belongs_to :topic, RkBackend.Repo.Complaint.Topic
    has_many :messages, RkBackend.Repo.Complaint.Message
    has_many :images, RkBackend.Repo.Complaint.Reklama.ReklamaImage, on_replace: :delete

    timestamps()
  end

  @required [:title, :content, :user_id, :topic_id]
  @optional []
  @doc false
  def changeset(reklama, args) do
    reklama
    |> cast(args, @required ++ @optional)
    |> cast_assoc(:images, required: false)
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required(@required)
  end
end
