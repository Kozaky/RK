defmodule RkBackendWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: RkBackend.Repo

  @moduledoc """
  Types supported by GraphQL in this application
  """

  object :role do
    field :id, :id
    field :type, :string
  end

  interface :user_entity do
    field :id, :id
    field :email, :string
    field :full_name, :string

    field :role, list_of(:role) do
      resolve(fn role, _, _ -> {:ok, role} end)
    end

    resolve_type(fn
      %{token: _}, _ ->
        :logged_in_user

      %{}, _ ->
        :user
    end)
  end

  object :user do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :role, list_of(:role), resolve: assoc(:role)

    interface(:user_entity)
  end

  @desc "User currectly logged in"
  object :logged_in_user do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :role, list_of(:role), resolve: assoc(:role)
    field :token, :string

    interface(:user_entity)
  end
end
