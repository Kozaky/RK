defmodule RkBackend.Repo.Auth.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias RkBackend.Repo.Auth.Schemas.Role
  alias RkBackend.Repo.Complaint.Schemas.Reklama
  alias RkBackend.Repo.Complaint.Schemas.Message

  @moduledoc """
  User Entity and basic functions
  """

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :avatar_name, :string
    field :avatar, :binary

    belongs_to :role, Role
    has_many :reklamas, Reklama
    has_many :messages, Message

    timestamps()
  end

  @required [:email, :full_name, :password, :password_confirmation, :role_id]
  @optional [:avatar, :avatar_name]
  @doc false
  def changeset(user, args) do
    user
    |> cast(args, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "password does not match")
    |> foreign_key_constraint(:role_id)
    |> put_password_hash
  end

  defp put_password_hash(%Ecto.Changeset{changes: %{password: pass}} = changeset),
    do: put_change(changeset, :password_hash, hash_password(pass))

  defp put_password_hash(changeset), do: changeset

  defp hash_password(password), do: Argon2.hash_pwd_salt(password)
end