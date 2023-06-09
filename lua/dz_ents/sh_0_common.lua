-- Define CSGO weapons' armor penetration, ammo pickup, etc.
DZ_ENTS.CanonicalWeapons = {
    ------------------------- Pistols
    ["glock"] = {
        Category = "Pistol",
        AmmoPickup = 10,
        ArmorPenetration = 0.475,
    },
    ["hkp2000"] = {
        Category = "Pistol",
        AmmoPickup = 7,
        ArmorPenetration = 0.505,
    },
    ["usp_silencer"] = {
        Category = "Pistol",
        AmmoPickup = 6,
        ArmorPenetration = 0.505,
    },
    ["elite"] = {
        Category = "Pistol",
        AmmoPickup = 10,
        ArmorPenetration = 0.525,
    },
    ["p250"] = {
        Category = "Pistol",
        AmmoPickup = 7,
        ArmorPenetration = 0.64,
    },
    ["cz75"] = {
        Category = "Pistol",
        AmmoPickup = 6,
        ArmorPenetration = 0.7765,
    },
    ["tec9"] = {
        Category = "Pistol",
        AmmoPickup = 6,
        ArmorPenetration = 0.902,
    },
    ["fiveseven"] = {
        Category = "Pistol",
        AmmoPickup = 6,
        ArmorPenetration = 0.9115,
    },
    ["deagle"] = {
        Category = "Pistol",
        AmmoPickup = 2,
        ArmorPenetration = 0.932,
    },
    ["revolver"] = {
        Category = "Pistol",
        AmmoPickup = 1,
        ArmorPenetration = 0.932,
    },

    ------------------------- Heavy
    ["nova"] = {
        Category = "Heavy",
        Type = "Shotgun",
        AmmoPickup = 5,
        ArmorPenetration = 0.5,
    },
    ["sawedoff"] = {
        Category = "Heavy",
        ShellType = "Shotgun",
        AmmoPickup = 5,
        ArmorPenetration = 0.75,
    },
    ["mag7"] = {
        Category = "Heavy",
        ShellType = "Shotgun",
        AmmoPickup = 5,
        ArmorPenetration = 0.75,
    },
    ["xm1014"] = {
        Category = "Heavy",
        ShellType = "Shotgun",
        AmmoPickup = 5,
        ArmorPenetration = 0.8,
    },
    ["negev"] = {
        Category = "Heavy",
        AmmoPickup = 20, -- negev isn't in danger zone so I can do what I want!
        ArmorPenetration = 0.71,
    },
    ["m249"] = {
        Category = "Heavy",
        AmmoPickup = 12, -- ...no excuses here
        ArmorPenetration = 0.8,
    },

    ------------------------- Rifle
    ["galilar"] = {
        Category = "Rifle",
        AmmoPickup = 7,
        ArmorPenetration = 0.775,
    },
    ["famas"] = {
        Category = "Rifle",
        AmmoPickup = 7,
        ArmorPenetration = 0.7,
    },
    ["ssg08"] = {
        Category = "Rifle",
        AmmoPickup = 2,
        ArmorPenetration = 0.85,
    },
    ["m4a1"] = { -- M4A4
        Category = "Rifle",
        AmmoPickup = 6,
        ArmorPenetration = 0.7,
    },
    ["m4a1_silencer"] = { -- M4A1-S
        Category = "Rifle",
        AmmoPickup = 6,
        ArmorPenetration = 0.7,
    },
    ["ak47"] = {
        Category = "Rifle",
        AmmoPickup = 5,
        ArmorPenetration = 0.775,
    },
    ["aug"] = {
        Category = "Rifle",
        AmmoPickup = 4,
        ArmorPenetration = 0.9,
    },
    ["sg556"] = {
        Category = "Rifle",
        AmmoPickup = 4,
        ArmorPenetration = 1,
    },
    ["awp"] = {
        Category = "Rifle",
        AmmoPickup = 1,
        ArmorPenetration = 1,
    },
    ["scar20"] = {
        Category = "Rifle",
        AmmoPickup = 4,
        ArmorPenetration = 0.825,
    },
    ["g3sg1"] = {
        Category = "Rifle",
        AmmoPickup = 4,
        ArmorPenetration = 0.825,
    },

    ------------------------- SMG
    ["mac10"] = {
        Category = "SMG",
        AmmoPickup = 10,
        ArmorPenetration = 0.575,
    },
    ["mp9"] = {
        Category = "SMG",
        AmmoPickup = 10,
        ArmorPenetration = 0.6,
    },
    ["mp7"] = {
        Category = "SMG",
        AmmoPickup = 10,
        ArmorPenetration = 0.625,
    },
    ["mp5sd"] = {
        Category = "SMG",
        AmmoPickup = 10,
        ArmorPenetration = 0.625,
    },
    ["ump45"] = {
        Category = "SMG",
        AmmoPickup = 10,
        ArmorPenetration = 0.65,
    },
    ["p90"] = {
        Category = "SMG",
        AmmoPickup = 10,
        ArmorPenetration = 0.75,
    },
    ["bizon"] = {
        Category = "SMG",
        AmmoPickup = 15, -- love u bizon <3
        ArmorPenetration = 0.6,
    },
}

