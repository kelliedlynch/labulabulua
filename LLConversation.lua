local _C = {}

_C.__index = _C

--------------------------------------------------------------------
-- Conversation States
--------------------------------------------------------------------

CHARACTER_SPEAKING = 1
MENU_VISIBLE = 2
NOTIFICATION_VISIBLE = 3

--------------------------------------------------------------------
--------------------------------------------------------------------
--
-- Public Functions
--
--------------------------------------------------------------------
--------------------------------------------------------------------
function _C.new(file, node)
	--------------------------------------------------------------------
	-- Create a new conversation object from the specified script file
	--------------------------------------------------------------------
	local conv = {}
	setmetatable(conv, _C)
	
	-- Load script, and set up metatable for script defaults
	local script = require ("Resources/Conversations/"..file)
	conv.script = _C.__setupScriptDefaults(script)

	conv.currentState = {}
	conv.notificationQueue = {}

	-- Begin listening for the startConversation event
	LLDispatcher.registerEventListener(conv, "startConversation", node)

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

function _C:__goToConversation(file, node)
	self.script = _C.__setupScriptDefaults(require ("Resources/Conversations/"..file))
	self:__goToNode(node or self:__nextNode())
end

function _C:__nextNode(currentKey)
	-- Returns the key of the next conversation node. If no current key
	-- is provided, the root (entry point) will be returned.
    if currentKey then
        if type(currentKey) == "string" then
        	-- scripts are currently structured such that "root" is at index 2,
        	-- so if currentKey is a string, next key is 3
            currentKey = 3 
        else currentKey = currentKey + 1 end
    else currentKey = "root" end
    return currentKey
end

function _C:__goToNode(n)
	-- draw all the node elements
	self.oldNode = self.currentNode
	self.currentNodeKey , self.currentNode = n , deepcopy(self.script[n])
	self.background = self:__displayBackground(self.currentNode.background)
	self.speakerNameBox = self:__drawSpeakerNameBox(self.currentNode.speaker)
	self.speakerSprite = self:__displaySpeakerSprite(self.currentNode.portrait)
	self.speakerTextTextbox = self:__drawMainTextBox(self.currentNode.text)

	-- wait for touches
	self.currentState[CHARACTER_SPEAKING] = true
	LLDispatcher.registerEventListener(self, "nodeTextFinished")
end

function _C:__setNextConversationNode(n)
	self.currentNode.nextConversationNode = n
end

function _C:__displayBackground(img)
	if self.oldNode and img == self.oldNode.background then
		return self.background
	else
		LLDispatcher.removeListenersForProp(self.background)
		BackgroundLayer:clear()
		if img == "" then 
			return nil 
		end

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
		LLDispatcher.registerPersistentTouchListener(self, prop, "screenTouched")
		return prop
	end
end

function _C:__displaySpeakerSprite(img)
	if self.oldNode and img == self.oldNode.portrait then
		return self.speakerSprite
	else
		SpriteLayer:clear()
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
--------------------------------------------------------------------
--
-- Functions for processing end-of-node stuff
--
-- All this stuff should stay together; it all happens in the order
-- laid out.
--
--------------------------------------------------------------------
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
	-- Add all node items to player inventory, displaying notifications about each one.
	if self.currentNode.getItem and not node then
		for item, qty in pairs(self.currentNode.getItem) do
			self:__getItem(item, qty)
		end
		self.currentNode.getItem = nil
	elseif self.currentNode.getItem then
		print("node was set on __getNodeItems")
	end
end

function _C:__getSpecifiedItems(items)
	-- add all items from a list to the player's inventory
	for item, qty in pairs(items) do
		self:__getItem(item, qty)
	end
end

function _C:__getItem(item, qty)
	-- get a single item and add it to the player's inventory
	table.insert (Player.items , { [item] = 1, })
	local qtyMod
	if qty > 1 then
		qtyMod = " x"..qty
	end
	local text = "Got item: "..item..(qtyMod or "")

	for k, i in pairs(Player.items) do
		for name, q in pairs(i) do
			if name == item then
				Player.items[k][name] = Player.items[k][name] + qty
			end
		end
	end

	-- if self.currentNode.getItem then
	-- 	self.currentNode.getItem[item] = nil
	-- end
	self:__displayNotification(text)
