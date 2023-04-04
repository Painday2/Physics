GiantBoStateSearch = GiantBoStateSearch or class(GiantBoState)
GiantBoStateSearch._zones = 8

function GiantBoStateSearch:update(t, dt)
	local zone_angle_size = 360 / self._zones
	local zone_ratings = {}

	for i = 1, self._zones do
		zone_ratings[i] = 0
	end

	local criminals = managers.groupai:state():all_player_criminals()
	for _, data in pairs(criminals) do
		local position = data.unit:position()
		local direction = position - self._base:state_data().origin
		mvector3.set_z(direction, 0)
		mvector3.normalize(direction)

		for i = 1, self._zones do
			local forward = Rotation(zone_angle_size * (i - 1), 0, 0):y()
			zone_ratings[i] = zone_ratings[i] + mvector3.dot(forward, direction)
		end
	end

	local best_zone_id = 0
	local best_zone_rating = -10
	for i = 1, self._zones do
		if zone_ratings[i] > best_zone_rating then
			best_zone_id = i
			best_zone_rating = zone_ratings[i]
		end
	end

	local new_angle = zone_angle_size * (best_zone_id - 1)
	local old_angle = self._base:state_data().current_angle

	local delta = new_angle - old_angle

	-- Some crappy wrapping so Bo doesn't do a complete 270 turn to go round a corner.
	if delta > 180 then
		new_angle = new_angle - 360
	elseif delta < -180 then
		new_angle = new_angle + 360
	end

	if new_angle == old_angle then
		self._base:set_state("attack")
	else
		self._base:state_data().target_angle = new_angle
		self._base:set_state("move")
	end
end