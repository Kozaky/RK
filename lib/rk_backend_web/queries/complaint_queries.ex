defmodule RkBackendWeb.Schema.Queries.ComplaintQueries do
  use Absinthe.Schema.Notation

  @moduledoc """
  Module with queries and mutations for Complaint
  """

  object :complaint_queries do
    import_fields(:reklama_queries)
    import_fields(:topic_queries)
    import_fields(:message_queries)
  end

  object :complaint_mutations do
    import_fields(:reklama_mutations)
    import_fields(:topic_mutations)
    import_fields(:message_mutations)
  end
end
