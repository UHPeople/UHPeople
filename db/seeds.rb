user = User.create username: 'asd', email: 'asd@asd.fi', campus:'Viikki', unit:'Maametsis', 
	profilePicture: 'http://www.mycatspace.com/wp-content/uploads/2013/08/adopting-a-cat.jpg',
	name: 'Johanna Tukiainen', about: 'Palasin juuri uudesta koulustani, sain tänään tietää, että minun ei tarvitse osallistua ollenkaan ruotsin kielen tunneille, sillä kielitaitoni on niin vahva! Jee, tosi hienoa, saan skipattua kuulemma koko kurssin! Asuin vuonna -98 Ruotsissa ja opiskelin ruotsin kieltä Uppsalan yliopistossa, joten minun ei tarvitse käydä perusasioita enää läpi. Sama juttu englannin kielessä, opettelen ainoastaan bisnes-sanastoa.'

user.hashtags.create tag: 'lätkämutsit'
user.hashtags.create tag: 'avantouinti'


