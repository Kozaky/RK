defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.TopicQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.ComplaintResolvers.TopicResolvers

  @moduledoc """
  Module with queries and mutations for Topic
  """

  object :topic_queries do
    @desc "Get a topic"
    field :topic, :topic do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&TopicResolvers.get_topic/2)
    end

    @desc "Get a list of topics"
    field :topics, list_of(:topic) do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&TopicResolvers.list_topics/2)
    end
  end

  object :topic_mutations do
    @desc "Create a topic"
    field :create_topic, :topic do
      arg(:topic_details, non_null(:topic_details))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&TopicResolvers.store_topic/2)
    end

    @desc "Update a topic"
    field :update_topic, :topic do
      arg(:update_topic_details, non_null(:update_topic_details))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&TopicResolvers.update_topic/2)
    end

    @desc "Delete a topic"
    field :delete_topic, :topic do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&TopicResolvers.delete_topic/2)
    end
  end
end
