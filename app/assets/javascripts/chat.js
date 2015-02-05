$(function() {
  var scheme   = "ws://";
  var uri      = scheme + window.document.location.host;
  var ws       = new WebSocket(uri);

  var hashtag = $("#hashtag-id")[0].value;
  var user = $("#user-id")[0].value;

  // ws.send(JSON.stringify({ event: "online", hashtag: hashtag, user: user }));

  $("#chat-text").scrollTop($("#chat-text")[0].scrollHeight);

  ws.onmessage = function(message) {
    var data = JSON.parse(message.data);
    if (data.hashtag != hashtag) return;
    
    $("#chat-text").append("<div class='panel-body'><span class='chat-name'>" +
      data.user + "</span> " + data.content + "</div>");

    $("#chat-text").stop().animate({
      scrollTop: $('#chat-text')[0].scrollHeight
    }, 800);
  };

  $("#input-form").on("submit", function(event) {
    event.preventDefault();

    var text = $("#input-text")[0].value;

    ws.send(JSON.stringify({ event: "message", content: text, hashtag: hashtag, user: user }));
    
    $("#input-text")[0].value = "";
  });
});