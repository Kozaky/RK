defmodule RkBackend.Repo.Auth.Role do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Role Entity and basic functions
  """

  schema "roles" do
    field :type, :string

    timestamps()

    has_many :users, RkBackend.Repo.Auth.User
  end

  @required [:type]
  @optional []
  @doc false
  def changeset(role, args) do
    role
    |> cast(args, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:type)
  end
end