end

function _C:__setNodeVars(node)
	-- Set all node variables. Player should not be notified.
	if node.setVar then
		self.__setVar(node.setVar)
		node.setVar = nil
	end
	if node.changeVar then
		self.__changeVar(node.changeVar)
		node.changeVar = nil
	end
end

function _C:__setVar(vars)
	for var, value in pairs(vars) do
		Player.variables[var] = value
	end
end

function _C:__changeVar(vars)
	for var, value in pairs(vars) do
		Player.variables[variable] = Player.variables[variable] + value
	end
end

function _C:__setNodeStats(node)
	-- Set all node stats and notify player of changes
	if node.setStat then
		for stat, value in pairs(node.setStat) do
			self:__setStat(stat,value)
		end
		node.setStat = nil
	end
	if node.changeStat then
		for stat, value in pairs(node.changeStat) do
			self:__changeStat(stat,value)
		end
		node.changeStat = nil
	end
end

function _C:__setStat(stat, value)
	Player[stat] = value
	local text = stat.." is now "..value
	self.currentNode.setStat[stat] = nil
	self:__displayNotification(text)
end

function _C:__changeStat(stat, value)
	Player[stat] = Player[stat] + value
	if value < 0 then
		operator = " decreased by "
	else
		operator = " increased by "
	end

	local text = stat..operator..value
	self.currentNode.changeStat[stat] = nil
	self:__displayNotification(text)
end

--------------------------------------------------------------------
-- End of end-of-node processing
--------------------------------------------------------------------

function _C:__displayChoices ()
	for choice, actions in pairs(self.currentNode.choices) do
	 	for action, data in pairs(actions) do
	 		if action == "getItem" then
	 			self.currentNode.choices[choice]["getSpecifiedItems"] = self.currentNode.choices[choice]["getItem"]
	 			self.currentNode.choices[choice]["getItem"] = nil
	 		end
	 		if action == "goToNode" then
	 			self.currentNode.choices[choice]["setNextConversationNode"] = self.currentNode.choices[choice]["goToNode"]
	 			self.currentNode.choices[choice]["goToNode"] = nil
	 		end
	 	end
	end
	self.menu = LLMenu.new()
	self.menu:makeMenu(self, MenuLayer, self.currentNode.choices)
	self.currentState[MENU_VISIBLE] = true
	LLDispatcher.registerEventListener(self, "removeMenu")
end

function _C:__onRemoveMenu()
	self.currentState[MENU_VISIBLE] = nil
	if self.currentNode.nextConversationNode and not self.currentState[NOTIFICATION_VISIBLE] then
		self:__goToNode(self.currentNode.nextConversationNode)
	end
end

function _C:__displayNotification(text)
	print("running __displayNotification")
	if self.currentState[NOTIFICATION_VISIBLE] then
		table.insert(self.notificationQueue, text)
		return
	elseif #self.notificationQueue == 0 then
		-- if there's no queue, then this is the first notification queued
		-- registering listener for all notifications cleared
		print("registering allNotificationsCleared")
		LLDispatcher.registerEventListener(self, "allNotificationsCleared")
	end

	local gradient1 = Meshes2D.newGradient( "#CC33CC", "#0099FF", 45 )
	local notificationBG = Meshes2D.newRect( 40 , 215 , 280 , 260 , gradient1 )
	PopupLayer:insertProp( notificationBG )

	self.notificationTextbox = MOAITextBox.new ()
	self.notificationTextbox:setStyle ( newStyle ( defaultFont , 44 ))
	self.notificationTextbox:setRect ( 45 , 220 , 275 , 255 )
	self.notificationTextbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	self.notificationTextbox:setYFlip(true)
	PopupLayer:insertProp ( self.notificationTextbox )
	self.notificationTextbox:setString(text)

	self.currentState[NOTIFICATION_VISIBLE] = true
	-- start listening for the clearNotification event
	LLDispatcher.registerEventListener(self, "clearNotification")
