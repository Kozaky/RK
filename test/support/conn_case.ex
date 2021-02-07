defmodule RkBackendWeb.ConnCase do
  alias RkBackend.Auth.SignIn

  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias RkBackendWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint RkBackendWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RkBackend.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RkBackend.Repo, {:shared, self()})
    end

    {:ok, %{token: token}} = SignIn.sign_in("admin@rk.com", "adminRK")

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
      |> Plug.Conn.put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end
end
