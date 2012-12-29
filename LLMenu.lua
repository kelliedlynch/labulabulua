local _M = {}
local Meshes2D = require "DrawClean/draw/meshes2D"

local itemList = {}

local defaults = {
	boxWidth = 240,
	boxHeight = 30,
	boxSpacing = 10,
}

function makeMenu(items)
	local boxWidth , boxHeight , gutter = defaults.boxWidth , defaults.boxHeight , defaults.boxSpacing
	local totalheight = ( boxHeight * #items ) + (gutter * (#items - 1))
	local ox , oy , w , h = -boxWidth / 2 , totalheight / 2 , boxWidth , boxHeight
	local ex , ey = boxWidth / 2 , oy + boxHeight
	for choice, action in pairs(items) do
		--print(choice,action)
		local tbb = Meshes2D.newRect( ox , oy , w , h , "#999999")

		convoLayer:insertProp(tbb)

		local tbt = MOAITextBox.new()
		tbt:setStyle( newStyle ( defaultFont , 44 ))
		tbt:setRect ( ox , oy , ex , ey )
		tbt:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
		tbt:setYFlip(true)
		tbt:setString ( choice )
		convoLayer:insertProp(tbt)
		for action , value in pairs(action) do
			--this "conversation" needs to change; we need to pass the context around somehow
			print(conversation, tbb, action, value)
			TouchDispatcher.registerListener(conversation, tbt, action, value)
		end
		TouchDispatcher.registerListener(_M, tbt, "removeMenu")

		table.insert ( itemList , { box = tbb , tbox = tbt , act = action })
		oy = oy - (boxHeight + gutter)
		ey = ey - (boxHeight + gutter)

	end

end

function removeMenu()
	for k , v in pairs(itemList) do
		convoLayer:removeProp(v["box"])
		convoLayer:removeProp(v["tbox"])

		-- The listener for the item touched has already been removed,
		-- but we have to remove the rest of the menu
		TouchDispatcher.removeListener( v["box"] )

		itemList[k] = nil
	end
end

_M.options = {}
