_M = {}

_M.currentMacros = {}

function _M.sound(file)
	local sfx = MOAIUntzSound.new()
	sfx:load("Resources/SFX/"..file)
	sfx:play()
end

function _M.shake(imgfile)
	local prop
	for k,v in pairs(conversation.actors) do
		if imgfile == v.img then
			prop = v.prop
		end
	end
	thread = MOAICoroutine.new ()
	thread:run ( _M.__shakeFunc, prop )
end

function _M.__shakeFunc(prop)
	local action
	action = prop:moveLoc ( 10, 7, .05 )
	MOAICoroutine.blockOnAction ( action )

	action = prop:moveLoc ( -16, -11, .05 )
	MOAICoroutine.blockOnAction ( action )

	action = prop:moveLoc ( 12, 8, .05 )
	MOAICoroutine.blockOnAction ( action )
	
	action = prop:moveLoc ( -6, -4, .05 )
	MOAICoroutine.blockOnAction ( action )
end

function _M.fromLeft(newActor, existingActors)
	local texX = newActor:getDims()
	local action
	for k, actor in pairs(existingActors) do
		local texX = actor.prop:getDims()
		local x = _M.__getSpriteXPos( texX, k+1, #existingActors + 1 )
		local xx, yy = actor.prop:worldToModel(x, 0)
		action = actor.prop:seekLoc(xx, yy, .5)
		action:start()
	end
	local xPos = _M.__getSpriteXPos(texX, 1, #existingActors + 1)
	local xx, yy = newActor:worldToModel(xPos, 0)
	local action2 = newActor:seekLoc(xx, yy, .5)
	action2:start()
end

function _M.toLeft(leavingActor, existingActors)
	local action, actorLeft, xx, yy
	local texX = leavingActor:getDims()
	xx, yy = -texX, 0
	action = leavingActor:seekLoc(xx, yy, .5)
	action:start()
	for k, actor in pairs(existingActors) do
		local texX = actor.prop:getDims()
		local x = _M.__getSpriteXPos( texX, k, #existingActors )
		xx, yy = x, 0
		action = actor.prop:seekLoc(xx, yy, .5)
		action:start()
	end
end

function _M.__getSpriteXPos(texX, count, total)
	local xPos
	if total == 1 then xPos = screenWidth / 2 - texX / 2
	elseif total == 2 then
		if count == 1 then xPos = screenWidth / 4 - texX / 2
		elseif count == 2 then xPos = (screenWidth / 4) * 3 - texX / 2
		end
	elseif total == 3 then
		if count == 1 then xPos = screenWidth / 6  - texX / 2
		elseif count == 2 then xPos = (screenWidth / 6 ) * 3  - texX / 2
		elseif count == 3 then xPos = (screenWidth / 6 ) * 5 - texX / 2
		end
	else
		return nil
	end
	return xPos
end

-- function _M.pause(delay)
-- 	local timer = MOAITimer.new()
-- 	timer:setSpan(delay)
-- 	timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN,
-- 		function()      
-- 	   		print("timer done")
--     	end
--     )
-- 	timer:start()
-- end

-- function _M.__performWithDelay ( delay, func, arg )
-- 	local t = MOAITimer.new()
-- 	t:setSpan(delay/100)

-- 	t:setListener( MOAITimer.EVENT_TIMER_END_SPAN,
-- 		function()      
-- 	   		func(arg)
--     	end
--     )
-- 	t:start()
-- end

return _M