_M = {}

_M.currentMacros = {}

function _M.sound(file)
	local sfx = MOAIUntzSound.new()
	sfx:load("Resources/SFX/"..file)
	sfx:play()
end

function _M.shake(imgfile)
	--for k,v in pairs(conversation.activeMacros) do
	local prop = conversation.activeProps[imgfile]
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

function _M.pause(delay)
	local box = conversation.speakerTextTextbox
	box:pause()
	_M.__performWithDelay(delay, box.start, box)
end

function _M.__performWithDelay ( delay, func, arg )
	local t = MOAITimer.new()
	t:setSpan(delay/100)

	t:setListener( MOAITimer.EVENT_TIMER_END_SPAN,
		function()      
	   		func(arg)
    	end
    )
	t:start()
end

return _M