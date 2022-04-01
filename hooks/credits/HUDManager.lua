function HUDManager:_create_boworks_credits(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self._hud_boworks_credits = HUDBoworksCredits:new(hud)
end

function HUDManager:open_boworks_credits()
	self._hud_boworks_credits:open()
end

function HUDManager:close_boworks_credits()
	self._hud_boworks_credits:close()
end

Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "_setup_player_info_hud_pd2_boworks_credits", function(self)
	if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self:_create_boworks_credits(hud)
end)

Hooks:PostHook(HUDManager, "update", "update_boworks_credits", function(self, t, dt)
	if self._hud_boworks_credits then
		self._hud_boworks_credits:update(t, dt)
	end
end)

Hooks:PostHook(HUDManager, "destroy", "destroy_boworks_credits", function(self)
	-- Force reset the timers on destruction to catch quitting or restarts.
	TimerManager:game_animation():play()
	TimerManager:timer(Idstring("player")):play()
end)