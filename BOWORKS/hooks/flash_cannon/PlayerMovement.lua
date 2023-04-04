Hooks:PostHook(PlayerMovement, "_setup_states", "playermovement_boworks_setup_states", function(self)
	self._states.turret = PlayerTurret:new(self._unit)
end)

Hooks:PostHook(PlayerMovement, "on_cuffed", "playermovement_boworks_on_cuffed", function(self)
	if self._unit:character_damage()._god_mode then
		return
	end

	if self._current_state_name == "turret" then
		managers.player:set_player_state("arrested")
	end
end)