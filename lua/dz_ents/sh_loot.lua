
-- God fucking knows what kind of stupid ammo types CW2 gun modders are cooking up
DZ_ENTS.SortingAmmoTypes = {
    ["pistol"] = {
        ["pistol"] = true,
        ["apex_light"] = true,
        ["9x19mm"] = true,
        ["9x18mm"] = true,
        ["9x17mm"] = true,
        ["9x25mm"] = true,
        [".25 acp"] = true,
        [".32 acp"] = true,
        [".45 acp"] = true,
        [".380"] = true,
        ["7.62x25mm"] = true,
        ["40sw"] = true,
        [".40 s&w"] = true,
    },
    ["magnum"] = {
        ["357"] = true,
        ["apex_arrow"] = true, -- only here for ammo pickup purposes
        [".38 special"] = true,
        [".357 magnum"] = true,
        [".44 amp"] = true,
        [".44 magnum"] = true,
        [".50 ae"] = true,
        [".500 magnum"] = true,
        [".50 beowulf"] = true,
    },
    ["smg"] = {
        ["smg1"] = true,-- m9k, tfa and mw base typically uses smg1 for SMGs. tacrp, arccw and arc9 uses it for carbine calibers (5.56 etc).
        ["apex_energy"] = true,
        ["hk 4.6x30mm"] = true,
        ["fn 5.7x28mm"] = true,
        [".30 carbine"] = true,
    },
    ["shotgun"] = {
        ["buckshot"] = true,

        ["apex_shotgun"] = true,
        ["12 gauge"] = true,
        ["20 gauge"] = true,
        ["8 gauge"] = true,
        [".410 bore"] = true,
        [".700"] = true, -- ????
    },
    ["rifle"] = {
        ["ar2"] = true,

        -- intermediate cartridges
        ["5.56x45mm"] = true,
        ["5.45x39mm"] = true,
        ["5.6x45mm gp90"] = true,
        [".300 aac blackout"] = true,
        ["9x39mm"] = true,
        ["airboatgun"] = true, -- why does the winchester have its own ammo type, _bob_

        -- "battle rifle" or bolt action rifles but idrc
        ["apex_heavy"] = true,
        ["7.62x51mm"] = true,
        ["7.62x54mmr"] = true,
        ["7.62x54r"] = true,
        ["7.92x57mm mauser"] = true,
        [".30-06"] = true,
        [".303"] = true,
        ["7.92x33mm"] = true,
        ["7.92x57mm"] = true,
    },
    ["sniper"] = {
        ["xbowbolt"] = true, -- I guess?
        ["sniperpenetratedround"] = true,
        ["apex_sniper"] = true,
        [".338mm"] = true,
        [".338 lapua"] = true,
        ["50 bmg"] = true,
        [".50 bmg"] = true,
        [".30 winchester"] = true,
    }
}
function DZ_ENTS:GetWeaponAmmoCategory(ammo_name)
    if not ammo_name then return end
    ammo_name = string.lower(ammo_name)
    for k, v in pairs(DZ_ENTS.SortingAmmoTypes) do
        if v[ammo_name] then return k end
    end
end

