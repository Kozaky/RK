defmodule RkBackend.Repo.Complaint.Reklama do
  use Ecto.Schema
  import Ecto.Changeset

  alias RkBackend.Repo.Complaint.Reklama.ReklamaImage

  schema "reklamas" do
    field :title, :string
    field :content, :string

    belongs_to :user, RkBackend.Repo.Auth.User
    belongs_to :topic, RkBackend.Repo.Complaint.Topic
    has_many :messages, RkBackend.Repo.Complaint.Message
    has_many :images, RkBackend.Repo.Complaint.Reklama.ReklamaImage

    timestamps()
  end

  @required [:title, :content, :user_id, :topic_id]
  @optional []
  @doc false
  def changeset(reklama, attrs) do
    reklama
    |> cast(attrs, @required ++ @optional)
    |> cast_assoc(:images, required: false)
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required(@required)
  end

  @update_required []
  @update_optional [:title, :content, :user_id, :topic_id]
  @doc false
  def update_changeset(reklama, attrs) do
    reklama
    |> cast(attrs, @update_required ++ @update_optional)
    |> cast_assoc(:images, required: false, with: &ReklamaImage.update_changeset/2)
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required(@update_required)
  end
end
