Hooks:PostHook(TimeSpeedEffectTweakData, "_init_mission_effects", "timespeed_init_boworks", function(self)
	self.mission_effects.bo_smash = {
		timer = "pausable",
		speed = 0.2,
		affect_timer = {
			"game",
			"game_animation",
			"player"
		},
		sync = true,
		fade_in_delay = 0,
		fade_in = 0,
		sustain = 2,
		fade_out = 0
	}
	self.mission_effects.bo_death = {
		timer = "pausable",
		speed = 0.001,
		affect_timer = {
			"game",
			"game_animation",
			"player"
		},
		sync = true,
		fade_in_delay = 0,
		fade_in = 2.5,
		sustain = 10,
		fade_out = 0.3
	}
end)