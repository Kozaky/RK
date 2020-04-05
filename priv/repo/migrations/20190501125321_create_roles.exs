defmodule RkBackend.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  alias RkBackend.Repo.Auth

  def change do
    create table(:roles) do
      add :type, :string, null: false

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
    |> Enum.each(fn role -> Auth.store_role(role) end)
  end
end
