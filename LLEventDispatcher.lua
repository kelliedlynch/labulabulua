_E = {}

_E.events = {}

function _E.registerEvent(sender, name, callback, ...)
	print("sender,name,callback,data",sender,name,callback,...)
	table.insert(_E.events, {
		sender = sender,
		eventName = name,
		["callback"] = callback,
		data = {...},
		})
end
function _E.registerPermanentEvent(...)
	_E.registerEvent(...)
	_E.events[#_E.events].permanent = true
end

function _E.triggerEvent(name)
	for k, listener in pairs(_E.events) do
		print("k,listener",k,listener)
		if name == listener.eventName then
			print("listener.eventName,listener.callback,listener.data",listener.eventName, listener.callback, listener.data)
			-- for k,v in pairs(listener.data) do
			-- 	print("listener data:", k, v)
			-- end
			--listener.callback(listener.data)
			if not listener.permanent then
				_E.events[k] = nil
			end
			listener.callback(unpack(listener.data))
		end
	end
end

function _E.removeEvent(name)
	for k, listener in pairs(_E.events) do
		if name == listener.eventName then
			_E.events[k] = nil
		end
	end	
end

function _E.removeSender(sender)
	for k, listener in pairs(_E.events) do
		if sender == listener.sender then
			_E.events[k] = nil
		end
	end	
end

function _E.removeEventForSender(event, sender)
	for k, listener in pairs(_E.events) do
		if name == listener.eventName and sender == listener.sender then
			_E.events[k] = nil
		end
	end	
end

return _E