DZ_ENTS.LootTypes = {
    ["melee"] = {
        -- any slot 1 melee (that isn't fists or hands)
        filter = function(class, ent, ammocat)
            return ent.Slot == 0
                and (not ent.IsTFAWeapon or ent.IsMelee)
                and (not ent.ArcCW or ent.PrimaryBash)
                and (not ent.ARC9 or ent.PrimaryBash)
                and (not ent.IsSWCSWeapon or ent.IsKnife)
                and not ( -- no good way to do this since fist holdtype can be a melee too
                string.find(class, "fist")
                or string.find(class, "hand")
                or string.find(class, "unarmed")
                or string.find(class, "holster")
                or string.find(class, "punch")
                or string.find(class, "zombie"))
        end,
        default = {
            "weapon_crowbar_hl1",
        },
        blacklist = {
            ["apexswep"] = true,
            ["remotecontroller"] = true,
            ["laserpointer"] = true,
        },
        fallback = {
            "weapon_crowbar",
            "weapon_stunstick",
        },
    },
    ["healing"] = {
        whitelist = {
            "weapon_dz_healthshot",
            -- "item_healthkit",
            -- "item_healthvial",
            -- "tacrp_medkit",
            -- "weapon_medkit",
            -- "tfa_csgo_medishot",
        },
    },
    ["armor"] = {
        whitelist = {
            "dz_armor_kevlar_helmet",
        },
    },
    ["ammo"] = {
        whitelist = {
            "dz_ammobox",
        }
    },
    ["mobility"] = {
        whitelist = {
            "weapon_dz_bumpmine",
            "dz_pickup_exojump",
            "dz_pickup_parachute",
        }
    },

    ["explosive"] = { -- ideally only contains stuff that goes boom, that means no flashbangs, smokes or fire nades. impossible to detect though!
        filter = function(class, ent, ammocat)

            if string.find(class, "flash")
                    or string.find(class, "decoy")
                    or string.find(class, "stun")
                    or string.find(class, "smoke")
                    or string.find(class, "fire")
                    or string.find(class, "molotov")
                    or string.find(class, "incendiary")
                    or string.find(class, "gas")
                    or string.find(class, "thermite") then
                return false
            end

            if ent.ArcCW then
                return ent.Throwing
            elseif ent.IsTFAWeapon then
                return ent.IsGrenade
            elseif ent.ARC9 then
                return ent.Throwable
            elseif weapons.IsBasedOn(class, "cw_grenade_base") then
                return false-- use default list only
            elseif ent.ArcticTacRP then
                return false -- use default list only
            elseif weapons.IsBasedOn(class, "bobs_gun_base") or weapons.IsBasedOn(class, "bobs_nade_base") then
                return false -- use default list only
            elseif ent.IsSWCSWeapon then
                return false -- use default list only
            end

            return ent.Slot == 4 and (ent.HoldType == "grenade" or ent.HoldType == "slam" or ent.HoldType == "normal")
        end,
        default = {
            ------------------------------- HL:S
            "weapon_handgrenade",
            "weapon_satchel",
            "weapon_tripmine",
            ------------------------------- M9K
            "m9k_m61_frag",
            "m9k_ied_detonator",
            "m9k_nitro",
            "m9k_proxy_mine",
            "m9k_sticky_grenade",
            "m9k_nerve_gas",
            "m9k_suicide_bomb",
            ------------------------------- TacRP
            "tacrp_nade_charge",
            "tacrp_nade_frag",
            ------------------------------- SWCS
            "weapon_swcs_c4",
            "weapon_swcs_hegrenade",
            ------------------------------- CW 2.0
            "cw_frag_grenade",
            "cw_kk_ins2_nade_c4",
            "cw_kk_ins2_nade_ied",
            "cw_kk_ins2_nade_f1",
            "cw_kk_ins2_nade_m67",
            ------------------------------- TFA CSGO
            "tfa_csgo_c4",
            "tfa_csgo_frag",
        },
        blacklist = {
            ["weapon_dz_healthshot"] = true,
            ["weapon_dz_bumpmine"] = true,
            ------------------------------- ArcCW
            ["arccw_nade_flash"] = true,
            ["arccw_nade_gas"] = true,
            ["arccw_nade_flare"] = true,
            ["arccw_nade_incendiary"] = true,
            ["arccw_nade_smoke"] = true,
            ["arccw_apex_nade_nox"] = true,
            ["arccw_apex_nade_thermite"] = true,
            ------------------------------- ARC9
            ["arc9_go_nade_decoy"] = true,
            ["arc9_go_nade_flashbang"] = true,
            ["arc9_go_nade_incendiary"] = true,
            ["arc9_go_nade_molotov"] = true,
            ["arc9_go_nade_mines"] = true,
            ["arc9_go_nade_sonar"] = true,
            ["arc9_go_zeus"] = true,
            ["arc9_go_nade_rock"] = true,
            ["arc9_go_nade_smoke"] = true,
            ["arc9_fas_m84"] = true,
            ["arc9_fas_m18"] = true,
            ["arc9_fas_flare"] = true,
            ------------------------------- SWCS
            ["weapon_swcs_smokegrenade"] = true,
            ["weapon_swcs_incgrenade"] = true,
            ["weapon_swcs_flashbang"] = true,
            ["weapon_swcs_testnade"] = true,
            ------------------------------- TFA CSGO
            ["tfa_csgo_molly"] = true,
            ["tfa_csgo_incen"] = true,
        },
        fallback = {
            "weapon_frag",
            "weapon_slam",
        },
    },
    ["utility"] = { -- every throwable/placeable thing that isn't explosive. technically in csgo you can only get firebomb/diversion device, but whatever man.
        filter = function(class, ent, ammocat)

            if not (string.find(class, "flash")
                    or string.find(class, "decoy")
                    or string.find(class, "stun")
                    or string.find(class, "smoke")
                    or string.find(class, "fire")
                    or string.find(class, "molotov")
                    or string.find(class, "incendiary")
                    or string.find(class, "gas")
                    or string.find(class, "thermite")) then
                return false
            end

            if ent.ArcCW then
                return ent.Throwing
            elseif ent.IsTFAWeapon then
                return ent.IsGrenade
            elseif ent.ARC9 then
                return ent.Throwable
            elseif weapons.IsBasedOn(class, "cw_grenade_base") then
                return false-- use default list only
            elseif ent.ArcticTacRP then
                return false -- use default list only
            elseif weapons.IsBasedOn(class, "bobs_gun_base") or weapons.IsBasedOn(class, "bobs_nade_base") then
                return false -- use default list only
            elseif ent.IsSWCSWeapon then
                return false -- use default list only
            end

            return ent.Slot == 4 and (ent.HoldType == "grenade" or ent.HoldType == "slam" or ent.HoldType == "normal")
        end,
        default = {
            ------------------------------- HL:S
            "weapon_snark",
            ------------------------------- ArcCW
            "arccw_nade_flash",
            "arccw_nade_gas",
            "arccw_nade_flare",
            "arccw_nade_incendiary",
            "arccw_nade_smoke",
            "arccw_apex_nade_nox",
            "arccw_apex_nade_thermite",
            ------------------------------- ARC9
            "arc9_go_nade_decoy",
            "arc9_go_nade_flashbang",
            "arc9_go_nade_incendiary",
            "arc9_go_nade_molotov",
            "arc9_go_nade_sonar",
            "arc9_go_zeus",
            "arc9_go_nade_rock",
            "arc9_go_nade_smoke",
            "arc9_fas_m84",
            "arc9_fas_m18",
            "arc9_fas_flare",
            ------------------------------- SWCS
            "weapon_swcs_smokegrenade",
            "weapon_swcs_incgrenade",
            "weapon_swcs_flashbang",
            ------------------------------- CW 2.0
            "cw_smoke_grenade",
            "cw_flash_grenade",
            "cw_kk_ins2_nade_molotov",
            "cw_kk_ins2_nade_anm14",
            "cw_kk_ins2_nade_m18",
            "cw_kk_ins2_nade_m84",
            ------------------------------- TFA CSGO
            "tfa_csgo_molly",
            "tfa_csgo_incen",
            "tfa_csgo_sonarbomb",
        },
        blacklist = {
            ["weapon_dz_healthshot"] = true,
            ["weapon_dz_bumpmine"] = true,
        },
        fallback = {
            "weapon_physcannon",
        },
    },
    ["pistol_light"] = {
        filter = function(class, ent, ammocat)
            if ent.IsSWCSWeapon then
                return false
            end
            return ent.Slot == 1 and ammocat ~= "magnum"
        end,
        blacklist = {
            ["none"] = true, -- ???
            ["cw_g4p_customizable_knife"] = true, -- YOUR KNIFE CAN RUN OUT OF AMMO.
            ["weapon_swcs_deagle"] = true,
            ["weapon_swcs_revolver"] = true,
        },
        default = {
            ------------------------------- HL:S
            "weapon_glock_hl1",
            ------------------------------- SWCS
            "weapon_swcs_cz75",
            "weapon_swcs_elite",
            "weapon_swcs_fiveseven",
            "weapon_swcs_glock",
            "weapon_swcs_hkp2000",
            "weapon_swcs_tec9",
            "weapon_swcs_usp_silencer",
            "weapon_swcs_p250",
        },
        fallback = {
            "weapon_pistol",
        },
    },
    ["pistol_heavy"] = {
        filter = function(class, ent, ammocat)
            if ent.IsSWCSWeapon then
                return false
            end
            return ent.Slot == 1 and ammocat == "magnum"
        end,
        default = {
            ------------------------------- HL:S
            "weapon_357_hl1",
            ------------------------------- CS:GO Weapons
            "weapon_swcs_deagle",
            "weapon_swcs_revolver",
        },
        fallback = {
            "weapon_357",
        },
    },
    ["shotgun"] = {
        filter = function(class, ent, ammocat)
            if ent.ArcticTacRP then
                return ent.SubCatType == "5Shotgun"
            elseif ent.ARC9 and ent.Class then
                return ent.Class == "Shotgun" or ent.Class == "Combat Shotgun"
            elseif weapons.IsBasedOn(class, "mg_base") then
                return ent.SubCategory == "Shotguns"
            elseif ent.IsSWCSWeapon then
                return false
            end

            return (ent.Slot == 2 or ent.Slot == 3) and ammocat == "shotgun"
        end,
        default = {
            ------------------------------- HL:S
            "weapon_shotgun_hl1",
            ------------------------------- CS:GO Weapons
            "weapon_swcs_sawedoff",
            "weapon_swcs_mag7",
            "weapon_swcs_nova",
            "weapon_swcs_xm1014",
        },
        fallback = {
            "weapon_shotgun",
        },
    },
    ["smg"] = {
        filter = function(class, ent, ammocat)

            if ent.ArcticTacRP then
                return ent.SubCatType == "3Submachine Gun" or ent.SubCatType == "2Machine Pistol"
            elseif ent.ARC9 and ent.Class then
                return ent.Class == "Submachine Gun" or ent.Class == "Personal Defense Weapon" or ent.Class == "Machine Pistol"
            elseif weapons.IsBasedOn(class, "mg_base") then
                return ent.SubCategory == "Submachine Guns"
            elseif weapons.IsBasedOn(class, "bobs_gun_base") then
                return string.find(ent.Category or "", "Submachine")
            elseif ent.IsTFAWeapon then
                return ent.SMG == true or ent.Type == "Sub-Machine Gun" or (ent.Slot == 2 and (ammocat == "pistol" or ammocat == "smg"))
            elseif ent.IsSWCSWeapon then
                return false
            end

            return ent.Slot == 2 and (ammocat == "pistol" or ammocat == "smg")
        end,
        default = {
            ------------------------------- HL:S
            "weapon_mp5_hl1",
            ------------------------------- SWCS
            "weapon_swcs_mac10",
            "weapon_swcs_mp9",
            "weapon_swcs_mp7",
            "weapon_swcs_mp5sd",
            "weapon_swcs_ump45",
            "weapon_swcs_bizon",
            "weapon_swcs_p90",
        },
        fallback = {
            "weapon_smg1",
        },
    },
    ["rifle"] = {
        filter = function(class, ent, ammocat)

            if ent.ArcticTacRP then
                return ent.SubCatType == "4Assault Rifle" or ent.SubCatType == "6Precision Rifle"
            elseif ent.ARC9 and ent.Class then
                return (string.find(string.lower(ent.Class), "rifle") or string.find(string.lower(ent.Class), "carbine"))
                        and not (string.find(string.lower(ent.Class), "sniper") or string.find(string.lower(ent.Class), "marksman"))
            elseif weapons.IsBasedOn(class, "mg_base") then
                return ent.SubCategory == "Assault Rifles"
            elseif weapons.IsBasedOn(class, "bobs_gun_base") then
                return string.find(ent.Category or "", "Assault")
            elseif ent.IsTFAWeapon then
                return ent.Type == "Rifle" or (ent.Slot == 2 and ammocat == "rifle")
            elseif ent.CW20Weapon then
                -- CW2 modders love putting assault rifles in slot 4
                return (ent.Slot == 2 or ent.Slot == 3) and ammocat == "rifle"
            elseif ent.IsSWCSWeapon then
                return false
            end

            return ent.Slot == 2 and (ammocat == "smg" or ammocat == "rifle")
        end,
        default = {
            ------------------------------- HL:S
            "weapon_hornetgun",
            "weapon_gauss",
            ------------------------------- SWCS
            "weapon_swcs_ak47",
            "weapon_swcs_aug",
            "weapon_swcs_m4a1_silencer",
            "weapon_swcs_m4a1",
            -- you can't get these in airdrop in danger zone, but we don't really have another place to put it (plus this loot type is used for other crates as well)
            "weapon_swcs_sg556",
            "weapon_swcs_ssg08",
            "weapon_swcs_famas",
            "weapon_swcs_galilar",
        },
        fallback = {
            "weapon_ar2",
        },
    },
    ["sniper"] = {
        filter = function(class, ent, ammocat)

            if ent.ArcticTacRP then
                return ent.SubCatType == "7Sniper Rifle"
            elseif weapons.IsBasedOn(class, "mg_base") then
                return ent.SubCategory == "Sniper Rifles" or ent.SubCategory == "Marksman Rifles"
            elseif weapons.IsBasedOn(class, "bobs_gun_base") then
                return string.find(ent.Category or "", "Sniper")
            elseif ent.ARC9 and ent.Class then
                return string.find(string.lower(ent.Class), "sniper") or string.find(string.lower(ent.Class), "marksman")
            elseif ent.IsTFAWeapon and (ent.Type == "Sniper Rifle" or ent.Type == "Designated Marksman Rifle") then
                return true
            elseif ent.IsSWCSWeapon then
                return false
            end

            return ent.Slot == 3 and (ammocat == "rifle" or ammocat == "sniper")
        end,
        default = {
            ------------------------------- HL:S
            "weapon_crossbow_hl1",
            ------------------------------- SWCS
            "weapon_swcs_scar20",
            "weapon_swcs_g3sg1",
            "weapon_swcs_awp",
        },
        fallback = {
            "weapon_crossbow",
        },
    },
    ["machinegun"] = {
        filter = function(class, ent, ammocat)

            if ent.ArcticTacRP then
                return ent.SubCatType == "4Machine Gun"
            elseif ent.ARC9 and ent.Class then
                return string.find(string.lower(ent.Class), "machine gun") and not string.find(string.lower(ent.Class), "sub")
            elseif weapons.IsBasedOn(class, "mg_base") then
                return ent.SubCategory == "Lightmachine Guns" or ent.SubCategory == "Machine Guns"
            elseif weapons.IsBasedOn(class, "bobs_gun_base") then
                return string.find(ent.Category or "", "Machine Guns")
            elseif ent.IsTFAWeapon then
                return ent.Type == "Machine Gun" or (ent.Slot == 3 and ammocat == "rifle")
            elseif ent.CW20Weapon then
                -- CW2 modders love putting assault rifles in slot 4
                return ent.Slot == 3 and ammocat == "rifle"
            elseif ent.IsSWCSWeapon then
                return false
            end

            return ent.Slot == 3 and (ammocat == "smg" or ammocat == "rifle")
        end,
        default = {
            ------------------------------- HL:S
            "weapon_egon",
            "weapon_rpg_hl1", -- uhh
            ------------------------------- SWCS
            "weapon_swcs_negev",
            "weapon_swcs_m249",
        },
        fallback = {
            "weapon_rpg", -- well...
        },
    },
}

DZ_ENTS.CrateContents = {
    ["dz_case_tool"] = {
        ["utility"] = 7,
        ["melee"] = 6,
        ["armor"] = 2,
        ["healing"] = 1,
    },
    ["dz_case_tool_heavy"] = {
        ["ammo"] = 5,
        ["mobility"] = 5,
        ["healing"] = 3,
        ["explosive"] = 3,
        ["armor"] = 2,
    },
    ["dz_case_explosive"] = "explosive",
    ["dz_case_pistol"] = "pistol_light",
    ["dz_case_pistol_heavy"] = "pistol_heavy",
    ["dz_case_light_weapon"] = "smg",
    ["dz_case_heavy_weapon"] = "shotgun",
    ["dz_case_random_drop"] = {
        ["rifle"] = 3,
        ["sniper"] = 1,
    },
    ["dz_case_respawn"] = {
        ["rifle"] = 3,
        ["machinegun"] = 2,
        ["sniper"] = 1,
    },
}
DZ_ENTS.CrateContentWeight = {}
for class, tbl in pairs(DZ_ENTS.CrateContents) do
    if not istable(tbl) then continue end
    local w = 0
    for k, v in pairs(tbl) do
        w = w + v
    end
    DZ_ENTS.CrateContentWeight[class] = w
end

DZ_ENTS.LootTypeList = {}
DZ_ENTS.LootTypeListLookup = {}

function DZ_ENTS:GetLootType(loot_type)
    local lt = DZ_ENTS.LootTypes[loot_type]
    if not lt then return {} end
    if not DZ_ENTS.LootTypeList[loot_type] then

        if SERVER and DZ_ENTS.ConVars["case_userdef"]:GetBool() and (not DZ_ENTS.UserDefLists["case_category"] or #DZ_ENTS.UserDefLists["case_category"] == 0) then
            PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] Empty whitelist detected. Turning off whitelist to ensure normal spawning.")
            DZ_ENTS.ConVars["case_userdef"]:SetBool(false)
        end

        DZ_ENTS.LootTypeList[loot_type] = {}
        DZ_ENTS.LootTypeListLookup[loot_type] = {}

        -- Whitelisted entries are guaranteed to exist and always will be added, ignoring userdef whitelist.
        for _, class in ipairs(lt.whitelist or {}) do
            table.insert(DZ_ENTS.LootTypeList[loot_type], class)
            DZ_ENTS.LootTypeListLookup[loot_type][class] = true
        end

        -- Add default entities if they exist
        for _, class in ipairs(lt.default or {}) do
            local tbl = weapons.Get(class)
            if not tbl then
                tbl = scripted_ents.Get(class)
            end
            if tbl and (not DZ_ENTS.ConVars["case_userdef"]:GetBool() or (DZ_ENTS.UserDefListsDict["case_category"] and DZ_ENTS.UserDefListsDict["case_category"][tbl.Category])) then
                table.insert(DZ_ENTS.LootTypeList[loot_type], class)
                DZ_ENTS.LootTypeListLookup[loot_type][class] = true
            end
        end

        -- Try to put fallback entities in as long as they match category filter
        for _, class in ipairs(lt.fallback or {}) do
            local tbl = weapons.Get(class)
            if tbl and (not DZ_ENTS.ConVars["case_userdef"]:GetBool() or (DZ_ENTS.UserDefListsDict["case_category"] and DZ_ENTS.UserDefListsDict["case_category"][tbl.Category])) then
                table.insert(DZ_ENTS.LootTypeList[loot_type], class)
                DZ_ENTS.LootTypeListLookup[loot_type][class] = true
            end
        end

        -- Attempt to dynamically include guns and entities
        local blacklist = lt.blacklist or {}

        if lt.filter then
            for _, v in pairs(list.Get("Weapon")) do
                local tbl = weapons.Get(v.ClassName) -- this includes inherited values
                local ammocat = tbl and DZ_ENTS:GetWeaponAmmoCategory((tbl.Primary.Ammo ~= "") and tbl.Primary.Ammo or tbl.Ammo or "")
                if tbl and not DZ_ENTS.LootTypeListLookup[loot_type][v.ClassName]
                        and (not DZ_ENTS.ConVars["case_userdef"]:GetBool() or (DZ_ENTS.UserDefListsDict["case_category"] and DZ_ENTS.UserDefListsDict["case_category"][tbl.Category]))
                        and not blacklist[v.ClassName]
                        and tbl.Spawnable and not tbl.AdminOnly
                        and ((istable(tbl.DZ_LootTypes) and tbl.DZ_LootTypes[loot_type])
                            or lt.filter(v.ClassName, tbl, ammocat)) then
                    table.insert(DZ_ENTS.LootTypeList[loot_type], v.ClassName)
                    DZ_ENTS.LootTypeListLookup[loot_type][v.ClassName] = true
                end
            end
        end
        if lt.filter_ent then
            for _, v in pairs(list.Get("SpawnableEntities")) do
                local tbl = scripted_ents.Get(v.ClassName)
                if tbl and not DZ_ENTS.LootTypeListLookup[loot_type][v.ClassName]
                        and not blacklist[v.ClassName]
                        and not tbl.AdminOnly
                        and ((istable(tbl.DZ_LootTypes) and tbl.DZ_LootTypes[loot_type])
                            or lt.filter_ent(v.ClassName, tbl)) then
                    table.insert(DZ_ENTS.LootTypeList[loot_type], v.ClassName)
                    DZ_ENTS.LootTypeListLookup[loot_type][v.ClassName] = true
                end
            end
        end

        -- Should not run into this ever again...
        if table.Count(DZ_ENTS.LootTypeList[loot_type]) == 0 then
            PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] Could not find a weapon of type '" .. loot_type .. "' matching the current whitelist.")
            PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] Go to Utilities -> Danger Zone -> Server - Cases and add more categories to your whitelist!")
            for _, class in ipairs(lt.fallback or {}) do
                table.insert(DZ_ENTS.LootTypeList[loot_type], class)
                DZ_ENTS.LootTypeListLookup[loot_type][class] = true
            end
        end

        if GetConVar("developer"):GetInt() > 0 then
            print("generated list for loot type " .. loot_type)
            PrintTable(DZ_ENTS.LootTypeList[loot_type])
        end
    end

    return DZ_ENTS.LootTypeList[loot_type]
