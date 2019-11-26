defmodule RkBackend.Logic.Auth.SessionServiceTest do
  use ExUnit.Case

  alias RkBackend.Logic.Auth.SessionService
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Repo.Auth.Role
  alias RkBackend.Repo.Auth

  @process "user8080"
  @user %User{
    id: 8080
  }

  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{type: "ADMIN"})
      |> Auth.store_role()

    role
  end

  setup_all do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RkBackend.Repo)
    # Setting the shared mode must be done only after checkout
    Ecto.Adapters.SQL.Sandbox.mode(RkBackend.Repo, {:shared, self()})

    state = %{@user | role: role_fixture()}
    {:ok, server_pid} = SessionService.start(state, "demoToken")
    {:ok, server: server_pid}
  end

  describe "SessionService" do
    test "assert lookup finds results" do
      assert {:ok, _} = SessionService.lookup(@process)
    end

    test "assert lookup without results" do
      assert {:error, :not_found} = SessionService.lookup("user1")
    end

    test "assert user has_any_role" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %{type: "ADMIN"})
      assert true = SessionService.has_any_role?(pid, ["ADMIN"])
    end

    test "assert user has_any_role multiple values" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %{type: "CONSULTANT"})
      assert true == SessionService.has_any_role?(pid, ["ADMIN", "USER", "CONSULTANT"])
    end

    test "assert user does not has_any_role" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %{type: "ADMIN"})
      assert false == SessionService.has_any_role?(pid, ["USER"])
    end

    test "assert role is updated" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %{type: "CONSULTANT"})

      assert %SessionService{user: %User{role: %Role{type: "CONSULTANT"}}} =
               SessionService.get_state(pid)
    end
  end
end
