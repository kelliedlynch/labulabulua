local _C = {}

_C.__index = _C

------------------------------------------------------------
-- Public Functions
------------------------------------------------------------
function _C.new(file, node)
	local conv = {}
	setmetatable(conv, _C)
	conv.script = require ("Resources/Conversations/"..file)
	_C.__setupScript(conv.script)
	-- if node then 
	-- 	conv.currentNodeKey = node
	-- 	conv.currentNode = conv[node]
	-- end
	return conv
end

function _C.goToConversation(self, file, node)
	print("self,file,node",self,file,node)
	print("conversation is", self)
	if file then
		self.script = require ("Resources/Conversations/"..file)
		self.__setupScript(self.script)
	end

	if node then
		self:__goToNode(node)
	else
		-- Load the first node
		self.currentNodeKey, self.currentNode = self.__nextNode(self.script)
		self:__goToNode(self.currentNodeKey)
	end
end

------------------------------------------------------------
-- Private Functions
------------------------------------------------------------

function _C.__setupScript(script)
	-- Set up metatable for conversation script;
	-- Any attempt to access a key that does not exist will return the default for that key,
	-- if it exists.
	local mt = {}
	mt.__index = script.default
	for k,v in pairs(script) do
		if k ~= "default" then
			setmetatable(v, mt)
		end
	end
end

function _C.__nextNode(conv, currentKey)
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

function _C.__displayBackground( img )
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
	gfxQuad:setRect ( 0 , 0 , 320 , 480  )
	--gfxQuad:setUVRect ( 0, 0, 1, 1 )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )

	BackgroundLayer:insertProp ( prop )

	return prop
end

function _C.__drawSpeakerNameBox(name)
	if name == "" then
		return nil
	else
		if not nameBG then
			local gradient1 = Meshes2D.newGradient( "#00CC00", "#0099FF", 45 )
			local nameBG = Meshes2D.newRect( 10 , 170 , 130 , 200 , gradient1 )
			WindowLayer:insertProp( nameBG )
		end

		if not nameTextbox then
			local nameTextbox = MOAITextBox.new ()
			nameTextbox:setStyle ( newStyle ( defaultFont , 44 ))
			nameTextbox:setRect ( 10 , 170 , 130 , 200 )
			nameTextbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
			nameTextbox:setYFlip(true)
			WindowLayer:insertProp ( nameTextbox )
			nameTextbox:setString(name)
			return nameTextBox
		end
	end
	return nil
end

function _C.__page(text, tbox)
	tbox:setString ( text )
	tbox:spool ()
end

function _C:__drawMainTextBox(text)
	if text == "" then
		return nil
	else
		if not mainTextBG then
			local gradient 
			if self.currentNode.boxStyle == "thought" then
				gradient = Meshes2D.newGradient( "#AACC00", "#AA99FF", 45 )
			else
				gradient = Meshes2D.newGradient( "#00CC00", "#0099FF", 45 )
			end
			local mainTextBG = Meshes2D.newRect( 10 , 10 , 300 , 150 , gradient )
			WindowLayer:insertProp( mainTextBG )
		end


		if not mainTextbox then
			local mainTextbox = MOAITextBox.new ()
			mainTextbox:setStyle (newStyle ( defaultFont, 38 ))
			mainTextbox:setRect ( 20 , 20 , 290 , 140 )
			mainTextbox:setAlignment (MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
			mainTextbox:setYFlip ( true )
			WindowLayer:insertProp ( mainTextbox )
			self.__page( text , mainTextbox )
			return mainTextbox
		end
	end
	return nil
end

function _C.__displaySpeakerSprite( img )
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
	gfxQuad:setRect ( screenWidth / 2 - texX / 2 , 0 , screenWidth / 2 + texX / 2 , texY  )

	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )

	SpriteLayer:insertProp ( prop )

	return prop
end

function _C:__clearNode()
	WindowLayer:clear()
	SpriteLayer:clear()
	nameBG, nameTextbox, mainTextBG, mainTextbox, self.currentNode, self.currentNodeKey = nil
