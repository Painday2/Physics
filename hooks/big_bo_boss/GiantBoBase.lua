GiantBoBase = GiantBoBase or class(UnitBase)
GiantBoBase._actions = {
	intro = {
		animation = "intro",
		length = 140/30
	},
	breath_fire = {
		animation = "breath_fire",
		length = 120/30,
		use_aggressiveness = true
	},
	throw_smoke = {
		animation = "throw_smoke",
		length = 40/30,
		use_aggressiveness = true
	},
	throw_molotov = {
		animation = "throw_molotov",
		length = 40/30,
		use_aggressiveness = true
	},
	shoot_grenades = {
		animation = "shoot_grenades",
		length = 40/30,
		use_aggressiveness = true
	},
	stun = {
		animation = "stun",
		length = 145/30,
	},
	death = {
		animation = "stun",
		sequence = "died",
		length = 145/30
	},
	show_health = {
		func = "show_health"
	},
	hide_health = {
		func = "hide_health"
	},
	reset_shield_generator_health = {
		func = "reset_shield_generator_health"
	},
	set_health_shielded = {
		func = "set_health_shielded"
	},
	set_health_unshielded = {
		func ="set_health_unshielded"
	},
	shield_enter = {
		animation = "shield_enter",
		length = 10/30
	},
	shield_exit = {
		animation = "shield_exit",
		length = 10/30
	}
}

GiantBoBase.health = 1000

GiantBoBase.shield_generator_count = 3
GiantBoBase.shield_generator_health = 10
GiantBoBase.shield_generator_spin_speed = 10
GiantBoBase.shield_generator_height = 1200

function GiantBoBase:init(unit)
	GiantBoBase.super.init(self, unit, true)

	self._unit = unit
	self._enabled = false

	self._states = {
		intro = GiantBoStateIntro:new(unit, self),
		idle = GiantBoStateIdle:new(unit, self),
		search = GiantBoStateSearch:new(unit, self),
		move = GiantBoStateMove:new(unit, self),
		attack = GiantBoStateAttack:new(unit, self),
		stun = GiantBoStateStun:new(unit, self),
		dead = GiantBoStateDead:new(unit, self),
		shield = GiantBoStateShield:new(unit, self)
	}

	self._last_state = nil
	self._current_state = "idle"

	local init_angle = self._unit:rotation():yaw()
	self._state_data = {
		origin = self._unit:position(),
		start_angle = init_angle,
		current_angle = init_angle,
		target_angle = init_angle,
		radius = 2400,
		aggressiveness = 0
	}

	self._last_health_percentage = 1

	self._shield_generators = {}
	self:spawn_shield_generators()

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

	self._left_hand = self._unit:get_object(Idstring("LeftHand"))
	self._right_hand = self._unit:get_object(Idstring("RightHand"))

	self._left_finger = self._unit:get_object(Idstring("LeftHandMiddle3"))
	self._right_finger = self._unit:get_object(Idstring("RightHandMiddle3"))

	self._flamethrower_effect_collection = {}

	self._flames = false
	self._next_flame_time = 0
	self._next_flame_damage_time = 0

	self._sound = SoundDevice:create_source("giant_bo")
	self._sound:link(self._head)
	self._sound:set_switch("suppressed", "regular")

	self._unit:character_damage():add_listener("giant_bo_take_damage", { "on_take_damage" }, callback(self, self, "_on_damage"))
	self._unit:character_damage():add_listener("giant_bo_shield_generator_damage", { "on_take_shield_generator_damage" }, callback(self, self, "_on_shield_generator_damage"))
end

