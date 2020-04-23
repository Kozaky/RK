defmodule RkBackend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.Schemas.User

  def change do
    create table(:users) do
      add :full_name, :string, size: 100, null: false
      add :email, :string, size: 50, null: false
      add :password_hash, :string, size: 250, null: false
      add :avatar_name, :string, size: 40
      add :avatar, :binary

      add :role_id, references(:roles), null: false

      timestamps()
    end

    create unique_index(:users, [:email])

    flush()

    # Basic Admin user
    admin_args = %{
      full_name: "admin",
      email: "admin@rk.com",
      password: "adminRK",
      password_confirmation: "adminRK",
      role_id: 2
    }

    %User{}
    |> User.changeset(admin_args)
    |> Repo.insert()
  end
end
