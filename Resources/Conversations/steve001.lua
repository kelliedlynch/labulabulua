local _C = {
	default = {
		speaker = "Steve",
		portrait = {"steve001portrait.png",},
		background = "room002.png",
		text = "default text",
		music = "nintendo.ogg",
	},
	root = {
		speaker = {},
		text = "Basic dialogue with no speaker. Let's make it longer so that we can test paging. Text, text, lots of text. I hope this is enough. Let's do one more sentence, just to be sure. And one more, because even after increasing the font size, that wasn't enough. Sheesh.",
		portrait = {""},
	},
	[3] = {
		text = "Hi, I'm Steve. I'm saying some basic dialogue.",
	},
	[4] = {
		text = "Choice with a goto: dost thou love me?",
		choices = {
			yes = { goToNode = 6 },
			no = { goToNode = 5 },
		},
	},
	[5] = {
		text = "But thou must!",
		goToNode = 4,
	},
	[6] = {
		text = "Good. Now talk to my friend Joe.",
		goToConv = {
			file = "joe001",
		},
	},
	[7] = {
		text = "Finally, you're back. What did you get?",
	},
	[8] = {
		portrait = {"steve002portrait.png",},
		text = "A {itemName}? What are you going to do with that? Wait, I have an idea.",
		conditional = { {
			condition = "itemName",
			results = { 
				["rubber duckie"] = { goToNode = 9, }, 
				["shiny nickel"] = { goToNode = 10, },
			}, },
		},
		--goToNode = 11,
	},
	[9] = {
		portrait = {"steve003portrait.png",},
		text = "Let's take a bath!",
		background = "bubblebath.png",
		getItem = { ["rubber duckie"] = -1, },
		goToNode = 11,
	},
	[10] = {
		portrait = {"steve003portrait.png",},
		text = "Let's get bubblegum!",
		background = "gumballmachine.png",
		getItem = { ["shiny nickel"] = -1, },
		goToNode = 11,
	},
	[11] = {
		text = "Well, that was silly.",
		changeStat = { silliness = 1, },
	},
	[12] = {
		--enterAction = { shake = "steve001portrait.png", },
		exitAction = {
			--pause = 5,
			sound = "crash.wav",
			shake = "steve001portrait.png",
		},
		text = "I see he gave you a sonic screwdriver. Try pointing it at the chandelier.",
	},
	[13] = {
		text = "On second thought, that's a terrible idea.",
	},
	[14] = {
		addCharacter = {
			portrait = {"joe001portrait.png",},
			animate = "fromLeft",
		},
		portrait = { "steve001portrait.png", },
		speaker = "Joe",
		text = "What was that noise? What have you done to the chandelier?",
	},
	[15] = {
		portrait = { "joe001portrait.png", "steve001portrait.png", },
		text = "What does it look like? {player} broke it.",
	},
	[16] = {
		removeCharacter = {
			portrait = {"joe001portrait.png"},
			animate = "toLeft",
		},
		portrait = { "joe001portrait.png", "steve001portrait.png", },
		speaker = "Joe",
		text = "*sigh* I'll go get the broom.",
		goToNode = 3,
	},
}

return _C