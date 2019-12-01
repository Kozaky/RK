defmodule RkBackendWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: RkBackend.Repo

  object :role do
    field :id, :id
    field :type, :string
  end

  object :user do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :role, list_of(:role), resolve: assoc(:role)
  end
end
