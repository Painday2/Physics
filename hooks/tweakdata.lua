Hooks:PostHook(TweakData, "init", "init_boworks", function(self, tweak_data)
	
	self.overlay_effects.fade_out_test = {
		text_to_upper = true,
		sustain = 30,
		blend_mode = "normal",
		fade_in = 3,
		text_blend_mode = "add",
		fade_out = 0,
		font = "fonts/font_large_mf",
		text = [[
Great job, gang!
You've reached the end of our E3 demo.
Play the full version soon to get your full PAYDAY!]],
		font_size = 44,
		play_paused = true,
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main(),
		text_color = Color(255, 255, 204, 0) / 255
	}
	
	
end)
