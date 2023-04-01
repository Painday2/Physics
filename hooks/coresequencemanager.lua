core:module("CoreSequenceManager")
core:import("CoreEngineAccess")
core:import("CoreLinkedStackMap")
core:import("CoreTable")
core:import("CoreUnit")
core:import("CoreClass")

function UnitElement:save_by_unit(unit, data)
	local state = {}
	local changed = false

	for name, _ in pairs(self._bodies) do --This is modified to check for nils
		changed = unit:body(name) and unit:body(name):extension() and unit:body(name):extension().damage:save(state) or changed
	end

	if changed then
		data.UnitElement = state
	end

	return changed
end