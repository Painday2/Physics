function UnitDamage:parent_run_sequence(sequence_name)
	if not sequence_name then
		return
	end

	if not self._unit:parent() then
		return
	end

	local parent_unit = self._unit:parent()

	if parent_unit:damage():has_sequence(sequence_name) then
		parent_unit:damage():run_sequence_simple(sequence_name)
	end
end