DZ_ENTS.CanonicalLookup = {
    ---------------------------------------- ArcCW Gunsmith Offensive
    ["arccw_go_ace"] = "galilar",
    ["arccw_go_ar15"] = "m4a1_silencer", -- semi auto because arctic hates me
    ["arccw_go_m4"] = "m4a1",
    ["arccw_go_g3"] = "g3sg1",
    ["arccw_go_scar"] = "scar20",
    ["arccw_go_m249para"] = "m249",
    ["arccw_go_m9"] = "elite", -- one instead of two. fine though right?
    ["arccw_go_r8"] = "revolver",
    ["arccw_go_usp"] = "usp_silencer",
    ["arccw_go_fnfal"] = "g3sg1", -- non-canon but let's match it anyways
    ["arccw_go_sw29"] = "revolver",
    ---------------------------------------- ArcCW Gunsmith Offensive Extras
    ["arccw_go_galil_ar"] = "galilar",
    ["arccw_go_m16a2"] = "m4a1_silencer",

    ---------------------------------------- ARC9 Gunsmith Reloaded
    ["arc9_go_elite_single"] = "elite",
    ["arc9_go_g1sg3"] = "g3sg1", -- WHAT THE FUCK?
    ["arc9_go_m4a1"] = "m4a1_silencer",

    ---------------------------------------- TFA CSGO
    ["tfa_csgo_m4a1"] = "m4a1_silencer",
    ["tfa_csgo_m4a4"] = "m4a1",
}
DZ_ENTS.ShortNameLookup = {
    ["p2000"] = "hkp2000",
    ["glock18"] = "glock",
    ["galil"] = "galilar",
    ["r8"] = "revolver",
    ["m4a4"] = "m4a1",
    ["m4a1"] = "m4a1_silencer",
    ["sg553"] = "sg556",
    ["sig556"] = "sg556",
    ["ump"] = "ump45",
    ["cz75a"] = "cz75",
    ["usp"] = "usp_silencer",
}
-- List of strings to look for to ensure the weapon is actually a CSGO weapon.
-- As long as one matches, it's green light.
DZ_ENTS.PrefixWhitelist = {
    "csgo_", -- TFA, RetroSource, all the various shitty ones
    "swcs_", -- SWCS
    "arccw_go_", -- ArcCW GSO
    "arc9_go_", -- ARC9 GSR
}
DZ_ENTS.CanonicalClassCache = {}
DZ_ENTS.CanonicalClassList = {}

