defmodule RkBackend.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :token, :string

      add :user_id, references(:users)

      timestamps()
    end
  end
end
