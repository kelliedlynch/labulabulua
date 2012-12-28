local _C = {}
--script = require "Resources/Conversations/steve001"

local function setupConversation(conversation)
	-- Create the conversation layers
	bgLayer = MOAILayer.new ()
	bgLayer:setViewport ( viewport )
	MOAISim.pushRenderPass ( bgLayer )

	spriteLayer = MOAILayer.new ()
	spriteLayer:setViewport ( viewport )
	MOAISim.pushRenderPass ( spriteLayer )

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

local function drawSpeakerNameBox ()
	if not nameBG then
		gradient1 = Meshes2D.newGradient( "#00CC00", "#0099FF", 45 )
		nameBG = Meshes2D.newRect( -150 , -70 , 120 , 30 , gradient1 )
		convoLayer:insertProp( nameBG )
	end

	if not nameTextbox then
		nameTextbox = MOAITextBox.new ()
		nameTextbox:setStyle ( newStyle ( defaultFont , 44 ))
		nameTextbox:setRect ( -150 , -70 , -30 , -40 )
		nameTextbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
		nameTextbox:setYFlip(true)
		convoLayer:insertProp ( nameTextbox )
	end
	-- if s and #s > 0 then
	-- 	nameTextbox:setString ( s )
	-- end
end

local function drawMainTextBox()
	if not mainTextBG then
		gradient1 = Meshes2D.newGradient( "#00CC00", "#0099FF", 45 )
		mainTextBG = Meshes2D.newRect( -150 , -230 , 300 , 150 , gradient1 )
		convoLayer:insertProp( mainTextBG )
	end

	if not mainTextbox then
		mainTextbox = MOAITextBox.new ()
		mainTextbox: setStyle (newStyle ( defaultFont, 38 ))
		mainTextbox:setRect ( -140 , -230 , 140 , -90 )
		mainTextbox:setAlignment (MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
		mainTextbox:setYFlip ( true )
		convoLayer:insertProp ( mainTextbox )
	end
end

local function displaySpeakerSprite( img )
	spriteTexture = MOAITexture.new ( )
	spriteTexture:load ( "Resources/Images/"..img )
	texX, texY = spriteTexture:getSize()
	scaleFactor = texY / 380
	texX = texX / scaleFactor
	texY = texY / scaleFactor

	gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( spriteTexture )
	gfxQuad:setRect ( -(texX / 2) , - 240 + texY , -(texX/2) + texX , -240  )
	gfxQuad:setUVRect ( 0, 0, 1, 1 )

	prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	spriteLayer:insertProp ( prop )
end

local function page ( text , tbox )
	tbox:setString ( text )
	tbox:spool ()
end

local function clearNode()
	convoLayer:clear()
	spriteLayer:clear()
	nameBG, nameTextbox, mainTextBG, mainTextbox = nil
end

local function goToNode(n)
	clearNode()
	_currentNodeKey , _currentNode = n , script[n]
	drawSpeakerNameBox()
	drawMainTextBox()
	if _currentNode.portrait ~= "" then
		displaySpeakerSprite( _currentNode.portrait )
	end
	
	print("calling registerListener for mainTextBG")
	TouchDispatcher.registerListener(mainTextBG, "advanceTextbox", mainTextbox)
	nameTextbox:setString(_currentNode.speaker)
	page ( _currentNode.text , mainTextbox )
end

local function displayChoices ( self ) 
	for k,v in pairs(_currentNode.choices) do
		for kk, vv in pairs(v) do
			print(kk , vv)
		end
	end
	require "LLMenu"
	makeMenu(_currentNode.choices)
end

local function advanceTextbox(box)
	if box:isBusy () then
		box:stop()
		box:revealAll()
		TouchDispatcher.registerListener(mainTextBG, "advanceTextbox", box)
	else
		if box:more() then
			box:nextPage ()
			box:spool()
			TouchDispatcher.registerListener(mainTextBG, "advanceTextbox", box)
		elseif _currentNode.choices then
			displayChoices()
		elseif _currentNode.exit then
			print("end of conversation")
		elseif _currentNode.goToNode then
			goToNode(_currentNode["goToNode"])
		elseif _currentNode.goToConv then
			_C.goToConversation(_currentNode.goToConv.file , _currentNode.goToConv.node)
		else
			_currentNodeKey, _currentNode = nextNode(script, _currentNodeKey)
			goToNode(_currentNodeKey)
		end
	end
end

function _C.goToConversation(file, node)
	print("loading ", file)
	script = require ("Resources/Conversations/"..file)
	setupConversation(script)

	print(node)
	if node then
		print("true")
		goToNode(node)
	else
		print("false")
		-- Load the first node
		_currentNodeKey, _currentNode = nextNode(script)
		goToNode(_currentNodeKey)
	end
end

_C.options = {
	advanceTextbox = function(box) advanceTextbox(box) end,
	goToNode = 	function(n) goToNode(n) end,
	goToConv = function(file, node) _C.goToConversation(file, node) end,
}

return _C