end

function _C:__onClearNotification()
	PopupLayer:clear()
	LLDispatcher.removeListenersForProp(self.notificationTextbox)
	LLDispatcher.removeListenersForProp(self.speakerTextTextbox)
	self.currentState[NOTIFICATION_VISIBLE] = nil

	-- if there are still notifications to display, go right on to the next one
	print("queued notifications",#self.notificationQueue)
	if #self.notificationQueue > 0 then
		k, text = next(self.notificationQueue)
		self:__displayNotification(text)
		table.remove(self.notificationQueue, k)
	else
		LLDispatcher.triggerEvent("allNotificationsCleared")
	end
end

--------------------------------------------------------------------
--------------------------------------------------------------------
--
-- onTouch Responders
-- 
--------------------------------------------------------------------
--------------------------------------------------------------------

function _C:__onScreenTouched()
	for k,v in pairs(self.currentState) do
		print("state",k,v)
	end
	if self.currentState[CHARACTER_SPEAKING] then
		self:__advanceBox(self.speakerTextTextbox, "nodeTextFinished")
	elseif self.currentState[NOTIFICATION_VISIBLE] then
		self:__advanceBox(self.notificationTextbox, "clearNotification", true)
	elseif not self.currentState[MENU_VISIBLE] then
		self:__exitNode()
	end
end

function _C:__advanceBox(box, callback, noSpool)
	--------------------------------------------------------------------
	-- Advances a textbox. Displays all text if it's currently scrolling
	-- or displays next page if there is one. Fires callback event on
	-- completion.
	--------------------------------------------------------------------
	if box:isBusy() then
		box:stop()
		box:revealAll()
	elseif box:more() then
		box:nextPage()
		if noSpool then
			box:revealAll()
		else
			box:spool()
		end
	else
		-- box is done, now trigger the 'done' event
		--LLDispatcher.removeListenersForProp(box)
		LLDispatcher.triggerEvent(callback)
	end
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
		self.currentNodeKey = self:__nextNode()
		self:__goToNode(self.currentNodeKey)
	end
end

--------------------------------------------------------------------
-- End-of-node event responders
--------------------------------------------------------------------

function _C:__onNodeTextFinished()
	self.currentState[CHARACTER_SPEAKING] = nil
	-- Process conditionals first, because they may add other things to do.
	self:__checkConditionals(self.currentNode)

	-- We're going to process items first, then vars, then stats
	if self.currentNode.getItem then 
		self:__getNodeItems()
	end
	if self.currentNode.setVar or self.currentNode.changeVar then 
		self:__setNodeVars(self.currentNode)
	end

	if self.currentNode.setStat or self.currentNode.changeStat then 
		self:__setNodeStats(self.currentNode)
	end

	if self.currentNode.choices then
		self:__displayChoices()
	elseif not self.currentState[NOTIFICATION_VISIBLE] then
		print("notification not visible, exiting node")
		self:__exitNode()
	end
end

function _C:__exitNode()
	-- All processing has been done on the node, so now we exit
	if self.currentNode.exit then
		print("end of conversation")
	elseif self.currentNode.goToNode then
		self:__goToNode(self.currentNode["goToNode"])
	elseif self.currentNode.nextConversationNode then
		self:__goToNode(self.currentNode.nextConversationNode)
	elseif self.currentNode.goToConv then
		self.__goToConversation(self, self.currentNode.goToConv.file , self.currentNode.goToConv.node)
	else
		print("going to next node")
		self:__goToNode(self:__nextNode(self.currentNodeKey))
	end
end

function _C:__onAllNotificationsCleared()
	self:__exitNode()
end

--------------------------------------------------------------------
-- End end-of-node event responders
--------------------------------------------------------------------

return _C