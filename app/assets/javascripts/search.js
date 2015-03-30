var users = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: {
    url: '/users/',
    ttl: 1
  }
});
 
var hashtags = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('tag'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: {
    url: '/hashtags/',
    ttl: 1
  }
});

$(document).ready(function() {
  users.initialize();
  hashtags.initialize();

  $('.typeahead').typeahead({
    highlight: true
  },

  {
    name: 'hashtags',
    displayKey: 'tag',
    source: hashtags.ttAdapter(),
    templates: {
      suggestion: Handlebars.compile(
        '<a href="/hashtags/{{id}}"><div class="suggest-tag">#{{tag}}</div></a>')
    }
  },

  {
    name: 'users',
    displayKey: 'name',
    source: users.ttAdapter(),
    templates: {
      suggestion: Handlebars.compile(
        '<a href="/users/{{id}}">' +
          '<div class="suggest-asd">' +
            '<div class="suggest-name">{{name}}</div>' + 
            '<img class="avatar-45" src="{{avatar}}"></img>'+
          '</div>'+
        '</a>')
    }
  });
});

function makeSexy() {
  var input = $('form[data-remote=true] span input#user');
  var form = $('form[data-remote=true]');

  input.click(function() {
    $('form[data-remote=true] span span.glyphicon-ok').remove();
    form.parent().removeClass('has-success');
    // $(this).val('');
  });

  form.submit(function() {
    // input.prop('disabled', true);
    input.blur();
  });

  $('form[data-remote=true]').bind('ajax:complete', function() {
    // input.prop('disabled', false);

    form.children('span').append(
      '<span class="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>'
    );

    form.parent().addClass('has-success');
  });
}

function send(name) {
  $('form[data-remote=true] span input#user').text(name);
  $('form[data-remote=true]').ajaxSend();
}

$(document).ready(function() {
  users.initialize();

  $('.typeahead-invite').typeahead({
    highlight: true
  },
  {
    name: 'users',
    displayKey: 'name',
    source: users.ttAdapter(),
    templates: {
      suggestion: Handlebars.compile(
        '<a onclick="send({{name}});">' +
          '<div class="suggest-asd">' +
            '<div class="suggest-name">{{name}}</div>' + 
            '<img class="avatar-45" src="{{avatar}}"></img>'+
          '</div>'+
        '</a>')
    }
  });

  makeSexy();
});
