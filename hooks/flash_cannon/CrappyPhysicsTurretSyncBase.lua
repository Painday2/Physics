CrappyPhysicsTurretSyncBase = CrappyPhysicsTurretSyncBase or class(UnitBase)

function CrappyPhysicsTurretSyncBase:save(data)
	data.lock_fire = self._unit:weapon()._lock_fire
	data.player_on = self._unit:weapon()._player_on

	data.rotation = self._unit:weapon()._player_rotation

	data.active = self._unit:weapon()._active
end

function CrappyPhysicsTurretSyncBase:load(data)
	self._unit:weapon()._lock_fire = data.lock_fire
	self._unit:weapon()._player_on = data.player_on

	self._unit:weapon()._player_rotation = data.rotation

	self._unit:weapon()._active = data.active
end

function CrappyPhysicsTurretSyncBase:init(unit)
	CrappyPhysicsTurretSyncBase.super.init(self, unit, true)

	self._unit = unit
end

function CrappyPhysicsTurretSyncBase:send_rotation()
	local rotation = self._unit:weapon()._player_rotation or Rotation()
	managers.network:session():send_to_peers_synched("sync_stored_pos", self._unit, false, Vector3(), Vector3(rotation:yaw() / 10, rotation:pitch() / 10, rotation:roll() / 10))
end

function CrappyPhysicsTurretSyncBase:send_hit(position, hit_generator)
	managers.network:session():send_to_peers_synched("sync_stored_pos", self._unit, true, position, Vector3(hit_generator and 1 or 0, 0, 0))

	self:do_hit(position, hit_generator)
end

function CrappyPhysicsTurretSyncBase:do_hit(position, hit_generator)
	if hit_generator then
		local env_controller = managers.environment_controller
		env_controller._flashbang_duration = 1
		env_controller._current_flashbang = env_controller._flashbang_duration
		env_controller._current_flashbang_flash = env_controller._flashbang_duration

		-- If the player unit doesn't exist (downed) then don't do this part.
		if managers.player:player_unit() and alive(managers.player:player_unit()) then
			managers.player:player_unit():character_damage():on_flashbanged(1)
		end

		if Network:is_server() then
			for c_key, c_data in pairs(managers.enemy:all_enemies()) do
				c_data.unit:character_damage():damage_explosion({
					damage = 0,
					variant = "stun",
					col_ray = {
						position = c_data.unit:position(),
						ray = math.UP
					}
				})
			end
		end
	elseif Network:is_server() then
		local carry_id = "physics_flashbang"
		local pos = position
		local rot = Rotation()
		local dir = Vector3()

		managers.player:server_drop_carry(carry_id, 1, true, false, 1, pos, rot, dir, 0, nil, nil)
	end
end

function CrappyPhysicsTurretSyncBase:sync_shot_or_rotation(shot, position, rotation)
	if shot then
		local hit_generator = rotation.x > 0.3
		self:do_hit(position, hit_generator)

		return
	end

	self._unit:weapon()._player_rotation = Rotation(rotation.x * 10, rotation.y * 10, rotation.z * 10)
end
CrappyPhysicsTurretSyncBase.sync_stored_pos = CrappyPhysicsTurretSyncBase.sync_shot_or_rotation

local actions = {
	"lock_fire",
	"unlock_fire",
	"player_enter",
	"player_exit",
	"fired",
	"activate",
	"deactivate"
}

local index_from_action = {}
for index, action_name in pairs(actions) do
	index_from_action[action_name] = index
end

function CrappyPhysicsTurretSyncBase:send_action(action)
	if index_from_action[action] then
		managers.network:session():send_to_peers_synched("sync_flashbang_event", self._unit, index_from_action[action])
	end
end

function CrappyPhysicsTurretSyncBase:sync_action(action)
	if actions[action] then
		action = actions[action]

		if action == "lock_fire" then
			self._unit:weapon()._lock_fire = true
		elseif action == "unlock_fire" then
			self._unit:weapon()._lock_fire = false
		elseif action == "player_enter" then
			self._unit:weapon()._player_on = true
		elseif action == "player_exit" then
			self._unit:weapon()._player_on = false
		elseif action == "fired" then
			if self._unit:damage() and self._unit:damage():has_sequence("fired") then
				self._unit:damage():run_sequence_simple("fired")
			end

			if self._unit:weapon()._muzzle_effect then
				World:effect_manager():spawn(self._unit:weapon()._muzzle_effect_table[self._unit:weapon()._current_barrel])

				if self._unit:weapon()._shell_ejection_effect_table then
					World:effect_manager():spawn(self._unit:weapon()._shell_ejection_effect_table)
				end
			end
		elseif action == "activate" then
			self._unit:weapon()._active = true
		elseif action == "deactivate" then
			self._unit:weapon()._active = false
		end
	end
end
CrappyPhysicsTurretSyncBase.on_network_event = CrappyPhysicsTurretSyncBase.sync_action