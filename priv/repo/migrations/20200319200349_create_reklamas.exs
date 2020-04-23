defmodule RkBackend.Repo.Migrations.CreateReklamas do
  use Ecto.Migration

  def change do
    create table(:reklamas) do
      add :title, :string, size: 100, null: false
      add :content, :string, size: 3_000, null: false

      add :user_id, references(:users), null: false
      add :topic_id, references(:topics, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
