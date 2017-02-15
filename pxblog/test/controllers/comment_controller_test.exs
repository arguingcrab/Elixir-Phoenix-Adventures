defmodule Pxblog.CommentControllerTest do
  use Pxblog.ConnCase

  import Pxblog.Factory

  @valid_attrs %{author: "Some Person", body: "Sample comment"}
  @invalid_attrs %{}

  # Setup defaults
  setup do
    user = insert(:user)
    post = insert(:post, user: user)

    {:ok, conn: build_conn(), user: user, post: post}
  end

  # Post to nested post->comment path with @valid_attrs
  # Assert we get redirected, and that comment was created for /that/ post
  test "creates resource and redirects when data is valid", %{conn: conn, post: post} do
    conn = post conn, post_comment_path(conn, :create, post), comment: @valid_attrs
    assert redirected_to(conn) == user_post_path(conn, :show, post.user, post)
    assert Repo.get_by(assoc(post, :comments), @valid_attrs)
  end

  # Post to nested post->comment path with @invalid_attrs
  test "does not create resource and renders errors when data is invalid", %{conn: conn, post: post} do
    conn = post conn, post_comment_path(conn, :create, post), comment: @invalid_attrs
    assert html_response(conn, 200) =~ "Oops, something went wrong"
  end
end
