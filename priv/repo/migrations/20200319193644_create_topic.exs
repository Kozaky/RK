defmodule RkBackend.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  alias RkBackend.Repo.Complaint.Topics

  def change do
    create table(:topics) do
      add :title, :string, size: 50, null: false
      add :description, :string, size: 100, null: false
      add :image_name, :string, size: 50, null: false
      add :image, :binary, null: false

      timestamps()
    end

    create unique_index(:topics, [:title])

    flush()

    # General topic
    %{
      title: "General",
      description: "All complaints are initailize with this topic till they are reorganized",
      image_name: "general_image",
      image: <<0, 0, 0>>
    }
    |> Topics.store_topic()
  end
end
