defmodule Pxblog.LayoutViewTest do
  @moduledoc """
  Test Login and negative case - delete session
  """
  use Pxblog.ConnCase, async: true

  alias Pxblog.LayoutView
  alias Pxblog.TestHelper

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "User Role", admin: false})
    {:ok, user} = TestHelper.create_user(role, %{username: "testuser", password: "test1234", password_confirmation: "test1234", email: "test@example.com"})
    {:ok, conn: build_conn(), user: user}
  end

  test "current user returns the user in the session", %{conn: conn, user: user} do
    conn = post conn, session_path(conn, :create), user: %{username: user.username, password: user.password}
    assert LayoutView.current_user(conn)
  end

  test "current user returns nothing if there is no user in the session", %{conn: conn, user: user} do
    conn = delete conn, session_path(conn, :delete, user)
    refute LayoutView.current_user(conn)
  end
end
