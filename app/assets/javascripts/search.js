var users = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/users/'
});
 
var hashtags = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('tag'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/hashtags/'
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
      header: '<h4 class="asd">Hashtags</h4>'
      // suggestion: Handlebars.compile('<p><strong>#{{value}}</strong></p>')
    }
  },

  {
    name: 'users',
    displayKey: 'name',
    source: users.ttAdapter(),
    templates: {
      header: '<h4 class="asd">Users</h4>'
    }
  });
});

function makeSexy() {
  $('form[data-remote=true] span input#user').click(function() {
    $('form[data-remote=true] span span.glyphicon-ok').remove();
    $('form[data-remote=true]').parent().removeClass('has-success');
    // $(this).val('');
  });

  $('form[data-remote=true]').submit(function() {
    var input = $('form[data-remote=true] span input#user');
    // input.prop('disabled', true);
    input.blur();
  });

  $('form[data-remote=true]').bind('ajax:complete', function() {
    var form = $(this);
    var span = form.children('span');
    span.children('input#user').prop('disabled', false);

    span.append('<span class="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>');
    form.parent().addClass('has-success');
  });
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
  });

  makeSexy();
});
