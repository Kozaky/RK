defmodule RkBackendWeb.Schema.Queries.AuthQueries.RoleQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.AuthResolvers.RoleResolvers

  @moduledoc """
  Module with queries and mutations for Role
  """

  object :role_queries do
    @desc "Get a list of available roles"
    field :roles, list_of(:role) do
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RoleResolvers.list_roles/2)
    end
  end

  object :role_mutations do
    @desc "Create a role"
    field :create_role, :role do
      arg(:type, non_null(:string))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RoleResolvers.store_role/2)
    end
  end
end
