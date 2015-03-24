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
});