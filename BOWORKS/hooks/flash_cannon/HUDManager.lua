Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "_setup_player_info_hud_pd2_boworks_flash_cannon", function(self)
	if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

	self:_create_turret_hud(hud)
end)

function HUDManager:_create_turret_hud(hud)
	self._turret_hud = HUDTurret:new(hud)

	self._turret_hud:set_x(hud.panel:w() / 2 - self._turret_hud:w() / 2)
	self._turret_hud:set_y(hud.panel:h() / 2 - self._turret_hud:h() / 2)
end

function HUDManager:show_turret_hud(turret_unit, bullet_type)
	self._turret_hud:show(turret_unit, bullet_type)
end

function HUDManager:hide_turret_hud(turret_unit)
	self._turret_hud:hide(turret_unit)
end

function HUDManager:update_heat_indicator(current)
	self._turret_hud:update_heat_indicator(current)
end

function HUDManager:player_turret_overheat(turret_unit)
	self._turret_hud:overheat(turret_unit)
end

function HUDManager:player_turret_flak_insert()
	self._turret_hud:flak_insert()
end

function HUDManager:set_player_turret_overheating(overheating)
	self._turret_hud:set_overheating(overheating)
end

function HUDManager:player_turret_cooldown()
	self._turret_hud:cooldown()
end