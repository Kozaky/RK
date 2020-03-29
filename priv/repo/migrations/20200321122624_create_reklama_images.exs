defmodule RkBackend.Repo.Migrations.CreateReklamaImages do
  use Ecto.Migration

  def change do
    create table(:reklama_images) do
      add :name, :string, null: false
      add :image, :binary, null: false

      add :reklama_id, references(:reklamas, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
