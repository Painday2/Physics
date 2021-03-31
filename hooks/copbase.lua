local material_config_paths = {
	-- Base Units
	"units/pd2_mod_bofa/characters/shared_materials/ene_sbz",
	"units/pd2_mod_bofa/characters/shared_materials/ene_ovk",
	"units/pd2_mod_bofa/characters/shared_materials/ene_ovk_heavy",
	"units/pd2_mod_bofa/characters/shared_materials/ene_bofa",
	"units/pd2_mod_bofa/characters/shared_materials/ene_bofa_heavy",
	"units/pd2_mod_bofa/characters/shared_materials/ene_bofa_zeal",
	"units/pd2_mod_bofa/characters/shared_materials/ene_bofa_zeal_heavy",

	-- Misc
	"units/pd2_mod_bofa/characters/shared_materials/misc/ene_stockos_security",

	-- Specials
	"units/pd2_mod_bofa/characters/shared_materials/specials/ene_bofa_medic",
	"units/pd2_mod_bofa/characters/shared_materials/specials/ene_bofa_sniper",

	-- Heist Laddos
	"units/mainman/characters/ene_the_boss/ene_the_boss",
	"units/mainman/characters/ene_bo/ene_bo",
	"units/matthelzor/characters/ford/ford",
	"units/matthelzor/characters/ford_civ/ford_civ"
}

for i, material_config_path in pairs(material_config_paths) do
	local normal_ids = Idstring(material_config_path)
	local contour_ids = Idstring(material_config_path .. "_contour")

	CopBase._material_translation_map[tostring(normal_ids:key())] = contour_ids
	CopBase._material_translation_map[tostring(contour_ids:key())] = normal_ids 
end

function CopBase:_chk_spawn_gear()

    if self._tweak_table == "drug_lord_boss" then
    else
        local align_obj_name = Idstring("Head")
        local align_obj = self._unit:get_object(align_obj_name)
        self._headwear_unit = World:spawn_unit(Idstring("units/mainman/characters/ene_acc_vr/ene_acc_vr"), Vector3(), Rotation())

        self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
    end
end
end