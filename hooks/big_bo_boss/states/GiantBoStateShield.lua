GiantBoStateShield = GiantBoStateShield or class(GiantBoState)

function GiantBoStateShield:enter(t)
	self._start_shield_t = t + self._base:do_action("shield_enter")
end

function GiantBoStateShield:update(t, dt)
	if self._start_shield_t and t > self._start_shield_t then
		self._base:do_action("reset_shield_generator_health")
		self._base:do_action("set_health_shielded")

		self._start_shield_t = nil
	end
end

function GiantBoStateShield:exit(t)
	self._base:do_action("shield_exit")
	self._base:do_action("set_health_unshielded")
end