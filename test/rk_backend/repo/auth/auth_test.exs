defmodule RkBackend.Repo.AuthTest do
  use RkBackend.DataCase

  alias RkBackend.Repo
  alias RkBackend.Fixture
  alias RkBackend.Repo.Auth.Roles
  alias RkBackend.Repo.Auth.Users
  alias RkBackend.Repo.Auth.Schemas.Role
  alias RkBackend.Repo.Auth.Schemas.User

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

    setup do
      Fixture.create(:user)
      :ok
    end

    test "store_user/1 with valid data creates a user" do
      role = Repo.get_by(Role, type: "USER")

      valid_args =
        @valid_args
        |> Map.put(:role_id, role.id)

      assert {:ok, %User{} = user} = Users.store_user(valid_args)
      assert user.email == "some email"
      assert user.full_name == "some full_name"
      assert user.password == "password"
      assert user.role_id == role.id
    end

    test "store_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.store_user(@invalid_args)
    end

    test "store_user/3 successful" do
      role = Repo.get_by(Role, type: "USER")

      valid_args =
        @valid_args
        |> Map.put(:role_id, role.id)

      assert {:ok, user = %User{}} = Users.store_user(valid_args)
      assert user.role_id == role.id
      assert user.full_name == @valid_args.full_name
    end

    test "store_user/3 unsuccessful" do
      args = %{user_details: @invalid_args}
      assert {:error, _changeset} = Users.store_user(args)
    end

    test "get_user/1 returns the user with given id" do
      user = Fixture.create(:user, @valid_args)
      assert Repo.get(User, user.id).id == user.id
    end

    test "list_users/1 returns users paginated" do
      metadata = %{
        page: 1,
        per_page: 10
      }

      assert [%User{} | _] = Users.list_users(metadata).users
    end

    test "list_users/1 returns users paginated and filtered" do
      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          full_name: "some full_name",
          email: "new_email@email.com"
        }
      }

      Fixture.create(:user, %{full_name: "some full_name", email: "new_email@email.com"})

      assert [%User{full_name: "some full_name"}] = Users.list_users(metadata).users
    end

    test "list_users/1 returns users paginated and filtered not found" do
      metadata = %{
        page: 1,
        per_page: 10,
        filter: %{
          full_name: "Not Found"
        }
      }

      assert [] = Users.list_users(metadata).users
    end

    test "list_users/1 returns users paginated and ordered" do
      another_user_args =
        @valid_args
        |> Map.put(:full_name, "A")
        |> Map.put(:email, "another@email.com")

      Fixture.create(:user, another_user_args)

      metadata = %{
        page: 1,
        per_page: 1,
        order: %{
          order_asc: "full_name"
        }
      }

      assert [%User{full_name: "A"}] = Users.list_users(metadata).users
    end

    test "update_user/2 with valid data updates the user" do
      user = Fixture.create(:user, @valid_args)

      update_args =
        @update_args
        |> Map.put(:id, user.id)

      assert {:ok, %User{} = user} = Users.update_user(update_args)
      assert user.email == "some updated email"
      assert user.full_name == "some updated full_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = Fixture.create(:user, @valid_args)

      invalid_args =
        @invalid_args
        |> Map.put(:id, user.id)

      assert {:error, %Ecto.Changeset{}} = Users.update_user(invalid_args)
    end

    test "update_user/2 successful" do
      user = Fixture.create(:user, @valid_args)

      update_args =
        @update_args
        |> Map.put(:id, user.id)

      assert {:ok, user = %User{}} = Users.update_user(update_args)
      assert user.password == "password2"
    end

    test "update_user/2 with avatar" do
      user = Fixture.create(:user, @valid_args)

      update_args =
        @update_args
        |> Map.put(:id, user.id)
        |> Map.put(:avatar_name, "avatar_name")
        |> Map.put(:avatar, <<25, 07, 15>>)

      assert {:ok, user = %User{}} = Users.update_user(update_args)
      assert user.avatar_name == "avatar_name"
      assert user.avatar == <<25, 07, 15>>
    end

    test "update_user/2 with bad update" do
      user = Fixture.create(:user, @valid_args)

      update_args =
        @invalid_args
        |> Map.put(:id, user.id)

      assert {:error, %Ecto.Changeset{}} = Users.update_user(update_args)
    end

    test "delete_user/1 deletes the user" do
      user = Fixture.create(:user, @valid_args)
      assert {:ok, %User{}} = Repo.delete(user)
      assert Repo.get(User, user.id) == nil
    end

    test "find_user_by_email/1 successful" do
      user = Fixture.create(:user, @valid_args)
      assert {:ok, %User{}} = Users.find_user_by_email(user.email)
    end

    test "find_user_by_email/1 unsuccessful" do
      assert {:error, :not_found} = Users.find_user_by_email("notFound@gmail.com")
    end
  end

  describe "roles" do
    @valid_args %{type: "NEW_ROLE"}
    @update_args %{type: "some updated type"}
    @invalid_args %{type: nil}

    test "get_role!/1 returns the role with given id" do
      role = Repo.get_by(Role, type: "USER")
      assert Repo.get(Role, role.id) == role
    end

    test "store_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Roles.store_role(@valid_args)
      assert role.type == "NEW_ROLE"
    end

    test "store_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Roles.store_role(@invalid_args)
    end

    test "store_role/3 successful" do
      assert {:ok, %Role{} = role} = Roles.store_role(@valid_args)
      assert role.type == "NEW_ROLE"
    end

    test "store_role/3 unsuccessful" do
      assert {:error, _reason} = Roles.store_role(@invalid_args)
    end

    test "update_role/2 with valid data updates the role" do
      role = Repo.get_by(Role, type: "USER")

      update_args =
        @update_args
        |> Map.put(:id, role.id)

      assert {:ok, %Role{} = role} = Roles.update_role(update_args)
      assert role.type == "some updated type"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = Repo.get_by(Role, type: "USER")

      invalid_args =
        @invalid_args
        |> Map.put(:id, role.id)

      assert {:error, %Ecto.Changeset{}} = Roles.update_role(invalid_args)
    end
  end
end
