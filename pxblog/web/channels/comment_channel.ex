defmodule Pxblog.CommentChannel do
  use Pxblog.Web, :channel

  alias Pxblog.CommentHelper

  def join("comments:" <> post_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (comment:lobby).
  def handle_in("CREATED_COMMENT", payload, socket) do
    case CommentHelper.create(payload, socket) do
      {:ok, comment} ->
        broadcast socket, "CREATED_COMMENT", Map.merge(payload, %{insertedAt: comment.inserted_at, commentId: comment.id, approved: comment.approved})
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_in("APPROVED_COMMENT", payload, socket) do
    case CommentHelper.approve(payload, socket) do
      {:ok, comment} ->
        new_payload = payload
          |> Map.merge(%{
            insertedAt: comment.inserted_at,
            commentId: comment.id,
            approved: comment.approved})
        broadcast socket, "APPROVED_COMMENT", new_payload
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
    # broadcast socket, "APPROVED_COMMENT", payload
    # {:noreply, socket}
  end

  def handle_in("DELETED_COMMENT", payload, socket) do
    case CommentHelper.delete(payload, socket) do
      {:ok, _} ->
        broadcast socket, "DELETED_COMMENT", payload
        {:noreply, socket}
      {:error, _} ->
        {:noreply, socket}
    end
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
