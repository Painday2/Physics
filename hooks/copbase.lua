local material_config_paths = {
  "units/mainman/characters/ene_the_boss/ene_the_boss",
  "units/mainman/characters/ene_bo/ene_bo",
  "units/matthelzor/characters/ford/ford",
  "units/matthelzor/characters/ford_civ/ford_civ",
  "units/pd2_mod_bofa/characters/sbz_units/ene_sbz_mp5/ene_sbz_mp5",
  "units/pd2_mod_bofa/characters/sbz_units/ene_sbz_r870/ene_sbz_r870",
  "units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_m4/ene_sbz_heavy_m4",
  "units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_r870/ene_sbz_heavy_r870",
  "units/pd2_mod_bofa/characters/sbz_units/ene_sbz_shield_c45/ene_sbz_shield_c45",
  "units/pd2_mod_bofa/characters/sbz_units/ene_sbz_shield_mp9/ene_sbz_shield_mp9",
  "units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4",
  "units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870",
  "units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_r870/ene_ovk_heavy_r870",
  "units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4",
  "units/pd2_mod_bofa/characters/ovk_units/ene_ovk_shield_c45/ene_ovk_shield_c45",
  "units/pd2_mod_bofa/characters/ovk_units/ene_ovk_shield_mp9/ene_ovk_shield_mp9",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_r870/ene_bofa_r870",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_r870/ene_bofa_heavy_r870",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_c45/ene_bofa_shield_c45",
  "units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_mp9/ene_bofa_shield_mp9"
}


for i, material_config_path in pairs(material_config_paths) do
  local normal_ids = Idstring(material_config_path)
  local contour_ids = Idstring(material_config_path .. "_contour")

  CopBase._material_translation_map[tostring(normal_ids:key())] = contour_ids
  CopBase._material_translation_map[tostring(contour_ids:key())] = normal_ids 
end