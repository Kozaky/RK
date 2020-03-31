defmodule RkBackend.Repo.Complaint.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Topic Entity and basic functions
  """

  schema "topics" do
    field :title, :string
    field :description, :string
    field :image_name, :string
    field :image, :binary

    has_many :reklamas, RkBackend.Repo.Complaint.Reklama

    timestamps()
  end

  @required [:title, :description, :image_name, :image]
  @optional []
  @doc false
  def changeset(topic, args) do
    topic
    |> cast(args, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:title)
  end
end
