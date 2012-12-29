local _C = {
	default = {
		speaker = "Steve",
		portrait = "steve001portrait.png",
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
			file = "joe001"
		},
	},
	[7] = {
		text = "Finally, you're back. What did you get?",
	},
	[8] = {
		text = "A {itemName}? What are you going to do with that?",
		goToNode = 3,
	}
}
return _C