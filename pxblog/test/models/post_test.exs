defmodule Pxblog.PostTest do
  use Pxblog.ModelCase

  alias Pxblog.Post

  @valid_attrs %{body: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end

  # Modify @valid_attrs, use changeset's get_change to pull translated val out of changeset
  # ~r sigil for regex
  # When body has <script>
  test "when the body includes a script tag" do
    changeset = Post.changeset(%Post{}, %{@valid_attrs | body: "Hello <script type='javascript'>alert('foo');</script>"})
    refute String.match? get_change(changeset, :body), ~r{<script>}
  end
  # When body has <iframe>
  test "when the body includes an iframe tag" do
    changeset = Post.changeset(%Post{}, %{@valid_attrs | body: "Hello <iframe src='http://google.com'></iframe"})
    refute String.match? get_change(changeset, :body), ~r{<iframe>}
  end

  # When body has none of valid tags
  test "body includes no stripped tags" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert get_change(changeset, :body) == @valid_attrs[:body]
  end
end
