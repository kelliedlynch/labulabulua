_M = {}

_M.currentMacros = {}

function _M.sound ()
	print("ping!")
	local sfx = MOAIUntzSound.new()
	sfx:load("Resources/SFX/crash.wav")
	sfx:play()
end


return _M