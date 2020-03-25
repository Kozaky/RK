defmodule RkBackendWeb.Schema do
  use Absinthe.Schema

  @moduledoc """
  Functions supported by GraphQL in this application
  """

  import_types(Absinthe.Plug.Types)
  import_types(RkBackendWeb.Schema.Types)
  import_types(Absinthe.Type.Custom)

  input_object :sort_order do
    field :order_asc, :string
    field :order_desc, :string
  end

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

  input_object :reklama_details do
    field :title, non_null(:string)
    field :content, non_null(:string)
    field :images, list_of(:reklama_image_details)
    field :topic_id, non_null(:integer)
  end

  input_object :update_reklama_details do
    field :id, non_null(:integer)
    field :title, :string
    field :content, :string
    field :images, list_of(:update_reklama_image_details)
    field :topic_id, :integer
  end

  input_object :update_reklama_image_details do
    field :id, :integer
    field :name, :string
    field :image, :upload
  end

  input_object :reklama_filter do
    field :id, :integer
    field :title, :string
    field :topic_id, :integer
    field :inserted_before, :naive_datetime
    field :inserted_after, :naive_datetime
  end

  input_object :reklama_image_details do
    field :image, non_null(:upload)
  end

  input_object :topic_details do
    field :title, non_null(:string)
    field :description, non_null(:string)
    field :image, non_null(:upload)
  end

  input_object :message_details do
    field :content, non_null(:string)
    field :reklama_id, non_null(:integer)
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

    @desc "Get a reklama"
    field :reklama, :reklama do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Repo.Complaint.get_reklama/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get a list of reklamas"
    field :reklamas, :paginated_reklama do
      arg(:filter, :reklama_filter)
      arg(:order, :sort_order)
      arg(:page, non_null(:integer))
      arg(:per_page, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Repo.Complaint.list_reklamas/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end

  mutation do
    @desc "Sign In"
    field :sign_in, :logged_in_user do
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
      middleware(RkBackend.Middlewares.Auth)
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

    @desc "Create a reklama"
    field :create_reklama, :reklama do
      arg(:reklama_details, non_null(:reklama_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Repo.Complaint.store_reklama/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update a reklama"
    field :update_reklama, :reklama do
      arg(:update_reklama_details, non_null(:update_reklama_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Repo.Complaint.update_reklama/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create a topic"
    field :create_topic, :topic do
      arg(:topic_details, non_null(:topic_details))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&RkBackend.Repo.Complaint.store_topic/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create a message"
    field :create_message, :message do
      arg(:message_details, non_null(:message_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&RkBackend.Repo.Complaint.store_message/3)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end
end
