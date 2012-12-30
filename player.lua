local _P = {}

_P.name = "Superstar"
_P.items = {}
_P.variables = {}
_P.silliness = 5

function _P:playerName()
	return self._name
end

return _P