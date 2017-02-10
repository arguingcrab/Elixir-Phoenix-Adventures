defmodule Pxblog.SessionController do
  use Pxblog.Web, :controller

  # Alias the User model so we can use it
  alias Pxblog.User

  # Import comeonin/bcrypt mod arity/2
  import Comeonin.Bcrypt, only: [checkpw: 2]

  # Func that cleans usr input; ie: blank = nil
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    # pass conn, template(-eex), +vars
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  @doc """
  Repo.get_by(User, username: "bob")
  """
  def create(conn, %{"user" => user_params}) do
    # Pull first applicable User from Ecto-Repo w/ matching username; else nil
    Repo.get_by(User, username: user_params["username"])
    |> sign_in(user_params["password"], conn)
  end

  # If user is nil, redirect to :index with flash msg
  defp sign_in(user, password, conn) when is_nil(user) do
    conn
    |> put_flash(:error, "Invalid username/password combination!")
    |> redirect(to: page_path(conn, :index))
  end

  @doc """
  No guard clause & other scenarios
  Checks results of checkpw() - user = current_user session var; else error
  """
  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username})
      |> put_flash(:info, "Sign in successful!")
      |> redirect(to: page_path(conn, :index))
    else
      conn
      |> put_session(:current_user, nil)
      |> put_flash(:error, "nvalid username/password combination!")
      |> redirect(to: page_path(conn, :index))
    end
  end

  @doc """
  Deleting :current_user key for logouts
  """
  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Signed out successfully!")
    |> redirect(to: page_path(conn, :index))
  end
end
