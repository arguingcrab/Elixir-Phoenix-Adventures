defmodule Pxblog.UserSocket do
  use Phoenix.Socket
  @moduledoc """
  Socket Handler(s)
  Holds a single connection to the server / combining sockets over one connection

  Authenticate & Identify a socket connection and allow you to set default
  socket assigns for use in all channels
  """
  ## Channels
  # Making comments live via Phoenix Channels
  # mix phoenix.gen.channel Comment
  # npm install --save-dev jquery
  # Channel Routes match topic strings & dispatch matching requests
  channel "comments:*", Pxblog.CommentChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  @doc """
  Pass token back to Phoenix and call PHoenix.Token.verify()
  Pass token to verify val, token, max_age of token (2w)

  We still want !logged_in to see live updates so we won't have user_id
  """
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user", token, max_age: 1209600) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user, user_id)}
      {:error, reason} ->
        {:ok, socket}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Pxblog.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
  # def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
