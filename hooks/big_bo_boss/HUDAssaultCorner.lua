HUDAssaultCorner.pre_boworks_get_assault_strings = HUDAssaultCorner.pre_boworks_get_assault_strings or HUDAssaultCorner._get_assault_strings
function HUDAssaultCorner:_get_assault_strings()
	local assault_strings = self:pre_boworks_get_assault_strings()

	if self._assault_mode == "normal" then
		self:_update_assault_hud_color(self._vip_assault_color)

		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_bo",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_bo",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line"
			}
		else
			return {
				"hud_assault_bo",
				"hud_assault_end_line",
				"hud_assault_bo",
				"hud_assault_end_line",
				"hud_assault_bo",
				"hud_assault_end_line"
			}
		end
	end

	if self._assault_mode == "phalanx" then
		self:_update_assault_hud_color(Color(1, 1/255, 1/255))

		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_bo_shield",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock",
				"hud_assault_bo_shield",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock"
			}
		else
			return {
				"hud_assault_bo_shield",
				"hud_assault_padlock",
				"hud_assault_bo_shield",
				"hud_assault_padlock",
				"hud_assault_bo_shield",
				"hud_assault_padlock"
			}
		end
	end

	return assault_strings
end