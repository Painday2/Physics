Hooks:PostHook(InteractionTweakData, "init", "interaction_init_boworks_flash_cannon", function(self, tweak_data)
	self.load_flashbang = {
		text_id = "hud_load_flashbang",
		action_text_id = "hud_action_loading_flashbang",
		timer = 2,
		start_active = false
	}
	self.turret_flash_cannon = {
		text_id = "hud_turret_flash_cannon",
		action_text_id = "hud_action_mounting_flash_cannon",
		start_active = false,
		timer = 0.5,
		interact_distance = 400,
		axis = "z"
	}
end)