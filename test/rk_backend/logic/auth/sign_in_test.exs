defmodule RkBackend.Logic.Auth.SignInTest do
  use RkBackend.DataCase

  alias RkBackend.Logic.Auth.SignIn
  alias RkBackend.Repo.Auth

  describe "SignIn" do
    @valid_args_role %{type: "USER"}

    @valid_args_user %{
      email: "some email",
      full_name: "some full_name",
      password: "password",
      password_confirmation: "password"
    }

    def role_fixture(args \\ %{}) do
      {:ok, role} =
        args
        |> Enum.into(@valid_args_role)
        |> Auth.store_role()

      role
    end

    def user_fixture(args \\ %{}) do
      role = role_fixture()

      valid_args =
        @valid_args_user
        |> Map.put(:role_id, role.id)

      {:ok, user} =
        args
        |> Enum.into(valid_args)
        |> Auth.store_user()

      user
    end

    test "sign_in/2 successful" do
      user = user_fixture()

      assert {:ok, _token} = SignIn.sign_in(%{email: user.email, password: user.password}, %{})
    end

    test "sign_in/2 unsuccessful" do
      assert {:error, _token} = SignIn.sign_in(%{email: "mail", password: "pass"}, %{})
    end

    test "resolve_user/2 successful" do
      user = user_fixture()

      assert {:ok, _token} = SignIn.sign_in(%{email: user.email, password: user.password}, %{})
      assert {:ok, %Auth.User{}} = SignIn.resolve_user(nil, %{context: %{user_id: user.id}})
    end

    test "resolve_user/2 unsuccessful" do
      assert {:error, "Not Authenticated"} = SignIn.resolve_user(nil, nil)
    end

    test "sign_out/2 successful" do
      user = user_fixture()

      assert {:ok, _token} = SignIn.sign_in(%{email: user.email, password: user.password}, %{})
      assert {:ok, "Session Deleted"} = SignIn.sign_out(nil, %{context: %{user_id: user.id}})
    end

    test "sign_out/2 unsuccessful" do
      user = user_fixture()

      assert {:ok, _token} = SignIn.sign_in(%{email: user.email, password: user.password}, %{})
      assert {:error, _reason} = SignIn.sign_out(nil, %{context: %{user_id: -1}})
    end

    test "is_valid_token unsuccessful" do
      assert {:error, _reason} = SignIn.is_valid_token("notAToken")
    end
  end
end
