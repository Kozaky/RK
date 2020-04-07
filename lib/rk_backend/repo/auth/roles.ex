defmodule RkBackend.Repo.Auth.Roles do
  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.Schemas.Role

  @moduledoc """
  Provide functions to manage Roles.
  """

  @doc """
  Stores a role.

  ## Examples

      iex> store_role(%{field: value})
      {:ok, %Role{}}

      iex> store_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_role(args) do
    %Role{}
    |> Role.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(args) do
    {id, args} = Map.pop(args, :id)

    case Repo.get(Role, id) do
      %Role{} = role ->
        role
        |> Repo.dynamically_preload(args)
        |> Role.changeset(args)
        |> Repo.update()

      nil ->
        {:error, :not_found}
    end
  end
end
