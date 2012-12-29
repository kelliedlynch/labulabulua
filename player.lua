local _P = {}

_P.name = "Superstar"
_P.items = {}
_P.variables = {}

function _P:playerName()
	return self._name
end

return _P