user1 = User.create username: 'tuntite', email: 'teemu.tuntiopettaja@helsinki.fi', campus:'Viikki', unit:'Solubiologia',	
	name: 'Teemu Tuntiopettaja', about: 'Innovatiivinen opetuksen kehittäjä'
# avatar_file_name: 'http://upload.wikimedia.org/wikipedia/commons/9/97/DNA_Double_Helix.png',

user1.hashtags.create tag: 'solu'
user1.hashtags.create tag: 'mitoosi'


user2 = User.create username: 'opiskol', email: 'olli.opiskelija@helsinki.fi', campus:'Keskusta', unit:'YVA',
										name: 'Olli Opiskelija', about: 'I have a dream'
# avatar_file_name: 'http://c1.staticflickr.com/5/4026/5131213010_0d1394858a_b.jpg',

user2.hashtags.create tag: 'kokoomus'
user2.hashtags.create tag: 'tasaarvo'
user2.hashtags.create tag: 'maserati'

user3 = User.create username: 'laakila', email: 'laura.laakislainen@helsinki.fi', campus:'Meilahti', unit:'Lääkis',
										name: 'Laura Lääkisläinen', about: ''
# avatar_file_name: 'http://i.dailymail.co.uk/i/pix/2011/09/16/article-2037848-0DEC8D2200000578-406_634x408.jpg',

user3.hashtags.create tag: 'lumilautailu'
user3.hashtags.create tag: 'golf'
user3.hashtags.create tag: 'tasaarvo'
