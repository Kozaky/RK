defmodule RkBackend.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  alias RkBackend.Repo.Auth.Roles

  def change do
    create table(:roles) do
      add :type, :string, size: 20, null: false

      timestamps()
    end

    create unique_index(:roles, [:type])

    flush()

    # Basic Roles
    [
      %{
        type: "USER"
      },
      %{
        type: "ADMIN"
      }
    ]
    |> Enum.each(fn role -> Roles.store_role(role) end)
  end
end
