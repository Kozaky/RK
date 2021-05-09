defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers.LocationResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint.Schemas.Location

  @moduledoc """
  Module with resolvers for Location queries and mutations
  """
  def list_locations(_args, _info) do
    locations = Repo.all(Location)
    {:ok, locations}
  end
end
