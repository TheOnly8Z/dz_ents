sound.Add({
    name = "DZ_Ents.Suit.CT",
    pitch = {90, 100},
    volume = {0.05, 0.1},
    level = 70,
    sound = {
        "dz_ents/footsteps/suit_ct_03.wav",
        "dz_ents/footsteps/suit_ct_06.wav",
        "dz_ents/footsteps/suit_ct_07.wav",
        "dz_ents/footsteps/suit_ct_08.wav",
        "dz_ents/footsteps/suit_ct_11.wav",
    },
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.Suit.T",
    pitch = 100,
    volume = {0.05, 0.1},
    level = 70,
    sound = {
        "dz_ents/footsteps/suit_t_01.wav",
        "dz_ents/footsteps/suit_t_02.wav",
        "dz_ents/footsteps/suit_t_03.wav",
        "dz_ents/footsteps/suit_t_04.wav",
        "dz_ents/footsteps/suit_t_05.wav",
        "dz_ents/footsteps/suit_t_06.wav",
        "dz_ents/footsteps/suit_t_07.wav",
        "dz_ents/footsteps/suit_t_08.wav",
        "dz_ents/footsteps/suit_t_09.wav",
        "dz_ents/footsteps/suit_t_10.wav",
        "dz_ents/footsteps/suit_t_11.wav",
        "dz_ents/footsteps/suit_t_12.wav",
    },
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.Suit.Heavy",
    pitch = {99, 101},
    volume = {0.7, 0.9},
    level = 75,
    sound = {
        "dz_ents/footsteps/bass_01.wav",
        "dz_ents/footsteps/bass_02.wav",
        "dz_ents/footsteps/bass_03.wav",
        "dz_ents/footsteps/bass_05.wav",
        "dz_ents/footsteps/bass_06.wav",
        "dz_ents/footsteps/bass_08.wav",
    },
    chan = CHAN_STATIC,
})

hook.Add("PlayerFootstep", "dz_ents_sound", function(ply, pos, foot, snd, volume, rf)
    if ply:DZ_ENTS_HasHeavyArmor() then
        ply:EmitSound("DZ_Ents.Suit.Heavy")
        if ply:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_HEAVY_CT then
            ply:EmitSound("DZ_Ents.Suit.CT")
        else
            ply:EmitSound("DZ_Ents.Suit.T")
        end
        -- still do default footstep?
        return nil
    end
end)