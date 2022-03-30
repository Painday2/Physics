GiantBoState = GiantBoState or class()

function GiantBoState:init(unit, base)
	self._unit = unit
	self._base = base
end

function GiantBoState:enter(t) end
function GiantBoState:exit(t) end
function GiantBoState:update(t, dt) end