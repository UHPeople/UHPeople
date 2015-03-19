var users = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('tag'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/hashtags/'
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
      header: '<h3>Hashtags</h3>'
    }
  },

  {
    name: 'users',
    displayKey: 'tag',
    source: users.ttAdapter(),
    templates: {
      header: '<h3>Users</h3>'
    }
  });
});