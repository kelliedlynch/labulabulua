local _C = {}

--local Conversation = {}

local function setupConversation(conversation)
	-- Create the conversation layers
	if bgLayer then bgLayer:clear() end
	bgLayer = MOAILayer.new ()
	bgLayer:setViewport ( viewport )
	MOAISim.pushRenderPass ( bgLayer )

	if spriteLayer then spriteLayer:clear() end
	spriteLayer = MOAILayer.new ()
	spriteLayer:setViewport ( viewport )
	MOAISim.pushRenderPass ( spriteLayer )

	if convoLayer then convoLayer:clear() end
	convoLayer = MOAILayer.new ()
	convoLayer:setViewport ( viewport )
	MOAISim.pushRenderPass ( convoLayer )


	-- Set up metatable for conversation script;
	-- Any attempt to access a key that does not exist will return the default for that key,
	-- if it exists.
	local mt = {}
	mt.__index = conversation.default
	for k,v in pairs(conversation) do
		if k ~= "default" then
			setmetatable(v, mt)
		end
	end
end

local function nextNode(conv, currentKey)
	-- Returns the key and value of the next conversation node. If no current key
	-- is provided, the root (entry point) will be returned.
    if currentKey then
        if type(currentKey) == "string" then
            currentKey = 3
        else
            currentKey = currentKey + 1
        end
    else
        currentKey = "root"
    end
    return currentKey, conv[currentKey]
end

local function displayBackground( img )
	if img == "" then
		return nil
	end
	local spriteTexture = MOAITexture.new ( )
	spriteTexture:load ( "Resources/Images/"..img )
	local texX, texY = spriteTexture:getSize()
	-- use screen height to determine scale
	local scaleFactor = texY / 480
	texX = texX / scaleFactor
	texY = texY / scaleFactor

	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( spriteTexture )
	gfxQuad:setRect ( -160 , 240 , 160 , -240  )
	gfxQuad:setUVRect ( 0, 0, 1, 1 )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )

	bgLayer:insertProp ( prop )

	return prop
end

local function drawSpeakerNameBox(name)
	if name == "" then
		return nil
	else
		if not nameBG then
			local gradient1 = Meshes2D.newGradient( "#00CC00", "#0099FF", 45 )
			local nameBG = Meshes2D.newRect( -150 , -70 , 120 , 30 , gradient1 )
			convoLayer:insertProp( nameBG )
		end

		if not nameTextbox then
			local nameTextbox = MOAITextBox.new ()
			nameTextbox:setStyle ( newStyle ( defaultFont , 44 ))
			nameTextbox:setRect ( -150 , -70 , -30 , -40 )
			nameTextbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
			nameTextbox:setYFlip(true)
			convoLayer:insertProp ( nameTextbox )
			nameTextbox:setString(name)
			return nameTextBox
		end
	end
	return nil
end

local function page ( text , tbox )
	tbox:setString ( text )
	tbox:spool ()
end

local function drawMainTextBox(text)
	if text == "" then
		return nil
	else
		if not mainTextBG then
			local gradient 
			if _currentNode.boxStyle == "thought" then
				gradient = Meshes2D.newGradient( "#AACC00", "#AA99FF", 45 )
			else
				gradient = Meshes2D.newGradient( "#00CC00", "#0099FF", 45 )
			end
			local mainTextBG = Meshes2D.newRect( -150 , -230 , 300 , 150 , gradient )
			convoLayer:insertProp( mainTextBG )
		end


		if not mainTextbox then
			local mainTextbox = MOAITextBox.new ()
			mainTextbox:setStyle (newStyle ( defaultFont, 38 ))
			mainTextbox:setRect ( -140 , -230 , 140 , -90 )
			mainTextbox:setAlignment (MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
			mainTextbox:setYFlip ( true )
			-- mainTextbox:setDeck()
			-- mainTextbox:setPriority(100)
			convoLayer:insertProp ( mainTextbox )
			page( text , mainTextbox )
			return mainTextbox
		end
	end
	return nil
end

local function displaySpeakerSprite( img )
	if img == "" then
		return nil
	end
	local spriteTexture = MOAITexture.new ( )
	spriteTexture:load ( "Resources/Images/"..img )
	local texX, texY = spriteTexture:getSize()
	local scaleFactor = texY / 380
	texX = texX / scaleFactor
	texY = texY / scaleFactor

	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( spriteTexture )
	gfxQuad:setRect ( -(texX / 2) , - 240 + texY , -(texX/2) + texX , -240  )
	gfxQuad:setUVRect ( 0, 0, 1, 1 )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )

	spriteLayer:insertProp ( prop )

	return prop
