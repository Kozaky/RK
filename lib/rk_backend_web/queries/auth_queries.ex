defmodule RkBackendWeb.Schema.Queries.AuthQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.AuthResolvers

  @moduledoc """
  Module with queries and mutations for Auth
  """

  object :auth_queries do
    @desc "Get the current user"
    field :resolve_user, :user do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&AuthResolvers.resolve_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get a list of users"
    field :users, list_of(:user) do
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&AuthResolvers.list_users/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get an user"
    field :user, :user do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&AuthResolvers.get_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get a list of available roles"
    field :roles, list_of(:role) do
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&AuthResolvers.list_roles/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end

  object :auth_mutations do
    @desc "Sign In"
    field :sign_in, :logged_in_user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&AuthResolvers.sign_in/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Sign Out"
    field :sign_out, :string do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&AuthResolvers.sign_out/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create an user"
    field :create_user, :user do
      arg(:user_details, non_null(:user_details))
      resolve(&AuthResolvers.store_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update an user"
    field :update_user, :user do
      arg(:user_update_details, non_null(:user_update_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&AuthResolvers.update_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update user's role"
    field :update_users_role, :user do
      arg(:user_update_role, non_null(:user_update_role))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&AuthResolvers.update_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create a role"
    field :create_role, :role do
      arg(:type, non_null(:string))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&AuthResolvers.store_role/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end
end
