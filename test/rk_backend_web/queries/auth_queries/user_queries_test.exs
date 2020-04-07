defmodule RkBackendWeb.Schema.Queries.AuthQueries.UserQueriesTest do
  use RkBackendWeb.ConnCase

  alias RkBackend.Fixture

  describe "Queries" do
    test "resolve user", %{conn: conn} do
      query = """
        query { resolveUser { fullName }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["resolveUser"]
      assert %{"fullName" => "admin"} = decode_response
    end

    test "get list of users", %{conn: conn} do
      query = """
        query { users(page: 1, per_page: 1) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [%{"fullName" => _}] = decode_response
    end

    test "get list of users by id", %{conn: conn} do
      query = """
        query { users(page: 1, per_page: 1, filter: { id: 1 }) { users { id }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [%{"id" => "1"}] = decode_response
    end

    test "get list of users by fullName", %{conn: conn} do
      query = """
        query { users(page: 1, per_page: 1, filter: { fullName: "admin" }) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [%{"fullName" => "admin"}] = decode_response
    end

    test "get list of users by fullName not found", %{conn: conn} do
      query = """
        query { users(page: 1, per_page: 1, filter: { fullName: "not found" }) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [] = decode_response
    end

    test "get list of users by email", %{conn: conn} do
      query = """
        query { users(page: 1, per_page: 1, filter: { email: "@" }) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [%{"fullName" => _}] = decode_response
    end

    test "get list of users by role", %{conn: conn} do
      query = """
        query { users(page: 1, per_page: 1, filter: { role: "ADMIN" }) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [%{"fullName" => _}] = decode_response
    end

    test "get list of users by date after", %{conn: conn} do
      datetime = ~U[2000-01-01 00:00:00.000Z]

      query = """
        query { users(page: 1, per_page: 1, filter: { inserted_after: "#{datetime}" }) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [%{"fullName" => _}] = decode_response
    end

    test "get list of users by date before", %{conn: conn} do
      datetime = ~U[2000-01-01 00:00:00.000Z]

      query = """
        query { users(page: 1, per_page: 1, filter: { inserted_before: "#{datetime}" }) { users { fullName }}}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["users"]["users"]
      assert [] = decode_response
    end

    test "get an user success", %{conn: conn} do
      user = Fixture.create(:user)

      query = """
        query { user(id: #{user.id}) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["user"]
      assert %{"id" => _} = decode_response
    end

    test "get an user not found", %{conn: conn} do
      query = """
        query { user(id: -1) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => "not_found"}] = decode_response
    end
  end

  describe "Mutations" do
    test "sign in", %{conn: conn} do
      query = """
        mutation { signIn(email: "admin@rk.com", password: "adminRK") { fullName }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["signIn"]
      assert %{"fullName" => "admin"} = decode_response
    end

    test "sign out", %{conn: conn} do
      query = """
        mutation { signOut }
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["signOut"]
      assert "signed_out" = decode_response
    end

    test "create user success", %{conn: conn} do
      user_details = %{
        full_name: "test",
        email: "test@test.com",
        password: "test",
        password_confirmation: "test"
      }

      query = """
        mutation { createUser(userDetails: {
          fullName: "#{user_details.full_name}",
          email: "#{user_details.email}",
          password: "#{user_details.password}",
          passwordConfirmation: "#{user_details.password_confirmation}"
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["createUser"]
      assert %{"id" => _} = decode_response
    end

    test "create user error", %{conn: conn} do
      user_details = %{
        full_name: "test",
        email: "test@test.com",
        password: "test2",
        password_confirmation: "test"
      }

      query = """
        mutation { createUser(userDetails: {
          fullName: "#{user_details.full_name}",
          email: "#{user_details.email}",
          password: "#{user_details.password}",
          passwordConfirmation: "#{user_details.password_confirmation}"
        }) { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["errors"]
      assert [%{"message" => _}] = decode_response
    end

    test "update user", %{conn: conn} do
      user = Fixture.create(:user)

      user_update_details = %{
        id: user.id,
        full_name: "testUpdated"
      }

      query = """
        mutation { updateUser(userUpdateDetails: {
          id: #{user_update_details.id},
          fullName: "#{user_update_details.full_name}"
        }) { fullName }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["updateUser"]
      assert %{"fullName" => "testUpdated"} = decode_response
    end

    test "update user role", %{conn: conn} do
      user = Fixture.create(:user)

      user_update_role_details = %{
        id: user.id,
        role_id: 2
      }

      query = """
        mutation { updateUsersRole(userUpdateRoleDetails: {
          id: #{user_update_role_details.id},
          roleId: #{user_update_role_details.role_id}
        }) { role { id } }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["updateUsersRole"]["role"]
      assert %{"id" => "2"} = decode_response
    end

    test "delete current logged in user", %{conn: conn} do
      query = """
        mutation { deleteMyUser { id }}
      """

      res =
        conn
        |> post("/graphiql", %{"query" => query})

      decode_response = json_response(res, 200)["data"]["deleteMyUser"]
      assert %{"id" => _} = decode_response
    end
  end
end
