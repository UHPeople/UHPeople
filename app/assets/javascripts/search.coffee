normalize = (str) ->
  if /^#[^#]*$/.test(str)
    return str.substring(1)
  str

users = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
  queryTokenizer: Bloodhound.tokenizers.whitespace
  prefetch:
    url: '/users/'
    ttl: 1)

hashtags = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('tag')
  queryTokenizer: (query) ->
    Bloodhound.tokenizers.whitespace normalize(query)
  prefetch:
    url: '/hashtags/'
    ttl: 1)

users_mentions = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
  queryTokenizer: (query) ->
    matches = query.toLowerCase().match(/@\w+/g)
    matches = if (matches == null) then [] else matches
    matches = (m.substr(1) for m in matches)
    return matches
  prefetch:
    url: '/users/'
    ttl: 1)

addNotice = (name, avatar) ->
  $('.invite-card .mdl-card__supporting-text').append '' +
    '<div class="invite-notice notification-card-wide mdl-card mdl-shadow--2dp" style="display: none;">' +
      '<div class="mdl-card__supporting-text">' +
        '<img class="img-circle mdl-card__supporting-image" src="' + avatar + '"></img>' +
        '<span>' + name + ' invited</span>' +
      '</div>' +
      '<div class="mdl-card__menu">' +
        '<button class="mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect">' +
          '<i class="material-icons">close</i>' +
        '</button>' +
      '</div>' +
    '</div>'

  $('.invite-notice').slideDown('slow')

  $('.invite-notice button').click ->
    $(this).parent().parent().hide('slow')

clearInviteBox = ->
  $('form#invite-form').parent().removeClass('has-success')
  $('form#invite-form').parent().removeClass('has-error')
  $('form#invite-form input#user').val('')

$(document).ready ->
  # users.clearPrefetchCache()

  users.initialize()
  hashtags.initialize()

  $('.typeahead').typeahead({
    highlight: true
  }, {
    name: 'hashtags'
    displayKey: 'tag'
    source: hashtags.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<a href="/hashtags/{{tag}}">' +
        '<div>' +
          '<span>#{{tag}}</span>' +
         ' <span class="search-small-font">{{topic}}</span>' +
        '</div>' +
        '</a>')
  }, {
    name: 'users'
    displayKey: 'name'
    source: users.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<a href="/users/{{id}}">' +
        '<div>' +
          '<span>{{name}}</span>' +
          ' <span class="search-small-font">{{about}}</span>' +
          '<img class="img-circle" src="{{avatar}}"></img>' +
        '</div>' +
      '</a>')
  }).on('typeahead:selected', (obj, datum) ->
    url = window.location.origin

    if datum.tag != undefined
      url = url + '/hashtags/' + datum.tag
    else
      url = url + '/users/' + datum.id

    window.location.href = url
  )

$(document).ready ->
  if $('.typeahead-invite').length == 0
    return

  $('.typeahead-invite').typeahead {
    highlight: true
  }, {
    name: 'users'
    displayKey: 'name'
    source: users.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<div>' +
        '<span>{{name}}</span>' +
        '<img class="img-circle" src="{{avatar}}"></img>' +
      '</div>')
  }

  input = $('form#invite-form span input#user')
  form = $('form#invite-form')

  form.submit (event) ->
    event.preventDefault()

    input.blur()
    $.ajax(
      type: 'POST'
      url: form.attr('action')
      data: form.serialize()
      dataType: 'JSON'
    ).done((json) ->
      input.addClass('has-success')
      addNotice(json['name'], json['avatar'])
      clearInviteBox()
    ).fail ->
      input.addClass('has-error')

$(document).ready ->
  if $('.typeahead-add').length == 0
    return

  $('.typeahead-add').typeahead {
    highlight: true
  }, {
    name: 'hashtags'
    displayKey: 'tag'
    source: hashtags.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<a href="/hashtags/{{tag}}">' +
        '<div><span>#{{tag}}</span></div>' +
      '</a>')
  }

$(document).ready ->
  users_mentions.initialize()

  $('.typeahead-mention').typeahead({
    highlight: true
  }, {
    name: 'users'
    displayKey: 'name'
    source: users_mentions.ttAdapter()
  }).on('typeahead:selected', (obj, datum) ->
    console.log $('.typeahead-mention').text()
    console.log $('.typeahead-mention').val()
  )