local shield_generator_unit = Idstring("units/pd2_mod_phys/props/giant_bo_shield_generator/giant_bo_shield_generator")
function GiantBoBase:spawn_shield_generators()
	for i = 1, GiantBoBase.shield_generator_count do
		local angle = 360 * i/GiantBoBase.shield_generator_count
		local rotation = Rotation(angle, 0, 0)
		local position = self:state_data().origin + Vector3(
			math.sin(angle) * self:state_data().radius,
			-math.cos(angle) * self:state_data().radius,
			GiantBoBase.shield_generator_height
		)

		self._shield_generators[i] = World:spawn_unit(shield_generator_unit, position, rotation)
		self._shield_generators[i]:character_damage():add_listener("shield_generator_take_damage", { "on_take_damage" }, function(unit, attacker, damage)
			self._unit:character_damage():add_shield_generator_damage(attacker, damage, i)
		end)

		self._shield_generators[i]:set_enabled(false)
		self._shield_generators[i]:effect_spawner(Idstring("laser")):kill_effect()
	end
end

function GiantBoBase:_on_shield_generator_damage(unit, attacker_unit, damage, index)
	local shield_generator_health_percentage = self._unit:character_damage():shield_generator_health_percentage(index)

	if shield_generator_health_percentage == 0 then
		self._shield_generators[index]:set_enabled(false)
		self._shield_generators[index]:effect_spawner(Idstring("laser")):kill_effect()

		World:effect_manager():spawn({
			effect = Idstring("effects/phys/explosions/shield_generator"),
			position = self._shield_generators[index]:position(),
			normal = math.UP
		})

		self._shield_generators[index]:sound_source():post_event("trip_mine_explode")
	end

	if self._unit:character_damage():all_shield_generators_dead() then
		self:set_state("idle")
		self._last_shield_generator_reset = nil
		self._last_shield_generator_angle = nil
	end
end

function GiantBoBase:reset_shield_generator_health()
	for i = 1, GiantBoBase.shield_generator_count do
		self._shield_generators[i]:set_enabled(true)
		self._shield_generators[i]:effect_spawner(Idstring("laser")):activate()
	end

	self._last_shield_generator_reset = Application:time()
	self._last_shield_generator_angle = 0

	self._unit:character_damage():reset_shield_generator_health()
end

function GiantBoBase:save(data)
	data.enabled = self._enabled

	data.origin = self:state_data().origin
	data.radius = self:state_data().radius

	data.current_angle = self:state_data().current_angle
	data.target_angle = self:state_data().target_angle

	data.last_shield_generator_angle = self._last_shield_generator_angle
end

function GiantBoBase:do_action(action)
	local action_data = self._actions[action]
	if not action_data then return 0 end

	local speed_multiplier = 1
	if action_data.use_aggressiveness then
		speed_multiplier = math.lerp(1, 1.5, self:state_data().aggressiveness)
	end

	if action_data.animation then
		local result = self._unit:play_redirect(Idstring(action_data.animation))
		self._unit:anim_state_machine():set_speed(result, speed_multiplier)
	end

	if action_data.sequence then
		self._unit:damage():run_sequence(action_data.sequence)
	end

	if action_data.func and self[action_data.func] then
		self[action_data.func](self)
	end

	self._unit:network():send("run_mission_door_sequence", action)

	return (action_data.length or 0) / speed_multiplier
end

function GiantBoBase:show_health()
	managers.hud:open_boss_health("GIANT BO")
end

function GiantBoBase:hide_health()
	managers.hud:close_boss_health()
end

function GiantBoBase:set_health_shielded()
	managers.hud:set_boss_health_shield(true)
end

function GiantBoBase:set_health_unshielded()
	managers.hud:set_boss_health_shield(false)
end

function GiantBoBase:_on_damage(unit, attacker, damage)
	if self._current_state == "dead" then return end
	if not self._unit:character_damage():all_shield_generators_dead() then return end

	local health_percentage = self._unit:character_damage():health_percentage()
	managers.hud:set_boss_health(health_percentage)

	self:state_data().aggressiveness = 1 - health_percentage

	if health_percentage == 0 then
		self:set_state("dead")
		self._last_health_percentage = 0
		return
	end

	if (self._last_health_percentage > 0.66 and health_percentage <= 0.66) or (self._last_health_percentage > 0.33 and health_percentage <= 0.33) then
		self:set_state("stun")
	end

	self._last_health_percentage = health_percentage
end

function GiantBoBase:activate()
	self._enabled = true

	self:set_state("intro")
end

