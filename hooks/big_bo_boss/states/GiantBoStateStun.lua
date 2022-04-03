GiantBoStateStun = GiantBoStateStun or class(GiantBoState)

function GiantBoStateStun:enter(t)
	local stun_time = self._base:do_action("stun")

	self._head = self._unit:get_object(Idstring("Head"))

	self._loot_left = true
	self._loot_to_drop = {
		{
			type = "loot_bag",
			id = "physics_flashbang",
			velocity = 3,
			amount = GiantBoBase.shield_generator_count
		},
		{
			type = "throwable",
			id = "ammo_projectile",
			velocity = 2,
			amount = 30
		}
	}

	self._stun_exit_t = t + stun_time
	self._next_throw_t = t + 0.1
end

function GiantBoStateStun:update(t, dt)
	if t > self._stun_exit_t then
		self._base:set_state("shield")
	elseif self._loot_left and t > self._next_throw_t then
		self:launch_loot()

		self._next_throw_t = t + 0.05
	end
end

function GiantBoStateStun:launch_loot()
	local dropped_loot = false

	for _, item in pairs(self._loot_to_drop) do
		if item.amount and item.amount > 0 then
			item.amount = item.amount - 1

			local position = self._head:position() + Vector3(0, 0, 1000)
			local rotation = self._head:rotation()
			local direction = Rotation(math.random(1, 360), 0, 0):y() * (item.velocity or 1)

			if item.type == "loot_bag" and item.id then
				managers.player:server_drop_carry(item.id, 1, true, false, 1, position, rotation, direction, 0, nil, nil)
			elseif item.type == "throwable" and item.id then
				ProjectileBase.throw_projectile_npc(item.id, position, direction)
			end

			dropped_loot = true
		end
	end

	if not dropped_loot then
		self._loot_left = false
	end 
end