DZ_ENTS.ConVars = {}

if CLIENT then
    CreateConVar("cl_dzents_subcat", 1, FCVAR_ARCHIVE, "Show sub-categories in spawn menu.", 0, 1)
    CreateConVar("cl_dzents_parachute_autodeploy", 1, FCVAR_ARCHIVE + FCVAR_USERINFO, "Automatically deploy parachute while falling.", 0, 1)
    CreateConVar("cl_dzents_parachute_vm", 1, FCVAR_ARCHIVE, "Draw parachute straps in first person.", 0, 1)
    CreateConVar("cl_dzents_parachute_frame", 1, FCVAR_ARCHIVE, "Draw black frames when in parachute.", 0, 1)
    CreateConVar("cl_dzents_healthshot_overlay", 1, FCVAR_ARCHIVE, "Draw health shot overlay.", 0, 1)
    CreateConVar("cl_dzents_heavyarmor_cc", 1, FCVAR_ARCHIVE, "Draw color correction while in heavy armor.", 0, 1)
    CreateConVar("cl_dzents_hint", 1, FCVAR_ARCHIVE + FCVAR_USERINFO, "Display hints.", 0, 1)

    CreateConVar("cl_dzents_hud_enabled", 1, FCVAR_ARCHIVE, "Use armor/equipment HUD.", 0, 1)
    CreateConVar("cl_dzents_hud_scale", 1, FCVAR_ARCHIVE, "HUD scale.", 0)
    CreateConVar("cl_dzents_hud_x", 200, FCVAR_ARCHIVE, "HUD X position in screen scale units. Negative values start from the right.")
    CreateConVar("cl_dzents_hud_y", -30, FCVAR_ARCHIVE, "HUD Y position in screen scale units. Negative values start from below.")

    CreateConVar("cl_dzents_volume_hit", 0.75, FCVAR_ARCHIVE + FCVAR_USERINFO, "Hit sound volume (headshot/armor) when hitting other players.", 0, 1)

    CreateConVar("cl_dzents_ttt_exojump", 1, FCVAR_USERINFO, "Toggles the ExoJump in TTT.", 0, 1)
end

