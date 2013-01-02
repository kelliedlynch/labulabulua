local _C = {}

_C.__index = _C

--------------------------------------------------------------------
--------------------------------------------------------------------
--
-- Public Functions
--
--------------------------------------------------------------------
--------------------------------------------------------------------
function _C.new(file)
	--------------------------------------------------------------------
	-- Create a new conversation object from the specified script file
	--------------------------------------------------------------------
	local conv = {}
	setmetatable(conv, _C)
	
	-- Load script, and set up metatable for script defaults
	local script = require ("Resources/Conversations/"..file)
	conv.script = _C.__setupScriptDefaults(script)

	-- Begin listening for the startConversation event
	LLDispatcher.registerEventListener(conv, "startConversation")

	return conv
end

--------------------------------------------------------------------
--------------------------------------------------------------------
-- 
-- Private Functions
--
--------------------------------------------------------------------
--------------------------------------------------------------------

function _C.__setupScriptDefaults(script)
	local mt = {}
	mt.__index = script.default
	for k,v in pairs(script) do
		if k ~= "default" then
			setmetatable(v, mt)
		end
	end
	return script
end

-- Function for switching scripts mid-conversation. Might also be used
-- when first loading conversation. Examine later.
-- function _C.__changeScript(file, node)
-- 	local script = require ("Resources/Conversations/"..file)
-- 	conv.script = _C.__setupScriptDefaults(script)
-- end

function _C.__nextNode(conv, currentKey)
	-- Returns the key and value of the next conversation node. If no current key
	-- is provided, the root (entry point) will be returned.
    if currentKey then
        if type(currentKey) == "string" then
        	-- scripts are currently structured such that "root" is at index 2,
        	-- so if currentKey is a string, next key is 3
            currentKey = 3 
        else currentKey = currentKey + 1 end
    else currentKey = "root" end
    return currentKey, conv[currentKey]
end

function _C:__goToNode(n)
	-- draw all the node elements
	self.currentNodeKey , self.currentNode = n , deepcopy(self.script[n])
	self.background = self.__displayBackground(self.currentNode.background)
	self.speakerNameBox = self:__drawSpeakerNameBox(self.currentNode.speaker)
	self.speakerTextTextbox = self:__drawMainTextBox(self.currentNode.text)
	self.speakerSprite = self.__displaySpeakerSprite( self.currentNode.portrait )

	-- wait for touches
	LLDispatcher.registerTouchListener(self, self.speakerTextTextbox, "textboxTapped", self.speakerTextTextbox)
	-- LLDispatcher.registerEventListener(self.speakerTextTextbox, "boxTapped" )
	LLDispatcher.registerEventListener(self, "nodeTextFinished")
end

function _C.__displayBackground(img)
	if img == "" then return nil end

	local spriteTexture = MOAITexture.new()
	spriteTexture:load("Resources/Images/"..img)

	local gfxQuad = MOAIGfxQuad2D.new()
	gfxQuad:setTexture (spriteTexture)
	gfxQuad:setRect (0, 0, screenWidth, screenHeight)

	--------------------------------------------------------------------
	-- The following will make room003.png display properly if it is
	-- padded out to power-of-2 dimensions (1024 x 2048). Look into this
	-- later; optimizing textures may improve performance.
	--------------------------------------------------------------------
	-- gfxQuad:setQuad (0, 683, 381, 683, 381, 0, 0, 0)

	local prop = MOAIProp2D.new ()
	prop:setDeck(gfxQuad)
	BackgroundLayer:insertProp(prop)

	return prop
end

function _C.__displaySpeakerSprite(img)
	if img == "" then return nil end
	local spriteTexture = MOAITexture.new()
	spriteTexture:load ( "Resources/Images/"..img )
	local texX, texY = spriteTexture:getSize()
	local scaleFactor = texY / 380
	texX = texX / scaleFactor
	texY = texY / scaleFactor

	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( spriteTexture )
	gfxQuad:setRect ( screenWidth / 2 - texX / 2 , 0 , screenWidth / 2 + texX / 2 , texY  )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	SpriteLayer:insertProp ( prop )

	return prop
end

function _C:__drawSpeakerNameBox(name)
	if name == "" then return nil else
		local gradient
		if self.currentNode.boxStyle == "thought" then
			gradient = Meshes2D.newGradient( "#fcecfc", "#ff7cd8", 45 )
		else
			gradient = Meshes2D.newGradient( "#2c539e", "#3f4c6b", 45 )
		end
		local nameBG = Meshes2D.newRect( 10 , 170 , 130 , 200 , gradient )
		WindowLayer:insertProp( nameBG )

		local nameTextbox = MOAITextBox.new ()
		nameTextbox:setStyle ( newStyle ( defaultFont , 44 ))
		nameTextbox:setRect ( 10 , 170 , 130 , 200 )			
		nameTextbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
		nameTextbox:setYFlip(true)
		WindowLayer:insertProp ( nameTextbox )
		nameTextbox:setString(name)
		return nameTextBox
	end
	return nil
end

