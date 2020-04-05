defmodule RkBackendWeb.Schema.Resolvers.AuthResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.Users
  alias RkBackend.Repo.Auth.Roles
  alias RkBackend.Repo.Auth.Schemas.User
  alias RkBackend.Auth.SignIn
  alias RkBackend.Utils
  alias RkBackendWeb.Schema

  require Logger

  @moduledoc """
  Module with resolvers for Auth queries and mutations
  """

  def sign_in(%{email: email, password: password}, _info) do
    SignIn.sign_in(email, password)
  end

  def sign_out(_arg, %{context: %{user_id: user_id}}) do
    SignIn.sign_out(user_id)
  end

  def resolve_user(_arg, %{context: %{user_id: user_id}}) do
    SignIn.resolve_user(user_id)
  end

  def resolve_user(_args, _context), do: {:error, "Not Authenticated"}

  def list_users(_args, _info) do
    {:ok, Repo.all(User)}
  end

  def get_user(%{id: id} = _args, _info) do
    case Repo.get(User, id) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :not_found}
    end
  end

  def store_user(args, _info) do
    args.user_details
    |> Schema.put_upload(file_bytes: :avatar, filename: :avatar_name)
    |> Users.store_user()
    |> case do
      {:ok, user} ->
        {:ok, user}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def update_user(args, _info) do
    get_user_update_details(args)
    |> Schema.put_upload(file_bytes: :avatar, filename: :avatar_name)
    |> Users.update_user()
    |> case do
      {:ok, user} ->
        {:ok, user}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  defp get_user_update_details(%{user_update_details: user_update}) do
    user_update
  end

  defp get_user_update_details(%{user_update_role: user_update}) do
    user_update
  end

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
