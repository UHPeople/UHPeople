var normalize = function(str) {
  if (/^#[^#]*$/.test(str)) {
    return str.substring(1);
  }
  return str;
}

var queryTokenizer = function(q) {
  var normalized = normalize(q);
  return Bloodhound.tokenizers.whitespace(normalized);
};

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
  queryTokenizer: queryTokenizer,
  prefetch: {
    url: '/hashtags/',
    ttl: 1
  }
});

$(document).ready(function() {
  users.clearPrefetchCache();

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
        '<a href="/hashtags/{{id}}"><div><span>#{{tag}}</span></div></a>')
    }
  },

  {
    name: 'users',
    displayKey: 'name',
    source: users.ttAdapter(),
    templates: {
      suggestion: Handlebars.compile(
        '<a href="/users/{{id}}">' +
          '<div>' + 
            '<span>{{name}}</span>' + 
            '<img class="img-circle" src="{{avatar}}"></img>' +
          '</div>' +
        '</a>')
    }
  });
});

function makeSexy() {
  var input = $('form#invite-form span input#user');
  var form = $('form#invite-form');

  input.click(function() {
    $('form#invite-form span span.glyphicon').remove();
    form.parent().removeClass('has-success');
    form.parent().removeClass('has-error');
    // $(this).val('');
  });

  form.submit(function() {
    input.blur();

    $.ajax({
      type: "POST",
      url: form.attr('action'),
      data: form.serialize(),
      dataType: "JSON"
    }).done(function() {
      // input.prop('disabled', false);

      form.children('span').append(
        '<span class="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>'
      );

      form.parent().addClass('has-success');
    }).fail(function() {
      // input.prop('disabled', false);

      form.children('span').append(
        '<span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>'
      );

      form.parent().addClass('has-error');
    });

    return false;
  });
}

function send(name) {
  $('form#invite-form span input#user').text(name);
  $('form#invite-form').submit();
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
        '<div onclick="send({{name}});">' + 
          '<span>{{name}}</span>' + 
          '<img class="img-circle" src="{{avatar}}"></img>' +
        '</div>')
    }
  });

  makeSexy();
});