function _C:__drawMainTextBox(text)
	if text == "" then return nil else
		local gradient 
		if self.currentNode.boxStyle == "thought" then
			gradient = Meshes2D.newGradient( "#fcecfc", "#ff7cd8", 45 )
		else
			gradient = Meshes2D.newGradient( "#2c539e", "#3f4c6b", 45 )
		end
		local mainTextBG = Meshes2D.newRect( 10 , 10 , 300 , 150 , gradient )
		WindowLayer:insertProp( mainTextBG )

		local mainTextbox = MOAITextBox.new()
		mainTextbox:setStyle(newStyle(defaultFont, 38 ))
		mainTextbox:setRect(20 , 20 , 290 , 140 )
		mainTextbox:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
		mainTextbox:setYFlip(true)
		WindowLayer:insertProp(mainTextbox)
		self:__scrollText(text, mainTextbox)
		return mainTextbox
	end
	return nil
end

--------------------------------------------------------------------
-- Functions for processing text in conversation dialogue
--------------------------------------------------------------------
function _C.__replaceVariables(str)
	local formatted, count = string.gsub(str, "{([^}]+)}", 
		function(varName)
			return Player.variables[varName]
		end
		)
	return formatted
end

function _C:__scrollText(text, tbox)
	tbox:setString (self.__replaceVariables(text))
	tbox:spool ()
end

--------------------------------------------------------------------
-- Functions for processing end-of-node stuff
--------------------------------------------------------------------

function _C:__checkConditionals(node)
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
		self:__checkConditionals(node)
	end
end

function _C:__getNodeItems(node)
	-- add item to inventory
	-- display notification about item
	-- wait for touch
	-- add next item to inv.
	if node.getItem then
		item, qty = next(node.getItem)
		if item then
			self:__getItem(item, qty)
			-- after the item is gained and notification cleared, check for items again
			--LLDispatcher.registerEventListener(self, "notificationCleared", "__getNodeItems", node )
		end
	end
end

function _C:__getItem(item, qty)
	table.insert (Player.items , { [item] = 1, })
	local text = "Got item: "..item

	self.currentNode.getItem[item] = nil
	self:__displayNotification("Got item: "..item)
	--TouchDispatcher.registerListener(self, notificationTextBox, "clearNotification", box, false, TouchDispatcher.CONVERSATION_NOTIFICATION_PRIORITY)
	--TouchDispatcher.registerListener(self, speakerTextTextbox, "displayNotification", text)
end

function _C:__displayNotification(text)
	local gradient1 = Meshes2D.newGradient( "#CC33CC", "#0099FF", 45 )
	local notificationBG = Meshes2D.newRect( 40 , 215 , 280 , 260 , gradient1 )
	PopupLayer:insertProp( notificationBG )

	local notificationTextbox = MOAITextBox.new ()
	notificationTextbox:setStyle ( newStyle ( defaultFont , 44 ))
	notificationTextbox:setRect ( 45 , 220 , 275 , 255 )
	notificationTextbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	notificationTextbox:setYFlip(true)
	PopupLayer:insertProp ( notificationTextbox )
	notificationTextbox:setString(text)
	self.notificationVisible = true
	
	LLDispatcher.registerTouchListener(self, notificationTextbox, "clearNotification")
	LLDispatcher.registerTouchListener(self, self.speakerTextTextbox, "clearNotification")
end

--------------------------------------------------------------------
--------------------------------------------------------------------
--
-- onTouch Responders
-- 
--------------------------------------------------------------------
--------------------------------------------------------------------

function _C:__onTextboxTapped(box)
	if box:isBusy() then
		box:stop()
		box:revealAll()
		LLDispatcher.registerTouchListener(self, box, "textboxTapped", box)
	elseif box:more() then
		box:nextPage()
		box:spool()
		LLDispatcher.registerTouchListener(self, box, "textboxTapped", box)
	else
		LLDispatcher.triggerEvent("nodeTextFinished")
	end
end

function _C:__onClearNotification()
	PopupLayer:clear()
	-- self.notificationVisible = false
	-- TouchDispatcher.removeListenersForEvent("clearNotification")
	-- EventDispatcher.triggerEvent("notificationCleared")
	LLDispatcher.triggerEvent("notificationCleared")
end

--------------------------------------------------------------------
--------------------------------------------------------------------
--
-- onEvent Responders
--
--------------------------------------------------------------------
--------------------------------------------------------------------

function _C:__onStartConversation(node)
	--------------------------------------------------------------------
	-- Begin the conversation. Node is optional and will probably not be
	-- used much. If used, conversation will start on that node.
	--------------------------------------------------------------------
	if node then
		self:__goToNode(node)
	else
		-- Load the first node
		self.currentNodeKey, _ = self.__nextNode(self.script)
		self:__goToNode(self.currentNodeKey)
	end
end

function _C:__onNodeTextFinished()
	-- Process conditionals first, because they may add other things to do.
	self:__checkConditionals(self.currentNode)

	if self.currentNode.getItem then self:__getNodeItems(self.currentNode) end

	if self.currentNode.setVar then
		for k,v in pairs(self.currentNode.setVar) do
			self.__setVar(k,v)
		end
	end
	if self.currentNode.changeStat then
		for k,v in pairs(self.currentNode.changeStat) do
			self.__changeStat(k,v)
		end
	end
end

function _C:__onNotificationCleared(action, ...)
	--------------------------------------------------------------------
	-- Responder for notificationCleared events. Takes a function name
	-- and a table of parameters, even if function only takes one param
	--------------------------------------------------------------------
	self[action](self, ...)
end

return _C