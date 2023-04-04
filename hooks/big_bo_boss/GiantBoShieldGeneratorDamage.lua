GiantBoShieldGeneratorDamage = GiantBoShieldGeneratorDamage or class()
GiantBoShieldGeneratorDamage.SHIELD_GENERATOR = true

local nda_unit = Idstring("units/pd2_mod_phys/props/nda_player_blockers/nda_wall_4x3m")
function GiantBoShieldGeneratorDamage:init(unit)
	self._unit = unit

	self._listener_holder = EventListenerHolder:new()
end

function GiantBoShieldGeneratorDamage:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function GiantBoShieldGeneratorDamage:remove_listener(key)
	self._listener_holder:remove(key)
end

function GiantBoShieldGeneratorDamage:add_damage(attacker_unit, type, damage)
	self._listener_holder:call("on_take_damage", self._unit, attacker_unit, damage)
	return false, 0
end

function GiantBoShieldGeneratorDamage:health_percentage()
	return self._health / self._max_health
end

function GiantBoShieldGeneratorDamage:damage_bullet(attack_data)
	return self:add_damage(attack_data.attacker_unit, "bullet", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_fire(attack_data)
	return self:add_damage(attack_data.attacker_unit, "fire", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_dot(attack_data)
	return self:add_damage(attack_data.attacker_unit, "dot", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_explosion(attack_data)
	return self:add_damage(attack_data.attacker_unit, "explosion", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_simple(attack_data)
	return self:add_damage(attack_data.attacker_unit, "simple", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_tase(attack_data)
	return self:add_damage(attack_data.attacker_unit, "tase", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_melee(attack_data)
	return self:add_damage(attack_data.attacker_unit, "melee", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:damage_mission(attack_data)
	return self:add_damage(attack_data.attacker_unit, "mission", attack_data.damage)
end

function GiantBoShieldGeneratorDamage:dead()
	return false
end