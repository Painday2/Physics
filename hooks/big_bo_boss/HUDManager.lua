function HUDManager:_create_boss_health(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self._hud_boss_health = HUDBossHealth:new(hud)
end

function HUDManager:open_boss_health(boss_name)
	boss_name = boss_name or "BOSS"

	self._hud_boss_health:set_name(boss_name)
	self._hud_boss_health:open()
end

function HUDManager:close_boss_health()
	self._hud_boss_health:close()
end

function HUDManager:set_boss_health(health)
	self._hud_boss_health:set_health(health)
end

Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "PhysicsBossHudSetup", function(self)
	if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self:_create_boss_health(hud)
end)