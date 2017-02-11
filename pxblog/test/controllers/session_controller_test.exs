defmodule Pxblog.SessionControllerTest do
  @moduledoc """
    Posting to session creation path
    Verify we set current_user session var
    Flash msg and redirect
    And
    Test for bad/missing login info
  """
  use Pxblog.ConnCase

  # Alias the User model so we can use it
  alias Pxblog.User

  setup do
    User.changeset(%User{}, %{username: "testuser", password: "test1234", password_confirmation: "test1234", email: "test@example.com"})
    |> Repo.insert
    {:ok, conn: build_conn()}
  end

  test "shows the login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "creates a new user session for a valid user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "testuser", password: "test1234"}
    assert get_session(conn, :current_user)
    assert get_flash(conn, :info) == "Sign in successful!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session with a bad login", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "testuser", password: "wrong"}
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) == "Invalid username/password combination!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session if use does not exist", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "foo", password: "wrong"}
    assert get_flash(conn, :error) == "Invalid username/password combination!"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  # Make sure current_user empty, check flash and redirect(ed)
  test "delete the user session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "testuser"})
    conn = delete conn, session_path(conn, :delete, user)
    refute get_session(conn, :current_u)
    assert get_flash(conn, :info) == "Signed out successfully!"
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
