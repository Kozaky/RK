defmodule RkBackend.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :type, :string, null: false

      timestamps()
    end

    create unique_index(:roles, [:type])
  end
end