end

-- have to delay it because we need to wait for weapon/ent tables to load
if SERVER then
    hook.Add("InitPostEntity", "dz_ents_initloottypes", function()
        for loot_type, _ in pairs(DZ_ENTS.LootTypes) do
            DZ_ENTS:GetLootType(loot_type)
        end
    end)
    concommand.Add("dzents_debug_loadall", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        DZ_ENTS.LootTypeList = {}
        DZ_ENTS.LootTypeListLookup = {}
        for loot_type, _ in pairs(DZ_ENTS.LootTypes) do
            DZ_ENTS:GetLootType(loot_type)
        end
    end)
end

function DZ_ENTS:GetCrateDrop(crate_class)

    if DZ_ENTS.InUserDefList("case_whitelisted", crate_class) then
        if DZ_ENTS.CountUserDefList(crate_class) > 0 then
            local tbl = DZ_ENTS.UserDefLists[crate_class]
            return tbl[math.random(1, #tbl)]
        else
            local printname = scripted_ents.Get(crate_class).PrintName or crate_class
            PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] " .. printname .. " has Custom Drops enabled but no entries set. Disabling.")
            DZ_ENTS.RemoveFromUserDefList("case_whitelisted", crate_class)
        end
    end

    local loot_type = DZ_ENTS.CrateContents[crate_class]
    if istable(DZ_ENTS.CrateContents[crate_class]) then
        local rng = math.random() * DZ_ENTS.CrateContentWeight[crate_class]
        for k, v in pairs(DZ_ENTS.CrateContents[crate_class]) do
            rng = rng - v
            if rng <= 0 then
                loot_type = k
                break
            end
        end
    end

    if not isstring(loot_type) then
        error("Failed to roll for loot in " .. tostring(crate_class) .. "!")
    end

    local tbl = DZ_ENTS:GetLootType(loot_type)
    if not istable(tbl) or tbl == {} then
        error("Failed to get entity from loot type " .. tostring(loot_type) .. "!")
    end

    return tbl[math.random(1, #tbl)]
end