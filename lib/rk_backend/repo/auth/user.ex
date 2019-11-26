defmodule RkBackend.Repo.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    belongs_to :role, RkBackend.Repo.Auth.Role

    timestamps()
  end

  @required [:email, :full_name, :password, :password_confirmation, :role_id]
  @optional []
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "does not match password")
    |> put_password_hash
  end

  @doc false
  def changeset_update(user, attrs) do
    user
    |> cast(attrs, @required ++ @optional)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "does not match password")
    |> put_password_hash
  end

  defp put_password_hash(changeset = %Ecto.Changeset{valid?: true, changes: %{password: pass}}),
    do: put_change(changeset, :password_hash, hash_password(pass))

  defp put_password_hash(changeset), do: changeset

  defp hash_password(password), do: Argon2.hash_pwd_salt(password)
end
