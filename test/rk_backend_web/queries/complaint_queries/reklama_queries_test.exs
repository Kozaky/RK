defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.ReklamaQueriesTest do
  use RkBackendWeb.ConnCase

  alias RkBackend.Fixture

  setup do
    Fixture.create(:reklama)
    :ok
  end

  describe "Queries" do
    test "get a reklama success", %{conn: conn} do
      %{id: reklama_id} = Fixture.create(:reklama)

      query = """
        query { reklama(id: #{reklama_id}) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklama"]

      reklama_id = Integer.to_string(reklama_id)
      assert %{"id" => ^reklama_id} = decode_response
    end

    test "get a reklama not found", %{conn: conn} do
      query = """
        query { reklama(id: -1) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end

    test "get list of reklamas", %{conn: conn} do
      %{id: reklama_id} = Fixture.create(:reklama)

      query = """
        query { reklamas(page: 1, per_page: #{reklama_id}) { reklamas { title }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklamas"]["reklamas"]
      assert [%{"title" => _} | _] = decode_response
    end

    test "get list of reklamas by id", %{conn: conn} do
      %{id: reklama_id} = Fixture.create(:reklama)

      query = """
        query { reklamas(page: 1, per_page: 1, filter: { id: #{reklama_id} }) { metadata { totalResults }, reklamas { title }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklamas"]
      assert %{"metadata" => %{"totalResults" => 1}} = decode_response
      assert %{"reklamas" => [%{"title" => _}]} = decode_response
    end

    test "get list of reklamas by title", %{conn: conn} do
      %{title: title} = Fixture.create(:reklama)

      query = """
        query { reklamas(page: 1, per_page: 1, filter: { title: "#{title}" }) { metadata { totalResults }, reklamas { title }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklamas"]
      assert %{"reklamas" => [%{"title" => ^title} | _]} = decode_response
    end

    test "get list of reklamas by topic_id", %{conn: conn} do
      %{topic_id: topic_id} = Fixture.create(:reklama)

      query = """
        query { reklamas(page: 1, per_page: 1, filter: { topicId: #{topic_id} }) { metadata { totalResults }, reklamas { topic { id } }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklamas"]

      topic_id = Integer.to_string(topic_id)
      assert %{"reklamas" => [%{"topic" => %{"id" => ^topic_id}} | _]} = decode_response
    end

    test "get list of reklamas by inserted_after", %{conn: conn} do
      datetime = ~U[2000-01-01 00:00:00.000Z]

      query = """
        query { reklamas(page: 1, per_page: 1, filter: { inserted_after: "#{datetime}" }) { metadata { totalResults }, reklamas { topic { id } }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklamas"]["reklamas"]
      assert [%{"topic" => %{"id" => _}}] = decode_response
    end

    test "get list of reklamas by inserted_before", %{conn: conn} do
      datetime = ~U[2000-01-01 00:00:00.000Z]

      query = """
        query { reklamas(page: 1, per_page: 1, filter: { inserted_before: "#{datetime}" }) { metadata { totalResults }, reklamas { topic { id } }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["reklamas"]["reklamas"]
      assert [] = decode_response
    end
  end

  describe "Mutations" do
    test "create reklama", %{conn: conn} do
      topic = Fixture.create(:topic)

      reklama_details = %{
        title: "Title",
        content: "Content",
        topic_id: topic.id
      }

      query = """
        mutation { createReklama(reklamaDetails: {
          title: "#{reklama_details.title}",
          content: "#{reklama_details.content}",
          topicId: #{reklama_details.topic_id}
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["createReklama"]
      assert %{"id" => _} = decode_response
    end

    test "update reklama success", %{conn: conn} do
      reklama = Fixture.create(:reklama)

      update_reklama_details = %{
        id: reklama.id,
        title: "Updated"
      }

      query = """
        mutation { updateReklama(updateReklamaDetails: {
          id: #{update_reklama_details.id},
          title: "#{update_reklama_details.title}"
        }) { title }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["updateReklama"]
      assert %{"title" => "Updated"} = decode_response
    end

    test "update reklama not found", %{conn: conn} do
      update_reklama_details = %{
        id: -1,
        title: "Updated"
      }

      query = """
        mutation { updateReklama(updateReklamaDetails: {
          id: #{update_reklama_details.id},
          title: "#{update_reklama_details.title}"
        }) { title }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end

    test "delete reklama success", %{conn: conn} do
      reklama = Fixture.create(:reklama)

      query = """
        mutation { deleteReklama(id: #{reklama.id}) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["deleteReklama"]

      reklama_id = Integer.to_string(reklama.id)
      assert %{"id" => ^reklama_id} = decode_response
    end

    test "delete reklama not found", %{conn: conn} do
      query = """
        mutation { deleteReklama(id: -1) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end
  end
end
