defmodule RkBackend.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string, null: false
      add :description, :string, null: false
      add :image_name, :string, null: false
      add :image, :binary, null: false

      timestamps()
    end

    create unique_index(:topics, [:title])
  end
end
