GiantBoStateIdle = GiantBoStateIdle or class(GiantBoState)

function GiantBoStateIdle:enter(t)
	local idle_time = math.lerp(4, 1, self._base:state_data().aggressiveness)

	self._idle_exit_t = t + idle_time
end

function GiantBoStateIdle:update(t, dt)
	if t > self._idle_exit_t then
		self._base:set_state("search")
	end
end