defmodule Pxblog.LayoutView do
  use Pxblog.Web, :view

  # Modifying layout to display msg/link for member (!)logged_in
  def current_user(conn) do
    Plug.Conn.get_session(conn, :current_user)
  end
end
