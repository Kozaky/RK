defmodule RkBackend.Repo.Complaint.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :user, RkBackend.Repo.Auth.User
    belongs_to :reklama, RkBackend.Repo.Complaint.Reklama

    timestamps()
  end

  @required [:content, :user_id, :reklama_id]
  @optional []
  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, @required ++ @optional)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:reklama_id)
    |> validate_required(@required)
  end
end
