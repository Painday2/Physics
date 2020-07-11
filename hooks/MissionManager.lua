function MissionManager:set_fading_debug_enabled(enabled)
	self._fading_debug_output:show()
end

function MissionManager:add_fading_debug_output(debug, color, as_subtitle)
	if as_subtitle then
		self:_show_debug_subtitle(debug, color)
	else
		local stuff = {
			" -",
			" \\",
			" |",
			" /"
		}
		self._fade_index = (self._fade_index or 0) + 1
		self._fade_index = self._fade_index > #stuff and self._fade_index and 1 or self._fade_index

		self._fading_debug_output:script().log(stuff[self._fade_index] .. " " .. debug, color, nil)
	end
end