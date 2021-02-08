defmodule RkBackend.Repo do
  import Ecto.Query, except: [preload: 2]
  use Ecto.Repo,
    otp_app: :rk_backend,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Returns a dynamic preload from absinthe inputs
  """
  def dynamically_preload(struct, args) do
    preload(struct, gen_preload(args))
  end

  @doc """
  Returns a dynamic preload list from absinthe inputs

  ## Examples

      iex> gen_preload(%{name: "name", association: %{ name: "name" }})
      [association: []]

      iex> gen_preload(%{name: "name"})
      []

      iex> gen_preload(%{name: "name", associations: [ %{ name: "name", role: %{ type: "admin" }} ]})
      [associations: [role: []]]
  """
  def gen_preload(%{} = args) do
    Enum.reduce(args, [], fn x, acc ->
      case x do
        {name, %{} = association} ->
          [{name, gen_preload(association)} | acc]

        {name, list} when is_list(list) ->
          associations = merge(name, list)
          [{name, associations} | acc]

        _no_association ->
          acc
      end
    end)
  end

  defp merge(name, list) when is_atom(name) and is_list(list) do
    Enum.reduce(list, [], fn x, acc ->
      [{name, gen_preload(x)} | acc]
    end)
    |> merge_list()
  end

  defp merge(tuple_1, tuple_2) when is_tuple(tuple_1) and is_tuple(tuple_2) do
    [tuple_1, tuple_2]
    |> merge_list()
  end

  defp merge_list(list) when is_list(list) do
    list
    |> Enum.flat_map(fn {_name, associations} -> associations end)
    |> Enum.reduce([], fn {name, associations}, acc ->
      Enum.find_index(acc, fn {k, _v} -> k == name end)
      |> case do
        nil ->
          [{name, associations} | acc]

        index ->
          merge_nested_list(name, associations, acc, index)
      end
    end)
  end

  defp merge_nested_list(_name, [], acc, _index) do
    acc
  end

  defp merge_nested_list(name, associations, acc, index) do
    List.replace_at(acc, index, {name, merge(Enum.at(acc, index), {name, associations})})
  end

  def pageable_select(entity, key, args, filter_fn) do
    {page, args} = Map.pop(args, :page)
    {per_page, args} = Map.pop(args, :per_page)

    query =
      args
      |> Enum.reduce(entity, fn
        {:order, %{order_asc: field}}, query ->
          field = String.to_existing_atom(field)
          query |> order_by(asc: ^field)

        {:order, %{order_desc: field}}, query ->
          field = String.to_existing_atom(field)
          query |> order_by(desc: ^field)

        {:filter, filter}, query ->
          filter_fn.(query, filter)
      end)

    entities =
      query
      |> limit(^per_page)
      |> offset((^page - 1) * ^per_page)
      |> all()

    total_results = query |> count_total_results
    total_pages = count_total_pages(total_results, per_page)

    %{
      key => entities,
      metadata: %{
        page: page,
        total_pages: total_pages,
        total_results: total_results
      }
    }
  end

  defp count_total_results(query) do
    aggregate(query, :count, :id)
  end

  defp count_total_pages(total_results, per_page) do
    total_pages = ceil(total_results / per_page)

    if total_pages > 0, do: total_pages, else: 1
  end
end
