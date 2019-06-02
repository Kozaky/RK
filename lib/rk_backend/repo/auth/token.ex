defmodule RkBackend.Repo.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :token, :string

    belongs_to :user, RkBackend.Repo.Auth.User

    timestamps()
  end

  @required [:token, :user_id]
  @optional []
  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
