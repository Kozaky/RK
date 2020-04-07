defmodule RkBackend.Fixture do
  alias RkBackend.Repo
  alias RkBackend.Repo.Auth.Users
  alias RkBackend.Repo.Auth.Roles
  alias RkBackend.Repo.Complaint.Topics
  alias RkBackend.Repo.Auth.Schemas.User
  alias RkBackend.Repo.Complaint.Reklamas
  alias RkBackend.Repo.Complaint.Messages
  alias RkBackend.Repo.Complaint.Schemas.Topic

  @moduledoc """
  Module that centralize all fixture functions
  """

  def create(atom, args \\ %{})

  def create(:role, args) do
    %{
      type: "NEW_ROLE"
    }
    |> Map.merge(args)
    |> Roles.store_role()
    |> case do
      {:ok, role} -> role
    end
  end

  def create(:user, args) do
    unique_email = "email@email.com"

    %{
      full_name: "Full Name",
      email: unique_email,
      password: "password",
      password_confirmation: "password"
    }
    |> Map.merge(args)
    |> Users.store_user()
    |> case do
      {:ok, user} ->
        user

      {:error, %Ecto.Changeset{errors: [email: {"has already been taken", _}]}} ->
        Repo.get_by(User, email: unique_email)
    end
  end

  def create(:topic, args) do
    unique_title = "Topic Title"

    %{
      title: unique_title,
      description: "Description",
      image_name: "image",
      image: <<25, 07, 15>>
    }
    |> Map.merge(args)
    |> Topics.store_topic()
    |> case do
      {:ok, topic} ->
        topic

      {:error, %Ecto.Changeset{errors: [title: {"has already been taken", _}]}} ->
        Repo.get_by(Topic, title: unique_title)
    end
  end

  def create(:reklama, args) do
    user = create(:user)
    topic = create(:topic)

    %{
      title: "Reklama Title",
      content: "Content",
      user_id: user.id,
      topic_id: topic.id
    }
    |> Map.merge(args)
    |> Reklamas.store_reklama()
    |> case do
      {:ok, reklama} -> reklama
    end
  end

  def create(:message, args) do
    user = create(:user)
    reklama = create(:reklama)

    %{
      content: "Reklama message",
      user_id: user.id,
      reklama_id: reklama.id
    }
    |> Map.merge(args)
    |> Messages.store_message()
    |> case do
      {:ok, message} -> message
    end
  end
end
