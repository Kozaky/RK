defmodule RkBackendWeb.Schema.Queries.AuthQueries do
  use Absinthe.Schema.Notation

  @moduledoc """
  Module with queries and mutations for Auth
  """

  object :auth_queries do
    import_fields(:user_queries)
    import_fields(:role_queries)
  end

  object :auth_mutations do
    import_fields(:user_mutations)
    import_fields(:role_mutations)
  end
end
