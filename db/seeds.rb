user = User.create username: 'asd', email: 'asd@asd.fi', campus:'Viikki', unit:'Maametsis', 
	profilePicture: 'http://www.mycatspace.com/wp-content/uploads/2013/08/adopting-a-cat.jpg',
	name: 'Johanna Tukiainen', about: ''

user.hashtags.create tag: 'lätkämutsit'
user.hashtags.create tag: 'avantouinti'


