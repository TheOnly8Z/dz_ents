if CLIENT then
    CreateConVar("cl_dzents_subcat", 1, FCVAR_ARCHIVE, "Show sub-categories in spawn menu.", 0, 1)
    CreateConVar("cl_dzents_autoparachute", 1, FCVAR_ARCHIVE + FCVAR_USERINFO, "Automatically deploy parachute while falling.", 0, 1)
end

CreateConVar("dzents_case_reinforced", 1, FCVAR_ARCHIVE, "Reinforced cases cannot be broken by unarmed attacks.", 0, 1)
CreateConVar("dzents_case_health", 1, FCVAR_ARCHIVE, "Health multiplier for newly spawned cases.", 0.01)
CreateConVar("dzents_case_gib", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Configure gib settings. 0 - no gibs; 1 - client gibs; 2 - server gibs", 0, 2)

CreateConVar("dzents_ammo_mult", 1, FCVAR_ARCHIVE, "Multiplier for amount of ammo given by Ammo Boxes.", 0)
CreateConVar("dzents_ammo_cleanup", 1, FCVAR_ARCHIVE, "After being emptied, remove the box if it isn't regenerating.", 0, 1)
CreateConVar("dzents_ammo_regen", 0, FCVAR_ARCHIVE, "Ammo boxes replenish themselves after being consumed.", 0, 1)
CreateConVar("dzents_ammo_regen_delay", 60, FCVAR_ARCHIVE, "Time for the ammo box to regenerate after last use.", 1)

CreateConVar("dzents_armor_enabled", 1, FCVAR_ARCHIVE, "Whether to use CS:GO armor logic. 1 - If player equipped armor/helmet. 2 - always use custom logic.", 0, 2)
CreateConVar("dzents_armor_onspawn", 0, FCVAR_ARCHIVE, "Whether to give armor on spawn. 1 - Give armor but not helmet. 2 - Armor + helmet.", 0, 2)
CreateConVar("dzents_armor_deathdrop", 1, FCVAR_ARCHIVE, "On death, drop helmet and armor if player had them. If set to 2, heavy armor will also be dropped.", 0, 2)

CreateConVar("dzents_parachute_consume", 1, FCVAR_ARCHIVE, "After parachute is deployed and released, it is used up.", 0, 1)