GiantBoStateDead = GiantBoStateDead or class(GiantBoState)

function GiantBoStateDead:enter(t)
	self._base:do_action("death")
	self._base:do_action("hide_health")
	self._base:do_action("start_credits")
end