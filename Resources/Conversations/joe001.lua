local _C = {
	default = {
		speaker = "Joe",
		portrait = {"joe001portrait.png",},
		background = "room003.png",
		text = "default text",
		music = "potion_shop.ogg",
	},
	root = {
		text = "Hi, I'm Joe. Take this sonic screwdriver.",
		getItem = { ["sonic screwdriver"] = 1, ["another thing"] = 5 },
	},
	[3] = {
		text = "I have to give you one other thing. What do you want?",
		choices = {
			["rubber duckie"] = {
				getItem = { ["rubber duckie"] = 1, },
				setVar = { itemName = "rubber duckie", },
				goToNode = 4,
			},
			["shiny nickel"] = {
				getItem = { ["shiny nickel"] = 1, },
				setVar = { itemName = "shiny nickel", },
				goToNode = 4,
			},
		},
	},
	[4] = {
		boxStyle = "thought",
		speaker = Player.name,
		portrait = {},
		text = "What am I going to do with this?",
		goToConv = { 
			file = "steve001", 
			node = 7,
		},
	},
}
return _C