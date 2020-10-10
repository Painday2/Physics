Hooks:PostHook(CharacterTweakData, "_init_escort_undercover", "boworks_silent_ford", function(self, presets)
	self.escort_undercover.escort_idle_talk = false
end)

Hooks:PostHook(CharacterTweakData, "_init_drug_lord_boss", "thechase_boss", function(self, presets)
		self.drug_lord_boss.HEALTH_INIT = 10000
		self.drug_lord_boss.headshot_dmg_mul = 12
		self.drug_lord_boss.weapon.mini = {}
		self.drug_lord_boss.weapon.mini.aim_delay = {
			0.1,
			0.2
		}
		self.drug_lord_boss.weapon.mini.focus_delay = 4
		self.drug_lord_boss.weapon.mini.focus_dis = 800
		self.drug_lord_boss.weapon.mini.spread = 20
		self.drug_lord_boss.weapon.mini.miss_dis = 40
		self.drug_lord_boss.weapon.mini.RELOAD_SPEED = 1
		self.drug_lord_boss.weapon.mini.melee_speed = 1
		self.drug_lord_boss.weapon.mini.melee_dmg = 1000
		self.drug_lord_boss.weapon.mini.melee_retry_delay = {
			0.5,
			1
		}
		self.drug_lord_boss.weapon.mini.range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		}
		self.drug_lord_boss.weapon.mini.autofire_rounds = {
			20,
			40
		}
		self.drug_lord_boss.weapon.mini.FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.1,
					0.15
				},
				recoil = {
					2,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					500,
					700
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.05,
					0.1
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					500,
					500
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.04,
					0.075
				},
				recoil = {
					1.2,
					1.5
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					300,
					500
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.025,
					0.05
				},
				recoil = {
					0.7,
					1
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					100,
					300
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.01,
					0.025
				},
				recoil = {
					0.5,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				},
				autofire_rounds = {
					40,
					100
				}
			}
		}
		self.drug_lord_boss.damage.hurt_severity = presets.hurt_severities.no_hurts
		self.drug_lord_boss.die_sound_event = "l1n_burndeath"
		
end)