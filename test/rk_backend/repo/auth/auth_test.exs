defmodule RkBackend.Repo.AuthTest do
  use RkBackend.DataCase

  alias RkBackend.Repo.Auth
  alias RkBackend.Repo.Auth.Role
  alias RkBackend.Repo.Auth.User

  describe "users" do
    @valid_args %{
      email: "some email",
      full_name: "some full_name",
      password: "password",
      password_confirmation: "password"
    }
    @update_args %{
      email: "some updated email",
      full_name: "some updated full_name",
      password: "password2",
      password_confirmation: "password2"
    }
    @invalid_args %{
      email: nil,
      full_name: nil,
      password: "password1",
      password_confirmation: "password2"
    }

    def user_fixture(args \\ %{}) do
      role = role_fixture()

      valid_args =
        @valid_args
        |> Map.put(:role_id, role.id)

      {:ok, user} =
        args
        |> Enum.into(valid_args)
        |> Auth.store_user()

      user
    end

    test "list_users/0 returns all users" do
      user_fixture(@valid_args)
      assert {:ok, [%User{}]} = Auth.list_users(nil, nil, nil)
    end

    test "store_user/1 with valid data creates a user" do
      role = role_fixture()

      valid_args =
        @valid_args
        |> Map.put(:role_id, role.id)

      assert {:ok, %User{} = user} = Auth.store_user(valid_args)
      assert user.email == "some email"
      assert user.full_name == "some full_name"
      assert user.password == "password"
      assert user.role_id == role.id
    end

    test "store_user/1 with invalid data returns error changeset" do
      role_fixture()

      assert {:error, %Ecto.Changeset{}} = Auth.store_user(@invalid_args)
    end

    test "store_user/3 successful" do
      role = role_fixture()

      valid_args =
        @valid_args
        |> Map.put(:role_id, role.id)

      args = %{user_details: valid_args}
      assert {:ok, user = %User{}} = Auth.store_user(nil, args, nil)
      assert user.role_id == role.id
      assert user.full_name == @valid_args.full_name
    end

    test "store_user/3 unsuccessful" do
      role_fixture()

      args = %{user_details: @invalid_args}
      assert {:error, changeset} = Auth.store_user(nil, args, nil)
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id).id == user.id
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Auth.update_user(user, @update_args)
      assert user.email == "some updated email"
      assert user.full_name == "some updated full_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_args)
    end

    test "update_user/2 successful" do
      user = user_fixture()

      update_args =
        @update_args
        |> Map.put(:id, user.id)

      assert {:ok, user = %User{}} = Auth.update_user(%{user_update_details: update_args}, nil)
      assert user.password == "password2"
    end

    test "update_user/2 with user not found" do
      update_args =
        @update_args
        |> Map.put(:id, -1)

      assert {:error, reason} = Auth.update_user(%{user_update_details: update_args}, nil)
      assert reason == "ID: -1 not found"
    end

    test "update_user/2 with bad update" do
      user = user_fixture()

      update_args =
        @invalid_args
        |> Map.put(:id, user.id)

      assert {:error, reason} = Auth.update_user(%{user_update_details: update_args}, nil)
      assert reason = "password_confirmation: does not match password\n"
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end

    test "find_user_by_email/1 successful" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.find_user_by_email(user.email)
    end

    test "find_user_by_email/1 unsuccessful" do
      assert {:error, "User not found"} = Auth.find_user_by_email("notFound@gmail.com")
    end
  end

  describe "roles" do
    @valid_args %{type: "USER"}
    @update_args %{type: "some updated type"}
    @invalid_args %{type: nil}

    def role_fixture(args \\ %{}) do
      {:ok, role} =
        args
        |> Enum.into(@valid_args)
        |> Auth.store_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role_fixture()
      assert {:ok, [%Role{} | tail]} = Auth.list_roles(nil, nil, nil)
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Auth.get_role!(role.id) == role
    end

    test "store_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Auth.store_role(@valid_args)
      assert role.type == "USER"
    end

    test "store_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.store_role(@invalid_args)
    end

    test "store_role/3 successful" do
      assert {:ok, %Role{} = role} = Auth.store_role(nil, @valid_args, nil)
      assert role.type == "USER"
    end

    test "store_role/3 unsuccessful" do
      assert {:error, _reason} = Auth.store_role(nil, @invalid_args, nil)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Auth.update_role(role, @update_args)
      assert role.type == "some updated type"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_role(role, @invalid_args)
      assert role == Auth.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Auth.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_role!(role.id) end
    end
  end
end
