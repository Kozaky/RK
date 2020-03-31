defmodule RkBackend.Repo.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  User Entity and basic functions
  """

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    belongs_to :role, RkBackend.Repo.Auth.Role
    has_many :reklamas, RkBackend.Repo.Complaint.Reklama
    has_many :messages, RkBackend.Repo.Complaint.Message

    timestamps()
  end

  @required [:email, :full_name, :password, :password_confirmation, :role_id]
  @optional []
  @doc false
  def changeset(user, args) do
    user
    |> cast(args, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "does not match password")
    |> foreign_key_constraint(:role_id)
    |> put_password_hash
  end

  @update_required []
  @update_optional [:email, :full_name, :password, :password_confirmation, :role_id]
  @doc false
  def update_changeset(user, args) do
    user
    |> cast(args, @update_required ++ @update_optional)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "does not match password")
    |> foreign_key_constraint(:role_id)
    |> put_password_hash
  end

  defp put_password_hash(%Ecto.Changeset{changes: %{password: pass}} = changeset),
    do: put_change(changeset, :password_hash, hash_password(pass))

  defp put_password_hash(changeset), do: changeset

  defp hash_password(password), do: Argon2.hash_pwd_salt(password)
end
