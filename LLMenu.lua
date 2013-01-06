local _M = {}
--local Meshes2D = require "DrawClean/draw/meshes2D"

_M.itemList = {}

local defaults = {
	boxWidth = 240,
	boxHeight = 30,
	boxSpacing = 10,
}

_M.__index = _M

function _M.new()
	local menu = {}
	setmetatable(menu, _M)
	return menu
end

function _M:makeMenu(conv, layer, items)
	self.layer = layer
	local boxWidth , boxHeight , gutter = defaults.boxWidth , defaults.boxHeight , defaults.boxSpacing
	local totalheight = ( boxHeight * #items ) + (gutter * (#items - 1))
	local ox , oy = screenWidth / 2 - boxWidth / 2 , screenHeight / 2 - totalheight / 2
	local ex , ey = ox + boxWidth, oy + boxHeight

	for choice, action in pairs(items) do

		local tbb = Meshes2D.newRect( ox , oy , ex , ey , "#999999")

		layer:insertProp(tbb)

		local tbt = MOAITextBox.new()
		tbt:setStyle(newStyle(defaultFont , 38))
		tbt:setRect(ox , oy , ex , ey)
		tbt:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
		tbt:setYFlip(true)
		tbt:setString(choice)
		layer:insertProp(tbt)

		table.insert(self.itemList, {
			choice = choice,
			action = action,
			box = tbt,
		})

	    LLDispatcher.registerTouchListener(self, tbt, "screenTouched", tbt)

		

		oy = oy - (boxHeight + gutter)
		ey = ey - (boxHeight + gutter)
	end
	LLDispatcher.registerEventListener(self, "removeMenu")
end

function _M:__onScreenTouched(prop)
	--print("prop touched is", prop)
	for k, menuItem in pairs(self.itemList) do
		if prop == menuItem.box then
			for action, value in pairs(menuItem.action) do
				conversation["__"..action](conversation, value)
			end
			LLDispatcher.triggerEvent("removeMenu")
		end
	end
end

function _M:__onRemoveMenu()
	for k, item in pairs(self.itemList) do
		LLDispatcher.removeListenersForProp(item.box)
	end
	self.layer:clear()
	self = nil
end

return _M
