GiantBoBaseHusk = GiantBoBaseHusk or class(UnitBase)

function GiantBoBaseHusk:load(data)
	self._enabled = data.enabled

	self._rotation_data = {
		origin = data.origin,
		radius = data.radius,
		start_angle = data.current_angle,
		current_angle = data.current_angle,
		target_angle = data.target_angle,
		transition_start_time = Application:time()
	}
end

function GiantBoBaseHusk:init(unit)
	GiantBoBaseHusk.super.init(self, unit, true)

	self._unit = unit
	self._enabled = false

	self._aggressiveness = 0

	self._rotation_data = {
		origin = self._unit:position(),
		radius = 2400,
		start_angle = 0,
		current_angle = 0,
		target_angle = 0,
		transition_start_time = 0
	}

	self._flame_stats = {
		range = 3500,
		radius = 50,
		damage = 5,
		single_flame_effect_duration = 1,
		flame_rate = 0.01,
		flame_effect = Idstring("effects/payday2/particles/explosions/flamethrower"),

		damage_rate = 0.05,
		slotmask = managers.slot:get_mask("world_geometry", "vehicles"),
		damage_slotmask = managers.slot:get_mask("bullet_impact_targets"),

		offset = Vector3(0, 10, 350)
	}

	self._head = self._unit:get_object(Idstring("Head"))

	self._flamethrower_effect_collection = {}

	self._flames = false
	self._next_flame_time = 0
	self._next_flame_damage_time = 0

	self._sound = SoundDevice:create_source("giant_bo")
	self._sound:link(self._head)
	self._sound:set_switch("suppressed", "regular")

	self._unit:character_damage():add_listener("giant_bo_take_damage", { "on_take_damage" }, callback(self, self, "_on_damage"))
end

function GiantBoBaseHusk:_on_damage(unit, attacker, damage)
	if self._current_state == "dead" then return end

	local health_percentage = self._unit:character_damage():health_percentage()
	managers.hud:set_boss_health(health_percentage)

	self._aggressiveness = 1 - health_percentage
end

function GiantBoBaseHusk:show_health()
	managers.hud:open_boss_health("GIANT BO")
end

function GiantBoBaseHusk:hide_health()
	managers.hud:close_boss_health()
end

function GiantBoBaseHusk:sync_origin_and_angles(sync, position, rotation)
	self._rotation_data.origin = position

	self._rotation_data.start_angle = self._rotation_data.current_angle
	self._rotation_data.transition_start_time = Application:time()

	self._rotation_data.radius = rotation.x
	self._rotation_data.target_angle = rotation.z

	local speed_multiplier = math.lerp(1, 2, self._aggressiveness)

	local delta = self._rotation_data.target_angle - self._rotation_data.current_angle
	if delta > 0 then
		local result = self._unit:play_redirect(Idstring("turn_left"))
		self._unit:anim_state_machine():set_speed(result, speed_multiplier)
	elseif delta < 0 then
		local result = self._unit:play_redirect(Idstring("turn_right"))
		self._unit:anim_state_machine():set_speed(result, speed_multiplier)
	end
end
GiantBoBaseHusk.sync_stored_pos = GiantBoBaseHusk.sync_origin_and_angles

function GiantBoBaseHusk:sync_action(action)
	local action_data = self._actions[action]
	if not action_data then return end

	local speed_multiplier = 1
	if action_data.use_aggressiveness then
		speed_multiplier = math.lerp(1, 1.5, self._aggressiveness)
	end

	if action_data.animation then
		local result = self._unit:play_redirect(Idstring(action_data.animation))
		self._unit:anim_state_machine():set_speed(result, speed_multiplier)
	end

	if action_data.sequence then
		self._unit:damage():run_sequence(action_data.sequence)
	end

	if action_data.func and self[action_data.func] then
		self[action_data.func]()
	end
end
GiantBoBaseHusk.run_sequence_simple = GiantBoBaseHusk.sync_action

