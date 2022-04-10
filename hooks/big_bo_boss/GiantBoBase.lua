GiantBoBase = GiantBoBase or class(UnitBase)
GiantBoBase._actions = {
	intro = {
		animation = "intro",
		length = 140/30
	},
	breath_fire = {
		animation = "breath_fire",
		length = 120/30,
		attack_funcs = {
			"set_flames_on",
			"set_flames_off"
		},
		use_aggressiveness = true
	},
	throw_smoke_mid = {
		animation = "throw_smoke",
		length = 40/30,
		attack_funcs = {
			"throw_smoke"
		},
		use_aggressiveness = true
	},
	throw_smoke_sides = {
		animation = "throw_molotov",
		length = 40/30,
		attack_funcs = {
			"throw_smoke"
		},
		use_aggressiveness = true
	},
	throw_molotov_mid = {
		animation = "throw_smoke",
		length = 40/30,
		attack_funcs = {
			"throw_molotov"
		},
		use_aggressiveness = true
	},
	throw_molotov_sides = {
		animation = "throw_molotov",
		length = 40/30,
		attack_funcs = {
			"throw_molotov"
		},
		use_aggressiveness = true
	},
	shoot_grenades_close = {
		animation = "throw_smoke",
		length = 40/30,
		attack_funcs = {
			"shoot_grenade_close_left",
			"shoot_grenade_close_right"
		},
		use_aggressiveness = true
	},
	shoot_grenades_mid = {
		animation = "throw_smoke",
		length = 40/30,
		attack_funcs = {
			"shoot_grenade_mid_left",
			"shoot_grenade_mid_right"
		},
		use_aggressiveness = true
	},
	shoot_grenades_far = {
		animation = "shoot_grenades",
		length = 40/30,
		attack_funcs = {
			"shoot_grenade_left",
			"shoot_grenade_right"
		},
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
	},
	start_credits = {
		func = "start_credits"
	},
	invincible_players = {
		func = "invincible_players"
	}
}

GiantBoBase.health = 7500

GiantBoBase.shield_generator_count = 3
GiantBoBase.shield_generator_health = GiantBoBase.health/10
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

	local players = Global.running_simulation and managers.editor:mission_player()
	players = players or managers.network:session() and managers.network:session():amount_of_players()

	log(players)

	GiantBoBase.health = GiantBoBase.health * players

	GiantBoBase.shield_generator_count = GiantBoBase.shield_generator_count * players

	log(GiantBoBase.shield_generator_count)
	log(GiantBoBase.health)

	self._shield_generators = {}
	self:spawn_shield_generators()

	self._unit:character_damage():add_listener("giant_bo_take_damage", { "on_take_damage" }, callback(self, self, "_on_damage"))
	self._unit:character_damage():add_listener("giant_bo_shield_generator_damage", { "on_take_shield_generator_damage" }, callback(self, self, "_on_shield_generator_damage"))

	self._attack_class = GiantBoBaseAttacks:new(unit, self)
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
		self:set_state("idle", 0.3)
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

	if action_data.attack_funcs then
		self._last_attack_action = action
	end

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

function GiantBoBase:do_action_attack(unit, attack_index)
	local attack_funcs = self._actions[self._last_attack_action].attack_funcs or {}
	if #attack_funcs < 1 then return end

	local attack_func_name = attack_funcs[attack_index]

	if self._attack_class[attack_func_name] then
		self._attack_class[attack_func_name](self._attack_class)
	end
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
	if self._current_state == "shield" then return end

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

function GiantBoBase:set_state(new_state, delay)
	if not delay or delay == 0 then
		self._current_state = new_state

		return
	end

	self._next_wanted_state = new_state
	self._next_state_t = Application:time() + delay
end

local flame_mvec1 = Vector3()
function GiantBoBase:update(unit, t, dt)
	if not self._enabled then return end

	if self._next_wanted_state and self._next_state_t then
		if t > self._next_state_t then
			self._current_state = self._next_wanted_state

			self._next_wanted_state = nil
			self._next_state_t = nil
		end
	end

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

	self._attack_class:update(t, dt)
end

function GiantBoBase:start_credits()
	managers.hud:open_boworks_credits()
end

function GiantBoBase:invincible_players()
	managers.player:player_unit():character_damage():set_invulnerable(true)
end