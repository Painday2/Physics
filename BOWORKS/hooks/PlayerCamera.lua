Hooks:PostHook(PlayerCamera, "init", "BoworksReduceZFighting", function(self, unit)
	self._camera_object:set_near_range(7)
	-- Increase the vanilla near range as much as we can to help z-fighting.
end)