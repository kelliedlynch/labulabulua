local _P = {}

_P.name = "Superstar"
_P.items = {}
_P.variables = { var1 = "foo", var2 = "bar", var3 = "a third variable" }
_P.silliness = 5

_P.settings = {
	textSpeed = 18
}

function _P:playerName()
	return self._name
end

return _P