end

local function clearNode()
	convoLayer:clear()
	spriteLayer:clear()
	nameBG, nameTextbox, mainTextBG, mainTextbox, _currentNode, _currentNodeKey = nil
end

local function replaceVariables(str)
	local formatted, count = string.gsub(str, "{([^}]+)}", 
		function(varName)
			return Player.variables[varName]
		end
		)
	return formatted
end

function deepcopy(orig)
	-- deepcopy function from lua-users wiki
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function goToNode(n)
	clearNode()
	_currentNodeKey , _currentNode = n , deepcopy(script[n])
	background = displayBackground(_currentNode.background)
	speakerNameBox = drawSpeakerNameBox(_currentNode.speaker)
	speakerTextBox = drawMainTextBox(replaceVariables(_currentNode.text))
	speakerSprite = displaySpeakerSprite( _currentNode.portrait )
	
	TouchDispatcher.registerListener(_C, speakerTextBox , "advanceTextbox", speakerTextBox)
	
	
end

local function displayChoices ( self ) 
	require "LLMenu"
	makeMenu(_currentNode.choices)
end

local function getItem(item, qty)
	table.insert (Player.items , { [item] = 1, })
end

local function setVar(variable, value)
	Player.variables[variable] = value
end

local function changeVar(variable, value)
	Player.variables[variable] = Player.variables[variable] + value
end

local function setStat(stat, value)
	Player[stat] = value
end

local function changeStat(stat, value)
	Player[stat] = Player[stat] + value
end

local function checkConditionals(node)
	-- Check if any of the current node's conditional statements are true
	-- First they are checked against the Player.variables (game state) table.
	-- Then against Player (player stats).
	if node.conditional then
		node.checkedConditional = nil
		node.checkedConditional = node.conditional
		node.conditional = nil

		for _,item in pairs(node.checkedConditional) do
			for result, actionTable in pairs(item.results) do
				if Player.variables[item.condition] == result then
					for action, data in pairs(actionTable) do
						node[action] = data
					end
				elseif Player[item.condition] == result then
					for action, data in pairs(actionTable) do
						node[action] = data
					end
				end
			end
		end
		node.checkedConditional = nil
	end

	-- If there were any nested conditionals, they have just been added to the node.
	-- Check the node again.
	if node.conditional then
		checkConditionals(node)
	end
end

local function advanceTextbox(box)
	if box:isBusy () then
		box:stop()
		box:revealAll()
		TouchDispatcher.registerListener(_C, speakerTextBox, "advanceTextbox", box)
	else
		if box:more() then
			box:nextPage()
			box:spool()
			TouchDispatcher.registerListener(_C, speakerTextBox, "advanceTextbox", box)
		else
			-- Do conditionals first, because they may add other things to do.
			checkConditionals(_currentNode)

			if _currentNode.getItem then
				for k,v in pairs(_currentNode.getItem) do
					getItem( k,v)
				end
			end
			if _currentNode.setVar then
				for k,v in pairs(_currentNode.setVar) do
					setVar(k,v)
				end
			end
			if _currentNode.changeStat then
				for k,v in pairs(_currentNode.changeStat) do
					changeStat(k,v)
				end
			end

			if _currentNode.choices then
				displayChoices()
			elseif _currentNode.exit then
				print("end of conversation")
			elseif _currentNode.goToNode then
				goToNode(_currentNode["goToNode"])
			elseif _currentNode.goToConv then
				_C.goToConversation(_currentNode.goToConv.file , _currentNode.goToConv.node)
			else
				goToNode(nextNode(script, _currentNodeKey))
			end
		end
	end
end

function _C.goToConversation(file, node)
	script = require ("Resources/Conversations/"..file)
	setupConversation(script)

	if node then
		goToNode(node)
	else
		-- Load the first node
		_currentNodeKey, _currentNode = nextNode(script)
		goToNode(_currentNodeKey)
	end
end

-- The following are possible responses to touch events from TouchDispatcher.
-- This table is necessary for LLMenu to be able to pass the name of an action
-- to TouchDispatcher; otherwise all conversation options would need to be global.
-- Maybe that wouldn't be such a bad thing...
_C.options = {
	advanceTextbox = function(box) advanceTextbox(box) end,
	goToNode = 	function(n) goToNode(n) end,
	goToConv = function(file, node) _C.goToConversation(file, node) end,
	getItem = function(table) 
					for k,v in pairs(table) do
						getItem(k, v) 
					end
				end,
	setVar = function(table)
					for k,v in pairs(table) do
						setVar(k,v)
					end
				end,
}

return _C