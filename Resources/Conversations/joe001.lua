local _C = {
	default = {
		speaker = "Joe",
		portrait = "joe001portrait.png",
		text = "default text",
	},
	root = {
		text = "Hi, I'm Joe. Take this sonic screwdriver.",
		getItem = "sonic screwdriver",
	},
	[3] = {
		text = "I have to give you one other thing. What do you want?",
		choices = {
			["rubber duckie"] = {
				getItem = "rubber duckie",
				goToNode = 4,
			},
			["shiny nickel"] = {
				getItem = "shiny nickel",
				goToNode = 4,
			},
		},
	},
	[4] = {
		boxStyle = "thought",
		speaker = player,
		text = "What am I going to do with this?",
		goToConv = { 
			file = "steve001", 
			node = 7,
		},
	},
}
return _C