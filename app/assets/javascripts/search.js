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

function addNotice(name, avatar) {
  $('.modal-body').append('' +
    '<div class="alert alert-success alert-dismissible invite-notice" role="alert" style="display: none;">' +
      '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
        '<span aria-hidden="true">&times;</span>' +
      '</button>' + 
      '<div>' + 
        '<span>' + name + ' invited</span>' + 
        '<img class="img-circle" src="' + avatar + '"></img>' +
      '</div>' +
    '</div>');

  $('.invite-notice').slideDown('slow');

  $('.invite-notice button').on('click', function() {
    $(this).parent().hide('slow');
  });
}

function clearInviteBox() {
  $('form#invite-form span span.glyphicon').remove();
  $('form#invite-form').parent().removeClass('has-success');
  $('form#invite-form').parent().removeClass('has-error');
  $('form#invite-form span input#user').val('');
}

function makeSexy() {
  var input = $('form#invite-form span input#user');
  var form = $('form#invite-form');

  input.click(function() {
    clearInviteBox();   
  });

  form.submit(function() {
    input.blur();

    $.ajax({
      type: 'POST',
      url: form.attr('action'),
      data: form.serialize(),
      dataType: 'JSON'
    }).done(function(json) {
      form.children('span').append(
        '<span class="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>'
      );

      form.parent().addClass('has-success');

      addNotice(json['name'], json['avatar']);
    }).fail(function() {
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
