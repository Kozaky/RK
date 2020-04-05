defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.MessageQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.ComplaintResolvers.MessageResolvers

  @moduledoc """
  Module with queries and mutations for Message
  """

  object :message_queries do
  end

  object :message_mutations do
    @desc "Create a message"
    field :create_message, :message do
      arg(:message_details, non_null(:message_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&MessageResolvers.store_message/2)
    end

    @desc "Delete a message"
    field :delete_message, :message do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&MessageResolvers.delete_message/2)
    end
  end
end