-- Match various weapon bases' CSGO weapons to the canonical name.
function DZ_ENTS:GetCanonicalClass(class)

    -- generate cache
    if DZ_ENTS.CanonicalClassCache[class] == nil then

        -- direct lookup in case something is really different
        local canonclass = DZ_ENTS.CanonicalLookup[class]

        if not canonclass then
            local exp = string.Explode("_", class, false)

            -- ensure the weapon is part of an approved CSGO weapon pack
            local whitelisted = false
            for _, str in ipairs(DZ_ENTS.PrefixWhitelist) do
                if string.find(class, str) then
                    whitelisted = true
                    break
                end
            end

            for i = 1, math.min(#exp, 2) do
                local short
                if i == 1 then
                    short = exp[#exp]
                else
                    short = exp[#exp - 1] .. "_" .. exp[#exp]
                end
                if not short then continue end

                -- some names are confusing
                -- (e.g.: TFA CSGO's "m4a1" is the M4A1-S, but that is the canonical name for the M4A4. Thanks Valve!)
                if whitelisted and DZ_ENTS.CanonicalWeapons[short] then
                    canonclass = short
                elseif whitelisted and DZ_ENTS.ShortNameLookup[short] then
                    canonclass = DZ_ENTS.ShortNameLookup[short]
                end
            end
        end

        -- still no? tough luck
        if not canonclass then
            canonclass = false
        end

        DZ_ENTS.CanonicalClassCache[class] = canonclass
        if canonclass then
            DZ_ENTS.CanonicalClassList[canonclass] = DZ_ENTS.CanonicalClassList[canonclass] or {}
            table.insert(DZ_ENTS.CanonicalClassList[canonclass], class)
        end
    end

    return DZ_ENTS.CanonicalClassCache[class]
end

if SERVER then
    concommand.Add("dzents_debug_canonclass", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        DZ_ENTS.CanonicalClassCache = {}
        for _, v in pairs(list.Get("Weapon")) do
            DZ_ENTS:GetCanonicalClass(v.ClassName)
        end

        PrintTable(DZ_ENTS.CanonicalClassList)
        -- for k, v in pairs(DZ_ENTS.CanonicalClassCache) do
        --     if v then print(k, v) end
        -- end
    end)
end

-- uses SortingAmmoTypes
DZ_ENTS.AmmoTypeAP = {
    ["pistol"] = 0.4,
    ["magnum"] = 0.75,
    ["smg"] = 0.65,
    ["shotgun"] = 0.4,
    ["rifle"] = 0.8,
    ["sniper"] = 1,
}

DZ_ENTS.AmmoTypeGiven = {
    ["pistol"] = 10,
    ["smg"] = 6, -- could be either smg or carbine. awkward!
    ["rifle"] = 5,
    ["shotgun"] = 4,
    ["magnum"] = 2,
    ["sniper"] = 1,
}

DZ_ENTS.AmmoMaxReserveSWCS = {
    ["BULLET_PLAYER_50AE"] = 35,
    ["BULLET_PLAYER_762MM"] = 90,
    ["BULLET_PLAYER_556MM"] = 90,
    ["BULLET_PLAYER_556MM_SMALL"] = 80, -- M4A1-S
    ["BULLET_PLAYER_556MM_BOX"] = 200,
    ["BULLET_PLAYER_338MAG"] = 30,
    ["BULLET_PLAYER_9MM"] = 120,
    ["BULLET_PLAYER_BUCKSHOT"] = 32,
    ["BULLET_PLAYER_45ACP"] = 100,
    ["BULLET_PLAYER_57MM"] = 100,
    ["BULLET_PLAYER_357SIG"] = 52, -- Valve really doesn't know what a caliber is huh
    ["BULLET_PLAYER_357SIG_SMALL"] = 24, -- USP-S
    ["BULLET_PLAYER_357SIG_MIN"] = 12, -- CZ-75
    ["BULLET_PLAYER_357SIG_P250"] = 26, -- P250
}

DZ_ENTS.AmmoMaxReserve = { -- only used when max ammo is not defined in ammo type (read: cw 2.0)
    ["pistol"] = 120,
    ["smg"] = 225,
    ["rifle"] = 60,
    ["shotgun"] = 30,
    ["magnum"] = 12,
    ["sniper"] = 15,
}

-- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/game/shared/shareddefs.h#L369
DZ_ENTS.PLAYER_FATAL_FALL_SPEED = 922.5
DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED = 526.5
DZ_ENTS.DAMAGE_FOR_FALL_SPEED = 100 / ( DZ_ENTS.PLAYER_FATAL_FALL_SPEED - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED )