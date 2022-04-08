GiantBoBaseAttacks = GiantBoBaseAttacks or class()

function GiantBoBaseAttacks:init(unit, base)
	self._unit = unit
	self._base = base

	self._head = self._unit:get_object(Idstring("Head"))

	self._left_hand = self._unit:get_object(Idstring("LeftHand"))
	self._right_hand = self._unit:get_object(Idstring("RightHand"))

	self._left_finger = self._unit:get_object(Idstring("LeftHandMiddle3"))
	self._right_finger = self._unit:get_object(Idstring("RightHandMiddle3"))

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

	self._flamethrower_effect_collection = {}

	self._flames = false
	self._next_flame_time = 0
	self._next_flame_damage_time = 0

	self._sound = SoundDevice:create_source("giant_bo")
	self._sound:link(self._head)
	self._sound:set_switch("suppressed", "regular")
end

function GiantBoBaseAttacks:flame_spawn_pos()
	return self._head:position() + self._flame_stats.offset:rotate_with(self._head:rotation())
end

local flame_mvec1 = Vector3()
function GiantBoBaseAttacks:update(t, dt)
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

function GiantBoBaseAttacks:play_sound(unit, event)
	self._sound:post_event(event)
end

function GiantBoBaseAttacks:set_flames_on()
	if self._flames == false then
		self:play_sound(unit, "flamethrower_fire")
	end

	self._flames = true
end

function GiantBoBaseAttacks:set_flames_off()
	if self._flames == true then
		self:play_sound(unit, "flamethrower_stop")
	end

	self._flames = false
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

local bo_spawn_smoke = function(self, normal) 	
	local position = self._unit:position()
	local rotation = self._unit:rotation()
	local data = {
		sound_event = "trip_mine_explode",
		range = 150,
		curve_pow = 3,
		damage = 0,
		fire_alert_radius = 1500,
		alert_radius = 1500,
		sound_event_burning = "burn_loop_gen",
		is_molotov = true,
		player_damage = 1,
		sound_event_impact_duration = 4,
		burn_tick_period = 0.5,
		burn_duration = 15,
		effect_name = "effects/particles/explosions/smoke_grenade_smoke",
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 15,
			dot_length = 6,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		}
	}

	EnvironmentFire.spawn(position, rotation, data, normal, self._thrower_unit, 0, 1)

	self._unit:set_visible(false)

	if Network:is_server() then
		self.burn_stop_time = TimerManager:game():time() + data.burn_duration + data.fire_dot_data.dot_length + 1
	end
end

local bo_spawn_fire = function(self, normal) 
	local position = self._unit:position()
	local rotation = self._unit:rotation()
	local data = {
		sound_event = "molotov_impact",
		range = 250,
		curve_pow = 3,
		damage = 0,
		fire_alert_radius = 1500,
		alert_radius = 1500,
		sound_event_burning = "burn_loop_gen",
		is_molotov = true,
		player_damage = 1,
		sound_event_impact_duration = 4,
		burn_tick_period = 0.5,
		burn_duration = 15,
		effect_name = "effects/payday2/particles/fire/fire_floor",
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 15,
			dot_length = 6,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		}
	}

	EnvironmentFire.spawn(position, rotation, data, normal, self._thrower_unit, 0, 1)

	self._unit:set_visible(false)

	if Network:is_server() then
		self.burn_stop_time = TimerManager:game():time() + data.burn_duration + data.fire_dot_data.dot_length + 1
	end
end

function GiantBoBaseAttacks:throw_smoke()
	if Network:is_server() then
		local left_position = self._left_hand:position()
		local left_direction = self._left_hand:rotation():x()
		left_position = left_position + (left_direction * 1000)

		local right_position = self._right_hand:position()
		local right_direction = self._right_hand:rotation():x() * -1
		right_position = right_position + (right_direction * 1000)

		do_spread(left_direction, 5, 2)
		do_spread(right_direction, 5, 2)

		local grenade_left = ProjectileBase.throw_projectile_npc("molotov", left_position, left_direction * 2.5)
		local grenade_right = ProjectileBase.throw_projectile_npc("molotov", right_position, right_direction * 2.5)

		grenade_left:base()._spawn_environment_fire = bo_spawn_smoke
		grenade_right:base()._spawn_environment_fire = bo_spawn_smoke
	end
end

function GiantBoBaseAttacks:throw_molotov()
	if Network:is_server() then
		local left_position = self._left_hand:position()
		local left_direction = self._left_hand:rotation():y() * -1
		left_position = left_position + (left_direction * 1000)

		local right_position = self._right_hand:position()
		local right_direction = self._right_hand:rotation():y()
		right_position = right_position + (right_direction * 1000)

		do_spread(left_direction, 5, 20)
		do_spread(right_direction, 5, 20)

		local grenade_left = ProjectileBase.throw_projectile_npc("molotov", left_position, left_direction * 3)
		local grenade_right = ProjectileBase.throw_projectile_npc("molotov", right_position, right_direction * 3)

		grenade_left:base()._spawn_environment_fire = bo_spawn_fire
		grenade_right:base()._spawn_environment_fire = bo_spawn_fire
	end
end

function GiantBoBaseAttacks:shoot_grenade_left()
	if Network:is_server() then
		local position = self._left_finger:position()
		local direction = self._left_finger:rotation():x()
		do_spread(direction, 20.0, 10.0)

		local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 1.7)
		grenade:base()._timer = 5
		grenade:base()._range = 2000
		grenade:base()._damage = 0
		grenade:base()._player_damage = 15
	end
end

function GiantBoBaseAttacks:shoot_grenade_right()
	if Network:is_server() then
		local position = self._right_finger:position()
		local direction = self._right_finger:rotation():x() * -1
		do_spread(direction, 20.0, 10.0)

		local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 1.7)
		grenade:base()._timer = 5
		grenade:base()._range = 2000
		grenade:base()._damage = 0
		grenade:base()._player_damage = 15
	end
end

function GiantBoBaseAttacks:shoot_grenade_close_left()
	if Network:is_server() then
		local position = self._left_finger:position()
		local direction = self._left_finger:rotation():x()
		do_spread(direction, 20.0, 10.0)

		local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 0.6)
		grenade:base()._timer = 5
		grenade:base()._range = 2000
		grenade:base()._damage = 0
		grenade:base()._player_damage = 15
	end
end

function GiantBoBaseAttacks:shoot_grenade_close_left()
	if Network:is_server() then
		local position = self._right_finger:position()
		local direction = self._right_finger:rotation():x() * -1
		do_spread(direction, 20.0, 10.0)

		local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 0.6)
		grenade:base()._timer = 5
		grenade:base()._range = 2000
		grenade:base()._damage = 0
		grenade:base()._player_damage = 15
	end
end

function GiantBoBaseAttacks:shoot_grenade_mid_left()
	if Network:is_server() then
		local position = self._left_finger:position()
		local direction = self._left_finger:rotation():x()
		do_spread(direction, 20.0, 10.0)

		local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 1)
		grenade:base()._timer = 5
		grenade:base()._range = 2000
		grenade:base()._damage = 0
		grenade:base()._player_damage = 15
	end
end

function GiantBoBaseAttacks:shoot_grenade_mid_left()
	if Network:is_server() then
		local position = self._right_finger:position()
		local direction = self._right_finger:rotation():x() * -1
		do_spread(direction, 20.0, 10.0)

		local grenade = ProjectileBase.throw_projectile_npc("frag", position, direction * 1)
		grenade:base()._timer = 5
		grenade:base()._range = 2000
		grenade:base()._damage = 0
		grenade:base()._player_damage = 15
	end
end