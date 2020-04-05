defmodule RkBackendWeb.Schema.Resolvers.ComplaintResolvers.ReklamaResolvers do
  alias RkBackend.Repo
  alias RkBackend.Utils
  alias RkBackendWeb.Schema
  alias RkBackend.Repo.Complaint.Reklamas
  alias RkBackend.Repo.Complaint.Schemas.Reklama

  @moduledoc """
  Module with resolvers for Reklama queries and mutations
  """

  def store_reklama(args, %{context: %{user_id: user_id}}) do
    args.reklama_details
    |> Map.put(:user_id, user_id)
    |> put_images()
    |> Reklamas.store_reklama()
    |> case do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  def delete_reklama(%{id: id}, _info) do
    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        Repo.delete(reklama)

      nil ->
        {:error, :not_found}
    end
  end

  def list_reklamas(args, _info) do
    reklamas = Reklamas.list_reklamas(args)
    {:ok, reklamas}
  end

  def get_reklama(%{id: id} = _args, _info) do
    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        {:ok, reklama}

      nil ->
        {:error, :not_found}
    end
  end

  def update_reklama(args, _info) do
    args.update_reklama_details
    |> put_images()
    |> Reklamas.update_reklama()
    |> case do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = Utils.errors_to_string(errors)
        {:error, errors}
    end
  end

  defp put_images(%{images: images} = args) do
    args
    |> Map.put(
      :images,
      Enum.map(images, &Schema.put_upload(&1, file_bytes: :image, filename: :name))
    )
  end

  defp put_images(args) do
    args
  end
end