GiantBoStateAttack = GiantBoStateAttack or class(GiantBoState)
GiantBoStateAttack._attack_cone = 45
GiantBoStateAttack._attack_distances = {
	4300, 6000, 10000
}
GiantBoStateAttack._attack_map = {
	{"breath_fire"},
	{"throw_smoke", "throw_molotov"},
	{"shoot_grenades"}
}

function GiantBoStateAttack:enter(t)
	local forward = Rotation(self._base:state_data().current_angle, 0, 0):y()
	local limit = math.cos(self._attack_cone/2)

	local distances = {}

	local criminals = managers.groupai:state():all_player_criminals()
	for _, data in pairs(criminals) do
		local position = data.unit:position()
		local direction = position - self._base:state_data().origin
		mvector3.set_z(direction, 0)
		mvector3.normalize(direction)

		if mvector3.dot(forward, direction) > limit then
			table.insert(distances, mvector3.distance(position, self._base:state_data().origin))
		end
	end

	local distance = 0
	if #distances > 0 then
		distance = table.random(distances)
	end

	local distance_index = #self._attack_distances
	for index, max_distance in pairs(self._attack_distances) do
		if distance < max_distance then
			distance_index = index
			break
		end
	end

	-- Not same attack twice if there's more than one
	if #self._attack_map[distance_index] > 1 then
		while self._current_attack == self._last_attack do
			self._current_attack = table.random(self._attack_map[distance_index])
		end
	else
		self._current_attack = self._attack_map[distance_index][1]
	end

	self._last_attack = self._current_attack

	if self._current_attack then
		self._exit_attack_t = t + self._base:do_action(self._current_attack)
	else
		self._exit_attack_t = t
	end
end

function GiantBoStateAttack:update(t)
	if t > self._exit_attack_t then
		self._base:set_state("idle")
	end
end