if CLIENT then
    CreateConVar("cl_dzents_subcat", 1, FCVAR_ARCHIVE, "Show sub-categories in spawn menu.", 0, 1)
    CreateConVar("cl_dzents_autoparachute", 1, FCVAR_ARCHIVE + FCVAR_USERINFO, "Automatically deploy parachute while falling.", 0, 1)
    CreateConVar("cl_dzents_vmparachute", 1, FCVAR_ARCHIVE + FCVAR_USERINFO, "Draw parachute straps in first person.", 0, 1)

end

-- General
CreateConVar("dzents_cleanup_drop", 60, FCVAR_ARCHIVE, "Timer for removing items dropped on death. 0 - never remove.", 0)

-- Case
CreateConVar("dzents_case_reinforced", 1, FCVAR_ARCHIVE, "Reinforced cases cannot be broken by unarmed attacks.", 0, 1)
CreateConVar("dzents_case_health", 1, FCVAR_ARCHIVE, "Health multiplier for newly spawned cases.", 0.01)
CreateConVar("dzents_case_gib", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Configure gib settings. 0 - no gibs; 1 - client gibs; 2 - server gibs", 0, 2)

-- Ammo
CreateConVar("dzents_ammo_clip", 0, FCVAR_ARCHIVE, "Use clip size per ammo box instead of Danger Zone values.", 0, 1)
CreateConVar("dzents_ammo_mult", 1, FCVAR_ARCHIVE, "Multiplier for amount of ammo given by ammo boxes.", 0)
CreateConVar("dzents_ammo_cleanup", 1, FCVAR_ARCHIVE, "After being emptied, remove the box unless it will regen ammo.", 0, 1)
CreateConVar("dzents_ammo_limit", 1, FCVAR_ARCHIVE, "Multiplier for reserve ammo limit when picking up ammo from ammo boxes. 0 - no limit.", 0)
CreateConVar("dzents_ammo_regen", 0, FCVAR_ARCHIVE, "Ammo boxes replenish themselves after being consumed.", 0, 1)
CreateConVar("dzents_ammo_regen_delay", 60, FCVAR_ARCHIVE, "Time for the ammo box to regenerate fully after last use.", 1)
CreateConVar("dzents_ammo_regen_partial", 0, FCVAR_ARCHIVE, "Regenerate ammo boxes one by one instead of all at once.", 0, 1)

-- Armor
CreateConVar("dzents_armor_enabled", 1, FCVAR_ARCHIVE, "Whether to use CS:GO armor logic. 1 - If player equipped armor/helmet. 2 - always use custom logic.", 0, 2)
CreateConVar("dzents_armor_fallback", 1, FCVAR_ARCHIVE, "If CS:GO armor does not protect from damage, use HL2 armor logic.", 0, 1)
CreateConVar("dzents_armor_onspawn", 0, FCVAR_ARCHIVE, "Whether to give armor on spawn. 1+ gives armor. 2+ gives helmet. 3 gives Heavy Assault Suit.", 0, 3)
CreateConVar("dzents_armor_deathdrop", 1, FCVAR_ARCHIVE, "On death, drop helmet and armor. Does not drop the Heavy Assault Suit.", 0, 1)
CreateConVar("dzents_armor_heavy_damage", 0.85, FCVAR_ARCHIVE, "When using Heavy Assault Suit, scale all incoming damage by this much in addition to its defense boost.", 0, 1)
CreateConVar("dzents_armor_heavy_durability", 1, FCVAR_ARCHIVE, "Multiplier for durability loss when using Heavy Assault Suit.", 0)
CreateConVar("dzents_armor_heavy_speed", 130, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Walk speed when using the Heavy Assault Suit. Set 0 to not slow down at all.", 0)
CreateConVar("dzents_armor_heavy_sprint", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "When using Heavy Assault Suit, allow sprinting. Sprinting speed will be twice the walk speed.", 0, 1)
CreateConVar("dzents_armor_heavy_norifle", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "When using Heavy Assault Suit, disallow equipping rifles. This only affects canonical CS:GO weapons.", 0, 1)
CreateConVar("dzents_armor_heavy_deployspeed", 0.8, FCVAR_ARCHIVE + FCVAR_REPLICATED, "When using Heavy Assault Suit, multiply deploy speed by this number. Only works for certain weapon bases.", 0, 1)

-- Equipment
CreateConVar("dzents_equip_deathdrop", 1, FCVAR_ARCHIVE, "On death, drop the Parachute or ExoJump.", 0, 1)
CreateConVar("dzents_parachute_onspawn", 0, FCVAR_ARCHIVE, "Give a parachute on spawn.", 0, 1)
CreateConVar("dzents_parachute_consume", 1, FCVAR_ARCHIVE, "After parachute is deployed and released, it is used up.", 0, 1)
CreateConVar("dzents_parachute_fall", 200, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Target vertical velocity when using parachute. Higher value means faster falling.", 50, 500)
CreateConVar("dzents_parachute_threshold", 650, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Minimum downwards velocity for parachute deployment. Negative values allow for deploying while rising in the air.")
CreateConVar("dzents_parachute_drag", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Horizontal velocity drag multiplier when using parachute. Higher value slows players down further.", 0)
CreateConVar("dzents_exojump_onspawn", 0, FCVAR_ARCHIVE, "Give an ExoJump on spawn.", 0, 1)
CreateConVar("dzents_exojump_vel_up", 1100, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Velocity when high jumping with the ExoJump.", 0)
CreateConVar("dzents_exojump_vel_long", 1100, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Velocity when long jumping with the ExoJump.", 0)
CreateConVar("dzents_exojump_boostdur", 0.5, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Duration of the ExoJump boost.", 0)
CreateConVar("dzents_exojump_drag", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Horizontal velocity drag multiplier when high jumping with the ExoJump. Higher value slows players down further.", 0)
CreateConVar("dzents_exojump_cooldown", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "After using the ExoJump and landing, how long until you can jump again.", 0)