-- Case
DZ_ENTS.ConVars["case_reinforced"]      = CreateConVar("dzents_case_reinforced", 1, FCVAR_ARCHIVE, "Reinforced cases cannot be damaged by unarmed attacks.", 0, 1)
DZ_ENTS.ConVars["case_health"]          = CreateConVar("dzents_case_health", 1, FCVAR_ARCHIVE, "Health multiplier for newly spawned cases.", 0.01)
DZ_ENTS.ConVars["case_gib"]             = CreateConVar("dzents_case_gib", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Configure gib settings. 0 - no gibs; 1 - client gibs; 2 - server gibs", 0, 2)
DZ_ENTS.ConVars["case_userdef"]         = CreateConVar("dzents_case_userdef", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Use user-defined category whitelist.", 0, 1)
DZ_ENTS.ConVars["case_cleanup"]         = CreateConVar("dzents_case_cleanup", 300, FCVAR_ARCHIVE, "Timer for removing items dropped by cases. 0 or 1- never remove.", 0)
DZ_ENTS.ConVars["case_shrink"]          = CreateConVar("dzents_case_shrink", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Shrink the size or all cases and disables player collision.", 0, 1)

-- Ammo
DZ_ENTS.ConVars["ammo_clip"]            = CreateConVar("dzents_ammo_clip", 0, FCVAR_ARCHIVE, "Use clip size per ammo box instead of Danger Zone values.", 0, 1)
DZ_ENTS.ConVars["ammo_mult"]            = CreateConVar("dzents_ammo_mult", 1, FCVAR_ARCHIVE, "Multiplier for amount of ammo given by ammo boxes.", 0)
DZ_ENTS.ConVars["ammo_cleanup"]         = CreateConVar("dzents_ammo_cleanup", 1, FCVAR_ARCHIVE, "After being emptied, remove the box unless it will regen ammo.", 0, 1)
DZ_ENTS.ConVars["ammo_limit"]           = CreateConVar("dzents_ammo_limit", 1, FCVAR_ARCHIVE, "Multiplier for reserve ammo limit when picking up ammo from ammo boxes. 0 - no limit.", 0)
DZ_ENTS.ConVars["ammo_regen"]           = CreateConVar("dzents_ammo_regen", 0, FCVAR_ARCHIVE, "Ammo boxes replenish themselves after being consumed.", 0, 1)
DZ_ENTS.ConVars["ammo_regen_delay"]     = CreateConVar("dzents_ammo_regen_delay", 60, FCVAR_ARCHIVE, "Time for the ammo box to regenerate fully after last use.", 1)
DZ_ENTS.ConVars["ammo_regen_partial"]   = CreateConVar("dzents_ammo_regen_partial", 0, FCVAR_ARCHIVE, "Regenerate ammo boxes one by one instead of all at once.", 0, 1)
DZ_ENTS.ConVars["ammo_adminonly"]       = CreateConVar("dzents_ammo_adminonly", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Infinite Ammo Can is admin only. Requires reload.", 0, 1)

-- Armor
DZ_ENTS.ConVars["armor_enabled"]        = CreateConVar("dzents_armor_enabled", 1, FCVAR_ARCHIVE, "Whether to use CS:GO armor logic. 1 - If player equipped armor/helmet. 2 - always use custom logic.", 0, 2)
DZ_ENTS.ConVars["armor_fallback"]       = CreateConVar("dzents_armor_fallback", 1, FCVAR_ARCHIVE, "If CS:GO armor does not protect from damage, use HL2 armor logic.", 0, 1)
DZ_ENTS.ConVars["armor_onspawn"]        = CreateConVar("dzents_armor_onspawn", 0, FCVAR_ARCHIVE, "Whether to give armor on spawn. 1+ gives armor. 2+ gives helmet. 3 gives Heavy Assault Suit.", 0, 3)
DZ_ENTS.ConVars["armor_damage"]         = CreateConVar("dzents_armor_damage", 1, FCVAR_ARCHIVE, "When using standard armor, scale all incoming damage by this much.", 0)
DZ_ENTS.ConVars["armor_durability"]     = CreateConVar("dzents_armor_durability", 1, FCVAR_ARCHIVE, "Multiplier for durability loss when using standard armor.", 0)
DZ_ENTS.ConVars["armor_eff_head"]       = CreateConVar("dzents_armor_eff_head", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Show a spark effect on a blocked headshot.", 0, 1)
DZ_ENTS.ConVars["armor_eff_heavy"]      = CreateConVar("dzents_armor_eff_heavy", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Show a spark effect on hitting heavy armor.", 0, 1)
DZ_ENTS.ConVars["armor_snd_dink"]       = CreateConVar("dzents_armor_snd_dink", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Play headshot sound on players without DZ armor.", 0, 1)
DZ_ENTS.ConVars["armor_snd_world"]      = CreateConVar("dzents_armor_snd_world", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Play kevlar/helmet impact sound effect for everyone.", 0, 1)

DZ_ENTS.ConVars["armor_heavy_damage"]       = CreateConVar("dzents_armor_heavy_damage", 0.85, FCVAR_ARCHIVE, "When using Heavy Assault Suit, scale all incoming damage by this much in addition to its defense boost.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_durability"]   = CreateConVar("dzents_armor_heavy_durability", 1, FCVAR_ARCHIVE, "Multiplier for durability loss when using Heavy Assault Suit.", 0)
DZ_ENTS.ConVars["armor_heavy_falldamage"]   = CreateConVar("dzents_armor_heavy_falldamage", 1, FCVAR_ARCHIVE, "Take velocity-based fall damage when using the Heavy Assault Suit even with mp_falldamage off.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_fallstomp"]    = CreateConVar("dzents_armor_heavy_fallstomp", 1, FCVAR_ARCHIVE, "With the Heavy Assault Suit, do damage to anything you land on when taking fall damage.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_break"]        = CreateConVar("dzents_armor_heavy_break", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Allow the Heavy Assault Suit to break when armor reaches 0, restoring movement speed.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_speed"]        = CreateConVar("dzents_armor_heavy_speed", 130, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Walk speed when using the Heavy Assault Suit. Set 0 to not slow down at all.", 0)
DZ_ENTS.ConVars["armor_heavy_nosprint"]     = CreateConVar("dzents_armor_heavy_nosprint", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "When using Heavy Assault Suit, allow sprinting. Sprinting speed will be twice the walk speed.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_norifle"]      = CreateConVar("dzents_armor_heavy_norifle", 2, FCVAR_ARCHIVE + FCVAR_REPLICATED, "When using Heavy Assault Suit, disallow equipping rifles. 1 - only CS:GO rifles. 2 - attempt to block all rifles.", 0, 2)
DZ_ENTS.ConVars["armor_heavy_deployspeed"]  = CreateConVar("dzents_armor_heavy_deployspeed", 0.8, FCVAR_ARCHIVE + FCVAR_REPLICATED, "When using Heavy Assault Suit, multiply deploy speed by this number. Only works for certain weapon bases.", 0.25, 1)
DZ_ENTS.ConVars["armor_heavy_adminonly"]    = CreateConVar("dzents_armor_heavy_adminonly", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Heavy Assault Suit is admin only. Requires reload.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_gravity"]      = CreateConVar("dzents_armor_heavy_gravity", 0.3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Additional gravity multiplier when you have the Heavy Assault Suit. Also reduces effectiveness of Parachutes, Bump Mines and ExoJumps.", 0)
DZ_ENTS.ConVars["armor_heavy_exojump"]      = CreateConVar("dzents_armor_heavy_exojump", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Velocity multiplier when using the ExoJump with the Heavy Assault Suit.", 0)
DZ_ENTS.ConVars["armor_heavy_robert"]               = CreateConVar("dzents_armor_heavy_robert", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "ROBERTOOOOOOOOO", 0, 1)
DZ_ENTS.ConVars["armor_heavy_playermodel"]          = CreateConVar("dzents_armor_heavy_playermodel", 1, FCVAR_ARCHIVE, "Set playermodel when using the Heavy Assault Suit.", 0, 1)
DZ_ENTS.ConVars["armor_heavy_playermodel_skin"]     = CreateConVar("dzents_armor_heavy_playermodel_skin", 1, FCVAR_ARCHIVE, "Randomize skins when using the Heavy Assault Suit.", 0, 1)


-- Death drop
DZ_ENTS.ConVars["drop_armor"]       = CreateConVar("dzents_drop_armor", 1, FCVAR_ARCHIVE, "On death, drop helmet and armor. Does not drop the Heavy Assault Suit.", 0, 1)
DZ_ENTS.ConVars["drop_equip"]       = CreateConVar("dzents_drop_equip", 1, FCVAR_ARCHIVE, "On death, drop the Parachute or ExoJump.", 0, 1)
DZ_ENTS.ConVars["drop_cleanup"]     = CreateConVar("dzents_drop_cleanup", 0, FCVAR_ARCHIVE, "Timer for removing items dropped on death. 0 - never remove.", 0)

-- Pickups
DZ_ENTS.ConVars["pickup_instantuse"]    = CreateConVar("dzents_pickup_instantuse", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Pick up equipment instantly.", 0, 1)
DZ_ENTS.ConVars["parachute_onspawn"]    = CreateConVar("dzents_parachute_onspawn", 0, FCVAR_ARCHIVE, "Give a parachute on spawn.", 0, 1)
DZ_ENTS.ConVars["parachute_detach"]     = CreateConVar("dzents_parachute_detach", 0, FCVAR_ARCHIVE, "Allow premature detaching of the parachute.", 0, 1)
DZ_ENTS.ConVars["parachute_consume"]    = CreateConVar("dzents_parachute_consume", 1, FCVAR_ARCHIVE, "After parachute is deployed and released, it is used up.", 0, 1)
DZ_ENTS.ConVars["parachute_fall"]       = CreateConVar("dzents_parachute_fall", 200, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Target vertical velocity when using parachute. Higher value means faster falling.", 50, 500)
DZ_ENTS.ConVars["parachute_threshold"]  = CreateConVar("dzents_parachute_threshold", 400, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Minimum downwards velocity for instant parachute deployment. Below this threshold there is a short deployment delay.", 0)
DZ_ENTS.ConVars["parachute_drag"]       = CreateConVar("dzents_parachute_drag", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Horizontal velocity drag multiplier when using parachute. Higher value slows players down further.", 0)
DZ_ENTS.ConVars["parachute_speed"]      = CreateConVar("dzents_parachute_speed", 150, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Horizontal speed while using parachute.", 0)

DZ_ENTS.ConVars["exojump_onspawn"]          = CreateConVar("dzents_exojump_onspawn", 0, FCVAR_ARCHIVE, "Give an ExoJump on spawn.", 0, 1)
DZ_ENTS.ConVars["exojump_runboost"]         = CreateConVar("dzents_exojump_runboost", 1, FCVAR_ARCHIVE, "Allow using ExoJump at running speeds.", 0, 1)
DZ_ENTS.ConVars["exojump_boost_up"]         = CreateConVar("dzents_exojump_boost_up", 0.6, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Velocity boost when high jumping with the ExoJump.", 0)
DZ_ENTS.ConVars["exojump_boost_forward"]    = CreateConVar("dzents_exojump_boost_forward", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Velocity boost when long jumping with the ExoJump.", 0)
DZ_ENTS.ConVars["exojump_falldamage"]       = CreateConVar("dzents_exojump_falldamage", 0.4, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Fall damage multiplier when wearing the ExoJump.", 0, 1)
DZ_ENTS.ConVars["exojump_drag"]             = CreateConVar("dzents_exojump_drag", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Horizontal velocity drag multiplier when high jumping with the ExoJump. Higher value slows players down further.", 0)
-- DZ_ENTS.ConVars["exojump_cooldown"]  = CreateConVar("dzents_exojump_cooldown", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "After using the ExoJump and landing, how long until you can use it again.", 0)
-- DZ_ENTS.ConVars["exojump_boostdur"]  = CreateConVar("dzents_exojump_boostdur", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Duration of the ExoJump boost.", 0)

-- Equipment
DZ_ENTS.ConVars["equipment_swcs"]  = CreateConVar("dzents_equipment_swcs", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Use SWCS as our weapon base if possible.", 0, 1)

DZ_ENTS.ConVars["healthshot_health"]        = CreateConVar("dzents_healthshot_health", 50, FCVAR_ARCHIVE, "How much health is restored by the Medi-Shot.", 0)
DZ_ENTS.ConVars["healthshot_use_at_full"]   = CreateConVar("dzents_healthshot_use_at_full", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Allow using the Medi-Shot at full health.", 0, 1)
DZ_ENTS.ConVars["healthshot_healtime"]      = CreateConVar("dzents_healthshot_healtime", 2, FCVAR_ARCHIVE, "Duration over which health is restored. At 0, health is given instantly.", 0)
DZ_ENTS.ConVars["healthshot_damage_dealt"]  = CreateConVar("dzents_healthshot_damage_dealt", 1, FCVAR_ARCHIVE, "Outgoing damage multiplier while under the effects of the Medi-Shot.", 0)
DZ_ENTS.ConVars["healthshot_damage_taken"]  = CreateConVar("dzents_healthshot_damage_taken", 1, FCVAR_ARCHIVE, "Incoming damage multiplier while under the effects of the Medi-Shot.", 0)
DZ_ENTS.ConVars["healthshot_speed"]         = CreateConVar("dzents_healthshot_speed", 1.2, FCVAR_ARCHIVE, "Speed multiplier while under the effects of the Medi-Shot.", 0)
DZ_ENTS.ConVars["healthshot_duration"]      = CreateConVar("dzents_healthshot_duration", 6.5, FCVAR_ARCHIVE, "Duration of damage and speed bonuses from the Medi-Shot.", 0)
DZ_ENTS.ConVars["healthshot_maxammo"]       = CreateConVar("dzents_healthshot_maxammo", 2, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Maximum amount of Medi-Shots you can have on you.", 0)
DZ_ENTS.ConVars["healthshot_killcount"]     = CreateConVar("dzents_healthshot_killcount", 3, FCVAR_ARCHIVE, "Kill this many players to get a Medi-Shot. 0 disables.", 0)

DZ_ENTS.ConVars["bumpmine_maxammo"]             = CreateConVar("dzents_bumpmine_maxammo", 3, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Maximum amount of Bump Mines you can have on you.", 0)
DZ_ENTS.ConVars["bumpmine_lifetime"]            = CreateConVar("dzents_bumpmine_lifetime", 600, FCVAR_ARCHIVE, "How long do placed Bump Mines last before being removed. 0 - never remove", 0)
DZ_ENTS.ConVars["bumpmine_force"]               = CreateConVar("dzents_bumpmine_force", 1000, FCVAR_ARCHIVE, "Bump mine push force.", 0)
DZ_ENTS.ConVars["bumpmine_upadd"]               = CreateConVar("dzents_bumpmine_upadd", 200, FCVAR_ARCHIVE, "Additional upwards force from the bump mine.", 0)
DZ_ENTS.ConVars["bumpmine_armdelay"]            = CreateConVar("dzents_bumpmine_armdelay", 0.3, FCVAR_ARCHIVE, "Delay after landing before the bump mine can detonate.", 0)
DZ_ENTS.ConVars["bumpmine_detdelay"]            = CreateConVar("dzents_bumpmine_detdelay", 0.2, FCVAR_ARCHIVE, "Delay between triggering the bump mine and detonating.", 0)
DZ_ENTS.ConVars["bumpmine_damage_fall"]         = CreateConVar("dzents_bumpmine_damage_fall", 1, FCVAR_ARCHIVE, "Fall damage multiplier when launched by Bump Mines.", 0)
DZ_ENTS.ConVars["bumpmine_damage_crash"]        = CreateConVar("dzents_bumpmine_damage_crash", 1, FCVAR_ARCHIVE, "Damage multiplier when crashing into walls from Bump Mines.", 0)
DZ_ENTS.ConVars["bumpmine_damage_selfcrash"]    = CreateConVar("dzents_bumpmine_damage_selfcrash", 0.5, FCVAR_ARCHIVE, "Additional damage multiplier on the user when crashing into walls from Bump Mines.", 0)
DZ_ENTS.ConVars["bumpmine_damage_crashchain"]   = CreateConVar("dzents_bumpmine_damage_crashchain", 1, FCVAR_ARCHIVE, "Crashing NPCs and players can deal damage to things they land on.", 0, 1)
DZ_ENTS.ConVars["bumpmine_stack"]               = CreateConVar("dzents_bumpmine_stack", 1, FCVAR_ARCHIVE, "Multiple Bump Mines in close proximity will cause a bigger, stronger explosion.", 0, 1)

cvars.AddChangeCallback("dzents_case_userdef", function(cvar, old, new)
    if SERVER and tonumber(new) == 1 and (not DZ_ENTS.UserDefLists["case_category"] or #DZ_ENTS.UserDefLists["case_category"] == 0) then
        PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] Remember to also add some categories to the whitelist!")
    end
    DZ_ENTS.LootTypeList = {}
    DZ_ENTS.LootTypeListLookup = {}
end)