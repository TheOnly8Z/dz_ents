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
    name = "DZ_Ents.Healthshot.Success",
    volume = 0.6,
    level = 75,
    sound =  ")dz_ents/healthshot_success_01.wav",
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.Healthshot.Prepare",
    volume = 1,
    level = 75,
    sound =  ")dz_ents/healthshot_prepare_01.wav",
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.Healthshot.Thud",
    volume = 0.6,
    level = 75,
    sound =  ")dz_ents/healthshot_thud_01.wav",
    chan = CHAN_STATIC,
})

-- used on equipment
sound.Add({
    name = "DZ_Ents.HEGrenade.Draw",
    volume = 0.3,
    level = 65,
    sound =  ")dz_ents/he_draw.wav",
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.BumpMine.Throw",
    volume = 0.8,
    level = 65,
    pitch = 120,
    sound =  "dz_ents/bumpmine_throw.wav",
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.BumpMine.Idle",
    volume = 0.65,
    level = 70,
    pitch = 90,
    sound =  "dz_ents/power_transformer_loop_1.wav",
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.BumpMine.SetArmed",
    volume = 1,
    level = 85,
    pitch = 100,
    sound =  "dz_ents/bumpmine_land_01.wav",
    chan = CHAN_STATIC,
    -- ignore_occlusion?
})

sound.Add({
    name = "DZ_Ents.BumpMine.Warning",
    volume = 0.5,
    level = 75,
    pitch = 100,
    sound = "dz_ents/breach_warning_beep_01.wav", -- ~
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.BumpMine.Detonate",
    volume = 0.8,
    level = 75,
    pitch = 100,
    sound = ")dz_ents/bumpmine_launch_01.wav", -- ~
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.BumpMine.PreDetonate",
    volume = 1,
    level = 75,
    pitch = 100,
    sound = "dz_ents/breach_activate_01.wav",
    chan = CHAN_STATIC,
})

sound.Add({
    name = "DZ_Ents.BumpMine.Pickup",
    volume = 1,
    level = 75,
    pitch = 100,
    sound = "dz_ents/bumpmine_pickup.wav",
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