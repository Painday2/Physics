HUDBossHealth = HUDBossHealth or class()

function HUDBossHealth:init(hud)
	self._hud_panel = hud.panel

	if self._hud_panel:child("boss_health_panel") then
		self._hud_panel:remove(self._hud_panel:child("boss_health_panel"))
	end

	local width = 500
	local height = 45
	local margin = 20

	self._boss_health_panel = self._hud_panel:panel({
		x = (self._hud_panel:w() / 2) - width/2,
		y = 40,
		name = "boss_health_panel",
		h = height,
		w = width,
		visible = false,
		valign = "top"
	})

	self._boss_text = self._boss_health_panel:text({
		vertical = "top",
		word_wrap = false,
		wrap = false,
		y = margin/2,
		h = height - margin,
		font_size = height - margin,
		align = "center",
		text = "GIANT BO",
		layer = 2,
		font = tweak_data.hud.medium_font_noshadow,
		color = Color.white
	})

	self._health_bg = self._boss_health_panel:rect({
		x = (self._boss_health_panel:w() / 2) - (width - margin)/2,
		y = margin/2,
		w = width - margin,
		h = height - margin,
		color = Color.black,
		alpha = 0.25
	})

	self._health_bar = self._boss_health_panel:rect({
		x = (self._boss_health_panel:w() / 2) - (width - margin)/2,
		y = margin/2,
		w = self._health_bg:w(),
		h = height - margin,
		color = Color.red,
		alpha = 0.5,
		layer = 1
	})

	self._bg_box = HUDBGBox_create(self._boss_health_panel)
end

function HUDBossHealth:_animate_show_component(input_panel, target_alpha, done_cb)
	local TOTAL_T = 0.25
	local t = 0

	while t < TOTAL_T do
		local dt = coroutine.yield()
		t = t + dt

		input_panel:set_alpha((t / TOTAL_T) * target_alpha)
	end

	input_panel:set_alpha(target_alpha)
	if done_cb then done_cb() end
end

function HUDBossHealth:_animate_hide_component(input_panel, start_alpha, done_cb)
	local TOTAL_T = 0.25
	local t = 0

	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt

		input_panel:set_alpha(start_alpha - ((t / TOTAL_T) * start_alpha))
	end

	input_panel:set_alpha(0)
	if done_cb then done_cb() end
end

function HUDBossHealth:set_name(name)
	self._boss_text:set_text(name)
end

function HUDBossHealth:set_health(health)
	self._health_bar:set_width(self._health_bg:w() * health)
end

function HUDBossHealth:_animate_change_color(input_panel, start_color, end_color)
	local TOTAL_T = 0.25
	local t = 0

	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt

		input_panel:set_color(math.lerp(start_color, end_color, t/TOTAL_T))
	end

	input_panel:set_color(end_color)
end

function HUDBossHealth:set_shielded(state)
	if state then
		self._health_bar:animate(callback(self, self, "_animate_change_color"), Color.red, Color(0.2, 0, 0))
	else
		self._health_bar:animate(callback(self, self, "_animate_change_color"), Color(0.2, 0, 0), Color.red)
	end
end

function HUDBossHealth:open()
	self._boss_text:set_alpha(0)
	self._health_bg:set_alpha(0)
	self._health_bar:set_alpha(0)

	local function open_done()
		self._boss_health_panel:set_visible(true)

		self._boss_text:animate(callback(self, self, "_animate_show_component"), 1)
		self._health_bg:animate(callback(self, self, "_animate_show_component"), 0.25)
		self._health_bar:animate(callback(self, self, "_animate_show_component"), 0.5)
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_center"), nil, self._bg_box:w(), open_done)
end

function HUDBossHealth:close()
	self._boss_text:set_alpha(1)
	self._health_bg:set_alpha(0.25)
	self._health_bar:set_alpha(0.5)

	local function fade_done()
		local function close_done()
			self._boss_health_panel:set_visible(false)
		end

		self._bg_box:stop()
		self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_center"), close_done)
	end

	self._boss_text:animate(callback(self, self, "_animate_hide_component"), 1, fade_done)
	self._health_bg:animate(callback(self, self, "_animate_hide_component"), 0.25)
	self._health_bar:animate(callback(self, self, "_animate_hide_component"), 0.5)
end