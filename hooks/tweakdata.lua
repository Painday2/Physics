Hooks:PostHook(TweakData, "init", "init_boworks", function(self, tweak_data)
	self.overlay_effects.fade_out_mex = {
		text_to_upper = true,
		sustain = 1,
		localize = true,
		fade_in = 1,
		text_blend_mode = "add",
		fade_out = 1,
		font = "fonts/font_large_mf",
		text = "heist_physics_transition",
		font_size = 44,
		blend_mode = "normal",
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main(),
		text_color = Color(255, 255, 153, 0) / 255
	}
	self.overlay_effects.fade_out_boworks = {
		text_to_upper = true,
		sustain = 1,
		localize = true,
		fade_in = 1,
		text_blend_mode = "add",
		fade_out = 1,
		font = "fonts/font_large_mf",
		text = "heist_physics_transition",
		font_size = 66,
		blend_mode = "normal",
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main(),
		text_color = Color(255, 255, 153, 0) / 255
	}
end)
