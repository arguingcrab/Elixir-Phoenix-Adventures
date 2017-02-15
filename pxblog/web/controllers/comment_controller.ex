defmodule Pxblog.CommentController do
  use Pxblog.Web, :controller

  alias Pxblog.Comment
  alias Pxblog.Post

  # Check presence of comment key (ensure !empty/isset / changes empty = nil)
  # %{"user" => %{"name" => "foo", "age" => ""}}
  # age = nil
  plug :scrub_params, "comment" when action in [:create, :update]

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
    post = Repo.get!(Post, post_id) |> Repo.Preload([:user, :comments])
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

  """
  end
  def update(conn, _), do: conn
  def delete(conn, _), do: conn
end
