Hooks:PostHook(PlayerManager, "init", "playermanager_boworks_init", function(self)
	self._player_states.turret = "ingame_standard"
end)

Hooks:PostHook(PlayerManager, "_setup", "playermanager_boworks_setup", function(self)
	Global.player_manager.synced_turret = {}
end)

Hooks:PostHook(PlayerManager, "set_player_state", "playermanager_boworks_set_player_state", function(self, state)
	local states_which_dont_disable_berserker = {
		"standard",
		"carry",
		"tased",
		"bipod",
		"jerry1",
		"jerry2",
		"turret"
	}

	if not table.contains(states_which_dont_disable_berserker, state) then
		local unit = self:player_unit()

		if unit then
			unit:character_damage():disable_berserker()
		end
	end
end)

Hooks:PostHook(PlayerManager, "peer_dropped_out", "playermanager_boworks_peer_dropped_out", function(self, peer)
	if Network:is_server() then
		self:_turret_drop_out(peer)
	end

	local peer_id = peer:id()
	self._global.synced_turret[peer_id] = nil
end)

Hooks:PostHook(PlayerManager, "sync_save", "playermanager_boworks_sync_save", function(self, data)
	data.PlayerManager.husk_turret_data = self._global.synced_turret
end)

Hooks:PostHook(PlayerManager, "sync_load", "playermanager_boworks_sync_load", function(self, data)
	local state = data.PlayerManager

	if state then
		self:set_husk_turret_data(state.husk_turret_data)
	end
end)

function PlayerManager:clear_synced_turret()
	self._global.synced_turret = {}
end

function PlayerManager:_turret_drop_out(peer)
	local peer_id = peer:id()
	local husk_data = self._global.synced_turret[peer_id]

	if husk_data and alive(husk_data.turret_unit) then
		local weapon = husk_data.turret_unit:weapon()

		weapon:on_player_exit()
		weapon:set_weapon_user(nil)
		husk_data.turret_unit:interaction():set_active(true, true)
		weapon:enable_automatic_SO(true)
	end
end

function PlayerManager:update_husk_turret_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_turret[peer_id] then
		local husk_pos = self._global.synced_turret[peer_id].husk_pos
		local turret_rot = self._global.synced_turret[peer_id].turret_rot
		local enter_animation = self._global.synced_turret[peer_id].enter_animation
		local exit_animation = self._global.synced_turret[peer_id].exit_animation
		local turret_unit = self._global.synced_turret[peer_id].turret_unit

		--peer:send_queued_sync("sync_ground_turret_husk", husk_pos, turret_rot, enter_animation, exit_animation, turret_unit)
	end
end

function PlayerManager:set_husk_turret_data(data)
	self._global.synced_turret = data
end

function PlayerManager:set_turret_data_for_peer(data)
	if not self._global.synced_turret then
		self._global.synced_turret = {}
	end

	self._global.synced_turret[data.peer_id] = {
		husk_pos = data.husk_pos,
		turret_rot = data.turret_rot,
		enter_animation = data.enter_animation,
		exit_animation = data.exit_animation,
		turret_unit = data.turret_unit
	}
end

function PlayerManager:get_turret_data_for_peer(peer_id)
	return self._global.synced_turret[peer_id]
end

function PlayerManager:set_synced_turret(peer, husk_pos, turret_rot, enter_animation, exit_animation, turret_unit)
	local peer_id = peer:id()
	self._global.synced_turret[peer_id] = {
		husk_pos = husk_pos,
		turret_rot = turret_rot,
		enter_animation = enter_animation,
		exit_animation = exit_animation,
		turret_unit = turret_unit
	}
end

function PlayerManager:set_husk_turret_data(data)
	self._global.synced_turret = data
end

function PlayerManager:use_turret(turret_unit)
	self._turret_unit = turret_unit
end

function PlayerManager:leave_turret()
	self._turret_unit = nil
end

function PlayerManager:get_turret_unit()
	return self._turret_unit
end
