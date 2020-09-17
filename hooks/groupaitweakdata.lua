local enable_debug_prints = true
-------------------------------------------------------------------------------
-- Faction adding code. Don't touch this unless you know what your doing. :) --
-------------------------------------------------------------------------------
local function debug_log(...)
	if enable_debug_prints then
		log(...)
	end
end

local function string_list_to_idstring_list(list)
	local output = {}
	for key, value in pairs(list) do
		output[key] = Idstring(value)
	end
	return output
end

local function add_faction(faction_name, chatter, prefixes, groups, difficulty_specific)
	debug_log("[Faction Adder] Adding Faction: " .. faction_name)
	LevelsTweakData.LevelType[faction_name] = faction_name
	-- BeardLib cares about this. Even though they're all just glorified paths to strings. :sader:
	Hooks:PostHook(LevelsTweakData, "init", "unique_special_level_group_hook_" .. faction_name, function(self)
		self.ai_groups[faction_name] = faction_name
	end)

	-- Setup unit category hook.
	Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "unique_special_faction_hook_" .. faction_name, function(groupai_td, difficulty_index)
		-- Get difficulty specific unit lists.
		local difficulty_specific_groups = difficulty_specific[difficulty_index]
		if difficulty_specific_groups then
			debug_log("[Faction Adder] Found Difficulty Specific: " .. tostring(difficulty_index))
			for category_name, unit_list in pairs(difficulty_specific_groups) do
				groups[category_name] = unit_list
			end
		end

		-- Add our faction group variants.
		for category_name, category_data in pairs(groupai_td.unit_categories) do
			local unit_list = groups[category_name]

			if unit_list then
				debug_log("[Faction Adder] Custom Group: " .. category_name)
				category_data.unit_types[faction_name] = string_list_to_idstring_list(unit_list)
			elseif category_data.unit_types.america then
				debug_log("[Faction Adder] No Custom Group: " .. category_name)
				category_data.unit_types[faction_name] = category_data.unit_types.america
			end
		end
	end)

	-- Setup the function used to set prefixes and chatter.
	CharacterTweakData["_init_region_" .. faction_name] = function(self)
		self:_init_region_america()

		self._default_chatter = chatter or self._default_chatter
		for key, value in pairs(prefixes) do
			self._unit_prefixes[key] = value
		end
	end
end

--------------------------
-- Faction Setup Stuff --
--------------------------

-- Define the factions internal name.
local faction_name = "bo"

-- Define voice data.
local chatter = "dispatch_generic_message"
local prefixes = {
	cop = "l",
	swat = "l",
	heavy_swat = "l",
	taser = "tsr",
	cloaker = "clk",
	bulldozer = "bdz",
	medic = "mdc"
}

-- Define generic units.
-- If your really cool you can add groups from rebalances here as well and it'll handle that.
-- If you don't specify a group it'll just default to a copy of `america` so that shit doesn't explode.
local groups = {
	spooc = {
		"units/payday2/characters/ene_spook_1/ene_spook_1"
	},
	CS_cop_C45_R870 = {
		"units/payday2/characters/ene_cop_1/ene_cop_1",
		"units/payday2/characters/ene_cop_3/ene_cop_3",
		"units/payday2/characters/ene_cop_4/ene_cop_4"
	},
	CS_cop_stealth_MP5 = {
		"units/payday2/characters/ene_cop_2/ene_cop_2"
	},
	CS_swat_MP5 = {
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_mp5/ene_sbz_mp5"
	},
	CS_swat_R870 = {
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_r870/ene_sbz_r870"
	},
	CS_heavy_M4 = {
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_m4/ene_sbz_heavy_m4"
	},
	CS_heavy_R870  = {
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_r870/ene_sbz_heavy_r870"
	},
	CS_heavy_M4_w = {
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_m4/ene_sbz_heavy_m4"
	},
	CS_tazer = {
		"units/payday2/characters/ene_tazer_1/ene_tazer_1"
	},
	CS_shield = {
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_shield_c45/ene_sbz_shield_c45",
		"units/pd2_mod_bofa/characters/sbz_units/ene_sbz_shield_mp9/ene_sbz_shield_mp9"
	},
	FBI_suit_C45_M4 = {
		"units/payday2/characters/ene_fbi_1/ene_fbi_1",
		"units/payday2/characters/ene_fbi_2/ene_fbi_2"
	},
	FBI_suit_M4_MP5 = {
		"units/payday2/characters/ene_fbi_2/ene_fbi_2",
		"units/payday2/characters/ene_fbi_3/ene_fbi_3"
	},
	FBI_suit_stealth_MP5 = {
		"units/payday2/characters/ene_fbi_3/ene_fbi_3"
	},
	FBI_swat_M4 = {
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"
	},
	FBI_swat_R870 = {
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870"
	},
	FBI_heavy_G36 = {
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4"
	},
	FBI_heavy_R870  = {
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_r870/ene_ovk_heavy_r870"
	},
	FBI_heavy_G36_w = {
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4"
	},
	FBI_shield = {
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_shield_c45/ene_ovk_shield_c45",
		"units/pd2_mod_bofa/characters/ovk_units/ene_ovk_shield_mp9/ene_ovk_shield_mp9"
	},
	FBI_tank = {
		"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"
	},
	medic_M4 = {
		"units/payday2/characters/ene_medic_m4/ene_medic_m4"
	},
	medic_R870 = {
		"units/payday2/characters/ene_medic_r870/ene_medic_r870"
	},
	Phalanx_minion = {
		"units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1"
	},
	Phalanx_vip = {
		"units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1"
	}
}

-- Define difficulty specific units.
local difficulty_specific = {}

-- Overkill --
difficulty_specific[5] = {
	FBI_tank = {
		"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
		"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"
	}
}

-- Mayhem --
difficulty_specific[6] = {
	FBI_swat_M4 = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump"
	},
	FBI_swat_R870 = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_r870/ene_bofa_r870"
	},
	FBI_heavy_G36 = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36"
	},
	FBI_heavy_R870  = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_r870/ene_bofa_heavy_r870"
	},
	FBI_shield = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_c45/ene_bofa_shield_c45",
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_mp9/ene_bofa_shield_mp9"
	},
	FBI_tank = {
		"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
		"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"
	}
}

-- Death Wish --
difficulty_specific[7] = {
	FBI_swat_M4 = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump",
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"
	},
	FBI_swat_R870 = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_r870/ene_bofa_r870"
	},
	FBI_heavy_G36 = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36"
	},
	FBI_heavy_R870  = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_r870/ene_bofa_heavy_r870"
	},
	FBI_shield = {
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_c45/ene_bofa_shield_c45",
		"units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_mp9/ene_bofa_shield_mp9"
	},
	FBI_tank = {
		"units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1",
		"units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2",
		"units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3",
		"units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"
	}
}

-- Death Sentence --
difficulty_specific[8] = {
	spooc = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker"
	},
	CS_swat_MP5 = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"
	},
	CS_swat_R870 = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"
	},
	CS_heavy_M4 = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	CS_heavy_R870  = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	CS_heavy_M4_w = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	CS_tazer = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer"
	},
	CS_shield = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"
	},
	FBI_swat_M4 = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"
	},
	FBI_swat_R870 = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"
	},
	FBI_heavy_G36 = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	FBI_heavy_R870  = {
		"units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"
	},
	FBI_heavy_G36_w = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"
	},
	FBI_shield = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"
	},
	FBI_tank = {
		"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer",
		"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2",
		"units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3",
		"units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic",
		"units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"
	}
}

-- Add the faction.
add_faction(faction_name, chatter, prefixes, groups, difficulty_specific)