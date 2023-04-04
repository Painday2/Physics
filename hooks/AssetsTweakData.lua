Hooks:PostHook(AssetsTweakData, "init", "init_boworks_assets", function(self, tweak_data)
	--DAY 1--
	--Museum skip
	self.physics_citystreets_bypass = {
		name_id = "physics_citystreets_bypass_name",
		unlock_desc_id = "physics_citystreets_bypass_desc",
		texture = "guis/mods/phys/textures/pd2/mission_briefing/assets/d1_bypass",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 10),
		no_mystery = true
	}
	--Prerequisite for secret
	self.physics_citystreets_gammon = {
		name_id = "physics_citystreets_gammon_name",
		unlock_desc_id = "physics_citystreets_gammon_desc",
		texture = "guis/mods/phys/textures/pd2/mission_briefing/assets/d1_gammon",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 10),
		no_mystery = true
	}

	--DAY 2--
	--Reduced Spawn Guards
	self.physics_tower_reduced_security = {
		name_id = "physics_tower_reduced_security_name",
		unlock_desc_id = "physics_tower_reduced_security_desc",
		texture = "guis/mods/phys/textures/pd2/mission_briefing/assets/d2_reduced_security",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 10),
		no_mystery = true
	}

	--DAY 3--
	--Friendly sniper
	self.physics_core_sniper = {
		name_id = "menu_asset_sniper",
		unlock_desc_id = "menu_asset_sniper_desc",
		texture = "guis/mods/phys/textures/pd2/mission_briefing/assets/d3_sniper",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 6),
		no_mystery = true
	}
	--Friendly minigun dozer
	self.physics_core_dozer = {
		name_id = "physics_core_dozer_name",
		unlock_desc_id = "physics_core_dozer_desc",
		texture = "guis/mods/phys/textures/pd2/mission_briefing/assets/d3_dozer",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 10),
		no_mystery = true
	}
	--Friendly bonco cop
	self.physics_core_bronco = {
		name_id = "physics_core_bronco_name",
		unlock_desc_id = "physics_core_bronco_desc",
		texture = "guis/mods/phys/textures/pd2/mission_briefing/assets/d3_bronco",
		money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_medium", 6),
		no_mystery = true
	}
end)