end

function _C.__replaceVariables(str)
	local formatted, count = string.gsub(str, "{([^}]+)}", 
		function(varName)
			return Player.variables[varName]
		end
		)
	return formatted
end

function _C:__deepcopy(orig)
	-- deepcopy function from lua-users wiki
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:__deepcopy(orig_key)] = self:__deepcopy(orig_value)
        end
        setmetatable(copy, self:__deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function _C:__goToNode(n)
	print("self, n", self, n)
	--if there's a notification visible, wait for that
	if self.notificationVisible then
		print("notification is visible, wait for it to be cleared and call gotonode again")
		-- for k,v in pairs(n) do
		-- 	print("k,v in n",k,v)
		-- end
		-- EventDispatcher.registerEvent(self, "notificationCleared", self.__goToNode, n)
		EventDispatcher.registerEvent(self, "notificationCleared", self.__goToNode, self, n )
		--TouchDispatcher.registerListener(self, speakerTextBox , "clear", speakerTextBox, true)	
	else
		self:__clearNode()
		self.currentNodeKey , self.currentNode = n , self:__deepcopy(self.script[n])
		background = self.__displayBackground(self.currentNode.background)
		speakerNameBox = self.__drawSpeakerNameBox(self.currentNode.speaker)
		speakerTextBox = self:__drawMainTextBox(self.__replaceVariables(self.currentNode.text))
		speakerSprite = self.__displaySpeakerSprite( self.currentNode.portrait )
		TouchDispatcher.registerListener(self, speakerTextBox , "advanceTextbox", speakerTextBox, true)	
	end
end

function _C:__displayChoices ()
	print("displayChoices") 
	for choice, actions in pairs(self.currentNode.choices) do
	 	for action, data in pairs(actions) do
	 		if action == "getItem" then
	 			self.currentNode.choices[choice]["getSpecifiedItems"] = self.currentNode.choices[choice]["getItem"]
	 			self.currentNode.choices[choice]["getItem"] = nil
	 		end
	 	end
	end
	print("new choices")
	for k,v in pairs(self.currentNode.choices) do
		print(k,v)
		for kk, vv in pairs(v) do
			print("what's this?", kk, vv)
			--for kkk,vvv in pairs(vv) do
				--print("what about this?", kkk, vvv)
			--end
		end
	end
	-- 			print("value of", action)
	-- 			print("for choice", choice)
	-- 			print("has been set to", data)
	-- 			self.currentNode.choices[choice][action] = data
	-- 		end
	-- 	end
	-- end
	--if self.currentNode.choices
	self.menu = LLMenu.makeMenu(WindowLayer, self.currentNode.choices)
end

function _C:__getItem(item, qty)
	print("running getItem")
	table.insert (Player.items , { [item] = 1, })
	local text = "Got item: "..item
	self:__displayNotification("Got item: "..item)
	--TouchDispatcher.registerListener(self, notificationTextBox, "clearNotification", box, false, TouchDispatcher.CONVERSATION_NOTIFICATION_PRIORITY)
	--TouchDispatcher.registerListener(self, speakerTextBox, "displayNotification", text)
end

function _C.__setVar(variable, value)
	Player.variables[variable] = value
end

function _C.__changeVar(variable, value)
	Player.variables[variable] = Player.variables[variable] + value
end

function _C.__setStat(stat, value)
	Player[stat] = value
end

function _C.__changeStat(stat, value)
	Player[stat] = Player[stat] + value
end

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
	print("registering touch event for clearNotification")
	TouchDispatcher.registerListener(self, notificationTextbox, "clearNotification")
	TouchDispatcher.registerListener(self, speakerTextBox, "clearNotification")
end

function _C:__clearNotification()
	print("clearing")
	PopupLayer:clear()
	self.notificationVisible = false
	TouchDispatcher.removeListenersForEvent("clearNotification")
	EventDispatcher.triggerEvent("notificationCleared")
end

function _C:__advanceTextbox(box)
	print("notification visible", self.notificationVisible)
	if self.notificationVisible then
		-- self:__clearNotification()
		--EventDispatcher.registerEvent(self, "notificationCleared", self.__advanceTextbox, self, box )
	elseif self.menu then
		--wait for menu input
	elseif box:isBusy () then
		box:stop()
		box:revealAll()
		--TouchDispatcher.registerListener(self, speakerTextBox, "advanceTextbox", box)
	else
		if box:more() then
			box:nextPage()
			box:spool()
			--TouchDispatcher.registerListener(self, speakerTextBox, "advanceTextbox", box)
		else
			-- if self.currentNode.processed then
			-- 	self:__leaveNode()
			-- else
			-- 	self:__processNode()
			-- end
			self:__processNode()
		end
	end
end

function _C:__processNode()
	print("actionsDone, notificationVisible", self.currentNode.actionsDone, self.notificationVisible)
	-- if self.currentNode.actionsDone and not self.notificationVisible then
	-- 	self:__leaveNode()
	-- else
	if not self.currentNode.actionsDone then
		-- Process conditionals first, because they may add other things to do.
		self:__checkConditionals(self.currentNode)

		self:__getNodeItems(self.currentNode)
		-- Do things that don't require leaving the node

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
		--TouchDispatcher.registerListener(self, sz)
		--self:__leaveNode()
		self.currentNode.actionsDone = true
	end
	if self.currentNode.actionsDone and not self.notificationVisible then
		self:__leaveNode()
	elseif self.currentNode.actionsDone and self.notificationVisible then
		-- Actions are done, but a notification is visible. When the notification
		-- is cleared, you may leave the node.
		--EventDispatcher.registerEvent(self, "notificationCleared", self.__leaveNode, self )
	end
end 

function _C:__getNodeItems(node)
	if node.getItem then
		k, v = next(node.getItem)
		--for k,v in pairs(node.getItem) do
			--node.gainedItem[k] = node.getItem[k]
			--node.gainedItem = node.getItem
			node.getItem[k] = nil
			self:__getItem( k,v)
			print("getItem was just called")
			-- When this item has been gained and its notification cleared, get the next item
			EventDispatcher.registerEvent(self, "notificationCleared", self.__getNodeItems, self, node )
		--end
	end
end

function _C:__getSpecifiedItems(items)
	print("items to get", items)
	if items then
		k, v = next(items)
		items[k] = nil
		self:__getItem(k, v)
		EventDispatcher.registerEvent(self, "notificationCleared", self.__getSpecifiedItems, self, items )
	end
end

function _C:__leaveNode()
	--if not self.notificationVisible then
		-- Now we have the ways one might leave a node
		if self.currentNode.choices then
			self:__displayChoices()
		elseif self.currentNode.exit then
			print("end of conversation")
		elseif self.currentNode.goToNode then
			self:__goToNode(self.currentNode["goToNode"])
		elseif self.currentNode.goToConv then
			self.goToConversation(self, self.currentNode.goToConv.file , self.currentNode.goToConv.node)
		else
			self:__goToNode(self.__nextNode(self.script, self.currentNodeKey))
		end
	--end
end

-- The following are possible responses to touch events from TouchDispatcher.
-- This table is necessary for LLMenu to be able to pass the name of an action
-- to TouchDispatcher; otherwise all conversation options would need to be global.
-- Maybe that wouldn't be such a bad thing...
_C.options = {
	advanceTextbox = function(self, box) self:__advanceTextbox(box) end,

	goToNode = 	function(self, n) self:__goToNode(n) end,
	goToConv = function(self, file, node) self.goToConversation(file, node) end,
	getItem = function(self, table) 
					for k,v in pairs(table) do
						self:__getItem(k, v) 
					end
				end,
	getSpecifiedItems = function(self, table) self:__getSpecifiedItems(table) end,
	setVar = function(self, table)
					for k,v in pairs(table) do
						self.__setVar(k,v)
					end
				end,
	displayNotification = function(self, text) self:__displayNotification(text) end,
	clearNotification = function(self) self:__clearNotification() end,
}

return _C