defmodule RkBackend.Repo.Complaint.Schemas.Reklama.ReklamaImage do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  alias RkBackend.Repo.Complaint.Schemas.Reklama

  @moduledoc """
  ReklamaImage Entity and basic functions
  """

  schema "reklama_images" do
    field :name, :string
    field :image, :binary

    belongs_to :reklama, Reklama

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
