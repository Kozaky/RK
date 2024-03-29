defmodule RkBackendWeb.Schema.Types.ComplaintTypes do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  @moduledoc """
  Complaint Types supported by GraphQL in this application
  """

  object :reklama do
    field :id, :id
    field :title, :string
    field :content, :string
    field :inserted_at, :datetime
    field :user, :user, resolve: dataloader(RkBackend)
    field :topic, :topic, resolve: dataloader(RkBackend)
    field :messages, list_of(:message), resolve: dataloader(RkBackend)
    field :images, list_of(:image), resolve: dataloader(RkBackend)
    field :location, :location, resolve: dataloader(RkBackend)
  end

  object :paginated_reklamas do
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

  object :paginated_topics do
    field :topics, list_of(:topic)
    field :metadata, :page_info
  end

  object :message do
    field :id, :id
    field :content, :string
    field :inserted_at, :datetime
    field :user, :user, resolve: dataloader(RkBackend)
    field :reklama, :reklama, resolve: dataloader(RkBackend)
  end

  object :location do
    field :id, :id
    field :name, :string
  end

  input_object :reklama_details do
    field :title, non_null(:string)
    field :content, non_null(:string)
    field :images, list_of(:reklama_image_details)
    field :location_id, non_null(:integer)
  end

  input_object :update_reklama_details do
    field :id, non_null(:integer)
    field :title, :string
    field :content, :string
    field :images, list_of(:update_reklama_image_details)
    field :topic_id, :integer
    field :location_id, :integer
  end

  input_object :reklama_filter do
    field :id, :integer
    field :title, :string
    field :topic_id, :integer
    field :current_user, :boolean
    field :inserted_before, :naive_datetime
    field :inserted_after, :naive_datetime
    field :location_id, :integer
  end

  input_object :update_reklama_image_details do
    field :id, :integer
    field :image, :upload
  end

  input_object :reklama_image_details do
    field :image, non_null(:upload)
  end

  input_object :topic_details do
    field :title, non_null(:string)
    field :description, non_null(:string)
    field :image, non_null(:upload)
  end

  input_object :topic_filter do
    field :id, :integer
    field :title, :string
    field :description, :string
  end

  input_object :update_topic_details do
    field :id, non_null(:integer)
    field :title, :string
    field :description, :string
    field :image, :upload
  end

  input_object :message_details do
    field :content, non_null(:string)
    field :reklama_id, non_null(:integer)
  end
end
