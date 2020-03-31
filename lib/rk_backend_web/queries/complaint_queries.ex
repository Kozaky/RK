defmodule RkBackendWeb.Schema.Queries.ComplaintQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.ComplaintResolvers

  object :complaint_queries do
    @desc "Get a reklama"
    field :reklama, :reklama do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.get_reklama/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Get a list of reklamas"
    field :reklamas, :paginated_reklama do
      arg(:filter, :reklama_filter)
      arg(:order, :sort_order)
      arg(:page, non_null(:integer))
      arg(:per_page, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.list_reklamas/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end

  object :complaint_mutations do
    @desc "Create a reklama"
    field :create_reklama, :reklama do
      arg(:reklama_details, non_null(:reklama_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.store_reklama/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update a reklama"
    field :update_reklama, :reklama do
      arg(:update_reklama_details, non_null(:update_reklama_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.update_reklama/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Delete a reklama"
    field :delete_reklama, :reklama do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.delete_reklama/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create a topic"
    field :create_topic, :topic do
      arg(:topic_details, non_null(:topic_details))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&ComplaintResolvers.store_topic/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Update a topic"
    field :update_topic, :topic do
      arg(:update_topic_details, non_null(:update_topic_details))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&ComplaintResolvers.update_topic/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Delete a topic"
    field :delete_topic, :topic do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth, ["ADMIN"])
      resolve(&ComplaintResolvers.delete_topic/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Create a message"
    field :create_message, :message do
      arg(:message_details, non_null(:message_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.store_message/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end

    @desc "Delete a message"
    field :delete_message, :message do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ComplaintResolvers.delete_message/2)
      middleware(RkBackend.Middlewares.HandleErrors)
    end
  end
end
