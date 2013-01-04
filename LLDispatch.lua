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
	--print("registering", objectListening, propTouched, eventToFire, ...)
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
	--print("persistent touch listener arguments", ...)
	--print("#listeners", #_D.touchListeners)
	_D.registerTouchListener(...)
	--print("#listeners", #_D.touchListeners)
	_D.touchListeners[#_D.touchListeners].persistent = true
end

function _D.registerEventListener( objectListening, eventName, ... )
	--------------------------------------------------------------------
	-- An event listener is an object that will respond to a triggered
	-- event. By default, an event listener will only respond the first
	-- time an event is triggered, then it will stop listening.
	--------------------------------------------------------------------
	--print("registering", eventName)
	table.insert(_D.eventListeners, {
		listener = objectListening,
		event = eventName,
		params = {...},
		})
	for k,v in pairs(_D.eventListeners) do
		--print("listeners table", v.listener, v.event)
	end
end

function _D.registerPersistentEventListener( ... )
	--------------------------------------------------------------------
	-- A persistent event listener will continue to respond to triggered
	-- events until it is told not to.
	--------------------------------------------------------------------
	_D.registerEventListener(...)
	_D.eventListeners[#_D.eventListeners].persistent = true
end

function _D.removeListenersForProp( propListening )
	for k , v in pairs(_D.touchListeners) do
		if v.prop == propListening then
			table.remove(_D.touchListeners, k)
		end
	end
end

function _D.triggerEvent( eventName )
	--------------------------------------------------------------------
	-- Tell all objects listening for eventName to respond by calling
	-- __onEventName for each object
	--------------------------------------------------------------------

	-- copy the listeners table so we don't trigger new events added during this process.
	-- Why isn't a deepcopy necessary? I should try to understand this.
	-- local eListeners = deepcopy(_D.eventListeners)
	local eListeners = {}
	for k, listener in pairs(_D.eventListeners) do
		--print("listeners", pairs(listener))
		eListeners[k] = listener
	end
	print("triggering", eventName)
	for k, l in pairs(eListeners) do
		--print("eventName, l.event, l.listener",eventName, l.event, l.listener)
		if eventName == l.event then
			-- if listener is not persistent, have the object stop listening
			if not l.persistent then
				_D.eventListeners[k] = nil
			end

			-- now call __onEventName for the object
			

			local triggeredEvent = "__on"..eventName:gsub("^%l", string.upper)

			if l.params then
				--print("l.listener, triggeredEvent, params", l.listener, triggeredEvent, unpack(l.params))
				l.listener[triggeredEvent](l.listener, unpack(l.params))
			else
				--print("l.listener, triggeredEvent", l.listener, triggeredEvent)
				l.listener[triggeredEvent](l.listener)
			end
		end
	end
	--print("done triggering", eventName)
end

function _D.__checkLayersForProp(x, y)
	--------------------------------------------------------------------
	-- Check all layers for the prop at x,y, starting from the top down
	--------------------------------------------------------------------
	x, y, z = BackgroundLayer:wndToWorld(x,y)
	if _D.__checkLayer(PopupLayer, x, y, z) then
		return _D.__checkLayer(PopupLayer, x, y, z)
	elseif _D.__checkLayer(MenuLayer, x, y, z) then
		return _D.__checkLayer(MenuLayer, x, y, z)
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
	--print("partition", partition)
	if partition then
		--has a prop been touched?
		--print("prop list", partition:propListForPoint(x, y, z, MOAILayer.SORT_PRIORITY_ASCENDING))
		props = {partition:propListForPoint(x, y, z, MOAILayer.SORT_PRIORITY_ASCENDING)}
		if props then
			-- we're going to have to check all props under this point
			for k, prop in pairs(props) do
				-- is this prop listening for touches?
				for k, listener in pairs(_D.touchListeners) do
					-- check each listener for the prop
					if prop == listener.prop then
						return prop
					end
				end
			end
		end
		--no lisening props were found on this layer for this point
		return nil
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

	-- copy the listeners table so we don't trigger new events added during this process.
	-- Why isn't a deepcopy necessary? I should try to understand this.
	local tListeners = {}
	for k, l in pairs(_D.touchListeners) do
		tListeners[k] = l
		--print("_D.touchListeners k,v,prop", k, l, l.prop)
	end

	-- tell all objects listening that this prop has been touched
	for k, l in pairs(tListeners) do 
		if propTouched == l.prop then
			-- now tell the object it's time to respond
			--for k, l in pairs(tListeners) do
				-- if listener is not persistent, have the object stop listening
				if not l.persistent then
					_D.touchListeners[k] = nil
				end

				-- now call __onEventName for the object
				local eventName = l.event:gsub("^%l", string.upper)
				local triggeredEvent = "__on"..eventName

				-- this works because:
				-- "foo and bar or nil" will return the last thing looked at, and will stop looking
				-- at the statement when either something is true, or the end is reached.
				-- if foo, it checks bar
				-- if foo and bar, it returns bar (last thing looked at)
				-- if either foo or bar are false, it returns nil (it hit the end, and nil was the
				-- last thing looked at)
				-- if nil were instead baz, then
				-- if baz is true, it stops looking and baz is returned
				-- if baz is false, it hits the end of the statement and baz is returned (last checked)
				-- l.listener[triggeredEvent](l.listener, unpack(l.params or {}))
				print("trying to trigger event:", triggeredEvent)
				l.listener[triggeredEvent](l.listener, propTouched)
			--end
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