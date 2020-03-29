defmodule RkBackend.Repo.Migrations.CreateReklamas do
  use Ecto.Migration

  def change do
    create table(:reklamas) do
      add :title, :string, null: false, null: false
      add :content, :string, null: false, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :topic_id, references(:topics, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
