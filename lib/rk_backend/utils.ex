defmodule RkBackend.Utils do
  @moduledoc """
  Utils
  """

  alias Ecto.Changeset

  require Logger

  @doc """
  return a string representing the changeset's errors
  """
  def errors_to_string(%Changeset{} = changeset) do
    try do
      Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.reduce("", fn {k, v}, acc ->
        joined_errors = Enum.join(v, " - ")
        "#{acc}#{k}: #{joined_errors}\n"
      end)
    rescue
      error ->
        Logger.error("Error: #{inspect(error)}")
        "Unexpected error"
    end
  end

  def errors_to_string(errors) when is_bitstring(errors) do
    errors
  end

  def errors_to_string(_errors) do
    "Unexpected error"
  end
end
