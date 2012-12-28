local Meshes2D = require "DrawClean/draw/meshes2D"

itemList = {}

function makeMenu(items)
	boxWidth , boxHeight , gutter = 240 , 30 , 10
	totalheight = ( boxHeight * #items ) + (gutter * (#items - 1))
	ox , oy , w , h = -boxWidth / 2 , totalheight / 2 , boxWidth , boxHeight
	ex , ey = boxWidth / 2 , oy + boxHeight
	for choice, action in pairs(items) do
		tbb = Meshes2D.newRect( ox , oy , w , h , "#999999")

		convoLayer:insertProp(tbb)

		tbt = MOAITextBox.new()
		tbt:setStyle( newStyle ( defaultFont , 44 ))
		tbt:setRect ( ox , oy , ex , ey )
		tbt:setAlignment ( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
		tbt:setYFlip(true)
		tbt:setString ( choice )
		convoLayer:insertProp(tbt)
		for action , value in pairs(action) do
			TouchDispatcher.registerListener(tbb, action, value)
		end
		TouchDispatcher.registerListener(tbb, "removeMenu")

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
