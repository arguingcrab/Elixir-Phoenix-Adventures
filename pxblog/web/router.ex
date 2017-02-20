defmodule Pxblog.Router do
  use Pxblog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Pxblog.CurrentUserPlug
  end

  # Plug Pxblog.CurrentUserPlug allows @conn.assigns[:current_user]
  # when we need to access current logged_in user

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Pxblog do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/users", UserController do
      resources "/posts", PostController
    end

    # only: [] locks out root post routes
    # anon create / author or admin delete / author admin update
    resources "/posts", PostController, only: [] do
      resources "/comments", CommentController, only: [:create, :delete, :update]
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    # !logged_in display
    resources "/posts", PostController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Pxblog do
  #   pipe_through :api
  # end
end
