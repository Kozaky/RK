defmodule RkBackendWeb.Schema.Queries.AuthQueries.UserQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.AuthResolvers.UserResolvers

  @moduledoc """
  Module with queries and mutations for User
  """

  object :user_queries do
    @desc "Get the current user"
    field :resolve_user, :user do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&UserResolvers.resolve_user/2)
    end

    @desc "Get a list of users"
    field :users, :paginated_users do
      arg(:filter, :user_filter)
      arg(:order, :sort_order)
      arg(:page, non_null(:integer))
      arg(:per_page, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&UserResolvers.list_users/2)
    end

    @desc "Get an user"
    field :user, :user do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&UserResolvers.get_user/2)
    end
  end

  object :user_mutations do
    @desc "Sign In"
    field :sign_in, :logged_in_user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&UserResolvers.sign_in/2)
    end

    @desc "Sign Out"
    field :sign_out, :string do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&UserResolvers.sign_out/2)
    end

    @desc "Create an user"
    field :create_user, :user do
      arg(:user_details, non_null(:user_details))
      resolve(&UserResolvers.store_user/2)
    end

    @desc "Update an user"
    field :update_user, :user do
      arg(:user_update_details, non_null(:user_update_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&UserResolvers.update_user/2)
    end

    @desc "Update user ADMIN"
    field :update_users_role, :user do
      arg(:user_update_role_details, non_null(:user_update_role_details))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&UserResolvers.update_user/2)
    end

    @desc "Delete current logged in user"
    field :delete_my_user, :user do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&UserResolvers.delete_my_user/2)
    end
  end
end
