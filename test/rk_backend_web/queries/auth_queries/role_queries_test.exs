defmodule RkBackendWeb.Schema.Queries.AuthQueries.RoleQueriesTest do
  use RkBackendWeb.ConnCase

  alias RkBackend.Fixture

  describe "Queries" do
    test "get list of roles", %{conn: conn} do
      query = """
        query { roles { id, type }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["roles"]
      assert [%{"type" => "USER"}, %{"type" => "ADMIN"}] = decode_response
    end
  end

  describe "Mutations" do
    test "create a role success", %{conn: conn} do
      type = "NEW_TYPE"

      query = """
      mutation { createRole(type: "#{type}") { id, type }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["createRole"]
      assert %{"type" => "NEW_TYPE"} = decode_response
    end

    test "create a role error", %{conn: conn} do
      type = 2

      query = """
      mutation { createRole(type: #{type}) { id, type }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)
      assert %{"errors" => _} = decode_response
    end

    test "delete a role success", %{conn: conn} do
      role = Fixture.create(:role, %{type: "NEW"})

      query = """
      mutation { deleteRole(id: #{role.id}) { id, type }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["deleteRole"]
      assert %{"type" => "NEW"} = decode_response
    end

    test "delete a role not found", %{conn: conn} do
      query = """
      mutation { deleteRole(id: -1) { id, type }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end
  end
end
