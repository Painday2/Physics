GiantBoDamage = GiantBoDamage or class()
GiantBoDamage._DAMAGE_GRANULARITY = 512 + 512 + 128 + 300
GiantBoDamage._MAX_DAMAGE = 2500
GiantBoDamage._DAMAGE_GRANULARITY_PERCENT = GiantBoDamage._MAX_DAMAGE / GiantBoDamage._DAMAGE_GRANULARITY

GiantBoDamage.base_health = 500
GiantBoDamage.base_shield_generator_count = 3
GiantBoDamage.base_shield_generator_health = 75
GiantBoDamage.base_shield_generator_spin_speed = 10
GiantBoDamage.base_shield_generator_height = 1200

function GiantBoDamage:init(unit)
	self._unit = unit

	--[[
		Difficulty Indexes:
			1 - "easy"         - Easy (Unused)
			2 - "normal"       - Normal
			3 - "hard"         - Hard
			4 - "overkill"     - Very Hard
			5 - "overkill_145" - Overkill
			6 - "easy_wish"    - Mayhem
			7 - "overkill_290" - Death Wish
			8 - "sm_wish"      - Death Sentence
	]]--

	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self._max_health = GiantBoDamage.base_health
	self._shield_generator_max_health = GiantBoDamage.base_shield_generator_health
	self._shield_generator_count = GiantBoDamage.base_shield_generator_count

	-- Add an extra shield generator on overkill or above.
	if difficulty_index >= 5 then
		self._shield_generator_count = self._shield_generator_count + 1
	end

	self._health = self._max_health
	self._shield_generator_healths = {}
	for i = 1, self._shield_generator_count do
		self._shield_generator_healths[i] = 0
	end

	self._shield_generator_angle = 0
	self._shield_spinning = false
	self._shield_generator_origin = self._unit:position()
	self._shield_generator_radius = 2400
	self._shield_nda_wall_radius = 1300
	self._shield_generators = {}
	self._shield_nda_walls = {}
	self._shield_object = self._unit:get_object(Idstring("g_shield"))
	self:spawn_shield_generators()

	self._listener_holder = EventListenerHolder:new()
end

local nda_wall_unit = Idstring("units/pd2_mod_phys/props/nda_player_blockers/nda_wall_4x3m")
local nda_wall_length = 377
local nda_wall_height = 300
local shield_generator_unit = Idstring("units/pd2_mod_phys/props/giant_bo_shield_generator/giant_bo_shield_generator")
function GiantBoDamage:spawn_shield_generators()
	for i = 1, self:shield_generator_count() do
		local angle = 360 * i/self:shield_generator_count()
		local rotation = Rotation(angle, 0, 0)
		local position = self._shield_generator_origin + Vector3(
			math.sin(angle) * self._shield_generator_radius,
			-math.cos(angle) * self._shield_generator_radius,
			GiantBoDamage.base_shield_generator_height
		)

		self._shield_generators[i] = World:spawn_unit(shield_generator_unit, position, rotation)
		self._shield_generators[i]:character_damage():add_listener("shield_generator_take_damage", { "on_take_damage" }, function(unit, attacker, damage)
			self:add_shield_generator_damage(attacker, damage, i)
		end)

		self._shield_generators[i]:set_enabled(false)
		self._shield_generators[i]:effect_spawner(Idstring("laser")):kill_effect()
	end

	-- Calculate how many walls we can fit into the desired radius and then calculate the actual radius that'll make it fit perfectly.	
	local single_nda_wall_angle = 2 * math.asin(nda_wall_length / (2 * self._shield_nda_wall_radius))
	local nda_wall_count = math.floor(360 / single_nda_wall_angle)
	self._shield_nda_wall_actual_radius = (nda_wall_length/2) / math.sin(180 / nda_wall_count)

	for i = 1, nda_wall_count do
		local angle = 360 * i/nda_wall_count
		local rotation = Rotation(angle, 0, 0)
		local position = self._shield_generator_origin + Vector3(
			math.sin(angle) * self._shield_nda_wall_actual_radius,
			-math.cos(angle) * self._shield_nda_wall_actual_radius,
			GiantBoDamage.base_shield_generator_height - (nda_wall_height/2)
		)

		self._shield_nda_walls[i] = World:spawn_unit(nda_wall_unit, position, rotation)
		self._shield_nda_walls[i]:set_enabled(false)
	end
end

function GiantBoDamage:set_shield_generator_origin(position)
	self._shield_generator_origin = position
end

function GiantBoDamage:shield_generator_count()
	return self._shield_generator_count
end

