// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"
import $ from "jquery"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:

/**
let channel = socket.channel("topic:subtopic", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
**/
// GET postId from DOM
const postId = $("#post-id").val();
const channel = socket.channel(`comments:${postId}`, {});
const CREATED_COMMENT = "CREATED_COMMENT";
const APPROVED_COMMENT = "APPROVED_COMMENT";
const DELETED_COMMENT = "DELETED_COMMENT";
// Grab user token from meta tag
const userToken = $("meta[name='channel_token']").attr("content");
// Make sure we're connting with the user's token to persist user.id session
const socket = new Socket("/socket", {params: {token: userToken}});
// Connect to our socket
socket.connect();

const createComment = (payload) => `
  <div id="comment-${payload.commentId}" class="comment" data-comment-id="${payload.commentId}">
    <div class="row">
      <div class="col-xs-4">
        <strong class="comment-author">${payload.author}</strong>
      </div>
      <div class="col-xs-4">
        <em>${payload.insertedAt}</em>
      </div>
      <div class="col-xs-4 text-right">
        ${ userToken ? '<button class="btn btn-xs btn-primary approve">Approve</button> <button class="btn btn-xs btn-danger delete">Delete</button>' : '' }
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12 comment-body">
        ${payload.body}
      </div>
    </div>
  </div>
  `;
const getCommentAuthor = () => $("#comment_author").val();
const getCommentBody = () => $("#comment_body").val();
const getTargetCommentId = (target) => $(target).parents(".comment").data("comment-id")
const resetFields = () => {
  $("#comment_author").val("")
  $("#comment_body").val("")
}

// Push CREATED_COMMENT event to socket with appropriate val
$(".create-comment").on("click", function(e){
  e.preventDefault();
  channel.push(CREATED_COMMENT, {author: getCommentAuthor(), body: getCommentBody(), postId});
  resetFields();
});

// Push APPROVED_COMMENT event to socket with appropriate val
$(".comments").on("click", ".approve", function(e){
  e.preventDefault();
  const commentId = getTargetCommentId(e.currentTarget);
  // Get approved comment author
  const author = $(`#comment-${commentId} .comment-author`).text().trim();
  const body = $(`#comment-${commentId} .comment-body`).text().trim();
  channel.push(APPROVED_COMMENT, { author, body, commentId, postId });
});

// Push DELETED_COMMENT event to socket only needing comment_id
$(".comments").on("click", ".delete", function(e){
  e.preventDefault();
  const commentId = getTargetCommentId(e.currentTarget);
  channel.push(DELETED_COMMENT, { commentId, postId });
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

// Handles receiving CREATED_COMMENT event
channel.on(CREATED_COMMENT, (payload) => {
  // Don't append comment if !approved
  if (!userToken && !payload.approved){ return; }
  // Add to DOM
  $(".comments h2").after(createComment(payload));
});

// Handles receiving APPROVED_COMMENT
channel.on(APPROVED_COMMENT, (payload) => {
  if($(`#comment-${payload.commentId}`).length === 0){
    $(".comments h2").after(createComment(payload));
  }
  $(`#comment-${payload.commentId} .approve`).remove();
});

// Handles receiving DELETED_COMMENT
channel.on(DELETED_COMMENT, (payload) => {
  $(`#comment-${payload.commentId}`).remove();
});

export default socket
// $("input[type=submit]").on("click", function(e){});
$("input[type=submit]").on("click", (e) =>{
  e.preventDefault();
  channel.push(CREATED_COMMENT, { author: "test", body: "body"});
});
