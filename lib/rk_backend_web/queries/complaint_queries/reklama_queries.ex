defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.ReklamaQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.ComplaintResolvers.ReklamaResolvers

  @moduledoc """
  Module with queries and mutations for Reklama
  """

  object :reklama_queries do
    @desc "Get a reklama"
    field :reklama, :reklama do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ReklamaResolvers.get_reklama/2)
    end

    @desc "Get a list of reklamas"
    field :reklamas, :paginated_reklamas do
      arg(:filter, :reklama_filter)
      arg(:order, :sort_order)
      arg(:page, non_null(:integer))
      arg(:per_page, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ReklamaResolvers.list_reklamas/2)
    end
  end

  object :reklama_mutations do
    @desc "Create a reklama"
    field :create_reklama, :reklama do
      arg(:reklama_details, non_null(:reklama_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ReklamaResolvers.store_reklama/2)
    end

    @desc "Update a reklama"
    field :update_reklama, :reklama do
      arg(:update_reklama_details, non_null(:update_reklama_details))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ReklamaResolvers.update_reklama/2)
    end

    @desc "Delete a reklama"
    field :delete_reklama, :reklama do
      arg(:id, non_null(:integer))
      middleware(RkBackend.Middlewares.Auth)
      resolve(&ReklamaResolvers.delete_reklama/2)
    end
  end
end
