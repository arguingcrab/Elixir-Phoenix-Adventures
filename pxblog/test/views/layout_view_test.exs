defmodule Pxblog.LayoutViewTest do
  @moduledoc """
  Test Login and negative case - delete session
  """
  use Pxblog.ConnCase, async: true

  alias Pxblog.LayoutView
  alias Pxblog.User

  setup do
    User.changeset(%User{}, %{username: "testuser", password: "test1234", password_confirmation: "test1234", email: "test@example.com"})
    |> Repo.insert
    {:ok, conn:build_conn()}
  end

  test "current user returns the user in the session", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "testuser", password: "test1234"}
    assert LayoutView.current_user(conn)
  end

  test "current user returns nothing if there is no user in the session", %{conn: conn} do
    user = Repo.get_by(User, %{username: "testuser"})
    conn = delete conn, session_path(conn, :delete, user)
    refute LayoutView.current_user(conn)
  end
end
