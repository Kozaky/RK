defmodule RkBackendWeb.Schema.Resolvers.AuthResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Auth
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Logic.Auth.SignIn
  alias RkBackend.Utils
  alias RkBackendWeb.Schema

  require Logger

  @moduledoc """
  Module with resolvers for Auth queries and mutations
  """

  def sign_in(%{email: email, password: password}, _info) do
    SignIn.sign_in(email, password)
  end

  def sign_in(_args, _info) do
    {:error, "Arguments error"}
  end

  def sign_out(_arg, %{context: %{user_id: user_id}}) do
    SignIn.sign_out(user_id)
  end

  def resolve_user(_arg, %{context: %{user_id: user_id}}) do
    SignIn.resolve_user(user_id)
  end

  def resolve_user(_args, _context), do: {:error, "Not Authenticated"}

  def list_users(_args, _info) do
    try do
      {:ok, Repo.all(User)}
    rescue
      Ecto.NoResultsError ->
        {:error, :rescued}
    end
  end

  def get_user(%{id: id} = _args, _info) do
    try do
      {:ok, Auth.get_user!(id)}
    rescue
      Ecto.NoResultsError ->
        {:error, "ID: #{id} not found"}
    end
  end

  def store_user(args, _info) do
    args.user_details
    |> Schema.put_upload(file_bytes: :avatar, filename: :avatar_name)
    |> Auth.store_user()
    |> case do
      {:ok, user} ->
        {:ok, user}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def update_user(args, _info) do
    get_user_update_details(args)
    |> Schema.put_upload(file_bytes: :avatar, filename: :avatar_name)
    |> Auth.update_user()
    |> case do
      {:ok, user} ->
        {:ok, user}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
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
    try do
      {:ok, Repo.all(Role)}
    rescue
      Ecto.NoResultsError ->
        {:error, :rescued}
    end
  end

  def store_role(args, _info) do
    case Auth.store_role(args) do
      {:ok, changeset} ->
        {:ok, changeset}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end
end
