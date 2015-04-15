//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require twitter/bootstrap/rails/confirm

//= require masonry/jquery.masonry

//= require jqcloud
//= require moment

//= require select2

//= require twitter/typeahead
//= require handlebars

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

function clearAllMasonryBricks (){
  var bricks = [];
  bricks = document.getElementsByClassName("box");
  for(var i = bricks.length; i > 0; i--){
    $.post( "notifications/" + bricks[0].id);
    $('#masonry-container').masonry('remove', bricks[0]);
    $('#masonry-container').masonry();
    notifCounter();
  }
};

function notifCounter(){
  $( ".notif-count" ).text(function(i, t) {
    if (t > 1){
      return Number(t) - 1;
    } else {
      setupNoNotif();
      return ""
    }
  });
}

function setupNoNotif (){
  $( ".clearAll" ).remove();
  $( ".notif-icon" ).css("color", "#fff");
  $( ".empty-notif" ).append( "You don't have any new notifications." );  
}

function startOnboard(){
  if($(location).attr('pathname').indexOf("feed") > -1){

    $('#feed-onboard').joyride({
      autoStart : true,
      modal:true,
      expose: true
    });

  } else if($(location).attr('pathname').indexOf("edit") > -1){

    $('#new-user-onboard').joyride({
      autoStart : true,
      modal:true,
      expose: true
    });

  } else if($(location).attr('pathname').indexOf("hashtag") > -1){

    $('#hashtag-onboard').joyride({
      autoStart : true,
      modal:true,
      expose: true,
      nextButton : false
    });
  }
}

if($(location).attr('pathname').indexOf("users") > -1){
  $.getJSON("/hashtags", function(json){
    var tags = [];
    for(var i = 0; i < json.length; i++){
      tags.push(json[i].tag);
    }


    $("#Hashtag").select2({
      placeholder: "Select your Interests", 
      tags : tags,
      width: '100%'
    });
  });
}  

var ready = function() {
  $('#masonry-container').masonry({
    itemSelector: '.box',
    //columnWidth: 100,
    //isAnimated: !Modernizr.csstransitions,
    "isOriginTop": true
    //isRTL: true
  });

  $('.star').hover(function () {
  	$(this).toggleClass("glyphicon-star-empty");
  	$(this).toggleClass("glyphicon-star");
  });

  $('.notif > .alert .close').click(function(e) {
    //$(this).parent().remove();
    var box = $(this).parent().get(0).id;
    $.post( "notifications/" + box);
    $('#masonry-container').masonry('remove', $(this).parent(".box"));
    $('#masonry-container').masonry();

    notifCounter();

  });
  
  $('span.timestamp').each(function() {
    var text = $(this).text();
    var timestamp = moment.utc(text).local().format('MMM D, H:mm');
    $(this).text(timestamp);
  });

  
  //Onboarding
  if(first_time){
    $(window).load(function() {
      startOnboard();
    });
  }

  
  //HashCloud 
  if($(location).attr('pathname') == "/feed"){
    $("#tag_cloud").jQCloud(word_array);
  }
};

$(document).ready(ready);
$(document).on('page:load', ready);

