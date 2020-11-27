local jukebox_default_tracks = MusicManager.jukebox_default_tracks
function MusicManager:jukebox_default_tracks()
    local trax = jukebox_default_tracks(self)
    
    trax.heist_physics_citystreets = "music_pain3_cbt"
    trax.heist_physics_tower = "music_pain3_sex"
    trax.heist_physics_core = "music_pain3_cum"
    
    return trax
end