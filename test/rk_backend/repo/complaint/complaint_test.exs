defmodule RkBackend.Repo.ComplaintTest do
  use RkBackend.DataCase

  alias RkBackend.Repo
  alias RkBackend.Fixture
  alias RkBackend.Repo.Complaint.Reklamas
  alias RkBackend.Repo.Complaint.Topics
  alias RkBackend.Repo.Complaint.Messages
  alias RkBackend.Repo.Complaint.Schemas.Reklama
  alias RkBackend.Repo.Complaint.Schemas.Reklama.ReklamaImage
  alias RkBackend.Repo.Complaint.Schemas.Topic
  alias RkBackend.Repo.Complaint.Schemas.Message

  describe "reklamas" do
    @valid_args %{
      user_id: 1,
      title: "Some Title",
      content: "Some content"
    }
    @update_args %{
      current_user: 1,
      title: "Updated Title",
      content: "Some updated content"
    }
    @invalid_args %{
      title: nil,
      content: 1
    }

    setup do
      Fixture.create(:reklama)
      :ok
    end

    test "store_reklama/0 simple" do
      user = Fixture.create(:user, %{email: "newEmail@email.com"})
      topic = Fixture.create(:topic, %{title: "New Title"})

      reklama =
        @valid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:topic_id, topic.id)
        |> Map.put(:location_id, 1)
        |> Reklamas.store_reklama()

      assert {:ok, %Reklama{}} = reklama
    end

    test "store_reklama/0 with invalid args" do
      user = Fixture.create(:user, %{email: "newEmail@email.com"})
      topic = Fixture.create(:topic, %{title: "New Title"})

      reklama =
        @invalid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:topic_id, topic.id)
        |> Map.put(:location_id, 1)
        |> Reklamas.store_reklama()

      assert {:error, _changeset} = reklama
    end

    test "store_reklama/0 with images" do
      user = Fixture.create(:user, %{email: "newEmail@email.com"})
      topic = Fixture.create(:topic, %{title: "New Title"})

      images = [
        %{
          image: <<0, 255, 42>>,
          name: "image"
        },
        %{
          image: <<0, 255, 42>>,
          name: "image"
        }
      ]

      reklama =
        @valid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:topic_id, topic.id)
        |> Map.put(:location_id, 1)
        |> Map.put(:images, images)
        |> Reklamas.store_reklama()

      assert {:ok, %Reklama{images: [%{} | _]}} = reklama
      assert length(images) == 2
    end

    test "list_reklama/1 returns reklamas paginated" do
      metadata = %{
        page: 1,
        per_page: 10
      }

      assert [%Reklama{}] = Reklamas.list_reklamas(metadata).reklamas
    end

    test "list_reklama/1 returns reklamas paginated and filtered" do
      Fixture.create(:reklama, %{title: "Some Title"})

      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          title: "Some Title"
        }
      }

      assert [%Reklama{title: "Some Title"}] = Reklamas.list_reklamas(metadata).reklamas
    end

    test "list_reklama/1 returns reklamas paginated and filtered not found" do
      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          title: "Not Found"
        }
      }

      assert [] = Reklamas.list_reklamas(metadata).reklamas
    end

    test "list_reklama/1 returns reklamas paginated and ordered" do
      Fixture.create(:reklama, %{title: "A"})

      metadata = %{
        page: 1,
        per_page: 1,
        order: %{
          order_asc: "title"
        }
      }

      assert [%Reklama{title: "A"}] = Reklamas.list_reklamas(metadata).reklamas
    end

    test "update_reklama/1 without associations" do
      reklama = Fixture.create(:reklama, @valid_args)
      update = Map.put(@update_args, :id, reklama.id)

      assert {:ok, %Reklama{title: "Updated Title"}} = Reklamas.update_reklama(update)
    end

    test "update_reklama/1 with associations" do
      images = [
        %{
          image: <<0, 255, 42>>,
          name: "image"
        },
        %{
          image: <<0, 255, 42>>,
          name: "image"
        }
      ]

      reklama = Fixture.create(:reklama, Map.put(@valid_args, :images, images))

      images_update = [
        %{
          id: Enum.at(reklama.images, 0).id,
          image: <<0, 255, 42>>,
          name: "image_updated_1"
        },
        %{
          id: Enum.at(reklama.images, 1).id,
          image: <<0, 255, 42>>,
          name: "image_updated_2"
        }
      ]

      update =
        @update_args
        |> Map.put(:id, reklama.id)
        |> Map.put(:images, images_update)

      assert {:ok, %Reklama{title: "Updated Title"}} = result = Reklamas.update_reklama(update)

      assert {:ok, %Reklama{images: [%{name: "image_updated_1"}, %{name: "image_updated_2"}]}} =
               result
    end

    test "update_reklama/1 with empty associations" do
      reklama = Fixture.create(:reklama, @valid_args)

      images_update = []

      update =
        @update_args
        |> Map.put(:id, reklama.id)
        |> Map.put(:images, images_update)

      assert {:ok, %Reklama{title: "Updated Title"}} = result = Reklamas.update_reklama(update)
      assert {:ok, %Reklama{images: []}} = result
      assert [] = Repo.all(ReklamaImage)
    end
  end

  describe "topics" do
    @valid_args %{
      title: "Some Title",
      description: "Some Description",
      image: <<0, 255, 42>>,
      image_name: "image1"
    }
    @update_args %{
      title: "Updated Title",
      description: "Updated description"
    }
    @invalid_args %{
      title: 2,
      description: nil
    }

    test "store_topic/1 simple" do
      topic = Topics.store_topic(@valid_args)

      assert {:ok, %Topic{}} = topic
    end

    test "store_topic/1 with invalid args" do
      topic = Topics.store_topic(@invalid_args)

      assert {:error, _changeset} = topic
    end

    test "update_topic/1 with valid args" do
      topic = Fixture.create(:topic, @valid_args)
      update = Map.put(@update_args, :id, topic.id)

      assert {:ok, %Topic{description: "Updated description"}} = Topics.update_topic(update)
    end

    test "update_topic/1 with new  image" do
      topic = Fixture.create(:topic, @valid_args)

      update =
        Map.put(@update_args, :id, topic.id)
        |> Map.put(:image, <<0, 255, 42>>)
        |> Map.put(:image_name, "imageUpdated")

      assert {:ok, %Topic{image_name: "imageUpdated"}} = Topics.update_topic(update)
    end

    test "list_topic/1 returns topics paginated" do
      metadata = %{
        page: 1,
        per_page: 10
      }

      assert [%Topic{}] = Topics.list_topics(metadata).topics
    end

    test "list_topic/1 returns topics paginated and filtered by id" do
      %{id: topic_id} = Fixture.create(:topic)

      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          id: topic_id
        }
      }

      assert [%Topic{id: ^topic_id}] = Topics.list_topics(metadata).topics
    end

    test "list_topic/1 returns topics paginated and filtered by title" do
      Fixture.create(:topic, %{title: "Some Title"})

      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          title: "Some Title"
        }
      }

      assert [%Topic{title: "Some Title"}] = Topics.list_topics(metadata).topics
    end

    test "list_topic/1 returns topics paginated and filtered by description" do
      Fixture.create(:topic, %{description: "Some Description"})

      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          description: "Some Description"
        }
      }

      assert [%Topic{description: "Some Description"}] = Topics.list_topics(metadata).topics
    end

    test "list_topic/1 returns topics paginated and filtered not found" do
      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          title: "Not Found"
        }
      }

      assert [] = Topics.list_topics(metadata).topics
    end

    test "list_topic/1 returns topics paginated and ordered" do
      Fixture.create(:topic, %{title: "A"})

      metadata = %{
        page: 1,
        per_page: 1,
        order: %{
          order_asc: "title"
        }
      }

      assert [%Topic{title: "A"}] = Topics.list_topics(metadata).topics
    end
  end

  describe "messages" do
    @valid_args %{
      content: "Some content"
    }
    @invalid_args %{
      content: 2
    }

    test "store_message/1 simple" do
      user = Fixture.create(:user, %{email: "newEmail.email.com"})
      reklama = Fixture.create(:reklama)

      message =
        @valid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:reklama_id, reklama.id)
        |> Messages.store_message()

      assert {:ok, %Message{}} = message
    end

    test "store_message/1 with invalid args" do
      user = Fixture.create(:user, %{email: "newEmail.email.com"})
      reklama = Fixture.create(:reklama)

      message =
        @invalid_args
        |> Map.put(:user_id, user.id)
        |> Map.put(:reklama_id, reklama.id)
        |> Messages.store_message()

      assert {:error, _changeset} = message
    end
  end
end
