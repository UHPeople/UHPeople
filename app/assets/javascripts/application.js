//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets

// masonry dynamic grid system
//= require masonry/jquery.masonry
//= require masonry/jquery.event-drag
//= require masonry/jquery.imagesloaded.min
//= require masonry/jquery.infinitescroll.min
//= require masonry/modernizr-transitions

//= require masonry/box-maker
//= require masonry/jquery.loremimages.min

//= require moment
//= require twitter/typeahead
//= require joyride/jquery.joyride-2.1

//= require_tree .

var url = document.location.toString();
if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
} 

// Change hash for page-reload
$('.nav-tabs a').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash;
    window.scrollTo(0, 0);
})

var ready = function() {
  $('#masonry-container').masonry({
    itemSelector: '.box',
    //columnWidth: 100,
    isAnimated: !Modernizr.csstransitions,
    "isOriginTop": true
    //isRTL: true
  });

  $('.star').hover(function () {
  	$(this).toggleClass("glyphicon-star-empty");
  	$(this).toggleClass("glyphicon-star");
  });

  $('.alert .close').click(function(e) {
    //$(this).parent().remove();
    var box = $('.alert .close').first().parent().get(0).id;
    $.post( "notifications/" + box);
    $('#masonry-container').masonry('remove', $(this).parent(".box"));
    $('#masonry-container').masonry();
    $( ".notif-count" ).text(function(i, t) {
      if (t>1){
        return Number(t) - 1;
      } else {
        $( ".notif-icon" ).css("color", "#9D9D9D");
        $( ".empty-notif" ).append( "<p>You don't have any new notifications.</p>" );  
        return ""
      }
    });
  });
  

  $('span.timestamp').each(function() {
    var text = $(this).text();
    $(this).text(moment.utc(text).local().format('MMMM Do YYYY, H:mm:ss'));
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);

