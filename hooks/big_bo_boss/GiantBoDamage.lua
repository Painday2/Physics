GiantBoDamage = GiantBoDamage or class()
GiantBoDamage._DAMAGE_GRANULARITY = 512 + 512 + 128 + 300
GiantBoDamage._MAX_DAMAGE = 2500
GiantBoDamage._DAMAGE_GRANULARITY_PERCENT = GiantBoDamage._MAX_DAMAGE / GiantBoDamage._DAMAGE_GRANULARITY

function GiantBoDamage:init(unit)
	self._unit = unit

	self._max_health = GiantBoBase.health
	self._health = self._max_health

	self._shield_generator_healths = {}
	for i = 1, GiantBoBase.shield_generator_count do
		self._shield_generator_healths[i] = 0
	end

	self._listener_holder = EventListenerHolder:new()
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
	for i = 1, GiantBoBase.shield_generator_count do
		if self._shield_generator_healths[i] > 0 then
			return false
		end
	end

	return true
end

function GiantBoDamage:reset_shield_generator_health()
	for i = 1, GiantBoBase.shield_generator_count do
		self._shield_generator_healths[i] = GiantBoBase.shield_generator_health
	end
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
	self._shield_generator_healths[index] = math.clamp(self._shield_generator_healths[index], 0, GiantBoBase.shield_generator_health)

	self._listener_holder:call("on_take_shield_generator_damage", self._unit, attacker_unit, damage, index)

	return false, 0
end

function GiantBoDamage:add_damage(attacker_unit, type, damage)
	damage = math.clamp(damage, 0, self._MAX_DAMAGE)
	local damage_percent = math.ceil(damage / self._DAMAGE_GRANULARITY_PERCENT)
	damage = damage_percent * self._DAMAGE_GRANULARITY_PERCENT

	-- Abusing other melee network data to sync more detailed damage data.
	local split_damage_percent = split_number(damage_percent, 512, 512, 128, 300)
	self._unit:network():send("damage_melee", attacker_unit, split_damage_percent[1], split_damage_percent[2], split_damage_percent[3], split_damage_percent[4], 0, false)

	return self:do_damage(attacker_unit, damage)
end

function GiantBoDamage:do_damage(attacker_unit, damage)
	self._health = self._health - damage
	self._health = math.clamp(self._health, 0, self._max_health)

	self._listener_holder:call("on_take_damage", self._unit, attacker_unit, damage)

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
	return self._shield_generator_healths[index] / GiantBoBase.shield_generator_health
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
	return false
end

function GiantBoDamage:save(data)
	local save_health = self._health ~= self._max_health

	if save_health then
		data.health = self._health
		data.max_health = self._max_health
	end

	data.shield_generator_healths = self._shield_generator_healths
end

function GiantBoDamage:load(data)
	if data.health then
		self._health = data.health
		self._max_health = data.max_health
	end

	self._shield_generator_healths = data.shield_generator_healths
end