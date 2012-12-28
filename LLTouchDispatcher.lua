_T = {}
_T.listeners = {}

function _T.registerListener( propListening , callbackFunction , callbackFunctionValue , permanentListener )
-- prop listening, callback, single/perm listener
	if not permanentListener then permanentListener = false end
	table.insert(_T.listeners , { 
		prop = propListening, 
		callback = callbackFunction, 
		callbackValue = callbackFunctionValue, 
		permanent = permanentListener, })
	print("registered ", propListening)
end

function _T.removeListener( propListening )
	print("trying to remove listener ", propListening)
	for k , v in pairs(_T.listeners) do
		if v.prop == propListening then
			print("listener found, removing")
			_T.listeners[k] = nil
		end
	end
end

local function clickOrTouch(x,y)
	--print( x , y)
	partition = convoLayer:getPartition ()
	propTouched = partition:propForPoint( convoLayer:wndToWorld(x,y) )
	print("touched " , propTouched)
	for k , listener in pairs(_T.listeners) do 
		--print("prop listening is " , listener.prop)
		if propTouched == listener.prop then
			--print("callback " , listener.callback)
			if not listener.permanent then 
				print("removing listener ", listener.prop)
				_T.listeners[k] = nil 
			end
			if conversation.options[listener.callback] then
				conversation.options[listener.callback](listener.callbackValue)
			else
				_G[listener.callback](listener.callbackValue)
			end			
		end
		--print( k , listener)
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