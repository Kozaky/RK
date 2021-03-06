defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.TopicQueriesTest do
  use RkBackendWeb.ConnCase

  alias RkBackend.Fixture

  setup do
    Fixture.create(:topic)
    :ok
  end

  describe "Queries" do
    test "get a topic success", %{conn: conn} do
      topic = Fixture.create(:topic)

      query = """
        query { topic(id: #{topic.id}) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["topic"]

      topic_id = Integer.to_string(topic.id)
      assert %{"id" => ^topic_id} = decode_response
    end

    test "get a topic not found", %{conn: conn} do
      query = """
        query { topic(id: -1) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end

    test "get a list of topics by id", %{conn: conn} do
      %{id: topic_id} = Fixture.create(:topic)

      query = """
        query { topics(page: 1, per_page: 1, filter: { id: #{topic_id} }) { metadata { totalResults }, topics { title }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["topics"]
      assert %{"metadata" => %{"totalResults" => 1}} = decode_response
      assert %{"topics" => [%{"title" => _}]} = decode_response
    end
  end

  test "get list of topics by title", %{conn: conn} do
    %{title: title} = Fixture.create(:topic)

    query = """
      query { topics(page: 1, per_page: 1, filter: { title: "#{title}" }) { metadata { totalResults }, topics { title }}}
    """

    res =
      conn
      |> post("/graphiql", %{"query" => query})

    decode_response = json_response(res, 200)["data"]["topics"]
    assert %{"topics" => [%{"title" => ^title} | _]} = decode_response
  end

  test "get list of topics by description", %{conn: conn} do
    %{description: description} = Fixture.create(:topic)

    query = """
      query { topics(page: 1, per_page: 1, filter: { description: "#{description}" }) { metadata { totalResults }, topics { description }}}
    """

    res =
      conn
      |> post("/graphiql", %{"query" => query})

    decode_response = json_response(res, 200)["data"]["topics"]
    assert %{"topics" => [%{"description" => ^description} | _]} = decode_response
  end

  describe "Mutations" do
    test "create a topic", %{conn: conn} do
      topic_details = %{
        title: "Title",
        description: "description",
        image: %Plug.Upload{
          content_type: "image/png",
          filename: "image1.png",
          path: "test/resources/image1.png"
        }
      }

      query = """
        mutation { createTopic(topicDetails: {
          title: "#{topic_details.title}",
          description: "#{topic_details.description}",
          image: "image"
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query, "image" => topic_details.image})

      decode_response = json_response(res, 200)["data"]["createTopic"]
      assert %{"id" => _} = decode_response
    end

    test "update a topic successful", %{conn: conn} do
      topic = Fixture.create(:topic)

      update_topic_details = %{
        id: topic.id,
        title: "Update"
      }

      query = """
        mutation { updateTopic(updateTopicDetails: {
          id: #{update_topic_details.id},
          title: "#{update_topic_details.title}"
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["updateTopic"]

      topic_id = Integer.to_string(update_topic_details.id)
      assert %{"id" => ^topic_id} = decode_response
    end

    test "update a topic not found", %{conn: conn} do
      query = """
        mutation { updateTopic(updateTopicDetails: {
          id: -1,
          title: "UPDATE"
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end

    test "delete a topic", %{conn: conn} do
      topic = Fixture.create(:topic)

      query = """
        mutation { deleteTopic(id: #{topic.id}) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["deleteTopic"]
      assert %{"id" => _} = decode_response
    end
  end
end
