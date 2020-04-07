defmodule RkBackendWeb.Schema.Queries.ComplaintQueries.MessageQueriesTest do
  use RkBackendWeb.ConnCase

  alias RkBackend.Fixture

  describe "Queries" do
  end

  describe "Mutations" do
    test "create message", %{conn: conn} do
      reklama = Fixture.create(:reklama)

      message_details = %{
        content: "Content",
        reklama_id: reklama.id
      }

      query = """
        mutation { createMessage(messageDetails: {
          content: "#{message_details.content}",
          reklamaId: #{message_details.reklama_id}
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["createMessage"]
      assert %{"id" => _} = decode_response
    end

    test "delete message", %{conn: conn} do
      message = Fixture.create(:message)

      query = """
        mutation { deleteMessage(id: #{message.id}) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["deleteMessage"]
      assert %{"id" => _} = decode_response
    end
  end
end
