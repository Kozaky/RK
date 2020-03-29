defmodule RkBackend.UtilsTest do
  use RkBackend.DataCase

  alias RkBackend.Utils
  alias RkBackend.Repo.Auth.User

  describe "utils" do
    @invalid_args %{
      email: "some email",
      full_name: "some full_name",
      password: "pass",
      password_confirmation: "differentPass"
    }

    test "changeset_errors_to_string/1 returns a string of the changeset's errors" do
      changeset = User.changeset(%User{}, @invalid_args)
      errors = Utils.errors_to_string(changeset)
      assert is_bitstring(errors)
    end
  end
end
