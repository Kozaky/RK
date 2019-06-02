defmodule RkBackendWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: RkBackend.Repo

  object :role do
    field :id, :id
    field :type, :string
    field :users, list_of(:user), resolve: assoc(:users)
  end

  object :user do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :role, list_of(:role), resolve: assoc(:role)
  end
end
