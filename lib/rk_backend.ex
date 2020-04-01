defmodule RkBackend do
  @moduledoc """
  RkBackend keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def rk_data() do
    Dataloader.Ecto.new(RkBackend.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
