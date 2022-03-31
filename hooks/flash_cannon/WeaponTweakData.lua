Hooks:PostHook(WeaponTweakData, "init", "weapon_init_boworks_flash_cannon", function(self, tweak_data)
	self.turret_flak_88 = {
		name = "turret_flak_88",
		dazed_duration = 0.5,
		shaker_multiplier = 0.5,
		dismember_chance = 1,
		rate_of_fire = 60,
		exit_turret_speed = 1,
		camera_limit_horizontal = 55,
		camera_limit_vertical = 30,
		camera_limit_vertical_mid = 20,
		fire_range = 60000,
		damage = 8000,
		damage_radius = 2000,
		sound_fire_start = "flak88_fire",
		fire_type = "auto",
		number_of_barrels = 1,
		anim_enter = "e_so_flak_88_sit_enter",
		anim_exit = "e_so_flak_88_sit_exit",
		puppet_stance = "sitting",
		abandon_proximity = 500,
		puppet_damage_multiplier = 1,
		bullet_type = "shell",
		armor_piercing = true,
		use_dof = true,
		shell_ejection_effect = nil,
		muzzle_effect = "effects/phys/explosions/flash_cannon_muzzle",
		turret_rotation_deadzone = 30,
		turret_rotation_speed = 30,
		sound_movement_start = "aa_gun_movement_loop_start",
		sound_movement_stop = "aa_gun_movement_loop_stop",
		usable_by_npc = false,
		can_shoot_at_AI = false,
		hud = {}
	}
	self.turret_flak_88.hud.reticle = "weapons_reticles_smg_thompson"
	self.turret_flak_88.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 10,
		alert_size = 7,
		spread = 3,
		spread_moving = 7,
		recoil = 7,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 20
	}
	self.turret_flak_88.FIRE_RANGE = 100000
	self.turret_flak_88.MAX_PITCH_ANGLE = 70
	self.turret_flak_88.MIN_PITCH_ANGLE = -14
end)