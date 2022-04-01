HUDBoworksCredits = HUDBoworksCredits or class()

function HUDBoworksCredits:init(hud)
	self._hud_panel = hud.panel

	if self._hud_panel:child("boworks_credits_panel") then
		self._hud_panel:remove(self._hud_panel:child("boworks_credits_panel"))
	end

	self._boworks_credit_panel = self._hud_panel:panel({
		name = "boworks_credits_panel",
		visible = false,
		valign = "top"
	})

	self._pre_credit_time = 6
	self._pre_credits = {
		"Richard Dick \"PAIN\" Richardson, age 36, gave himself up to the authorities after downloading Bo's NFTs. He is now serving a life sentence.",
		"Cocke heard what happened to Pain & decided to stay low & decided to spend all his money to crypto mining.",
		"Dial, the real human, died & his mind went inside a computer.",
		"Switch bought a new truck & crashed it from a DUI.",
		"Mrs. Claus' Assistant's got promoted & now is the husband of ex-Mrs. Claus.",
		"Santa became depressed after what had happened in the last few years & decided to end Christmas forever.",
		"Zdann huffed too much paint thinner, irreversibly increasing his IQ. He is now too smart to write for Pain heists.",
		"After the events of Garnet Group Tower, the gang social distanced, wore masks and gloves, and hand sanitized and the zombies got eradicated.",
		"Luke voiced Pain for over 30 years, Luke died peacefully from throat cancer. His death inspired no one.",
		"Capcake, after crashing for the 666th time making the next pain heist, went clinically insane. He has since been admitted to Dr. Bill Dorfman's care centre. "
	}

	self._current_pre_credit = 0
	self._next_pre_credit = Application:time()

	self._pre_credit_text = self._boworks_credit_panel:text({
		vertical = "top",
		word_wrap = true,
		wrap = true,
		width = self._boworks_credit_panel:width() * 3/4,
		x = 160,
		y = 160,
		font_size = 64,
		text = "Richard Dick \"PAIN\" Richardson, age 36, gave himself up to the authorities after downloading Bo's NFTs. He is now serving a life sentence.",
		layer = 40,
		font = "fonts/font_large_mf",
		color = Color.white,
		alpha = 0
	})
end

function HUDBoworksCredits:_animate_pre_credit(input_panel)
	local t = 0
	while t < self._pre_credit_time do
		local alpha = 1
		if t < 1 then
			alpha = t
		elseif t > (self._pre_credit_time - 1) then
			alpha = self._pre_credit_time - t
		end

		local dt = coroutine.yield()
		t = t + dt

		input_panel:set_alpha(alpha)
	end

	input_panel:set_alpha(0)
end


local fades = {
	to_grey = {
		blend_mode = "normal",
		sustain = 0,
		play_paused = true,
		fade_in = 1,
		fade_out = 0,
		sustain = 300,
		color = Color(0.3, 0.7, 0.7, 0.7),
		timer = TimerManager:main()
	},
	to_black = {
		blend_mode = "normal",
		sustain = 0,
		play_paused = true,
		fade_in = 2,
		fade_out = 0,
		sustain = 300,
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main()
	},
}

HUDBoworksCredits.PATH = "gamedata/"
HUDBoworksCredits.FILE_EXTENSION = "credits"

HUDBoworksCredits.font = "fonts/font_medium_mf"
HUDBoworksCredits.layers = {
	background = 50,
	items = 51
}

function HUDBoworksCredits:update(t, dt)
	if not self._open then return end

	if self._next_pre_credit and t > self._next_pre_credit then
		self._current_pre_credit = self._current_pre_credit + 1

		self._pre_credit_text:set_text(self._pre_credits[self._current_pre_credit])
		self._pre_credit_text:animate(callback(self, self, "_animate_pre_credit"))

		self._next_pre_credit = t + self._pre_credit_time

		if self._current_pre_credit == #self._pre_credits then
			self._next_start_credits = self._next_pre_credit
		end
	end

	if self._next_start_credits and t > self._next_start_credits then
		self._next_start_credits = nil
		self._start_actual_credits = t + 2.5
		managers.overlay_effect:play_effect(fades.to_black)
	end

	if self._start_actual_credits and t > self._start_actual_credits then
		self._start_actual_credits = nil

		MenuNodeCreditsGui._build_credits_panel(self, "boworks_credits")
	end
end

function HUDBoworksCredits:open()
	self._boworks_credit_panel:set_visible(true)

	self._open_time = Application:time()

	self._current_pre_credit = 0
	self._next_pre_credit = self._open_time + 2

	self._open = true

	if managers.player:local_player() and managers.player:local_player():camera() and managers.player:local_player():camera()._camera_unit then
		managers.player:local_player():camera()._camera_unit:set_extension_update_enabled(Idstring("base"), false) -- Stop janky camera rotation.
	end

	managers.overlay_effect:play_effect(fades.to_grey)
	managers.music:post_event("music_boworks_credits")

	TimerManager:game_animation():pause()
	TimerManager:timer(Idstring("player")):pause()
end

function HUDBoworksCredits:close()
	self._boworks_credit_panel:set_visible(false)

	self._open = false

	if managers.player:local_player() and managers.player:local_player():camera() and managers.player:local_player():camera()._camera_unit then
		managers.player:local_player():camera()._camera_unit:set_extension_update_enabled(Idstring("base"), true) -- Start camera rotation.
	end

	TimerManager:game_animation():play()
	TimerManager:timer(Idstring("player")):play()
end