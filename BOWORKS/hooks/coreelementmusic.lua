--Special Thanks to Kythyria Zapdos for this block of code--
ElementMusic.on_executed = function(instigator)
    if not self._values.enabled then
        return
    end

    if not self._values.use_instigator or instigator == managers.player:player_unit() then
        if self._values.music_event then
            local ev = self.values.music_event
            if ev:sub(1,1) == "$" then
                ev = tweak_data.levels:get_music_event(ev:sub(2,-1))
            end
            managers.music:post_event(ev)
        elseif Application:editor() then
            managers.editor:output_error("Cant play music event nil [" .. self._editor_name .. "]")
        end
    end

    ElementMusic.super.on_executed(self, instigator)
end