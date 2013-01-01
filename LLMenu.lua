local _M = {}
local Meshes2D = require "DrawClean/draw/meshes2D"

local itemList = {}

local defaults = {
	boxWidth = 240,
	boxHeight = 30,
	boxSpacing = 10,
}

function _M.makeMenu(layer, items)
	_M.layer = layer
	local boxWidth , boxHeight , gutter = defaults.boxWidth , defaults.boxHeight , defaults.boxSpacing
	local totalheight = ( boxHeight * #items ) + (gutter * (#items - 1))
	local ox , oy = screenWidth / 2 - boxWidth / 2 , screenHeight / 2 - totalheight / 2
	local ex , ey = ox + boxWidth, oy + boxHeight

	for choice, action in pairs(items) do
		--print(choice,action)
		local tbb = Meshes2D.newRect( ox , oy , ex , ey , "#999999")

		layer:insertProp(tbb)

		local tbt = MOAITextBox.new()
		tbt:setStyle( newStyle ( defaultFont , 38 ))
		tbt:setRect ( ox , oy , ex , ey )
		tbt:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
		tbt:setYFlip(true)
		tbt:setString ( choice )
		layer:insertProp(tbt)
		for action , value in pairs(action) do
			--this "conversation" needs to change; we need to pass the context around somehow
			print("conversation,tbb,action,value", conversation, tbb, action, value)
			TouchDispatcher.registerListener(conversation, tbt, action, value)
		end
		TouchDispatcher.registerListener(_M, tbt, "removeMenu", _M)

		table.insert ( itemList , { box = tbb , tbox = tbt , act = action })
		oy = oy - (boxHeight + gutter)
		ey = ey - (boxHeight + gutter)

		-- global notice that a menu is visible
		-- menuVisible = true
	end

end

function _M:__removeMenu()
	for k , v in pairs(itemList) do
		self.layer:removeProp(v["box"])
		self.layer:removeProp(v["tbox"])

		-- The listener for the item touched has already been removed,
		-- but we have to remove the rest of the menu
		TouchDispatcher.removeListener( v["box"] )

		itemList[k] = nil
	end
	self = nil
end

_M.options = {
	removeMenu = function(self) self:__removeMenu() end,
}

return _M
