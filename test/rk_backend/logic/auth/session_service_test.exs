defmodule RkBackend.Logic.Auth.SessionServiceTest do
  use ExUnit.Case, async: true

  alias RkBackend.Logic.Auth.SessionService
  alias RkBackend.Repo.Auth.User
  alias RkBackend.Repo.Auth.Role

  @process "user8080"
  @user %User{
    id: 8080,
    role: %Role{type: "ADMIN"}
  }

  setup_all do
    {:ok, server_pid} = SessionService.start(@user, "demoToken")
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
      SessionService.update_role(pid, %Role{type: "ADMIN"})
      assert true = SessionService.has_any_role?(pid, ["ADMIN"])
    end

    test "assert user has_any_role multiple values" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %Role{type: "ADMIN"})
      assert true == SessionService.has_any_role?(pid, ["ADMIN", "USER", "CONSULTANT"])
    end

    test "assert user does not has_any_role" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %Role{type: "ADMIN"})
      assert false == SessionService.has_any_role?(pid, ["USER"])
    end

    test "assert role is updated" do
      {:ok, pid} = SessionService.lookup(@process)
      SessionService.update_role(pid, %Role{type: "CONSULTANT"})
      assert %SessionService{role: %Role{type: "CONSULTANT"}} = SessionService.get_state(pid)
    end
  end
end
