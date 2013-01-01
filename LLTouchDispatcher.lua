_T = {}

_T.listeners = {}

function _T.__clickOrTouch(x,y)
	--------------------------------------------------------------------
	-- Check all layers for props under the point touched.
	-- If any props are found, only the topmost prop will respond.
	--------------------------------------------------------------------
	propTouched = _T.__checkLayersForProp(x, y)
	local listeners = {}
	for k, listener in pairs(_T.listeners) do
		listeners[k] = listener
	end
	--local listeners = deepcopy(_T.listeners)
	for k , listener in pairs(listeners) do 
		--print(k,listener)
		--print(propTouched, listener.prop, listener.callback)
		if propTouched == listener.prop then
			--print("prop touched", propTouched)
			if not listener.permanent then 
				--print("removing listener for: ", listener.callback)
				_T.listeners[k] = nil 
			end
			if listener.context.options then
				if listener.context.options[listener.callback] then
					context = listener.context
					context.options[listener.callback](listener.context, listener.callbackValue)
				end
			else
				_G[listener.callback](listener.callbackValue)
			end			
		end
		--print( k , listener)
	end
end

function _T.__checkLayersForProp(x, y)
	--------------------------------------------------------------------
	-- Check all layers for the prop at x,y, starting from the top down
	--------------------------------------------------------------------
	x, y, z = BackgroundLayer:wndToWorld(x,y)

	if _T.__checkLayer(PopupLayer, x, y, z) then
		return _T.__checkLayer(PopupLayer, x, y, z)
	elseif _T.__checkLayer(WindowLayer, x, y, z) then
		return _T.__checkLayer(WindowLayer, x, y, z)
	elseif _T.__checkLayer(SpriteLayer, x, y, z) then
		return _T.__checkLayer(SpriteLayer, x, y, z)
	elseif _T.__checkLayer(BackgroundLayer, x, y, z) then
		return _T.__checkLayer(BackgroundLayer, x, y, z)
	end
	return nil
end

function _T.__checkLayer(layer, x, y, z)
	local partition = layer:getPartition()
	if partition then
		return partition:propForPoint(x, y, z, MOAILayer.SORT_PRIORITY_ASCENDING)
	end
	return false
end

function _T.registerListener( context, propListening , callbackFunction , callbackFunctionValue , permanentListener )
	print("registering listener", propListening, callbackFunction)
	if not permanentListener then permanentListener = false end
	table.insert(_T.listeners , { 
		context = context,
		prop = propListening, 
		callback = callbackFunction, 
		callbackValue = callbackFunctionValue, 
		permanent = permanentListener,
		})
end

function _T.removeListener( propListening )
	for k , v in pairs(_T.listeners) do
		if v.prop == propListening then
			_T.listeners[k] = nil
		end
	end
end

function _T.removeListenersForEvent( event )
	for k , v in pairs(_T.listeners) do
		if v.callback == event then
			_T.listeners[k] = nil
		end
	end
end

function _T.beginListening()
	if MOAIInputMgr.device.pointer then
	    MOAIInputMgr.device.mouseLeft:setCallback(
	        function(isMouseDown)
	            if(isMouseDown) then
	                _T.__clickOrTouch(MOAIInputMgr.device.pointer:getLoc())
	            end
	            -- Do nothing on mouseUp
	        end
	    )
	else
	-- If it isn't a mouse, its a touch screen... or some really weird device.
	    MOAIInputMgr.device.touch:setCallback (

	        function ( eventType, idx, x, y, tapCount )
				if eventType == MOAITouchSensor.TOUCH_DOWN then
	                _T.__clickOrTouch(x,y)
	            end
	        end
	    )
	end
end

return _T