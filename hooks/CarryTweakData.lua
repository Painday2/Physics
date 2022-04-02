Hooks:PostHook(CarryTweakData, "init", "init_boworks", function(self, tweak_data)
	self.forklift = {
		type = "mega_heavy",
		name_id = "hud_carry_forklift",
		skip_exit_secure = true,
		unit = "units/pd2_mod_phys/equipment/phys_4klift",
		visual_unit_name = "units/pd2_mod_phys/equipment/phys_4klift_tps",
	}
	
	self.meth_lab = {
		type = "heavy",
		name_id = "hud_carry_meth_lab",
		skip_exit_secure = true,
		unit = "units/payday2/pickups/gen_pku_toolbag/gen_pku_toolbag",
		visual_unit_name = "units/payday2/characters/npc_acc_tools_bag_1/npc_acc_tools_bag_1"
	}

	self.guilt = {
		type = "very_heavy",
		name_id = "hud_carry_guilt",
		unit = "units/payday2/pickups/gen_pku_bodybag/gen_pku_bodybag",
		visual_unit_name = "units/payday2/characters/npc_acc_body_bag_1/npc_acc_body_bag_1",
		default_value = 1,
		is_unique_loot = true,
		skip_exit_secure = true
	}

	self.stocks = {
		type = "medium",
		name_id = "hud_carry_stocks",
		visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1",
	}
	
	self.physics_key_rpn = {
		type = "medium",
		name_id = "hud_carry_key_rpn",
		visual_unit_name = "units/pd2_mod_phys/equipment/phys_key_blue/phys_key_red",
	}
	
	self.physics_key_sf = {
		type = "medium",
		name_id = "hud_carry_key_sf",
		visual_unit_name = "units/pd2_mod_phys/equipment/phys_key_blue/phys_key_blue",
	}
	
	self.physics_key_tlhs = {
		type = "medium",
		name_id = "hud_carry_key_tlhs",
		visual_unit_name = "units/pd2_mod_phys/equipment/phys_key_blue/phys_key_green",
	}

	self.physics_flashbang = {
		type = "medium",
		name_id = "hud_carry_phys_flashbang",
		unit = "units/pd2_mod_phys/equipment/phys_flashbang/phys_flashbang",
		visual_unit_name = "units/pd2_mod_phys/equipment/phys_flashbang/phys_flashbang_tps",
	}

end)