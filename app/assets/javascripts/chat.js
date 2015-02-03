$(function() {
  var scheme   = "ws://";
  var uri      = scheme + window.document.location.host + "/chat";
  var ws       = new WebSocket(uri);

  ws.onmessage = function(message) {
    var data = message.data; // JSON.parse(message.data);
    
    $("#chat-text").append(
      "<div class='panel panel-default'>" +
      "<div class='panel-body'>" + data + "</div></div>");

    $("#chat-text").stop().animate({
      scrollTop: $('#chat-text')[0].scrollHeight
    }, 800);
  };

  $("#input-form").on("submit", function(event) {
    event.preventDefault();
    var text = $("#input-text")[0].value;
    ws.send(text);
    $("#input-text")[0].value = "";
  });
});