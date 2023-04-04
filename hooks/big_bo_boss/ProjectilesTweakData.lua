Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "projectiles_init_boworks", function(self)
	self.projectiles.ammo_projectile = {
		name_id = "bm_ammo_projectile",
		unit = "units/pd2_mod_phys/projectiles/ammo_projectile/ammo_projectile",
		no_cheat_count = true
	}
end)