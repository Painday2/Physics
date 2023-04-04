function GuiTweakData:_setup_raid_colors()
	self.colors = {}
	self.colors.progress_yellow = Color("dd9a38")
	self.colors.turret_overheat = Color("b8392e")
	self.colors.turret_heat_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_yellow
		}
	}
end

function GuiTweakData:_setup_raid_hud_icons()
	self.icons.aa_gun_bg = {
		texture = "ui/atlas/phys_atlas_hud",
		texture_rect = {
			387,
			1355,
			384,
			54
		}
	}
	self.icons.aa_gun_flak = {
		texture = "ui/atlas/phys_atlas_hud",
		texture_rect = {
			731,
			1281,
			154,
			28
		}
	}
end

function GuiTweakData:_setup_raid_hud_reticles()
	self.icons.weapons_reticles_smg_thompson = {
		texture = "ui/hud/atlas/phys_atlas_reticles",
		texture_rect = {
			157,
			235,
			76,
			76
		}
	}
end

Hooks:PostHook(GuiTweakData, "init", "gui_init_boworks_flash_cannon", function(self)
	self:_setup_raid_colors()

	self.icons = {}
	self:_setup_raid_hud_icons()
	self:_setup_raid_hud_reticles()
end)