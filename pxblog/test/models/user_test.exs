defmodule Pxblog.UserTest do
  use Pxblog.ModelCase

  alias Pxblog.User

  @valid_attrs %{
    email: "test@example.com", password: "test1234",
    password_confirmation: "test1234", username: "testuser"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  # Test(s) for hashed passwords and comeonin
  # Simple verification for the encryption
  test "password_digest value gets set to a hash" do
    changeset = User.changeset(%User{}, @valid_attrs)
    # old >> assert get_change(changeset, :password_digest) == "ABCDE"
    assert Comeonin.Bcrypt.checkpw(@valid_attrs.password, Ecto.Changeset.get_change(changeset, :password_digest))
  end

  # If get_change() is not hit
  test "password_digest value does not get set if password is nil" do
    changeset = User.changeset(%User{}, %{email: "test@example.com", password: nil, password_confirmation: nil, username: "testuser"})
    refute Ecto.Changeset.get_change(changeset, :password_digest)
  end
end
