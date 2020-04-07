defmodule RkBackendWeb.Schema.Resolvers.AuthResolvers.RoleResolvers do
  alias RkBackend.Repo
  alias RkBackend.Utils
  alias RkBackend.Repo.Auth.Roles
  alias RkBackend.Repo.Auth.Schemas.Role

  @moduledoc """
  Module with resolvers for Role queries and mutations
  """

  def list_roles(_args, _info) do
    {:ok, Repo.all(Role)}
  end

  def store_role(args, _info) do
    case Roles.store_role(args) do
      {:ok, role} ->
        {:ok, role}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def delete_role(%{id: id}, _info) do
    case Repo.get(Role, id) do
      %Role{} = role ->
        Repo.delete(role)

      nil ->
        {:error, :not_found}
    end
  end
end
