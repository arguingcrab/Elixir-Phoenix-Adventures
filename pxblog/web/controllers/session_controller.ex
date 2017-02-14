defmodule Pxblog.SessionController do
  use Pxblog.Web, :controller

  # Alias the User model so we can use it
  alias Pxblog.User

  # Import comeonin/bcrypt mod arity/2
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  # Func that cleans usr input; ie: blank = nil
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    # pass conn, template(-eex), +vars
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  @doc """
  Repo.get_by(User, username: "bob")
  """
  def create(conn, %{"user" => %{"username" => username, "password" => password}})
   when not is_nil(username) and not is_nil(password) do
      user = Repo.get_by(User, username: username)
      sign_in(user, password, conn)
  end

  def create(conn, _) do
    failed_login(conn)
  end

  defp failed_login(conn) do
    dummy_checkpw()
    conn
    |> put_session(:current_user, nil)
    |> put_flash(:error, "Invalid username/password combination!")
    |> redirect(to: page_path(conn, :index))
    |> halt()
  end

  # If user is nil, redirect to :index with flash msg
  defp sign_in(user, password, conn) when is_nil(user) do
    failed_login(conn)
  end

  #Checks results of checkpw() - user = current_user session var; else error
  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username, role_id: user.role_id})
      |> put_flash(:info, "Sign in successful!")
      |> redirect(to: page_path(conn, :index))
    else
      failed_login(conn)
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
