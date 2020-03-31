defmodule RkBackend.Repo.Complaint.Reklama.ReklamaImage do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  ReklamaImage Entity and basic functions
  """

  schema "reklama_images" do
    field :name, :string
    field :image, :binary

    belongs_to :reklama, RkBackend.Repo.Complaint.Reklama

    timestamps()
  end

  @required [:name, :image]
  @optional []
  @doc false
  def changeset(reklama_image, args) do
    reklama_image
    |> cast(args, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:reklama_id)
  end
end
