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

	self._unit:character_damage():set_shield_generator_origin(self._rotation_data.origin)
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

	self._unit:character_damage():set_shield_generator_origin(self._rotation_data.origin)
	self._head = self._unit:get_object(Idstring("Head"))

	self._unit:character_damage():add_listener("giant_bo_take_damage", { "on_take_damage" }, callback(self, self, "_on_damage"))

	self._attack_class = GiantBoBaseAttacks:new(unit, self)
end

function GiantBoBaseHusk:_on_damage(unit, attacker, damage)
	self._aggressiveness = 1 - self._unit:character_damage():health_percentage()
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

	if action_data.attack_funcs then
		self._last_attack_action = action
	end

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
		self[action_data.func](self)
	end
end
GiantBoBaseHusk.run_sequence_simple = GiantBoBaseHusk.sync_action

function GiantBoBaseHusk:do_action_attack(unit, attack_index)
	if not self._last_attack_action then return end
	if not self._actions[self._last_attack_action] then return end

	local attack_funcs = self._actions[self._last_attack_action].attack_funcs or {}
	if #attack_funcs < 1 then return end

	local attack_func_name = attack_funcs[attack_index]

	if self._attack_class[attack_func_name] then
		self._attack_class[attack_func_name](self._attack_class)
	end
end

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

	self._attack_class:update(t, dt)
end

function GiantBoBaseHusk:get_origin()
	return self._rotation_data.origin or Vector3()
end

function GiantBoBaseHusk:activate()
	self._enabled = true
end

function GiantBoBaseHusk:reset_shield_generator_health()
	self._unit:character_damage():reset_shield_generator_health()
end

function GiantBoBaseHusk:show_health()
	self._unit:character_damage():set_health_display(true)
end

function GiantBoBaseHusk:hide_health()
	self._unit:character_damage():set_health_display(false)
end

function GiantBoBaseHusk:start_credits()
	managers.hud:open_boworks_credits()
end

function GiantBoBaseHusk:invincible_players()
	managers.player:player_unit():character_damage():set_invulnerable(true)
end

local ammo_unit = Idstring("units/pd2_mod_phys/projectiles/ammo_projectile/ammo_projectile")
function GiantBoBaseHusk:spew_ammo()
	local position = self._head:position() + Vector3(0, 0, 1000)
	local rotation = self._head:rotation()
	local direction = Rotation(math.random(1, 360), 0, 0):y() * 2

	local unit = World:spawn_unit(ammo_unit, position, Rotation(direction, math.UP))

	unit:base():throw({
		dir = direction,
		projectile_entry = "ammo_projectile"
	})
end

if not Network:is_server() then
	-- I should really make GiantBoBaseHusk inherit GiantBoBase but I'm too lazy to set it up for that now.
	GiantBoBaseHusk._actions = GiantBoBase._actions
	GiantBoBase = GiantBoBaseHusk
end