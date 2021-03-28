local material_config_paths = {
  "units/mainman/characters/ene_the_boss/ene_the_boss",
  "units/mainman/characters/ene_bo/ene_bo",
  "units/matthelzor/characters/ford/ford",
  "units/matthelzor/characters/ford_civ/ford_civ",
  "units/pd2_mod_bofa/characters/shared_materials/ene_bofa",
  "units/pd2_mod_bofa/characters/shared_materials/ene_bofa_heavy",
  "units/pd2_mod_bofa/characters/shared_materials/ene_ovk",
  "units/pd2_mod_bofa/characters/shared_materials/ene_ovk_heavy",
  "units/pd2_mod_bofa/characters/shared_materials/ene_sbz"
}


for i, material_config_path in pairs(material_config_paths) do
  local normal_ids = Idstring(material_config_path)
  local contour_ids = Idstring(material_config_path .. "_contour")

  CopBase._material_translation_map[tostring(normal_ids:key())] = contour_ids
  CopBase._material_translation_map[tostring(contour_ids:key())] = normal_ids 
end