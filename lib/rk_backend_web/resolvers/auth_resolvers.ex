defmodule RkBackendWeb.Schema.Resolvers.AuthResolvers do
  alias RkBackend.Repo
  alias RkBackend.Repo.Auth
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Logic.Auth.SignIn
  alias RkBackend.Utils

  require Logger

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
    case Auth.store_user(args.user_details) do
      {:ok, user} ->
        {:ok, user}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  def update_user(user_update, _info) do
    try do
      with user_update = %{} <- get_user_update(user_update),
           user = %User{} <- Repo.get(User, user_update.id),
           {:ok, user} <- Auth.update_user(user, user_update) do
        {:ok, user}
      else
        nil ->
          user_update = get_user_update(user_update)
          {:error, "ID: #{user_update.id} not found"}

        {:error, errors} ->
          errors = Utils.errors_to_string(errors)
          Logger.error(errors)
          {:error, errors}
      end
    rescue
      ArgumentError ->
        Logger.error("Invalid argument given")
        {:error, "Invalid argument given"}
    end
  end

  defp get_user_update(%{user_update_details: user_update}) do
    user_update
  end

  defp get_user_update(%{user_update_role: user_update}) do
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
