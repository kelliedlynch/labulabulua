_T = {}
_T.listeners = {}

local function clickOrTouch(x,y)
	--print( x , y)
	local partition = convoLayer:getPartition ()
	local x,y,z = convoLayer:wndToWorld(x,y)
	propTouched = partition:propForPoint( x, y, z, MOAILayer.SORT_PRIORITY_ASCENDING )
	for k , listener in pairs(_T.listeners) do 
		if propTouched == listener.prop then
			if not listener.permanent then 
				_T.listeners[k] = nil 
			end
			if listener.context.options then
				if listener.context.options[listener.callback] then
					context = listener.context
					context.options[listener.callback](listener.callbackValue)
				end
			else
				_G[listener.callback](listener.callbackValue)
			end			
		end
		--print( k , listener)
	end
end

function _T.registerListener( context, propListening , callbackFunction , callbackFunctionValue , permanentListener )
	if not permanentListener then permanentListener = false end
	table.insert(_T.listeners , { 
		context = context,
		prop = propListening, 
		callback = callbackFunction, 
		callbackValue = callbackFunctionValue, 
		permanent = permanentListener, })
end

function _T.removeListener( propListening )
	for k , v in pairs(_T.listeners) do
		if v.prop == propListening then
			_T.listeners[k] = nil
		end
	end
end

function _T.beginListening()
	if MOAIInputMgr.device.pointer then
	    MOAIInputMgr.device.mouseLeft:setCallback(
	        function(isMouseDown)
	            if(isMouseDown) then
	                clickOrTouch(MOAIInputMgr.device.pointer:getLoc())
	            end
	            -- Do nothing on mouseUp
	        end
	    )
	else
	-- If it isn't a mouse, its a touch screen... or some really weird device.
	    MOAIInputMgr.device.touch:setCallback (

	        function ( eventType, idx, x, y, tapCount )
				if eventType == MOAITouchSensor.TOUCH_DOWN then
	                clickOrTouch(x,y)
	            end
	        end
	    )
	end
end

return _T