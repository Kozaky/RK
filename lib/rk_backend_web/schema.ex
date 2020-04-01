defmodule RkBackendWeb.Schema do
  use Absinthe.Schema

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(RkBackend, RkBackend.rk_data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  @moduledoc """
  Endpoints supported by GraphQL in this application
  """

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(RkBackendWeb.Schema.Types.AuthTypes)
  import_types(RkBackendWeb.Schema.Types.ComplaintTypes)
  import_types(RkBackendWeb.Schema.Queries.AuthQueries)
  import_types(RkBackendWeb.Schema.Queries.ComplaintQueries)

  scalar :base64 do
    description("Base 64")
    serialize(&Base.encode64(&1))
  end

  object :page_info do
    field :page, :integer
    field :total_pages, :integer
    field :total_results, :integer
  end

  input_object :sort_order do
    field :order_asc, :string
    field :order_desc, :string
  end

  query do
    import_fields(:auth_queries)
    import_fields(:complaint_queries)
  end

  mutation do
    import_fields(:auth_mutations)
    import_fields(:complaint_mutations)
  end
end
