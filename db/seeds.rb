user1 = User.create username: 'tuntite', email: 'teemu.tuntiopettaja@helsinki.fi', campus:'Viikki',
	name: 'Teemu Tuntiopettaja', about: 'Innovatiivinen opetuksen kehittäjä'
# avatar_file_name: 'http://upload.wikimedia.org/wikipedia/commons/9/97/DNA_Double_Helix.png',

user1.hashtags.create tag: 'solu'
user1.hashtags.create tag: 'mitoosi'


user2 = User.create username: 'opiskol', email: 'olli.opiskelija@helsinki.fi', campus:'Keskusta',
										name: 'Olli Opiskelija', about: 'I have a dream'
# avatar_file_name: 'http://c1.staticflickr.com/5/4026/5131213010_0d1394858a_b.jpg',

user2.hashtags.create tag: 'kokoomus'
user2.hashtags.create tag: 'tasaarvo'
user2.hashtags.create tag: 'maserati'

user3 = User.create username: 'laakila', email: 'laura.laakislainen@helsinki.fi', campus:'Meilahti',
										name: 'Laura Lääkisläinen', about: ''
# avatar_file_name: 'http://i.dailymail.co.uk/i/pix/2011/09/16/article-2037848-0DEC8D2200000578-406_634x408.jpg',

user3.hashtags.create tag: 'lumilautailu'
user3.hashtags.create tag: 'golf'
user3.hashtags.create tag: 'tasaarvo'


(1..50).each{
	Hashtag.create tag: [*('a'..'ö')].sample(rand(3..12)).join, color: rand(12)
}

(1..50).each{
	u = User.create username: [*('a'..'Z')].sample(8).join, email: [*('a'..'z')].sample(8).join + '@helsinki.fi', campus:'Viikki',
		name: (2).times.map{[*('a'..'ö')].sample(rand(3..12)).join}.join(' '), about: rand(1..25).times.map{[*('a'..'Ö')].sample(rand(2..8)).join}.join(' ')
	rand(1..30).times{
		h = Hashtag.find(rand(1..50))
		unless h.users.include? u then h.users << u end
		rand(1..50).times{ Message.create content: (rand(1..20).times.map{[*('a'..'Ö')].sample(rand(2..8)).join}.join(' ')), user_id: u.id, hashtag_id: h.id}
	}
}


#Message.create content: rand(1..25).times.map{[*('A'..'Z')].sample(18).join}.join(' '), user_id: user1.id, hashtag_id: 1
