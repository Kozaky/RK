defmodule RkBackend.Repo.Complaint do
  @moduledoc """
  Provide functions to manage Complaint entities.
  """

  import Ecto.Query, warn: false

  alias RkBackend.Repo
  alias RkBackend.Repo.Complaint.Reklama
  alias RkBackend.Repo.Complaint.Topic
  alias RkBackend.Repo.Complaint.Message

  require Logger

  @doc """
  Stores a reklama.

  ## Examples

      iex> store_reklama(%{field: value})
      {:ok, %Reklama{}}

      iex> store_reklama(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_reklama(args) do
    args = put_images(args)

    %Reklama{}
    |> Reklama.changeset(args)
    |> Repo.insert()
  end

  defp put_images(%{images: images} = args) when is_list(images) do
    images =
      Enum.map(args.images, fn image_detail ->
        {id, _result} = Map.pop(image_detail, :id)
        name = image_detail.image.filename
        {:ok, image_binary} = File.read(image_detail.image.path)

        %{id: id, name: name, image: image_binary}
      end)

    args
    |> Map.put(:images, images)
  end

  defp put_images(args) do
    args
  end

  @doc """
  Stores a reklama.

  ## Examples

      iex> store_reklama(_, %{field: value}, _)
      {:ok, %Reklama{}}

      iex> store_reklama(%{field: bad_value})
      {:error, :string}

  """
  def store_reklama(_root, args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.reklama_details, :user_id, user_id)

    case store_reklama(args) do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = RkBackend.Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Deletes a reklama.

  ## Examples

      iex> delete_reklama(_, %{id: value}, _)
      {:ok, %Reklama{}}

      iex> delete_reklama(%{field: bad_value})
      {:error, :string}

  """
  def delete_reklama(_root, %{id: id}, _info) do
    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        Repo.delete(reklama)

      nil ->
        {:error, "Reklama not found"}
    end
  end

  @doc """
  Returns a list of reklamas.

  ## Examples

      iex> list_reklamas()
      {:ok, [%Reklama{}, ...]}

  """
  def list_reklamas(_root, args, _info) do
    case validate_args(args) do
      {:ok, args} ->
        reklamas = list_reklamas(args)
        {:ok, reklamas}

      {:error, msg} ->
        {:error, msg}
    end
  end

  defp validate_args(args) do
    errors =
      []
      |> validate_page(args)

    if length(errors) == 0, do: {:ok, args}, else: {:error, errors}
  end

  defp validate_page(errors, %{page: page}) when page > 0 do
    errors
  end

  defp validate_page(errors, _args) do
    ["Page: must be bigger than 0" | errors]
  end

  @doc """
  Returns a list of reklamas.

  ## Examples

      iex> list_reklamas()
      [%Reklama{}, ...]

  """
  def list_reklamas(args) do
    {page, args} = Map.pop(args, :page)
    {per_page, args} = Map.pop(args, :per_page)

    query =
      args
      |> Enum.reduce(Reklama, fn
        {:order, %{order_asc: field}}, query ->
          field = String.to_existing_atom(field)
          query |> order_by(asc: ^field)

        {:order, %{order_desc: field}}, query ->
          field = String.to_existing_atom(field)
          query |> order_by(desc: ^field)

        {:filter, filter}, query ->
          query |> filter_with(filter)
      end)

    reklamas =
      query
      |> limit(^per_page)
      |> offset((^page - 1) * ^per_page)
      |> Repo.all()

    total_results = query |> count_total_results
    total_pages = count_total_pages(total_results, per_page)

    %{
      reklamas: reklamas,
      metadata: %{
        page: page,
        total_pages: total_pages,
        total_results: total_results
      }
    }
  end

  defp filter_with(query, filter) do
    Enum.reduce(filter, query, fn
      {:id, id}, query ->
        from q in query, where: q.id == ^id

      {:title, title}, query ->
        from q in query, where: ilike(q.title, ^"%#{title}%")

      {:topic_id, topic_id}, query ->
        from q in query,
          join: t in assoc(q, :topic),
          where: t.id == ^topic_id

      {:inserted_before, date}, query ->
        from q in query, where: q.inserted_at <= ^date

      {:inserted_after, date}, query ->
        from q in query, where: q.inserted_at >= ^date
    end)
  end

  defp count_total_results(query) do
    Repo.aggregate(query, :count, :id)
  end

  defp count_total_pages(total_results, per_page) do
    total_pages = ceil(total_results / per_page)

    if total_pages > 0, do: total_pages, else: 1
  end

  @doc """
  Get a single reklama.

  ## Examples

      iex> get_reklama!(123)
      {:ok, %Reklama{}}

      iex> get_reklama!(456)
      {:error, "ID: id not found"}

  """
  def get_reklama(_root, %{id: id} = _args, _info) do
    case Repo.get(Reklama, id) do
      {:ok, reklama} ->
        {:ok, reklama}

      nil ->
        {:error, "This reklama could not be found"}
    end
  end

  @doc """
  Updates a reklama

  ## Examples

      iex> update_reklama(%{field: value})
      {:ok, %Reklama{}}

      iex> update_reklama(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reklama(args) do
    {id, args} = Map.pop(args, :id)
    args = put_images(args)

    case Repo.get(Reklama, id) do
      %Reklama{} = reklama ->
        reklama
        |> Repo.dynamically_preload(args)
        |> Reklama.update_changeset(args)
        |> Repo.update()

      nil ->
        {:error, "Reklama not found"}
    end
  end

  @doc """
  Updates a reklama

  ## Examples

      iex> update_reklama(_, %{field: value}, _)
      {:ok, %Reklama{}}

      iex> update_reklama(%{field: bad_value})
      {:error, :string}

  """
  def update_reklama(_root, args, _info) do
    case update_reklama(args.update_reklama_details) do
      {:ok, reklama} ->
        {:ok, reklama}

      {:error, errors} ->
        errors = RkBackend.Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Stores a topic.

  ## Examples

      iex> store_topic(%{field: value})
      {:ok, %Topic{}}

      iex> store_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_topic(args) do
    args = put_image(args)

    %Topic{}
    |> Topic.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Stores a topic.

  ## Examples

      iex> store_topic(_, %{field: value}, _)
      {:ok, %Topic{}}

      iex> store_topic(%{field: bad_value})
      {:error, :string}

  """
  def store_topic(_root, args, _info) do
    case store_topic(args.topic_details) do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = RkBackend.Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Updates a topic

  ## Examples

      iex> update_topic(%{field: value})
      {:ok, %Topic{}}

      iex> update_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(args) do
    {id, args} = Map.pop(args, :id)
    args = put_image(args)

    case Repo.get(Topic, id) do
      %Topic{} = topic ->
        topic
        |> Repo.dynamically_preload(args)
        |> Topic.update_changeset(args)
        |> Repo.update()

      nil ->
        {:error, "Topic not found"}
    end
  end

  defp put_image(%{image: image} = args) do
    image_name = image.filename
    {:ok, image_binary} = File.read(image.path)

    args
    |> Map.put(:image, image_binary)
    |> Map.put(:image_name, image_name)
  end

  defp put_image(args) do
    args
  end

  @doc """
  Updates a topic

  ## Examples

      iex> update_topic(_, %{field: value}, _)
      {:ok, %Topic{}}

      iex> update_topic(%{field: bad_value})
      {:error, :string}

  """
  def update_topic(_root, args, _info) do
    case update_topic(args.update_topic_details) do
      {:ok, topic} ->
        {:ok, topic}

      {:error, errors} ->
        errors = RkBackend.Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(_, %{id: value}, _)
      {:ok, %Topic{}}

      iex> delete_topic(%{field: bad_value})
      {:error, :string}

  """
  def delete_topic(_root, %{id: id}, _info) do
    case Repo.get(Topic, id) do
      %Topic{} = topic ->
        Repo.delete(topic)

      nil ->
        {:error, "Topic not found"}
    end
  end

  @doc """
  Stores a message.

  ## Examples

      iex> store_message(%{field: value})
      {:ok, %Message{}}

      iex> store_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def store_message(args) do
    %Message{}
    |> Message.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Stores a message.

  ## Examples

      iex> store_message(_, %{field: value}, _)
      {:ok, %Message{}}

      iex> store_message(%{field: bad_value})
      {:error, :string}

  """
  def store_message(_root, args, %{context: %{user_id: user_id}}) do
    args = Map.put(args.message_details, :user_id, user_id)

    case store_message(args) do
      {:ok, message} ->
        {:ok, message}

      {:error, errors} ->
        errors = RkBackend.Utils.errors_to_string(errors)
        Logger.error(errors)
        {:error, errors}
    end
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(_, %{id: value}, _)
      {:ok, %Message{}}

      iex> delete_message(%{field: bad_value})
      {:error, :string}

  """
  def delete_message(_root, %{id: id}, _info) do
    case Repo.get(Message, id) do
      %Message{} = message ->
        Repo.delete(message)

      nil ->
        {:error, "Message not found"}
    end
  end
end
