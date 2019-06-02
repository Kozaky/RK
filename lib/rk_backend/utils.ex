defmodule RkBackend.Utils do
  @moduledoc """
  Utils
  """

  alias Ecto.Changeset

  @doc """
  return a string representing the changeset's errors
  """
  def changeset_errors_to_string(%Changeset{} = changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, " - ")
      "#{acc}#{k}: #{joined_errors}\n"
    end)
  end
end
