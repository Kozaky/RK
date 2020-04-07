defmodule RkBackendWeb.Schema.Types.AuthTypes do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  @moduledoc """
  Auth Types supported by GraphQL in this application
  """

  object :role do
    field :id, :id
    field :type, :string
  end

  interface :user_entity do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :avatar_name, :string
    field :avatar, :base64

    field :role, :role do
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
    field :avatar_name, :string
    field :avatar, :base64
    field :role, :role, resolve: dataloader(RkBackend)

    interface(:user_entity)
  end

  @desc "User currectly logged in"
  object :logged_in_user do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :avatar_name, :string
    field :avatar, :base64
    field :role, :role, resolve: dataloader(RkBackend)
    field :token, :string

    interface(:user_entity)
  end

  object :paginated_users do
    field :users, list_of(:user)
    field :metadata, :page_info
  end

  input_object :user_details do
    field :email, non_null(:string)
    field :full_name, non_null(:string)
    field :password, non_null(:string)
    field :password_confirmation, non_null(:string)
    field :avatar, :upload
  end

  input_object :user_update_details do
    field :id, non_null(:integer)
    field :email, :string
    field :full_name, :string
    field :password, :string
    field :password_confirmation, :string
    field :avatar, :upload
  end

  input_object :user_filter do
    field :id, :integer
    field :email, :string
    field :full_name, :string
    field :role, :string
    field :inserted_before, :naive_datetime
    field :inserted_after, :naive_datetime
  end

  input_object :user_update_role_details do
    field :id, non_null(:integer)
    field :role_id, non_null(:integer)
  end
end
