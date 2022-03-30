GiantBoStateMove = GiantBoStateMove or class(GiantBoState)

function GiantBoStateMove:enter(t)
	local speed_multiplier = math.lerp(1, 2, self._base:state_data().aggressiveness)

	local delta = self._base:state_data().target_angle - self._base:state_data().current_angle
	if delta > 0 then
		local result = self._unit:play_redirect(Idstring("turn_left"))
		self._unit:anim_state_machine():set_speed(result, speed_multiplier)
	elseif delta < 0 then
		local result = self._unit:play_redirect(Idstring("turn_right"))
		self._unit:anim_state_machine():set_speed(result, speed_multiplier)
	end

	self._transition_start_t = t
	self._transition_t = 1 / speed_multiplier

	self._base:state_data().start_angle = self._base:state_data().current_angle

	self._unit:network():send("sync_stored_pos", true, self._base:state_data().origin, Vector3(
		self._base:state_data().radius,
		speed_multiplier,
		self._base:state_data().target_angle
	))
end

function GiantBoStateMove:update(t)
	if t > self._transition_start_t + self._transition_t then
		self._base:set_state("attack")

		self._base:state_data().current_angle = self._base:state_data().target_angle % 360
	else
		local percentage = (t - self._transition_start_t) / self._transition_t

		self._base:state_data().current_angle = math.lerp(
			self._base:state_data().start_angle,
			self._base:state_data().target_angle,
			percentage
		)
	end

	self._unit:set_rotation(Rotation(self._base:state_data().current_angle, 0, 0))
	self._unit:set_position(self._base:state_data().origin + Vector3(
		-math.sin(self._base:state_data().current_angle) * self._base:state_data().radius,
		math.cos(self._base:state_data().current_angle) * self._base:state_data().radius,
		0
	))
end