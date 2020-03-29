defmodule RkBackend.Repo do
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
end
