defmodule Pxblog.CommentController do
  use Pxblog.Web, :controller

  alias Pxblog.Comment
  alias Pxblog.Post

  # Check presence of comment key (ensure !empty/isset / changes empty = nil)
  # %{"user" => %{"name" => "foo", "age" => ""}}
  # age = nil
  plug :scrub_params, "comment" when action in [:create, :update]
  #---
  plug :set_post_and_authorize_user when action in [:update, :delete]

  @doc """
  Create a comment when comment_params is passed
  Fetch associated post - Preload user & comments since template will start referencing both

  Pipe into build_assoc - builds associated schema by specifying the assoc via an atom
  Build an associated comment
  Pipe into Comment.changeset() with comment_params we pattern matched

  Error condition using another View's render
  Pass conn, View to use - Pxblog.PostView, template to render, and vars (@post, @user, @comment_changeset)
  """
  def create(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    post = Repo.get!(Post, post_id) |> Repo.preload([:user, :comments])
    changeset = post
      |> build_assoc(:comments)
      |> Comment.changeset(comment_params)

    case Repo.insert(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully!")
        |> redirect(to: user_post_path(conn, :show, post.user, post))
      {:error, changeset} ->
        render(conn, Pxblog.PostView, "show.html", post: post, user: post.user, comment_changeset: changeset)
    end
  end

  @doc """
  Update comment
  """
  #def update(conn, _), do: conn
  def update(conn, %{"id" => id, "comment" => comment_params}) do
    # post = Repo.get!(Post, post_id) |> Repo.preload(:user)
    post = conn.assigns[:post]
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: user_post_path(conn, :show, post.user, post))
      {:error, _} ->
        conn
        |> put_flash(:info, "Failed to update comment!")
        |> redirect(to: user_post_path(conn, :show, post.user, post))
    end
  end

  def delete(conn, %{"id" => id}) do
    post = conn.assigns[:post]
    # post = Repo.get!(Post, post_id) |> Repo.preload(:user)
    Repo.get!(Comment, id) |> Repo.delete!
    conn
    |> put_flash(:info, "Deleted comment!")
    |> redirect(to: user_post_path(conn, :show, post.user, post))
  end

  #---
  defp set_post(conn) do
    post = Repo.get!(Post, conn.params["post_id"]) |> Repo.preload(:user)
    assign(conn, :post, post)
  end

  defp set_post_and_authorize_user(conn, _opts) do
    conn = set_post(conn)
    if is_authorized_user?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that comment!")
      |> redirect(to: page_path(conn, :index))
      |> halt
    end
  end

  defp is_authorized_user?(conn) do
    user = get_session(conn, :current_user)
    # Handle nil
    case user do
      nil -> false
      _ ->
        post = conn.assigns[:post]
        ((user.id == post.user_id) || Pxblog.RoleChecker.is_admin?(user))
    end
  end
end
