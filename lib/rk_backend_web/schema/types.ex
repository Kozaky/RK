defmodule RkBackendWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: RkBackend.Repo

  @moduledoc """
  Types supported by GraphQL in this application
  """

  scalar :base64 do
    description("Base 64")
    serialize(&Base.encode64(&1))
  end

  @doc """
  Page metadata
  """
  object :page_info do
    field :page, :integer
    field :total_pages, :integer
    field :total_results, :integer
  end

  object :role do
    field :id, :id
    field :type, :string
  end

  interface :user_entity do
    field :id, :id
    field :email, :string
    field :full_name, :string

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
    field :role, :role, resolve: assoc(:role)

    interface(:user_entity)
  end

  @desc "User currectly logged in"
  object :logged_in_user do
    field :id, :id
    field :email, :string
    field :full_name, :string
    field :role, :role, resolve: assoc(:role)
    field :token, :string

    interface(:user_entity)
  end

  object :reklama do
    field :id, :id
    field :title, :string
    field :content, :string
    field :inserted_at, :datetime
    field :user, :user, resolve: assoc(:user)
    field :topic, :topic, resolve: assoc(:topic)
    field :messages, list_of(:message), resolve: assoc(:messages)
    field :images, list_of(:image), resolve: assoc(:images)
  end

  object :paginated_reklama do
    field :reklamas, list_of(:reklama)
    field :metadata, :page_info
  end

  object :image do
    field :id, :id
    field :name, :string
    field :image, :base64
  end

  object :topic do
    field :id, :id
    field :title, :string
    field :description, :string
    field :image_name, :string
    field :image, :base64
  end

  object :message do
    field :id, :id
    field :content, :string
    field :inserted_at, :datetime
    field :user, :user, resolve: assoc(:user)
    field :reklama, :reklama, resolve: assoc(:reklama)
  end
end
