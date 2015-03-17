// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .

// masonry dynamic grid system
//= require masonry/jquery.masonry
//= require masonry/jquery.event-drag
//= require masonry/jquery.imagesloaded.min
//= require masonry/jquery.infinitescroll.min
//= require masonry/modernizr-transitions

//= require masonry/box-maker
//= require masonry/jquery.loremimages.min

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

  $(".star").hover(function () {
  	$(this).toggleClass("glyphicon-star-empty");
  	$(this).toggleClass("glyphicon-star");
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);