GiantBoStateDead = GiantBoStateDead or class(GiantBoState)

function GiantBoStateDead:enter(t)
	self._base:do_action("death")
	self._base:do_action("hide_health")

	self._credits_t = t + 0.5
end

function GiantBoStateDead:update(t)
	if self._credits_t and t > self._credits_t then
		self._credits_t = nil
		self._base:do_action("start_credits")
	end
end