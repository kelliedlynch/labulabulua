local _C = {
	default = {
		speaker = "Steve",
		portrait = "steve001portrait.png",
		background = "room002.png",
		text = "default text",
		music = "nintendo.ogg",
	},
	root = {
		speaker = "",
		text = "Basic dialogue with no speaker. Let's make it longer so that we can test paging. Text, text, lots of text. I hope this is enough. Let's do one more sentence, just to be sure. And one more, because even after increasing the font size, that wasn't enough. Sheesh.",
		portrait = "",
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
		portrait = "steve002portrait.png",
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
		portrait = "steve003portrait.png",
		text = "Let's take a bath!",
		background = "bubblebath.png",
		getItem = { ["rubber duckie"] = -1, },
		goToNode = 11,
	},
	[10] = {
		portrait = "steve003portrait.png",
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
	--{sound::crash.wav}{shake::steve001portrait.png}
	-- after 20 chars, delay should be 1.111, but is actually 1.18333
	-- .06666 .05 .06667 .05 .05 .06666 
		enterAction = {},
		exitAction = {
			sound = "crash.wav"
			shake = "steve001portrait.png"
		},
		text = "I see he gave you a sonic screwdriver. Try pointing it at the chandelier.",
		goToNode = 3,
	},
}

return _C