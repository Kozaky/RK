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
  import_types(RkBackendWeb.Schema.Queries.AuthQueries.RoleQueries)
  import_types(RkBackendWeb.Schema.Queries.AuthQueries.UserQueries)
  import_types(RkBackendWeb.Schema.Queries.ComplaintQueries.ReklamaQueries)
  import_types(RkBackendWeb.Schema.Queries.ComplaintQueries.TopicQueries)
  import_types(RkBackendWeb.Schema.Queries.ComplaintQueries.MessageQueries)
  import_types(RkBackendWeb.Schema.Queries.ComplaintQueries.LocationQueries)

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
    import_fields(:user_queries)
    import_fields(:role_queries)
    import_fields(:reklama_queries)
    import_fields(:topic_queries)
    import_fields(:message_queries)
    import_fields(:location_queries)
  end

  mutation do
    import_fields(:user_mutations)
    import_fields(:role_mutations)
    import_fields(:reklama_mutations)
    import_fields(:topic_mutations)
    import_fields(:message_mutations)
  end

  @doc """
  Use when you had to use Absinthe's upload type.

  This method return a map compatible with Ecto's Schemas

  ## Examples

      iex> put_upload(%{image: %Upload{}}, file_bytes: :image, filename: :image_name)
      %{
        image_name: "Image Name",
        image: [bytes]
      }
  """
  def put_upload(%{} = args, [{:file_bytes, file_bytes_key}, {:filename, filename_key}]) do
    {upload, _} = Map.pop(args, file_bytes_key)

    args
    |> put_file(upload, file_bytes_key, filename_key)
  end

  defp put_file(args, %{} = upload, file_bytes_key, filename_key) do
    filename_value = upload.filename
    {:ok, file_bytes_value} = File.read(upload.path)

    args
    |> Map.put(file_bytes_key, file_bytes_value)
    |> Map.put(filename_key, filename_value)
  end

  defp put_file(args, _upload, _file_bytes_key, _filename_key) do
    args
  end

  def middleware(middleware, _field, _object) do
    Enum.map(middleware, &RkBackend.Middlewares.HandleErrors.add_error_handling/1)
  end
end
