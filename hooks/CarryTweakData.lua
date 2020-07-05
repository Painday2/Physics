Hooks:PostHook(CarryTweakData, "init", "init_boworks", function(self, tweak_data)
   self.forklift = {
		type = "heavy",
		name_id = "hud_carry_forklift",
		bag_value = "coke",
		unit = "units/pd2_mod_bowks/equipment/bowks_4klift",
		visual_unit_name = "units/pd2_mod_bowks/equipment/bowks_4klift_tps",
		AI_carry = {
			SO_category = "enemies"
		}
	}
	
end)