function GiantBoDamage:update(unit, t, dt)
	if self._shield_spinning then
		self._shield_generator_angle = (self._shield_generator_angle + (dt * GiantBoDamage.base_shield_generator_spin_speed)) % 360

		for i = 1, self._unit:character_damage():shield_generator_count() do
			local angle = self._shield_generator_angle + (360 * i/self._unit:character_damage():shield_generator_count())
			local rotation = Rotation(angle, 0, 0)
			local position = self._shield_generator_origin + Vector3(
				math.sin(angle) * self._shield_generator_radius,
				-math.cos(angle) * self._shield_generator_radius,
				GiantBoDamage.base_shield_generator_height
			)

			self._shield_generators[i]:set_rotation(rotation)
			self._shield_generators[i]:set_position(position)
		end

		for i, nda_wall in pairs(self._shield_nda_walls) do
			local angle = (self._shield_generator_angle + (360 * i/#self._shield_nda_walls)) * -1
			local rotation = Rotation(angle, 0, 0)
			local position = self._shield_generator_origin + Vector3(
				math.sin(angle) * self._shield_nda_wall_actual_radius,
				-math.cos(angle) * self._shield_nda_wall_actual_radius,
				GiantBoDamage.base_shield_generator_height - (nda_wall_height/2)
			)

			nda_wall:set_rotation(rotation)
			nda_wall:set_position(position)
		end
	end
end

function GiantBoDamage:set_shield_visibility(state)
	self._shield_object:set_visibility(state)

	for i, nda_wall in pairs(self._shield_nda_walls) do
		nda_wall:set_enabled(state)
	end
end

function GiantBoDamage:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function GiantBoDamage:remove_listener(key)
	self._listener_holder:remove(key)
end

local function split_number(number, ...)
	local output = {}
	local bins = {...}

	for _, bin_size in pairs(bins) do
		local value = math.min(number, bin_size)
		number = number - value

		table.insert(output, value)
	end

	return output
end

function GiantBoDamage:all_shield_generators_dead()
	for i = 1, self._shield_generator_count do
		if self._shield_generator_healths[i] > 0 then
			return false
		end
	end

	return true
end

function GiantBoDamage:reset_shield_generator_health()
	self._shield_spinning = true
	self._shield_generator_reset_time = Application:time()

	for i = 1, self._shield_generator_count do
		self._shield_generator_healths[i] = self._shield_generator_max_health

		self._shield_generators[i]:set_enabled(true)
		self._shield_generators[i]:effect_spawner(Idstring("laser")):activate()
	end

	self:set_shield_visibility(true)

	managers.hud:set_boss_health_shield(true)
end

function GiantBoDamage:add_shield_generator_damage(attacker_unit, damage, index)
	damage = math.clamp(damage, 0, self._MAX_DAMAGE)
	local damage_percent = math.ceil(damage / self._DAMAGE_GRANULARITY_PERCENT)
	damage = damage_percent * self._DAMAGE_GRANULARITY_PERCENT

	-- Abusing other melee network data to sync more detailed damage data.
	local split_damage_percent = split_number(damage_percent, 512, 512, 128, 300)
	self._unit:network():send("damage_melee", attacker_unit, split_damage_percent[1], split_damage_percent[2], split_damage_percent[3], split_damage_percent[4], index, false)

	return self:do_shield_generator_damage(attacker_unit, damage, index)
end

function GiantBoDamage:do_shield_generator_damage(attacker_unit, damage, index)
	self._shield_generator_healths[index] = self._shield_generator_healths[index] - damage
	self._shield_generator_healths[index] = math.clamp(self._shield_generator_healths[index], 0, self._shield_generator_max_health)

	local shield_generator_health_percentage = self:shield_generator_health_percentage(index)
	if shield_generator_health_percentage == 0 then
		self._shield_generators[index]:set_enabled(false)
		self._shield_generators[index]:effect_spawner(Idstring("laser")):kill_effect()

		World:effect_manager():spawn({
			effect = Idstring("effects/phys/explosions/shield_generator"),
			position = self._shield_generators[index]:position(),
			normal = math.UP
		})

		self._shield_generators[index]:sound_source():post_event("trip_mine_explode")

		if self:all_shield_generators_dead() then
			self._shield_spinning = false

			self:set_shield_visibility(false)

			managers.hud:set_boss_health_shield(false)
		end
	end

	self._listener_holder:call("on_take_shield_generator_damage", self._unit, attacker_unit, damage, index)

	return false, 0
end

function GiantBoDamage:damage_multiplier()
	local player_count = Global.running_simulation and managers.editor:mission_player()
	player_count = player_count or managers.network:session() and managers.network:session():amount_of_players()

	--[[
		Player Count Based Damage Reduction:
			1 - 1/1 = 1
			2 - 1/2 = 0.5
			3 - 1/3 = 0.333
			4 - 1/4 = 0.25

		Effectively equivelent to (health * player_count)
	]]--

	return 1/player_count
end

function GiantBoDamage:add_damage(attacker_unit, type, damage)
	if self:dead() then return end
	if self._shield_spinning then return end

	damage = math.clamp(damage, 0, self._MAX_DAMAGE)
	local damage_percent = math.ceil(damage / self._DAMAGE_GRANULARITY_PERCENT)
	damage = damage_percent * self._DAMAGE_GRANULARITY_PERCENT

	-- Abusing other melee network data to sync more detailed damage data.
	local split_damage_percent = split_number(damage_percent, 512, 512, 128, 300)
	self._unit:network():send("damage_melee", attacker_unit, split_damage_percent[1], split_damage_percent[2], split_damage_percent[3], split_damage_percent[4], 0, false)

	return self:do_damage(attacker_unit, damage)
end

function GiantBoDamage:do_damage(attacker_unit, damage)
	if self:dead() then return end
	if self._shield_spinning then return end

	self._health = self._health - (damage * self:damage_multiplier())
	self._health = math.clamp(self._health, 0, self._max_health)

	self._listener_holder:call("on_take_damage", self._unit, attacker_unit, damage)

	local health_percentage = self._unit:character_damage():health_percentage()
	managers.hud:set_boss_health(health_percentage)

	return false, 0
end

-- Using this to sync all damage.
function GiantBoDamage:sync_damage_melee(attacker_unit, damage_percent_1, damage_percent_2, damage_percent_3, damage_percent_4, index, death)
	local damage_percent = damage_percent_1 + damage_percent_2 + damage_percent_3 + damage_percent_4
	local damage = damage_percent * self._DAMAGE_GRANULARITY_PERCENT

	if index > 0 then
		self:do_shield_generator_damage(attacker_unit, damage, index)
	else
		self:do_damage(attacker_unit, damage)
	end
end

function GiantBoDamage:health_percentage()
	return self._health / self._max_health
end

function GiantBoDamage:shield_generator_health_percentage(index)
	return self._shield_generator_healths[index] / self._shield_generator_max_health
end

function GiantBoDamage:damage_bullet(attack_data)
	return self:add_damage(attack_data.attacker_unit, "bullet", attack_data.damage)
end

function GiantBoDamage:damage_fire(attack_data)
	return self:add_damage(attack_data.attacker_unit, "fire", attack_data.damage)
end

function GiantBoDamage:damage_dot(attack_data)
	return self:add_damage(attack_data.attacker_unit, "dot", attack_data.damage)
end

function GiantBoDamage:damage_explosion(attack_data)
	return self:add_damage(attack_data.attacker_unit, "explosion", attack_data.damage)
end

function GiantBoDamage:damage_simple(attack_data)
	return self:add_damage(attack_data.attacker_unit, "simple", attack_data.damage)
end

function GiantBoDamage:damage_tase(attack_data)
	return self:add_damage(attack_data.attacker_unit, "tase", attack_data.damage)
end

function GiantBoDamage:damage_melee(attack_data)
	return self:add_damage(attack_data.attacker_unit, "melee", attack_data.damage)
end

function GiantBoDamage:damage_mission(attack_data)
	return self:add_damage(attack_data.attacker_unit, "mission", attack_data.damage)
end

function GiantBoDamage:dead()
	return self._health == 0
end

function GiantBoDamage:set_health_display(state)
	self._health_display_wanted = state

	if state then
		managers.hud:open_boss_health("GIANT BO")
	else
		managers.hud:close_boss_health()
	end
end

function GiantBoDamage:save(data)
	local save_health = self._health ~= self._max_health

	if save_health then
		data.health = self._health
		data.max_health = self._max_health
	end

	data.shield_spinning = self._shield_spinning

	data.shield_generator_angle = self._shield_generator_angle

	data.shield_generator_count = self._shield_generator_count
	data.shield_generator_max_health = self._shield_generator_max_health
	data.shield_generator_healths = self._shield_generator_healths

	data.health_display_wanted = self._health_display_wanted
end

function GiantBoDamage:load(data)
	if data.health then
		self._health = data.health
		self._max_health = data.max_health
	end

	self._shield_spinning = data.shield_spinning

	self._shield_generator_angle = data.shield_generator_angle

	self._shield_generator_count = data.shield_generator_count
	self._shield_generator_max_health = data.shield_generator_max_health
	self._shield_generator_healths = data.shield_generator_healths

	if not self._shield_spinning then
		self:set_shield_visibility(false)
	end

	if data.health_display_wanted then
		self:set_health_display(true)

		local health_percentage = self._unit:character_damage():health_percentage()
		managers.hud:set_boss_health(health_percentage)

		if self._shield_spinning then
			managers.hud:set_boss_health_shield(true)
			self:reset_shield_generator_health()

			-- Hide any already dead ones.
			for i = 1, self._shield_generator_count do
				local shield_generator_health_percentage = self:shield_generator_health_percentage(i)
				if shield_generator_health_percentage == 0 then
					self._shield_generators[i]:set_enabled(false)
					self._shield_generators[i]:effect_spawner(Idstring("laser")):kill_effect()
				end
			end
		end
	end
end