//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require twitter/bootstrap/rails/confirm

//= require jqcloud
//= require moment
//= require material
//= require select2

//= require twitter/typeahead
//= require handlebars

//= require joyride/jquery.joyride-2.1
//= require jquery.atwho

//= require rails
//= require chat_common
//= require chat
//= require feed_chat
//= require search

$(document).ready(function() {
	if ($(location).attr('pathname').indexOf("notifications") > -1) {
		$(".notif-count .badge").remove();
		$.post("notifications/seen");
	}
	if ($(location).attr('pathname').indexOf("hashtag") > -1) {

		$('.invite-modal__open').click(function() {
			$('.invite-card').fadeIn(300);
		});
		$('.invite-modal__close').click(function() {
			$('.invite-card').fadeOut(300);
		});
		$('.edit-modal__open').click(function() {
			$('.edit-card').fadeIn(300);
		});
		$('.edit-modal__close').click(function() {
			$('.edit-card').fadeOut(300);
		});

		$(".topic__toggle").click(function(){
			if ($(".mdl-layout__header-row.mdl-hashtag-topic").height() == 56 ){
				$(".mdl-layout__header-row.mdl-hashtag-topic").css("overflow", "scroll");
		    $(".mdl-layout__header-row.mdl-hashtag-topic").animate({height: '32vh'});
				$(".topic__toggle").text('Hide topic');
			} else {
				$(".mdl-layout__header-row.mdl-hashtag-topic").css("overflow", "hidden");
				$(".mdl-layout__header-row.mdl-hashtag-topic").animate({height: '56px'});
				$(".topic__toggle").text('Show topic');
			}
		});
	}
});

function startOnboard() {
	if ($(location).attr('pathname').indexOf("feed") > -1) {
		$('#feed-onboard').joyride({
			autoStart: true,
			modal: true,
			expose: true
		});
	} else if ($(location).attr('pathname').indexOf("edit") > -1) {
		$('#new-user-onboard').joyride({
			autoStart: true,
			modal: true,
			expose: true
		});
	} else if ($(location).attr('pathname').indexOf("hashtag") > -1) {
		$('#hashtag-onboard').joyride({
			autoStart: true,
			modal: true,
			expose: true,
			nextButton: false
		});
	}
}

if ($(location).attr('pathname').indexOf("users") > -1 || $(location).attr('pathname') === '/threehash') {
	$.getJSON("/hashtags", function(json) {
		var tags = [];
		for (var i = 0; i < json.length; i++) {
			tags.push(json[i].tag);
		}

		$("form #hashtags").select2({
			placeholder: "Select your Interests",
			tags: tags,
			width: '100%',
			tokenSeparators: [",", " "]
		});
	});
}

var updateTimestamps = function() {
	$('.timestamp').each(function() {
		var timestamp = moment.utc($(this).data('timestamp')).local().fromNow();
		$(this).text(timestamp);
	});
};

var toggleSearch = function() {
	$('.nav-toggleable').toggle();
	$('.mdl-layout__tab-bar-container').toggle();
	$('.overlay').toggle();

	if ($('.nav-toggleable')[0].style.display != 'none') {
		$('.search-toggle i').text('clear');

		$('.site-search').focus();
		$('.site-search').on('blur', toggleSearch);
	} else {
		$('.search-toggle i').text('search');

		$('.site-search').off('blur');
	}
}

var ready = function() {
	$('.search-toggle').on('click', toggleSearch);

	$(function() {
		setTimeout(function() {
			$('#collapseAlert').collapse('hide');
		}, 5000);
	});

	updateTimestamps();
	setInterval(function() {
		updateTimestamps();
	}, 60000);

	//Onboarding
	if (first_time) {
		$(window).load(function() {
			startOnboard();
		});
	}

	if ($(location).attr('pathname') == "/feed") {
		// Change hash for page-reload
		$('.mdl-layout__tab').click( function(e) {
			var href = $(this).attr('href').split('#')[1]
			window.location.hash = href
			$.post("/tab/" + href);
		});

		$('#new-interest-revealer').click(function() {
			$('.create').toggle('slow');
			$('.create input.form-control').focus();
		});

		// HashCloud
		$("#tag_cloud").jQCloud(word_array);

		var url = document.location.toString();
		if (url.match('#')) {
			componentHandler.upgradeDom();
			$('a[href="#' + url.split('#')[1] + '"] span').click();
		} else if(tab == 1){
			componentHandler.upgradeDom();
			$('a[href="#feed"] span').click();
		}
	}
};

$(document).ready(ready);
$(document).on('page:load', ready);
