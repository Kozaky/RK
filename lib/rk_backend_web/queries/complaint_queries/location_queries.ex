defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.LocationQueries do
  use Absinthe.Schema.Notation
  alias RkBackendWeb.Schema.Resolvers.ComplaintResolvers.LocationResolvers

  @moduledoc """
  Module with queries and mutations for Location
  """

  object :location_queries do
    @desc "Get a list of locations"
    field :locations, list_of(:location) do
      middleware(RkBackend.Middlewares.Auth)
      resolve(&LocationResolvers.list_locations/2)
    end
  end
end
