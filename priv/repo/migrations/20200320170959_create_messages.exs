defmodule RkBackend.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string, size: 500, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :reklama_id, references(:reklamas, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
