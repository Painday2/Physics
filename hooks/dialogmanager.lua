Hooks:Add("LocalizationManagerPostInit", "SpainLocalization", function(loc)
	if Global.game_settings.level_id == "physics_citystreets" or Global.game_settings.level_id == "physics_tower" or Global.game_settings.level_id == "physics_core"  then
		LocalizationManager:add_localized_strings({
		["menu_description_locke"] = "Cocke's Plan"
		})
	else
		return
	end
end)