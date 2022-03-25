local mrot1 = Rotation()
local mrot2 = Rotation()
local mrot3 = Rotation()
local mrot4 = Rotation()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec4 = Vector3()

function FPCameraPlayerBase:_update_rot(axis, unscaled_axis)
	if self._force_rotation then
		self._parent_unit:camera():set_rotation(self._force_rotation)

		self._output_data.rotation = self._force_rotation
		local forward_polar = self._force_rotation:y():to_polar()
		self._camera_properties.spin = forward_polar.spin
		self._camera_properties.pitch = forward_polar.pitch
		self._force_rotation = nil

		return
	end

	if self._animate_pitch then
		self:animate_pitch_upd()
	end

	local t = managers.player:player_timer():time()
	local dt = t - (self._last_rot_t or t)
	self._last_rot_t = t
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)

	if managers.player:current_state() ~= "turret" then
		mvector3.add(new_head_pos, self._head_stance.translation)
	end

	self._input.look = axis
	self._input.look_multiplier = self._parent_unit:base():controller():get_setup():get_connection("look"):get_multiplier()
	local stick_input_x, stick_input_y = self._look_function(axis, self._input.look_multiplier, dt, unscaled_axis)
	local multiplier = 1

	if self._parent_unit:movement()._current_state:in_steelsight() then
		local equipped_unit_base = managers.player:player_unit():movement():current_state()._equipped_unit:base()

		if equipped_unit_base and equipped_unit_base.get_name_id and equipped_unit_base.get_reticle_obj and equipped_unit_base:get_reticle_obj() then
			local weapon_id = equipped_unit_base:get_name_id()
			local stances = tweak_data.player.stances[weapon_id] or tweak_data.player.stances.default
			multiplier = stances.steelsight.camera_sensitivity_multiplier or multiplier
		end
	end

	self._stick_input_length = mvector3.length(Vector3(stick_input_x, stick_input_y, 0))

	if managers.player:current_state() == "turret" then
		local current_State = self._parent_unit:movement()._current_state
		local camera_speed_limit = current_State.get_camera_speed_limit and current_State:get_camera_speed_limit()

		if camera_speed_limit then
			stick_input_x = math.clamp(stick_input_x, -camera_speed_limit, camera_speed_limit)
			stick_input_y = math.clamp(stick_input_y, -camera_speed_limit, camera_speed_limit)
		end
	end

	local look_polar_spin = data.spin - stick_input_x
	local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -85, 85)
	local player_state = managers.player:current_state()

	if player_state == "turret" and not self._limits then
		self._turret_unit = managers.player:get_turret_unit()
		local turret_weapon_name = managers.player:get_turret_unit():weapon():get_name_id()
		local spin = tweak_data.weapon[turret_weapon_name].camera_limit_horizontal or 45
		local pitch = tweak_data.weapon[turret_weapon_name].camera_limit_vertical or 30
		local mid_spin = (self._turret_unit:rotation():y():to_polar().spin + 360) % 360
		local mid_pitch = tweak_data.weapon[turret_weapon_name].camera_limit_vertical_mid or 0

		self:set_limits(spin, pitch, mid_spin, mid_pitch)
	end

	if self._limits then
		if self._limits.spin then
			local angle = look_polar_spin
			local mid = self._limits.spin.mid
			local dist_angle_to_mid = math.abs(mid - angle) % 360

			if dist_angle_to_mid > 180 then
				dist_angle_to_mid = 360 - dist_angle_to_mid
			end

			local d = dist_angle_to_mid / self._limits.spin.offset
			d = math.clamp(d, -1, 1)
			look_polar_spin = data.spin - math.lerp(stick_input_x, 0, math.abs(d))
		end

		if self._limits.pitch then
			local angle = look_polar_pitch
			local mid = self._limits.pitch.mid
			local dist_angle_to_mid = math.abs(mid - angle) % 360

			if dist_angle_to_mid > 180 then
				dist_angle_to_mid = 360 - dist_angle_to_mid
			end

			local d = dist_angle_to_mid / self._limits.pitch.offset
			d = math.clamp(d, -1, 1)
			look_polar_pitch = data.pitch + math.lerp(stick_input_y, 0, math.abs(d))
			look_polar_pitch = math.clamp(look_polar_pitch, -85, 85)
		end
	end

	if not self._limits or not self._limits.spin then
		look_polar_spin = look_polar_spin % 360
	end

	local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
	local look_vec = look_polar:to_vector()
	local cam_offset_rot = mrot3

	mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)

	if self._animate_pitch == nil then
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
	end

	self._output_data.position = new_head_pos

	if self._camera_properties.camera_offset then
		mvector3.set(mvec4, self._camera_properties.camera_offset)
		mvector3.rotate_with(mvec4, Rotation(self._output_data.rotation:yaw(), 0, 0))
		mvector3.add(self._output_data.position, mvec4)
	end

	if self._parachute_exit then
		self._parachute_exit = false
		self._output_data.rotation = self._parent_unit:movement().fall_rotation

		mrotation.multiply(self._output_data.rotation, self._parent_unit:camera():rotation())

		data.spin = self._output_data.rotation:y():to_polar().spin
	else
		self._output_data.rotation = new_head_rot or self._output_data.rotation
	end

	if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
		self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
	end

	if self._camera_properties.current_tilt ~= 0 then
		self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
	end

	local equipped_weapon = self._parent_unit:inventory():equipped_unit()
	local bipod_weapon_translation = Vector3(0, 0, 0)

	if equipped_weapon and equipped_weapon:base() then
		local weapon_tweak_data = equipped_weapon:base():weapon_tweak_data()

		if weapon_tweak_data and weapon_tweak_data.bipod_weapon_translation then
			bipod_weapon_translation = weapon_tweak_data.bipod_weapon_translation
		end
	end

	local bipod_pos = Vector3(0, 0, 0)
	local bipod_rot = new_shoulder_rot

	mvector3.set(bipod_pos, bipod_weapon_translation)
	mvector3.rotate_with(bipod_pos, self._output_data.rotation)
	mvector3.add(bipod_pos, new_head_pos)
	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)

	if equipped_weapon and equipped_weapon:base() then
		local apply_gun_kick = alive(equipped_weapon) and equipped_weapon:base().is_melee_weapon and not equipped_weapon:base():is_melee_weapon()

		if apply_gun_kick then
			local gun_kick = equipped_weapon:base():gun_kick()
			local gun_kick_tweak = equipped_weapon:base():weapon_tweak_data().gun_kick
			local position_ratio = gun_kick_tweak and gun_kick_tweak.position_ratio or 0.25
			local kick_x = gun_kick.x.delta
			local kick_y = gun_kick.y.delta

			mrotation.set_zero(tmp_rot1)
			mrotation.set_yaw_pitch_roll(tmp_rot1, kick_x * -1, kick_y * -1, 0)
			mrotation.multiply(new_shoulder_rot, tmp_rot1)

			local direction = self._parent_unit:camera():forward()
			local mvec_direction = tmp_vec1
			local mvec_right = tmp_vec2
			local mvec_up = tmp_vec3

			mvec3_cross(mvec_right, direction, math.UP)
			mvec3_norm(mvec_right)
			mvec3_cross(mvec_up, direction, mvec_right)
			mvec3_norm(mvec_up)
			mvec3_mul(mvec_right, kick_x * position_ratio)
			mvec3_mul(mvec_up, kick_y * position_ratio)

			local gun_kick_pos = Vector3()

			mvector3.add(gun_kick_pos, mvec_right)
			mvector3.add(gun_kick_pos, mvec_up)
			mvector3.add(new_shoulder_pos, gun_kick_pos)
		end
	end

	local player_state = managers.player:current_state()

	if player_state == "driving" then
		self:_set_camera_position_in_vehicle()
	elseif player_state == "freefall" or player_state == "parachuting" then
		mrotation.set_zero(cam_offset_rot)
		mrotation.multiply(cam_offset_rot, self._parent_unit:movement().fall_rotation)
		mrotation.multiply(cam_offset_rot, self._output_data.rotation)

		local shoulder_pos = mvec3
		local shoulder_rot = mrot4

		mrotation.set_zero(shoulder_rot)
		mrotation.multiply(shoulder_rot, cam_offset_rot)
		mrotation.multiply(shoulder_rot, self._shoulder_stance.rotation)
		mrotation.multiply(shoulder_rot, self._vel_overshot.rotation)
		mvector3.set(shoulder_pos, self._shoulder_stance.translation)
		mvector3.add(shoulder_pos, self._vel_overshot.translation)
		mvector3.rotate_with(shoulder_pos, cam_offset_rot)
		mvector3.add(shoulder_pos, self._parent_unit:position())
		self:set_position(shoulder_pos)
		self:set_rotation(shoulder_rot)
		self._parent_unit:camera():set_position(self._parent_unit:position())
		self._parent_unit:camera():set_rotation(cam_offset_rot)
	else
		self:set_position(new_shoulder_pos)
		self:set_rotation(new_shoulder_rot)
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(self._output_data.rotation)
	end

	if player_state == "bipod" and not self._parent_unit:movement()._current_state:in_steelsight() then
		self:set_position(PlayerBipod._shoulder_pos or new_shoulder_pos)
		self:set_rotation(bipod_rot)
		self._parent_unit:camera():set_position(PlayerBipod._camera_pos or self._output_data.position)
		self:set_fov_instant(40)
	elseif not self._parent_unit:movement()._current_state:in_steelsight() then
		PlayerBipod:set_camera_positions(bipod_pos, self._output_data.position)
	end
end