function GiantBoBase:state_data()
	return self._state_data
end

function GiantBoBase:set_state(new_state)
	self._current_state = new_state
end

local flame_mvec1 = Vector3()
function GiantBoBase:update(unit, t, dt)
	if not self._enabled then return end

	if self._last_state ~= self._current_state then
		if self._states[self._last_state] then
			self._states[self._last_state]:exit(t)
		end

		if self._states[self._current_state] then
			self._states[self._current_state]:enter(t)
		end

		self._last_state = self._current_state
	end

	if self._states[self._current_state] then
		self._states[self._current_state]:update(t, dt)
	end

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

	if self._last_shield_generator_reset then
		local shield_generator_time = t - self._last_shield_generator_reset
		local base_angle = (shield_generator_time * GiantBoBase.shield_generator_spin_speed) % 360

		self._last_shield_generator_angle = base_angle

		for i = 1, GiantBoBase.shield_generator_count do
			local angle = base_angle + (360 * i/GiantBoBase.shield_generator_count)
			local rotation = Rotation(angle, 0, 0)
			local position = self:state_data().origin + Vector3(
				math.sin(angle) * self:state_data().radius,
				-math.cos(angle) * self:state_data().radius,
				GiantBoBase.shield_generator_height
			)

			self._shield_generators[i]:set_rotation(rotation)
			self._shield_generators[i]:set_position(position)
		end
	end
end

-- Attack Stuff
	function GiantBoBase:play_sound(unit, event)
		self._sound:post_event(event)
	end

	function GiantBoBase:flame_spawn_pos()
		return self._head:position() + self._flame_stats.offset:rotate_with(self._head:rotation())
	end

	local function do_spread(direction, spread_x, spread_y)
		local right = direction:cross(math.UP):normalized()
		local up = direction:cross(right):normalized()

		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x
		local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

		mvector3.add(direction, right * math.rad(ax))
		mvector3.add(direction, up * math.rad(ay))
		mvector3.normalize(direction)
	end

	function GiantBoBase:shoot_grenade(unit, is_left)
		if Network:is_server() then
			local position = nil
			local direction = nil

			if is_left == "true" then
				position = self._left_finger:position()
				direction = self._left_finger:rotation():x()
			else
				position = self._right_finger:position()
				direction = self._right_finger:rotation():x() * -1
			end

			do_spread(direction, 20.0, 10.0)

			local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 1.5)
			grenade:base()._timer = 5
		end
	end

	function GiantBoBase:set_flames(unit, state)
		if state == "true" and self._flames == false then
			self:play_sound(unit, "flamethrower_fire")
		elseif state == "false" and self._flames == true then
			self:play_sound(unit, "flamethrower_stop")
		end

		self._flames = state == "true"
	end

	function GiantBoBase:throw_molotov(unit)
		if Network:is_server() then
			local left_position = self._left_hand:position()
			local left_direction = self._left_hand:rotation():y() * -1
			left_position = left_position + (left_direction * 1000)

			local right_position = self._right_hand:position()
			local right_direction = self._right_hand:rotation():y()
			right_position = right_position + (right_direction * 1000)

			do_spread(left_direction, 5, 20)
			do_spread(right_direction, 5, 20)

			ProjectileBase.throw_projectile_npc("molotov", left_position, left_direction * 3)
			ProjectileBase.throw_projectile_npc("molotov", right_position, right_direction * 3)
		end
	end

	function GiantBoBase:throw_smoke(unit)
		if Network:is_server() then
			local left_position = self._left_hand:position()
			local left_direction = self._left_hand:rotation():x()
			left_position = left_position + (left_direction * 1000)

			local right_position = self._right_hand:position()
			local right_direction = self._right_hand:rotation():x() * -1
			right_position = right_position + (right_direction * 1000)

			do_spread(left_direction, 5, 2)
			do_spread(right_direction, 5, 2)

			ProjectileBase.throw_projectile_npc("molotov", left_position, left_direction * 2.5)
			ProjectileBase.throw_projectile_npc("molotov", right_position, right_direction * 2.5)
		end
	end