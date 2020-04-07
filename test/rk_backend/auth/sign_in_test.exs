defmodule RkBackend.Auth.SignInTest do
  use RkBackend.DataCase

  alias RkBackend.Fixture
  alias RkBackend.Auth.SignIn
  alias RkBackend.Repo.Auth.Schemas.User

  describe "SignIn" do
    test "sign_in/2 successful" do
      user = Fixture.create(:user)
      assert {:ok, _token} = SignIn.sign_in(user.email, user.password)
    end

    test "sign_in/2 unsuccessful" do
      assert {:error, _token} = SignIn.sign_in("mail", "pass")
    end

    test "resolve_user/2 successful" do
      user = Fixture.create(:user)

      assert {:ok, _token} = SignIn.sign_in(user.email, user.password)
      assert {:ok, %User{}} = SignIn.resolve_user(user.id)
    end

    test "sign_out/2 successful" do
      user = Fixture.create(:user)

      assert {:ok, _token} = SignIn.sign_in(user.email, user.password)
      assert {:ok, :signed_out} = SignIn.sign_out(user.id)
    end

    test "sign_out/2 unsuccessful" do
      user = Fixture.create(:user)

      assert {:ok, _token} = SignIn.sign_in(user.email, user.password)
      assert {:error, _reason} = SignIn.sign_out(-1)
    end

    test "is_valid_token unsuccessful" do
      assert {:error, _reason} = SignIn.is_valid_token("notAToken")
    end
  end
end
