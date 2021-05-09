defmodule RkBackend.Repo.Complaint.Schemas.Location do
  use Ecto.Schema

  import Ecto.Changeset

  alias RkBackend.Repo.Complaint.Schemas.Reklama

  @moduledoc """
  Location Entity and basic functions
  """

  schema "locations" do
    field :name, :string

    has_many :reklamas, Reklama

    timestamps()
  end

  @required [:name]
  @optional []
  @doc false
  def changeset(location, args) do
    location
    |> cast(args, @required ++ @optional)
    |> validate_required(@required)
  end
end
