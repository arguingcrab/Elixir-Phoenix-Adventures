defmodule Pxblog.Factory do
  @moduledoc """
  Factory - Nice to setup various models and assoc for tests without rewriting
  creation logic multiple times
  """
  use ExMachina.Ecto, repo: Pxblog.Repo

  alias Pxblog.Role
  alias Pxblog.User
  alias Pxblog.Post
  alias Pxblog.Comment

  # fn x -> "Test Role #{x}" end
  # return Role struct that defines properties we want it to have
  def role_factory do
    %Role{
      name: sequence(:name, &"Test Role #{&1}"),
      admin: false
    }
  end

  def user_factory do
    %User{
      username: sequence(:username, &"User #{&1}"),
      email: "test@example.com",
      password: "test1234",
      password_confirmation: "test1234",
      password_digest: Comeonin.Bcrypt.hashpwsalt("test1234"),
      role: build(:role)
    }
  end

  def post_factory do
    %Post{
      title: "Some Post",
      body: "And the body of some post",
      user: build(:user)
    }
  end

  def comment_factory do
    %Comment{
      author: "Test User",
      body: "Sample comment",
      approved: false,
      post: build(:post)
    }
  end
end
