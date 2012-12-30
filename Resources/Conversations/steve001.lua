local _C = {
	default = {
		speaker = "Steve",
		portrait = "steve001portrait.png",
		background = "room002.png",
		text = "default text",
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
		goToNode = 11,
	},
	[10] = {
		portrait = "steve003portrait.png",
		text = "Let's get bubblegum!",
		background = "gumballmachine.png",
		goToNode = 11,
	},
	[11] = {
		text = "Well, that was silly.",
		changeStat = { silliness = 1, },
		goToNode = 3,
	}
}

return _C