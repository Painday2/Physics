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
		text = self._pre_credits[1],
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
		play_paused = false,
		fade_in = 1,
		fade_out = 1,
		sustain = 300,
		color = Color(0.3, 0.7, 0.7, 0.7),
		timer = TimerManager:main()
	},
	to_black = {
		blend_mode = "normal",
		sustain = 0,
		play_paused = false,
		fade_in = 2,
		fade_out = 2,
		sustain = 300,
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main()
	}
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
		self._black_effect = managers.overlay_effect:play_effect(fades.to_black)
	end

	if self._start_actual_credits and t > self._start_actual_credits then
		self._start_actual_credits = nil

		HUDBoworksCredits:_build_credits_panel("boworks_credits")
	end
end

function HUDBoworksCredits:_build_credits_panel(file)
	local lang_key = SystemInfo:language():key()
	local files = {
		[Idstring("german"):key()] = "_german",
		[Idstring("french"):key()] = "_french",
		[Idstring("spanish"):key()] = "_spanish",
		[Idstring("italian"):key()] = "_italian"
	}

	if Application:region() == Idstring("eu") and file == "eula" then
		files[Idstring("english"):key()] = "_uk"
	end

	if (file == "eula" or file == "trial") and files[lang_key] then
		file = file .. files[lang_key] or file
	end

	local list = PackageManager:script_data(MenuNodeCreditsGui.FILE_EXTENSION:id(), (MenuNodeCreditsGui.PATH .. file):id())
	local ypos = 0
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local res = RenderSettings.resolution
	local global_scale = 1
	local side_padding = 200
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._clipping_panel = self._fullscreen_ws:panel():panel({})
	local bg = self._clipping_panel:rect({
		visible = true,
		color = Color.black,
		layer = self.layers.background
	})

	bg:set_top(0)
	bg:set_left(0)
	bg:set_height(self._clipping_panel:height())
	bg:set_width(self._clipping_panel:width())

	local text_offset = self._clipping_panel:height() - 50
	self._credits_panel = self._clipping_panel:panel({
		x = safe_rect_pixels.x + side_padding,
		y = text_offset,
		w = safe_rect_pixels.width - side_padding * 2,
		h = self._fullscreen_ws:panel():h()
	})

	self._credits_panel:set_center_x(self._credits_panel:parent():w() / 2)

	local text_width = self._credits_panel:width()

	bg:set_width(text_width)
	bg:set_size(self._clipping_panel:size())
	self._clipping_panel:gradient({
		y = 0,
		visible = false,
		orientation = "vertical",
		x = 0,
		w = self._clipping_panel:width(),
		h = 75 * global_scale,
		layer = self.layers.items + 1,
		gradient_points = {
			0,
			Color(1, 0, 0, 0),
			1,
			Color(0, 0, 0, 0)
		}
	})
	self._clipping_panel:gradient({
		visible = false,
		orientation = "vertical",
		x = 0,
		y = self._clipping_panel:height() - 75 * global_scale,
		w = self._clipping_panel:width(),
		h = 75 * global_scale,
		layer = self.layers.items + 1,
		gradient_points = {
			0,
			Color(0, 0, 0, 0),
			1,
			Color(1, 0, 0, 0)
		}
	})

	local function animate_fade_in(o)
		over(1, function (p)
			o:set_alpha(p)
		end)
	end

	bg:animate(animate_fade_in)

	self._blur = self._fullscreen_ws:panel():bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h(),
		layer = self.layers.background - 1
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	local commands = {}

	for _, data in ipairs(list) do
		if data._meta == "text" then
			local height = 50
			local color = Color(1, 1, 0, 0)

			if data.type == "title" then
				height = 24
				color = Color(255, 0, 161, 255) / 255
			elseif data.type == "name" then
				height = 24
				color = Color(1, 0.9, 0.9, 0.9)
			elseif data.type == "fill" then
				height = 26
				color = Color(1, 1, 1, 1)
			elseif data.type == "song" then
				height = 24
				color = Color(1, 0.8, 0.8, 0.8)
			elseif data.type == "song-credit" then
				height = 24
				color = Color(1, 0.5, 0.5, 0.5)
			elseif data.type == "image-text" then
				height = 24
				color = Color(1, 0.5, 0.5, 0.5)
			elseif data.type == "eula" then
				height = 22
				color = Color(1, 0.7, 0.7, 0.7)
			end

			height = height * global_scale
			local text_field = self._credits_panel:text({
				vertical = "bottom",
				h = 0,
				wrap = true,
				align = "center",
				word_wrap = true,
				halign = "left",
				x = 0,
				text = data.text,
				y = ypos,
				w = text_width,
				font_size = height,
				font = self.font,
				color = color,
				layer = self.layers.items
			})
			local _, _, _, h = text_field:text_rect()

			text_field:set_height(h)

			ypos = ypos + h
		elseif data._meta == "image" then
			local scale = (data.scale or 1) * global_scale
			local bitmap = self._credits_panel:bitmap({
				x = 0,
				layer = self.layers.items,
				y = ypos,
				texture = data.src
			})

			print(res.x, bitmap:width() * scale)
			bitmap:set_width(bitmap:width() * scale)
			bitmap:set_height(bitmap:height() * scale)
			bitmap:set_center_x(self._credits_panel:width() / 2)

			ypos = ypos + bitmap:height()
		elseif data._meta == "br" then
			ypos = ypos + 28 * global_scale
		elseif data._meta == "command" then
			table.insert(commands, {
				pos = ypos - text_offset + (data.offset or 0) * global_scale + self._clipping_panel:height() / 2,
				cmd = data.cmd,
				param = data.param
			})
		end
	end

	self._credits_panel:set_height(ypos + 50)

	local function scroll_func(o)
		local y = o:top()
		local speed = 50 * global_scale

		while true do
			y = y - coroutine.yield() * speed

			o:set_top(math.round(y))

			if commands[1] and y < -commands[1].pos then
				local cmd = table.remove(commands, 1)

				if cmd.cmd == "speed" then
					speed = cmd.param * global_scale
				elseif cmd.cmd == "close" then
					managers.hud:close_boworks_credits()

					return
				elseif cmd.cmd == "stop" then
					return
				end
			end
		end
	end

	self._credits_panel_thread = self._credits_panel:animate(scroll_func)
