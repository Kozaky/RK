defmodule RkBackend.Logic.AuthTest do
  use RkBackend.DataCase

  alias RkBackend.Logic.Auth.SignIn
  alias RkBackend.Repo.Auth

  @salt "salt"
  @secret "secret"

  describe "SignIn" do
    @valid_attrs %{
      email: "some email",
      full_name: "some full_name",
      password: "password",
      password_confirmation: "password",
      role_id: 1
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
    end

    @valid_attrs %{
      token: "some token"
    }

    def token_fixture(attrs \\ %{}) do
      user = user_fixture()

      token_attrs =
        @valid_attrs
        |> Map.put(:user_id, user.id)

      {:ok, token} =
        token_attrs
        |> Enum.into(attrs)
        |> Auth.create_token()

      token
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

      assert {:ok, %Auth.User{}} = SignIn.resolve_user(nil, %{context: %{user_id: user.id}})
    end

    test "resolve_user/2 unsuccessful" do
      assert {:error, "Not Authenticated"} = SignIn.resolve_user(nil, nil)
    end

    test "sign_out/2 successful" do
      token = token_fixture()

      assert {:ok, "Session Deleted"} =
               SignIn.sign_out(nil, %{context: %{user_id: token.user_id}})
    end

    test "sign_out/2 unsuccessful" do
      assert {:error, _reason} = SignIn.sign_out(nil, %{context: %{user_id: -1}})
    end

    test "is_valid_token successful" do
      token_value = Phoenix.Token.sign(@secret, @salt, 1)
      assert {:ok, 1} = SignIn.is_valid_token(token_value)
    end

    test "is_valid_token unsuccessful" do
      assert {:error, _reason} = SignIn.is_valid_token("notAToken")
    end
  end
end
