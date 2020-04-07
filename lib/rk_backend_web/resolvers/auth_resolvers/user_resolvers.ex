defmodule RkBackendWeb.Schema.Resolvers.AuthResolvers.UserResolvers do
  alias RkBackend.Repo
  alias RkBackend.Utils
  alias RkBackendWeb.Schema
  alias RkBackend.Auth.SignIn
  alias RkBackend.Repo.Auth.Users
  alias RkBackend.Repo.Auth.Schemas.User

  @moduledoc """
  Module with resolvers for User queries and mutations
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

  def list_users(args, _info) do
    users = Users.list_users(args)
    {:ok, users}
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

  defp get_user_update_details(%{user_update_role_details: user_update}) do
    user_update
  end

  def delete_my_user(_arg, %{context: %{user_id: user_id}}) do
    case Repo.get(User, user_id) do
      %User{} = user ->
        Repo.delete(user)

      nil ->
        {:error, :not_found}
    end
  end
end
