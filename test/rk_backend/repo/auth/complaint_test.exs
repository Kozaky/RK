defmodule RkBackend.Repo.ComplaintTest do
  use RkBackend.DataCase

  alias RkBackend.Repo
  alias RkBackend.Repo.Auth
  alias RkBackend.Repo.Complaint
  alias RkBackend.Repo.Complaint.Reklama
  alias RkBackend.Repo.Complaint.Reklama.ReklamaImage
  alias RkBackend.Repo.Complaint.Topic
  alias RkBackend.Repo.Complaint.Message

  describe "reklamas" do
    @valid_args %{
      title: "Some Title",
      content: "Some content"
    }
    @update_args %{
      title: "Updated Title",
      content: "Some updated content"
    }
    @invalid_args %{
      title: nil,
      content: 1
    }

    def reklama_fixture(args \\ %{}) do
      user =
        Repo.get_by(Auth.User, email: "some email")
        |> case do
          nil ->
            user_fixture()

          user ->
            user
        end

      topic =
        Repo.get_by(Topic, title: "Some Title")
        |> case do
          nil ->
            topic_fixture()

          topic ->
            topic
        end

      valid_args =
        @valid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:topic_id, topic.id)

      args
      |> Enum.into(valid_args)
      |> Complaint.store_reklama()
      |> case do
        {:ok, reklama} ->
          reklama

        {:error, _changeset} = error ->
          error
      end
    end

    def user_fixture(args \\ %{}) do
      role = role_fixture()

      valid_args =
        %{
          email: "some email",
          full_name: "some full_name",
          password: "password",
          password_confirmation: "password"
        }
        |> Map.put(:role_id, role.id)

      {:ok, user} =
        args
        |> Enum.into(valid_args)
        |> Auth.store_user()

      user
    end

    def role_fixture(args \\ %{}) do
      {:ok, role} =
        args
        |> Enum.into(%{type: "USER"})
        |> Auth.store_role()

      role
    end

    test "store_reklama/0 simple" do
      reklama = reklama_fixture(@valid_args)

      assert %Reklama{} = reklama
    end

    test "store_reklama/0 with invalid args" do
      reklama = reklama_fixture(@invalid_args)

      assert {:error, changeset} = reklama
    end

    test "store_reklama/0 with images" do
      images = [
        %{
          image: %{
            filename: "image1",
            path: "test/resources/images/image1.png"
          }
        },
        %{
          image: %{
            filename: "image1",
            path: "test/resources/images/image1.png"
          }
        }
      ]

      reklama =
        @valid_args
        |> Map.put(:images, images)
        |> reklama_fixture()

      assert %Reklama{images: images} = reklama
      assert length(images) == 2
    end

    test "list_reklama/1 returns reklamas paginated" do
      reklama_fixture(@valid_args)

      metadata = %{
        page: 1,
        per_page: 10
      }

      assert [%Reklama{}] = Complaint.list_reklamas(metadata).reklamas
    end

    test "list_reklama/1 returns reklamas paginated and filtered" do
      reklama_fixture(@valid_args)

      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          title: "Some Title"
        }
      }

      assert [%Reklama{title: "Some Title"}] = Complaint.list_reklamas(metadata).reklamas
    end

    test "list_reklama/1 returns reklamas paginated and filtered not found" do
      reklama_fixture(@valid_args)

      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          title: "Not Found"
        }
      }

      assert [] = Complaint.list_reklamas(metadata).reklamas
    end

    test "list_reklama/1 returns reklamas paginated and ordered" do
      reklama_fixture(@valid_args)
      reklama_fixture(Map.put(@valid_args, :title, "A"))

      metadata = %{
        page: 1,
        per_page: 1,
        order: %{
          order_asc: "title"
        }
      }

      assert [%Reklama{title: "A"}] = Complaint.list_reklamas(metadata).reklamas
    end

    test "update_reklama/1 without associations" do
      reklama = reklama_fixture(@valid_args)
      update = Map.put(@update_args, :id, reklama.id)

      assert {:ok, %Reklama{title: "Updated Title"}} = Complaint.update_reklama(update)
    end

    test "update_reklama/1 with associations" do
      images = [
        %{
          image: %{
            filename: "image1",
            path: "test/resources/images/image1.png"
          }
        },
        %{
          image: %{
            filename: "image1",
            path: "test/resources/images/image1.png"
          }
        }
      ]

      reklama =
        @valid_args
        |> Map.put(:images, images)
        |> reklama_fixture()

      images_update = [
        %{
          image: %{
            id: Enum.at(reklama.images, 0).id,
            filename: "image_updated_1",
            path: "test/resources/images/image1.png"
          }
        },
        %{
          image: %{
            id: Enum.at(reklama.images, 1).id,
            filename: "image_updated_2",
            path: "test/resources/images/image1.png"
          }
        }
      ]

      update =
        @update_args
        |> Map.put(:id, reklama.id)
        |> Map.put(:images, images_update)

      assert {:ok, %Reklama{title: "Updated Title"}} = result = Complaint.update_reklama(update)

      assert {:ok, %Reklama{images: [%{name: "image_updated_1"}, %{name: "image_updated_2"}]}} =
               result
    end

    test "update_reklama/1 with empty associations" do
      images = [
        %{
          image: %{
            filename: "image1",
            path: "test/resources/images/image1.png"
          }
        },
        %{
          image: %{
            filename: "image1",
            path: "test/resources/images/image1.png"
          }
        }
      ]

      reklama =
        @valid_args
        |> Map.put(:images, images)
        |> reklama_fixture()

      images_update = []

      update =
        @update_args
        |> Map.put(:id, reklama.id)
        |> Map.put(:images, images_update)

      assert {:ok, %Reklama{title: "Updated Title"}} = result = Complaint.update_reklama(update)
      assert {:ok, %Reklama{images: []}} = result
      assert [] = Repo.all(ReklamaImage)
    end
  end

  describe "topics" do
    @valid_args %{
      title: "Some Title",
      description: "Some Description",
      image: %{
        filename: "image1",
        path: "test/resources/images/image1.png"
      }
    }
    @update_args %{
      title: "Updated Title",
      description: "Updated description"
    }
    @invalid_args %{
      title: 2,
      description: nil
    }

    def topic_fixture(args \\ %{}) do
      args
      |> Enum.into(@valid_args)
      |> Complaint.store_topic()
      |> case do
        {:ok, topic} ->
          topic

        {:error, _changeset} = error ->
          error
      end
    end

    test "store_topic/1 simple" do
      topic = topic_fixture(@valid_args)

      assert %Topic{} = topic
    end

    test "store_topic/1 with invalid args" do
      topic = topic_fixture(@invalid_args)

      assert {:error, changeset} = topic
    end

    test "update_topic/1 with valid args" do
      topic = topic_fixture(@valid_args)
      update = Map.put(@update_args, :id, topic.id)

      assert {:ok, %Topic{description: "Updated description"}} = Complaint.update_topic(update)
    end

    test "update_topic/1 with new  image" do
      topic = topic_fixture(@valid_args)

      update =
        Map.put(@update_args, :id, topic.id)
        |> Map.put(:image, %{
          filename: "imageUpdated",
          path: "test/resources/images/image1.png"
        })

      assert {:ok, %Topic{image_name: "imageUpdated"}} = Complaint.update_topic(update)
    end
  end

  describe "messages" do
    @valid_args %{
      content: "Some content"
    }
    @invalid_args %{
      content: 2
    }

    def message_fixture(args \\ %{}) do
      user =
        Repo.get_by(Auth.User, email: "some email")
        |> case do
          nil ->
            user_fixture()

          user ->
            user
        end

      reklama = reklama_fixture()

      valid_args =
        @valid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:reklama_id, reklama.id)

      args
      |> Enum.into(valid_args)
      |> Complaint.store_message()
      |> case do
        {:ok, topic} ->
          topic

        {:error, _changeset} = error ->
          error
      end
    end

    test "store_message/1 simple" do
      message = message_fixture(@valid_args)

      assert %Message{} = message
    end

    test "store_message/1 with invalid args" do
      message = message_fixture(@invalid_args)

      assert {:error, changeset} = message
    end
  end
end