local flame_mvec1 = Vector3()
function GiantBoBaseHusk:update(unit, t, dt)
	if not self._enabled then return end

	local speed_multiplier = math.lerp(1, 2, self._aggressiveness)

	local transition_time = 1 / speed_multiplier
	local percentage = (t - self._rotation_data.transition_start_time) / transition_time

	if percentage < 1 then
		self._rotation_data.current_angle = math.lerp(
			self._rotation_data.start_angle,
			self._rotation_data.target_angle,
			percentage
		)
	else
		self._rotation_data.current_angle = self._rotation_data.target_angle
	end

	self._unit:set_rotation(Rotation(self._rotation_data.current_angle, 0, 0))
	self._unit:set_position(self._rotation_data.origin + Vector3(
		-math.sin(self._rotation_data.current_angle) * self._rotation_data.radius,
		math.cos(self._rotation_data.current_angle) * self._rotation_data.radius,
		0
	))

	if self._flames then
		if self._next_flame_time <= t then
			self._next_flame_time = t + self._flame_stats.flame_rate

			local nozzle_pos = self:flame_spawn_pos()
			local direction = self._head:rotation():z()

			local rotation = Rotation(direction, math.UP)
			local effect_id = World:effect_manager():spawn({
				effect = self._flame_stats.flame_effect,
				position = nozzle_pos,
				rotation = rotation
			})

			table.insert(self._flamethrower_effect_collection, {
				been_alive = false,
				id = effect_id,
				position = mvector3.copy(nozzle_pos),
				direction = rotation:y()
			})
		end
	end

	if self._flamethrower_effect_collection ~= nil then
		local flame_effect_dt = self._flame_stats.single_flame_effect_duration / dt
		local flame_effect_distance = self._flame_stats.range / flame_effect_dt

		local hit_unit_count = 0
		local hit_units = {}

		for index, effect_entry in pairs(self._flamethrower_effect_collection) do
			local do_continue = true

			if World:effect_manager():alive(effect_entry.id) == false then
				if effect_entry.been_alive == true then
					World:effect_manager():kill(effect_entry.id)
					table.remove(self._flamethrower_effect_collection, index)

					do_continue = false
				end
			elseif effect_entry.been_alive == false then
				effect_entry.been_alive = true
			end

			if do_continue == true then
				mvector3.set(flame_mvec1, effect_entry.position)
				mvector3.add(effect_entry.position, effect_entry.direction * flame_effect_distance)

				local hit_damage_bodies = World:find_bodies("intersect", "sphere", effect_entry.position, self._flame_stats.radius, self._flame_stats.damage_slotmask)
				for idx, body in ipairs(hit_damage_bodies) do
					local unit = body:unit()
					if unit and alive(unit) and unit.character_damage and unit:character_damage() and unit:character_damage().damage_killzone then
						if not hit_units[unit:key()] then
							hit_units[unit:key()] = unit
							hit_unit_count = hit_unit_count + 1
						end
					end
				end

				local hit_bodies = World:find_bodies(self._unit, "intersect", "sphere", effect_entry.position, self._flame_stats.radius, self._flame_stats.slotmask)
				if #hit_bodies > 0 then
					table.remove(self._flamethrower_effect_collection, index)
				else
					World:effect_manager():move(effect_entry.id, effect_entry.position)
				end

				local effect_distance = mvector3.distance(effect_entry.position, self:flame_spawn_pos())

				if self._flame_stats.range < effect_distance then
					World:effect_manager():kill(effect_entry.id)
				end
			end
		end

		if self._next_flame_damage_time <= t then
			for key, unit in pairs(hit_units) do
				unit:character_damage():damage_killzone({
					damage = self._flame_stats.damage,
					col_ray = {
						ray = self._head:rotation():z()
					}
				})
			end

			if hit_unit_count > 0 then
				self._next_flame_damage_time = t + self._flame_stats.damage_rate
			end
		end
	end
end

function GiantBoBaseHusk:activate()
	self._enabled = true
end

function GiantBoBaseHusk:play_sound(unit, event)
	self._sound:post_event(event)
end

function GiantBoBaseHusk:flame_spawn_pos()
	return self._head:position() + self._flame_stats.offset:rotate_with(self._head:rotation())
end

function GiantBoBaseHusk:set_flames(unit, state)
	if state == "true" and self._flames == false then
		self:play_sound(unit, "flamethrower_fire")
	elseif state == "false" and self._flames == true then
		self:play_sound(unit, "flamethrower_stop")
	end

	self._flames = state == "true"
end