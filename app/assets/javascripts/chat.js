$(function() {
  var scheme   = "ws://";
  var uri      = scheme + window.document.location.host;
  var ws       = new WebSocket(uri);

  ws.onmessage = function(message) {
    var data = JSON.parse(message.data);
    
    $("#chat-text").append(
      "<div class='panel panel-default'>" +
      "<div class='panel-body'>" + data.content + "</div></div>");

    $("#chat-text").stop().animate({
      scrollTop: $('#chat-text')[0].scrollHeight
    }, 800);
  };

  $("#input-form").on("submit", function(event) {
    event.preventDefault();
    var text = $("#input-text")[0].value;
    var id = $("#hashtag-id")[0].value;
    ws.send(JSON.stringify({ content: text, hashtag: id }));
    $("#input-text")[0].value = "";
  });
});