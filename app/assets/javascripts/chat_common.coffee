add_notification = ->
  count = $('.notif-count')
  t = Number(count.text())
  if t == 0
    $('.notif-count').append("<span class='badge badge-success'>1</span>");
  else
    $('.notif-count .badge').text(t + 1)

format_timestamp = (timestamp) ->
  if !moment.isMoment(timestamp)
    timestamp = moment.utc(timestamp)
  timestamp.local().format('MMM D, H:mm')

add_multiple_messages = (data, add_message, drawMarker = true) ->
  last_visit = null
  if (drawMarker)
    last_visit = moment.utc($('#last-visit')[0].value)

  markerDrawn = false
  for message in data.messages
    if (drawMarker and !markerDrawn and moment.utc(message.timestamp).isAfter(last_visit))
      $('.chatbox').append ''+
        '<div class="line text-center">' +
          '<span>Since<span class="timestamp">' + format_timestamp(last_visit) + '</span></span>'+
        '</div>'
      markerDrawn = true
    add_message message

exports = this
exports.add_multiple_messages = add_multiple_messages
exports.add_notification = add_notification
exports.format_timestamp = format_timestamp