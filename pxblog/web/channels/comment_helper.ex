defmodule Pxblog.CommentHelper do
  @moduledoc """
  Handling DB interactions required for creating/approving/deleting comments
  """
  alias Pxblog.Comment
  alias Pxblog.Post
  alias Pxblog.User
  alias Pxblog.Repo

  import Ecto, only: [build_assoc: 2]

  @doc """
  Fetch post via get_post()
  Build changeset off the post to build assoc comment with body&&author vars
  Return Repo.insert()
  """
  def create(%{"postId" => post_id, "body" => body, "author" => author}, _socket) do
    post = get_post(post_id)
    changeset = post
      |> build_assoc(:comments)
      |> Comment.changeset(%{body: body, author: author})
    Repo.insert(changeset)
  end

  @doc """
  Pattern match (post_id&&comment_id) && (verified user_id from socket)
  Call helper authorize_and_perform and pass anon()
  Fetches comment, updates approved to true via changeset
  Repo.update()
  """
  def approve(%{"postId" => post_id, "commentId" => comment_id}, %{assigns: %{user: user_id}}) do
    authorize_and_perform(post_id, user_id, fn ->
      comment = Repo.get!(Comment, comment_id)
      changeset = Comment.changeset(comment, %{approved: true})
      Repo.update(changeset)
    end)
  end

  # def approve(_params, %{}), do: {:error, "User is not authorized"}
  # def approve(_params, nil), do: {:error, "User is not authorized"}

  @doc """
  Pattern match (post_id&&comment_id) && (verified user_id from socket)
  Call helper authorize_and_perform and pass anon()
  Fetches comment and delete
  """
  def delete(%{"postId" => post_id, "commentId" => comment_id}, %{assigns: %{user: user_id}}) do
    authorize_and_perform(post_id, user_id, fn ->
      comment = Repo.get!(Comment, comment_id)
      Repo.delete(comment)
    end)
  end

  def delete(_params, %{}), do: {:error, "User is not authorized"}
  # def delete(_params, _), do: {:error, "User is not authorized"}

  @doc """
  Helper()
  Pass post_id&&user_id
  Call is_authorized_user? to return true false
  Call anon() - action
  Otherwise return tuple {:error, msg} for catch
  """
  defp authorize_and_perform(post_id, user_id, action) do
    post = get_post(post_id)
    user = get_user(user_id)
    if is_authorized_user?(user, post) do
      action.()
    else
      {:error, "User is not authorized"}
    end
  end

  # Fetches user
  defp get_user(user_id) do
    Repo.get!(User, user_id)
  end

  # Fetches post
  defp get_post(post_id) do
    Repo.get!(Post, post_id)
    |> Repo.preload([:user, :comments])
  end

  # Checks if user is authorized
  defp is_authorized_user?(user, post) do
    (user && (user.id == post.user_id || Pxblog.RoleChecker.is_admin?(user)))
  end
end
