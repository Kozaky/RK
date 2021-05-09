defmodule RkBackend.Repo.Migrations.CreateLocation do
  use Ecto.Migration

  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint.Schemas.Location

  def change do
    create table(:locations) do
      add :name, :string, size: 100, null: false

      timestamps()
    end

    flush()

    # Basic Locations
    [
      %{
        name: "Norte"
      },
      %{
        name: "Macarena"
      },
      %{
        name: "Este - Alcosa - Torreblanca"
      },
      %{
        name: "S. Pablo - Sta. Justa"
      },
      %{
        name: "Casco Antiguo"
      },
      %{
        name: "Nervión"
      },
      %{
        name: "Triana"
      },
      %{
        name: "Cerro - Amate"
      },
      %{
        name: "Sur"
      },
      %{
        name: "Los Remedios"
      },
      %{
        name: "Palmera Bellavista"
      },
      %{
        name: "Nervión"
      }
    ]
    |> Enum.each(fn location ->
      %Location{}
      |> Location.changeset(location)
      |> Repo.insert()
    end)
  end
end
