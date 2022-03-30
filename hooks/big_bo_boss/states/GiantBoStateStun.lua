GiantBoStateStun = GiantBoStateStun or class(GiantBoState)

function GiantBoStateStun:enter(t)
	local stun_time = self._base:do_action("stun")

	self._stun_exit_t = t + stun_time
end

function GiantBoStateStun:update(t, dt)
	if t > self._stun_exit_t then
		self._base:set_state("shield")
	end
end