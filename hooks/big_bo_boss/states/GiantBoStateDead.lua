GiantBoStateDead = GiantBoStateDead or class(GiantBoState)

function GiantBoStateDead:enter(t)
	self._base:do_action("death")
	self._base:do_action("hide_health")

	self._base:do_action("invincible_players")

	self._credits_t = t + 0.5

	for c_key, c_data in pairs(managers.enemy:all_enemies()) do
		c_data.unit:character_damage():damage_explosion({
			damage = 9999999999999999999,
			variant = "stun",
			col_ray = {
				position = c_data.unit:position(),
				ray = math.UP
			}
		})
	end

	managers.groupai:state():terminate_assaults()
	managers.hud:end_assault()
end

function GiantBoStateDead:update(t)
	if self._credits_t and t > self._credits_t then
		self._credits_t = nil
		self._base:do_action("start_credits")
	end
end