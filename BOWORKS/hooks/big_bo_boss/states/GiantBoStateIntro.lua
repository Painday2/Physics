GiantBoStateIntro = GiantBoStateIntro or class(GiantBoState)

function GiantBoStateIntro:enter(t)
	local intro_time = self._base:do_action("intro")
	self._intro_exit_t = t + intro_time

	self._assault_start_t = t + 0.1

	self._unit:set_rotation(Rotation(self._base:state_data().current_angle, 0, 0))
	self._unit:set_position(self._base:state_data().origin + Vector3(
		-math.sin(self._base:state_data().current_angle) * self._base:state_data().radius,
		math.cos(self._base:state_data().current_angle) * self._base:state_data().radius,
		0
	))

	self._unit:network():send("sync_stored_pos", true, self._base:state_data().origin, Vector3(
		self._base:state_data().radius,
		speed_multiplier,
		self._base:state_data().target_angle
	))
end

function GiantBoStateIntro:update(t, dt)
	if t > self._intro_exit_t then
		self._base:set_state("idle")

		self._base:do_action("show_health")
	end

	if self._assault_start_t and t > self._assault_start_t then
		local mgais = managers.groupai:state()

		mgais._backup_tweak_data = mgais._backup_tweak_data or deep_clone(mgais._tweak_data)
		mgais._tweak_data = mgais._backup_tweak_data

		mgais._tweak_data.assault.anticipation_duration = {{ 1, 1 }}
		mgais._tweak_data.assault.build_duration = 1

		mgais:on_enemy_weapons_hot()
		mgais:set_wave_mode("quiet")
		mgais:set_assault_mode(true)
	end
end