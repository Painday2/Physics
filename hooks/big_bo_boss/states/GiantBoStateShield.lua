GiantBoStateShield = GiantBoStateShield or class(GiantBoState)

function GiantBoStateShield:enter(t)
	self._start_shield_t = t + self._base:do_action("shield_enter")
end

function GiantBoStateShield:update(t, dt)
	if self._start_shield_t and t > self._start_shield_t then
		self._base:do_action("reset_shield_generator_health")
		self._base:do_action("set_health_shielded")

		self._start_shield_t = nil

		local mgais = managers.groupai:state()

		mgais:set_difficulty(1)
		mgais:set_wave_mode("besiege")

		self._needs_endless = true
	end

	if self._needs_endless then
		local mgais = managers.groupai:state()
		local assault_task = mgais._task_data.assault
		if assault_task and assault_task.phase and assault_task.phase ~= "anticipation" then
			managers.groupai:state():set_assault_endless(true)

			self._needs_endless = nil
		end
	end
end

function GiantBoStateShield:exit(t)
	self._base:do_action("shield_exit")
	self._base:do_action("set_health_unshielded")

	local mgais = managers.groupai:state()

	mgais:set_difficulty(0)
	mgais:force_end_assault_phase(true)
	mgais:set_assault_endless(true)
	mgais._hunt_mode = false

	local function check_phase()
		local mgais = managers.groupai:state()
		local assault_task = mgais._task_data.assault
		local regroup_task = mgais._task_data.regroup

		if assault_task and not assault_task.phase and regroup_task and regroup_task.end_t and Application:time() > regroup_task.end_t then
			managers.enemy:add_delayed_clbk("BoShieldStateExit", function()
				mgais:set_wave_mode("quiet")
				mgais:set_assault_mode(true)
			end, Application:time() + 2)

			return
		end

		managers.enemy:add_delayed_clbk("BoShieldStateExit", check_phase, Application:time() + 0.2)
	end

	check_phase()
end