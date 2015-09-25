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
// require_tree .

$(document).ready(function() {
	if ($(location).attr('pathname').indexOf("notifications") > -1) {
		$(".notif-count .badge").remove();
		$.post("notifications/seen");
	}
});

function chatComplete() {
	$('input.mentions').atwho({
		at: "@",
		data: userdata,
		displayTpl: '<li>${name} <small>${username}</small></li>',
		insertTpl: '@${username}'
	})
	.atwho({
		at: "#",
		data: hashtagdata,
		displayTpl: '<li>${name}</li>',
		insertTpl: '#${name}',
    limit: 30
	});
}

function topicComplete(){
  $('#topic').atwho({
		at: "@",
		data: userdata,
		displayTpl: '<li>${name} <small>${username}</small></li>',
		insertTpl: '@${username}'
	})
	.atwho({
		at: "#",
		data: hashtagdata,
		displayTpl: '<li>${name}</li>',
		insertTpl: '#${name}',
    limit: 30
	});
}

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

var ready = function() {
	$(function() {
		setTimeout(function() {
			$('#collapseAlert').collapse('hide');
		}, 5000);
	});

	$('span.timestamp').each(function() {
		var text = $(this).text();
		var timestamp = moment.utc(text).local().format('MMM D, H:mm');
		$(this).text(timestamp);
	});

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

	if ($(location).attr('pathname').indexOf("hashtag") > -1) {
		chatComplete();
    topicComplete();
	}
};

$(document).ready(ready);
$(document).on('page:load', ready);
