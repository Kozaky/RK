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
end
