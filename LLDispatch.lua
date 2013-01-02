--------------------------------------------------------------------
-- Combined Touch and Triggered Event Dispatcher
--------------------------------------------------------------------
_D = {}

_D.touchListeners = {}
_D.eventListeners = {}

-- function _D.registerTouchListener( objectListening, propTouched, eventToFire, data )
-- or do I want to take unlimited arguments?
function _D.registerTouchListener( objectListening, propTouched, eventToFire, ... )
	--------------------------------------------------------------------
	-- A touch listener is an object that will respond to a prop being
	-- touched. By default, a touch listener will only catch the first
	-- touch event, then it will stop listening.
	--------------------------------------------------------------------
	table.insert(_D.touchListeners, { 
		listener = objectListening,
		prop = propTouched,
		event = eventToFire,
		params = {...},
		})
end

function _D.registerPersistentTouchListener( ... )
	--------------------------------------------------------------------
	-- A persistent touch listener will continue to respond to touches
	-- until it is told not to.
	--------------------------------------------------------------------
	_D.registerTouchListener(...)
	_D.touchListeners[#_D.touchListeners].persistent = true
end

function _D.registerEventListener( objectListening, eventName, ... )
	--------------------------------------------------------------------
	-- An event listener is an object that will respond to a triggered
	-- event. By default, an event listener will only respond the first
	-- time an event is triggered, then it will stop listening.
	--------------------------------------------------------------------
	table.insert(_D.eventListeners, {
		listener = objectListening,
		event = eventName,
		params = {...},
		})
end

function _D.registerPersistentEventListener( ... )
	--------------------------------------------------------------------
	-- A persistent event listener will continue to respond to triggered
	-- events until it is told not to.
	--------------------------------------------------------------------
	_D.registerEventListener(...)
	_D.eventListeners[#_D.eventListeners].persistent = true
end

function _D.triggerEvent( eventName )
	--------------------------------------------------------------------
	-- Tell all objects listening for eventName to respond by calling
	-- __onEventName for each object
	--------------------------------------------------------------------

	-- copy the listeners table
	local eListeners = {}
	for k, listener in pairs(_D.eventListeners) do
		eListeners[k] = listener
	end

	for k, l in pairs(eListeners) do
		if eventName == l.event then
			-- if listener is not persistent, have the object stop listening
			if not l.persistent then
				_D.eventListeners[k] = nil
			end
			-- now call __onEventName for the object
			eventName = eventName:gsub("^%l", string.upper)

			local triggeredEvent = "__on"..eventName

			if l.params then
				l.listener[triggeredEvent](l.listener, unpack(l.params))
			else
				l.listener[triggeredEvent](l.listener)
			end
		end
	end
end

function _D.__checkLayersForProp(x, y)
	--------------------------------------------------------------------
	-- Check all layers for the prop at x,y, starting from the top down
	--------------------------------------------------------------------
	x, y, z = BackgroundLayer:wndToWorld(x,y)
	if _D.__checkLayer(PopupLayer, x, y, z) then
		return _D.__checkLayer(PopupLayer, x, y, z)
	elseif _D.__checkLayer(WindowLayer, x, y, z) then
		return _D.__checkLayer(WindowLayer, x, y, z)
	elseif _D.__checkLayer(SpriteLayer, x, y, z) then
		return _D.__checkLayer(SpriteLayer, x, y, z)
	elseif _D.__checkLayer(BackgroundLayer, x, y, z) then
		return _D.__checkLayer(BackgroundLayer, x, y, z)
	end
	return nil
end

function _D.__checkLayer(layer, x, y, z)
	local partition = layer:getPartition()
	if partition then
		return partition:propForPoint(x, y, z, MOAILayer.SORT_PRIORITY_ASCENDING)
	end
	return false
end

function _D.__clickOrTouch(x,y)
	--------------------------------------------------------------------
	-- The screen has been touched.
	-- Check all layers for props under the point touched.
	-- If any props are found, only the topmost prop will respond.
	--------------------------------------------------------------------
	propTouched = _D.__checkLayersForProp(x, y)

	-- copy the listeners table
	local tListeners = {}
	for k, listener in pairs(_D.touchListeners) do
		tListeners[k] = listener
	end

	-- tell all objects listening that this prop has been touched
	for k, listener in pairs(tListeners) do 
		if propTouched == listener.prop then
			-- now tell the object it's time to respond
			for k, l in pairs(tListeners) do
				-- if listener is not persistent, have the object stop listening
				if not l.persistent then
					_D.touchListeners[k] = nil
				end

				-- now call __onEventName for the object
				local eventName = l.event:gsub("^%l", string.upper)
				local triggeredEvent = "__on"..eventName
				if l.params then
					l.listener[triggeredEvent](l.listener, unpack(l.params))
				else
					l.listener[triggeredEvent](l.listener)
				end
			end
		end
	end	
end

function _D.beginListeningForTouches()
	if MOAIInputMgr.device.pointer then
	    MOAIInputMgr.device.mouseLeft:setCallback(
	        function(isMouseDown)
	            if(isMouseDown) then
	                _D.__clickOrTouch(MOAIInputMgr.device.pointer:getLoc())
	            end
	            -- Do nothing on mouseUp
	        end
	    )
	else
	-- If it isn't a mouse, its a touch screen... or some really weird device.
	    MOAIInputMgr.device.touch:setCallback (

	        function ( eventType, idx, x, y, tapCount )
				if eventType == MOAITouchSensor.TOUCH_DOWN then
	                _D.__clickOrTouch(x,y)
	            end
	        end
	    )
	end
end

return _D