end

function HUDBoworksCredits:open(close_clbk)
	if not self._open then
		self._boworks_credit_panel:set_visible(true)

		self._open_time = Application:time()

		self._current_pre_credit = 0
		self._next_pre_credit = self._open_time + 2

		self._open = true

		if managers.player:local_player() and managers.player:local_player():camera() and managers.player:local_player():camera()._camera_unit then
			managers.player:local_player():camera()._camera_unit:set_extension_update_enabled(Idstring("base"), false) -- Stop janky camera rotation.
		end

		self._grey_effect = managers.overlay_effect:play_effect(fades.to_grey)
		managers.music:post_event("music_boworks_credits")

		TimerManager:game_animation():pause()
		TimerManager:timer(Idstring("player")):pause()

		self._close_callback = close_clbk
	end
end

function HUDBoworksCredits:close()
	if self._open then
		if self._grey_effect then
			managers.overlay_effect:fade_out_effect(self._grey_effect)
		end
		if self._black_effect then
			managers.overlay_effect:fade_out_effect(self._black_effect)
		end
		managers.music:stop()

		self._boworks_credit_panel:set_visible(false)

		if self._credits_panel then
			self._credits_panel:set_visible(false)
			self._clipping_panel:set_visible(false)
			self._blur:set_visible(false)
		end

		self._open = false

		if managers.player:local_player() and managers.player:local_player():camera() and managers.player:local_player():camera()._camera_unit then
			managers.player:local_player():camera()._camera_unit:set_extension_update_enabled(Idstring("base"), true) -- Start camera rotation.
		end

		TimerManager:game_animation():play()
		TimerManager:timer(Idstring("player")):play()

		if self._close_callback then
			self._close_callback()
		end
	end
end