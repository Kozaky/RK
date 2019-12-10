defmodule RkBackendWeb.Schema do
  use Absinthe.Schema

  @moduledoc """
  Functions supported by GraphQL in this application
  """

  import_types(RkBackendWeb.Schema.Types)

  input_object :user_details do
    field :email, non_null(:string)
    field :full_name, non_null(:string)
    field :password, non_null(:string)
    field :password_confirmation, non_null(:string)
  end

  input_object :user_update_details do
    field :id, non_null(:integer)
    field :email, :string
    field :full_name, :string
    field :password, :string
    field :password_confirmation, :string
  end

  input_object :user_update_role do
    field :id, non_null(:integer)
    field :role_id, non_null(:integer)
  end

  query do
    @desc "Get the current user"
    field :resolve_user, :user do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Logic.Auth.SignIn.resolve_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get a list of users"
    field :users, list_of(:user) do
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RkBackend.Repo.Auth.list_users/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get an user"
    field :user, :user do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RkBackend.Repo.Auth.get_user/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get a list of available roles"
    field :roles, list_of(:role) do
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RkBackend.Repo.Auth.list_roles/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end

  mutation do
    @desc "Sign In"
    field :sign_in, :string do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&RkBackend.Logic.Auth.SignIn.sign_in/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Sign Out"
    field :sign_out, :string do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Logic.Auth.SignIn.sign_out/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create an user"
    field :create_user, :user do
      arg(:user_details, non_null(:user_details))
      resolve(&RkBackend.Repo.Auth.store_user/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update an user"
    field :update_user, :user do
      arg(:user_update_details, non_null(:user_update_details))
      resolve(&RkBackend.Repo.Auth.update_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update user's role"
    field :update_users_role, :user do
      arg(:user_update_role, non_null(:user_update_role))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RkBackend.Repo.Auth.update_user/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create a role"
    field :create_role, :role do
      arg(:type, non_null(:string))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RkBackend.Repo.Auth.store_role/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end
end
