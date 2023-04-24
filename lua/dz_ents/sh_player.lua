local PLAYER = FindMetaTable("Player")

-- one type of armor (enum)
DZ_ENTS_ARMOR_NONE = 0
DZ_ENTS_ARMOR_KEVLAR = 1
DZ_ENTS_ARMOR_HEAVY_CT = 2
DZ_ENTS_ARMOR_HEAVY_T = 3

-- any number of equips (bitflag)
DZ_ENTS_EQUIP_NONE = 0
DZ_ENTS_EQUIP_PARACHUTE = 1
DZ_ENTS_EQUIP_EXOJUMP = 2

function PLAYER:DZ_ENTS_HasHelmet()
    return self:GetNWBool("DZ_Ents.Helmet", false)
end

function PLAYER:DZ_ENTS_GiveHelmet()
    if swcs then
        self:GiveHelmet()
    end
    self:SetNWBool("DZ_Ents.Helmet", true)
end

function PLAYER:DZ_ENTS_RemoveHelmet(drop)
    if drop and self:DZ_ENTS_HasHelmet() and self:DZ_ENTS_GetArmor() <= DZ_ENTS_ARMOR_KEVLAR and (self:Armor() > 0 or self.PendingArmor > 0) then
        local ent = ents.Create("dz_armor_helmet")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 64)
            ent:MarkForRemove()
        end
    end

    if swcs then
        self:RemoveHelmet()
    end
    self:SetNWBool("DZ_Ents.Helmet", false)
end

function PLAYER:DZ_ENTS_GetArmor()
    return self:GetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE)
end

function PLAYER:DZ_ENTS_HasArmor()
    return self:DZ_ENTS_GetArmor() ~= DZ_ENTS_ARMOR_NONE
end

function PLAYER:DZ_ENTS_HasHeavyArmor()
    return self:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_HEAVY_CT or self:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_HEAVY_T
end

function PLAYER:DZ_ENTS_SetArmor(armor)
    self:SetNWInt("DZ_Ents.Armor", armor)
end

function PLAYER:DZ_ENTS_RemoveArmor(drop)
    if drop and self:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_KEVLAR and (self:Armor() > 0 or  (self.PendingArmor or 0) > 0) then
        local ent = ents.Create("dz_armor_kevlar")
        if IsValid(ent) then
            ent.GiveArmor = math.min((self.PendingArmor or 0) or self:Armor(), 100)
            ent:SetPos(self:GetPos() + Vector(0, 0, 48))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 64)
            ent:MarkForRemove()
        end
    end
    self:SetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE)
end

function PLAYER:DZ_ENTS_GetEquipment()
    return self:GetNWInt("DZ_Ents.Equipment", DZ_ENTS_EQUIP_NONE)
end

function PLAYER:DZ_ENTS_HasEquipment(equip)
    return bit.band(self:DZ_ENTS_GetEquipment(), equip) == equip
end

function PLAYER:DZ_ENTS_SetEquipment(equip)
    self:SetNWInt("DZ_Ents.Equipment", equip)
end

function PLAYER:DZ_ENTS_GiveEquipment(equip)
    self:DZ_ENTS_SetEquipment(bit.bor(self:DZ_ENTS_GetEquipment(), equip))
end

function PLAYER:DZ_ENTS_RemoveEquipment(drop, equip)
    local dropped = nil
    if equip then
        dropped = equip
        self:DZ_ENTS_SetEquipment(bit.band(self:DZ_ENTS_GetEquipment(), bit.bnot(equip)))
    else
        dropped = self:DZ_ENTS_GetEquipment()
        self:DZ_ENTS_SetEquipment(DZ_ENTS_EQUIP_NONE)
    end

    if drop and bit.band(dropped, DZ_ENTS_EQUIP_PARACHUTE) ~= 0 then
        local ent = ents.Create("dz_pickup_parachute")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 40))
            local ang = self:GetAngles()
            ang:RotateAroundAxis(ang:Right(), 90)
            ent:SetAngles(ang)
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 96)
            ent:MarkForRemove()
        end
    end
    if drop and bit.band(dropped, DZ_ENTS_EQUIP_EXOJUMP) ~= 0 then
        local ent = ents.Create("dz_pickup_exojump")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 20))
            local ang = self:GetAngles()
            ang:RotateAroundAxis(ang:Forward(), 90)
            ent:SetAngles(ang)
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 96)
            ent:MarkForRemove()
        end
    end
end

local armorregions = {
    [HITGROUP_GENERIC] = true, -- blast damage etc.
    [HITGROUP_GEAR] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
    [HITGROUP_LEFTARM] = true,
    [HITGROUP_RIGHTARM] = true,
}
-- Does not check for armor value... do that in the hook
function PLAYER:DZ_ENTS_IsArmoredHitGroup(hitgroup)
    local uselogic = GetConVar("dzents_armor_enabled"):GetInt()
    if uselogic == 0 then return false end

    return self:DZ_ENTS_HasHeavyArmor() -- heavy armor covers all regions
            or (hitgroup == HITGROUP_HEAD and (uselogic == 2 or self:DZ_ENTS_HasHelmet())) -- if hit head, check helmet
            or (armorregions[hitgroup] and (uselogic == 2 or self:DZ_ENTS_HasArmor())) -- otherwise check armored regions
end

function PLAYER:DZ_ENTS_ApplyHeavyArmorModel(armor)
    if not GetConVar("dzents_armor_heavy_playermodel"):GetBool() or (armor ~= DZ_ENTS_ARMOR_HEAVY_CT and armor ~= DZ_ENTS_ARMOR_HEAVY_T) then return end

    self.DZ_ENTS_OldPlayerModel = {self:GetModel(), self:GetSkin(), {}}
    for k, v in pairs(self:GetBodyGroups()) do
        self.DZ_ENTS_OldPlayerModel[3][v.id] = self:GetBodygroup(v.id)
    end
    if armor == DZ_ENTS_ARMOR_HEAVY_CT then
        self:SetModel("models/arachnit/csgo/ctm_heavy/ctm_heavy_player.mdl")
        local hands = self:GetHands()
        hands:SetModel("models/arachnit/csgo/weapons/c_arms_ctm_heavy.mdl")
    elseif armor == DZ_ENTS_ARMOR_HEAVY_T then
        self:SetModel("models/arachnit/csgoheavyphoenix/tm_phoenix_heavyplayer.mdl")
        local hands = self:GetHands()
        hands:SetModel("models/arachnit/csgoheavyphoenix/c_arms/c_arms_tm_heavy.mdl")
    end
    self:SetSkin(GetConVar("dzents_armor_heavy_playermodel_skin"):GetBool() and math.random(1, self:SkinCount()) or 0)
    self:SetBodyGroups("00000000")
end

-- DoPlayerDeath happens _before_ PostEntityTakeDamage, so Armor is 0 for purposes of damage calc.
hook.Add("DoPlayerDeath", "dz_ents_player", function(ply)
    local drop = GetConVar("dzents_drop_armor"):GetBool() and (ply:Armor() > 0 or (ply.PendingArmor or 0) > 0) and not ply:DZ_ENTS_HasHeavyArmor()
    local dropequip = GetConVar("dzents_drop_equip"):GetBool()
    ply:DZ_ENTS_RemoveHelmet(drop)
    ply:DZ_ENTS_RemoveArmor(drop)
    ply:DZ_ENTS_RemoveEquipment(dropequip)
    ply:SetNWFloat("DZ_Ents.Healthshot", 0)

    ply.DZENTS_BumpMine_Launched = nil
    ply.DZENTS_BumpMine_LaunchTime = nil
    ply.DZENTS_BumpMine_Attacker = nil
end)

hook.Add("PlayerLoadout", "dz_ents_player", function(ply)
    ply.DZ_ENTS_OriginalSpeed = nil
    ply.DZ_ENTS_OldPlayerModel = nil
    ply.DZENTS_Robert = nil
    timer.Simple(0, function()
        local give = GetConVar("dzents_armor_onspawn"):GetInt()
        if give == 3 then
            local armor = math.random() <= 0.5 and DZ_ENTS_ARMOR_HEAVY_CT or DZ_ENTS_ARMOR_HEAVY_T
            ply:DZ_ENTS_GiveHelmet() -- here for formality even though heavy armor protects all hitgroups (SWCS hit effects)
            ply:DZ_ENTS_SetArmor(armor)
            ply:SetArmor(200)
            ply:SetMaxArmor(200)
            ply:DZ_ENTS_ApplyHeavyArmorModel(armor)
            -- local speed = GetConVar("dzents_armor_heavy_speed"):GetInt()
            -- if speed > 0 then
            --     ply.DZ_ENTS_OriginalSpeed = {ply:GetSlowWalkSpeed(), ply:GetWalkSpeed(), ply:GetRunSpeed()}
            --     ply:SetSlowWalkSpeed(math.min(ply:GetSlowWalkSpeed(), speed))
            --     ply:SetWalkSpeed(speed)
            --     ply:SetRunSpeed(speed * 2)
            -- end
        else
            if give >= 1 then
                ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
                ply:SetArmor(100)
                ply:SetMaxArmor(100)
            end
            if give >= 2 then
                ply:DZ_ENTS_GiveHelmet()
            end
        end

        local giveequip = 0
        if GetConVar("dzents_parachute_onspawn"):GetBool() then
            giveequip = giveequip + DZ_ENTS_EQUIP_PARACHUTE
        end
        if GetConVar("dzents_exojump_onspawn"):GetBool() then
            giveequip = giveequip + DZ_ENTS_EQUIP_EXOJUMP
        end
        if giveequip > 0 then
            ply:DZ_ENTS_GiveEquipment(giveequip)
        end
    end)
end)

DZ_ENTS.HeavyArmorWeaponCache = {}
function DZ_ENTS.HeavyArmorCanPickup(class, mode)
    mode = mode or GetConVar("dzents_armor_heavy_norifle"):GetInt()
    if mode == 0 then
        return true
    end
    local canontbl = DZ_ENTS.CanonicalWeapons[DZ_ENTS:GetCanonicalClass(class)]
    if canontbl and canontbl.Category == "Rifle" then
        return false
    end
    if not canontbl and mode == 2 then
        if DZ_ENTS.HeavyArmorWeaponCache[class] == nil then
            local tbl = weapons.Get(class)
            local ammocat = tbl and DZ_ENTS:GetWeaponAmmoCategory((tbl.Primary.Ammo ~= "") and tbl.Primary.Ammo or tbl.Ammo or "")
            if not tbl then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(class == "weapon_ar2" or class == "weapon_crossbow")
            elseif tbl.ArcticTacRP then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.SubCatType or ""), "rifle"))
            elseif tbl.ARC9 and tbl.Class then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.Class), "rifle") or string.find(string.lower(tbl.Class), "carbine"))
            elseif weapons.IsBasedOn(class, "mg_base") then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.SubCategory), "rifle"))
            elseif weapons.IsBasedOn(class, "bobs_gun_base") then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.Category or ""), "rifle"))
            elseif tbl.IsTFAWeapon then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(tbl.Type == "Rifle" or (tbl.Slot == 2 and ammocat == "rifle"))
            elseif tbl.CW20Weapon then
                -- CW2 modders love putting assault rifles in slot 4
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool((tbl.Slot == 2 or tbl.Slot == 3) and ammocat == "rifle")
            else
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(tbl.Slot == 2 and (ammocat == "smg" or ammocat == "rifle"))
            end
        end
        if DZ_ENTS.HeavyArmorWeaponCache[class] == true then return false end
    end
    return true
end
if SERVER then
    concommand.Add("dzents_debug_riflecheck", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        for _, tbl in pairs(weapons.GetList()) do
            local rifle = not DZ_ENTS.HeavyArmorCanPickup(tbl.ClassName, 2)
            if rifle then print(tbl.ClassName) end
        end
    end)
end

hook.Add("PlayerSwitchWeapon", "dz_ents_player", function(ply, oldwep, wep)
    if ply:DZ_ENTS_HasHeavyArmor() then
        local class = wep:GetClass()
        if not DZ_ENTS.HeavyArmorCanPickup(class) then
            if SERVER then
                DZ_ENTS:Hint(ply, 15)
                ply:DropWeapon(wep)
            end
            return true
        elseif GetConVar("dzents_armor_heavy_deployspeed"):GetFloat() < 1 then
            local speed = GetConVar("dzents_armor_heavy_deployspeed"):GetFloat()
            if weapons.IsBasedOn(class, "mg_base") then
                -- EWWWWWWWWWWWWWWWWWW
                -- mw base doesn't have cool live stats like arccw so we'll have to do this the ugly way
                local oldfps = wep.Animations.Draw.Fps
                wep.Animations.Draw.Fps = wep.Animations.Draw.Fps * speed
                timer.Simple(0, function()
                    if IsValid(wep) then wep.Animations.Draw.Fps = oldfps end
                end)
            elseif wep.CW20Weapon then
                local olddsm = wep.DrawSpeedMult
                wep.DrawSpeedMult = wep.DrawSpeedMult * speed
                wep:recalculateDeployTime()
                timer.Simple(0, function()
                    if IsValid(wep) then
                        wep.DrawSpeedMult = olddsm
                        wep:recalculateDeployTime()
                    end
                end)
            end
        end
    end
end)

hook.Add("PlayerGiveSWEP", "dz_ents_player", function(ply, class, swep)
    if ply:DZ_ENTS_HasHeavyArmor() and not DZ_ENTS.HeavyArmorCanPickup(class) then
        if SERVER then
            DZ_ENTS:Hint(ply, 15)
        end
        return false
    end
end)

hook.Add("PlayerCanPickupWeapon", "dz_ents_player", function(ply, wep)
    if ply:DZ_ENTS_HasHeavyArmor() and not DZ_ENTS.HeavyArmorCanPickup(wep:GetClass()) then
        -- if SERVER then
        --     DZ_ENTS:Hint(ply, 15)
        -- end
        return false
    end

    if (wep.DZENTS_Pickup or 0) > CurTime() then return false end
end)


-- Simulate armor calculation
-- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/server/player.cpp#L1061
local function calcarmor(dmginfo, armor, flBonus, flRatio, fHeavyArmorBonus)
    local old = GetConVar("player_old_armor"):GetBool()
    if not flBonus then
        flBonus = old and 0.5 or 1
    end
    flRatio = flRatio or 0.2

    local dmg = dmginfo:GetDamage()
    if dmginfo:IsDamageType(DMG_BLAST) and not game.SinglePlayer() then
        flBonus = flBonus * 2
    end
    if armor > 0 then
        local flNew = dmg * flRatio
        local flArmor = (dmg - flNew) * flBonus * fHeavyArmorBonus

        if not old and flArmor == 0 then
            flArmor = 1
            -- flArmor = math.max(1, flArmor)
        end

        if flArmor > armor then
            flArmor = armor * (1 / flBonus)
            flNew = dmg - flArmor
            -- m_DmgSave = armor -- ?
            armor = 0
        else
            -- m_DmgSave = flArmor
            armor = math.max(0, armor - flArmor)
        end

        dmg = flNew
    end
    return dmg, armor
end

local bitflags_blockable = DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST
local bitflags_nohitgroup = DMG_FALL + DMG_BLAST + DMG_RADIATION + DMG_CRUSH + DMG_DROWN + DMG_POISON

--[[]
hook.Add("ScalePlayerDamage", "dz_ents_player", function(ply, hitgroup, dmginfo)
    local uselogic = GetConVar("dzents_armor_enabled"):GetInt()

    -- Block the blood effects on a headshot
    if CLIENT and ply:Armor() > 0 and (uselogic >= 2 or uselogic == 1 and ply:DZ_ENTS_HasArmor())
            and bit.band(dmginfo:GetDamageType(), bitflags_nohitgroup) == 0
            and bit.band(dmginfo:GetDamageType(), bitflags_blockable) ~= 0
            and ((GetConVar("dzents_armor_eff_head"):GetBool() and hitgroup == HITGROUP_HEAD)
            or (GetConVar("dzents_armor_eff_body"):GetBool() and armorregions[hitgroup])) then
        return true
    end
end)
]]

hook.Add("EntityTakeDamage", "ZZZZZ_dz_ents_damage", function(ply, dmginfo)

    if ply:GetNWFloat("DZ_Ents.Healthshot", 0) > CurTime() then
        dmginfo:ScaleDamage(GetConVar("dzents_healthshot_damage_taken"):GetFloat())
    end

    if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():GetNWFloat("DZ_Ents.Healthshot", 0) > CurTime() then
        dmginfo:ScaleDamage(GetConVar("dzents_healthshot_damage_dealt"):GetFloat())
    end

    if not ply:IsPlayer() then return end

    if dmginfo:IsFallDamage() then

        -- Nasty. Do it late here and with a hard-coded fall damage check in case some other addon is doing their own fall damage thing.
        -- Don't want to mess with hook loading orders now, do we?
        if not GetConVar("mp_falldamage"):GetBool() and dmginfo:GetDamage() == 10 and (
            (ply:DZ_ENTS_HasHeavyArmor() and GetConVar("dzents_armor_heavy_falldamage"):GetBool())
            or (ply.DZENTS_BumpMine_Launched and GetConVar("dzents_bumpmine_damage_fall"):GetFloat() > 0)) then
            -- SDK2013 damage calc. gets pretty close, the difference is probably related to velocity being a tick off or whatever
            dmginfo:SetDamage(math.max(math.abs(ply:GetVelocity().z) - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED, 0) * DZ_ENTS.DAMAGE_FOR_FALL_SPEED)
        end

        -- goomba stomp
        local groundent = ply:GetGroundEntity()
        if ply:DZ_ENTS_HasHeavyArmor() and GetConVar("dzents_armor_heavy_fallstomp"):GetBool() and IsValid(groundent) then
            local dmg = dmginfo:GetDamage()
            timer.Simple(0, function() -- can't do it immediately (creating new DamageInfo overrides our current one)
                if not IsValid(groundent) then return end
                local dmg2 = DamageInfo()
                dmg2:SetDamage(dmg * 3)
                dmg2:SetDamageForce(Vector(0, 0, dmg * -1000))
                dmg2:SetDamagePosition(ply:GetPos())
                dmg2:SetDamageType(DMG_CRUSH + DMG_NEVERGIB)
                dmg2:SetAttacker(ply)
                dmg2:SetInflictor(ply)
                groundent:TakeDamageInfo(dmg2)
            end)
            if groundent:IsPlayer() or groundent:IsNPC() or groundent:IsNextBot() then
                -- cushion some damage for ourselves
                dmginfo:SetDamage(dmginfo:GetDamage() - math.min(groundent:Health(), dmg * 0.5))
                groundent:EmitSound("dz_ents/mantreads.wav", 80)
            end
        end

        -- exojump reduces fall damage
        if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then
            dmginfo:ScaleDamage(GetConVar("dzents_exojump_falldamage"):GetFloat())
        end

        -- bump mine launch damage multiplier
        if (ply.DZENTS_BumpMine_Launched and GetConVar("dzents_bumpmine_damage_fall"):GetFloat() > 0) then
            dmginfo:ScaleDamage(GetConVar("dzents_bumpmine_damage_fall"):GetFloat())
        end

        -- attribute this fall damage to whoever launched us with the bump mine
        if IsValid(ply.DZENTS_BumpMine_Attacker) then
            dmginfo:SetAttacker(ply.DZENTS_BumpMine_Attacker)
        end

        -- armor can't handle fall damage!
        return
    end

    -- Check the hitgroup of the damage. Certain damage types should not have hitgroups so strip hitgroup if that's the case.
    local hitgroup = ply:LastHitGroup()
    if bit.band(dmginfo:GetDamageType(), bitflags_nohitgroup) ~= 0 or (dmginfo:GetDamageType() == DMG_CLUB and dmginfo:GetDamageCustom() == 67) then
        hitgroup = HITGROUP_GENERIC
        ply:SetLastHitGroup(hitgroup)
    end

    local uselogic = GetConVar("dzents_armor_enabled"):GetInt()

    if ply:DZ_ENTS_HasHeavyArmor() then
        dmginfo:ScaleDamage(GetConVar("dzents_armor_heavy_damage"):GetFloat())
    elseif ply:DZ_ENTS_HasArmor() then
        dmginfo:ScaleDamage(GetConVar("dzents_armor_damage"):GetFloat())
    end

    if uselogic > 0 and (ply:DZ_ENTS_HasArmor() or ply:DZ_ENTS_HasHelmet()) then
        local blockable = bit.band(dmginfo:GetDamageType(), bitflags_blockable) ~= 0
        local armored = ply:DZ_ENTS_IsArmoredHitGroup(hitgroup)
        local wep = dmginfo:GetInflictor()
        if wep:IsPlayer() then wep = wep:GetActiveWeapon() end
        local class = IsValid(wep) and wep:GetClass() or ""

        -- affects how much armor is reduced from damage
        local armorbonus = 0.5
        -- affects what fraction of damage is converted to armor damage (1 means none)
        local armorratio = 0.5
        -- Additional multiplier onto armor damage if wearing heavy armor
        local heavyarmorbonus = 1

        -- This value matches the wiki damage tables and the source code leak.
        -- However it doesn't appear to match current build CSGO.
        -- Valve must've changed how heavy armor works for Coop Strike.
        -- I don't have the code so I'm not gonna try to replicate it.
        if ply:DZ_ENTS_HasHeavyArmor() then
            armorratio = armorratio * 0.5
            armorbonus = 0.33
            heavyarmorbonus = 0.33 * GetConVar("dzents_armor_heavy_durability"):GetFloat()

            if hitgroup == HITGROUP_HEAD then
                dmginfo:ScaleDamage(0.5) -- csgo does it, so do we
            end
        elseif ply:DZ_ENTS_HasArmor() then
            armorbonus = armorbonus * GetConVar("dzents_armor_durability"):GetFloat()
        end

        -- print("Dealing " .. dmginfo:GetDamage() .. " to " .. tostring(ply) .. " (hp: " .. ply:Health() .. ", armor:" .. ply:Armor() .. ")")
        -- print("Armored: " .. tostring(armored) .. "; Blockable: " .. tostring(blockable))

        if armored and blockable then -- Blockable damage is hitting a protected part. Do our job!
            local ap = hook.Run("dz_ents_armorpenetration", ply, dmginfo, wep) -- penetration value. 1 means fully penetrate, 0 means no penetration
            local ab = hook.Run("dz_ents_armorbonus", ply, dmginfo, wep) or 1
            if ap then
                ap = math.Clamp(ap, 0, 1)
            elseif DZ_ENTS:GetCanonicalClass(class) then
                ap = DZ_ENTS.CanonicalWeapons[DZ_ENTS:GetCanonicalClass(class)].ArmorPenetration
            else
                -- Fallback AP value based on ammo category if possible
                local ammocat = DZ_ENTS:GetWeaponAmmoCategory(game.GetAmmoName(wep:IsWeapon() and wep:GetPrimaryAmmoType() or -1) or "")

                if ammocat then
                    ap = DZ_ENTS.AmmoTypeAP[ammocat]
                else
                    ap = 0.5
                end
            end

            -- print(armorratio, armorbonus, heavyarmorbonus)
            -- print(tostring(wep) .. ": " .. ap .. " armor pen")

            local healthdmg, newarmor = calcarmor(dmginfo, ply:Armor(), armorbonus * ab, armorratio * ap * 2, heavyarmorbonus)
            -- print("WANT", ply:Health() - healthdmg, newarmor, "(" .. healthdmg .. " dmg, " .. (ply:Armor() - newarmor) .. " armor)")
            ply.PendingArmor = newarmor
            ply.DZENTS_ArmorHit = hitgroup ~= HITGROUP_GENERIC
            ply:SetArmor(0) -- don't let engine do armor calculation
            dmginfo:SetDamage(healthdmg)
        elseif armored and not dmginfo:IsDamageType(DMG_SHOCK) then -- Damage is not blockable, but is hitting an armored part. Still do armor reduction, but don't use AP
            local healthdmg, newarmor = calcarmor(dmginfo, ply:Armor(), armorbonus, armorratio, heavyarmorbonus)
            ply.PendingArmor = newarmor
            ply:SetArmor(0)
            dmginfo:SetDamage(healthdmg)
        elseif dmginfo:IsDamageType(DMG_SHOCK) or not GetConVar("dzents_armor_fallback"):GetBool() then
            -- If fallback is on, use HL2 logic. Otherwise we are unprotected
            -- Also, Zeus ignores armor so do it like this
            ply.PendingArmor = ply:Armor()
            ply:SetArmor(0)
        end
    end
end)

hook.Add("PostEntityTakeDamage", "ZZZZZ_dz_ents_damage", function(ply, dmginfo, took)
    if not ply:IsPlayer() or GetConVar("dzents_armor_enabled"):GetInt() == 0 then return end
    if ply.PendingArmor then
        local amt = ply.PendingArmor
        ply:SetArmor(amt)
        -- timer.Simple(0, function() ply:SetArmor(amt) end) -- ?
    end

    local shooter = dmginfo:GetAttacker()
    local hitgroup = ply:LastHitGroup()
    local snd = nil
    if ply.DZENTS_ArmorHit then
        if hitgroup == HITGROUP_HEAD then
            --ply:EmitSound("dz_ents/bhit_helmet-1.wav")
            snd = "dz_ents/bhit_helmet-1.wav"
            if GetConVar("dzents_armor_eff_head"):GetBool() then
                local eff = EffectData()
                eff:SetOrigin(dmginfo:GetDamagePosition())
                eff:SetNormal((dmginfo:GetDamageForce() * -1):GetNormalized())
                util.Effect("MetalSpark", eff)
            end
        elseif armorregions[hitgroup] or ply:DZ_ENTS_HasHeavyArmor() then
            -- ply:EmitSound("dz_ents/kevlar" .. math.random(1, 5) .. ".wav")
            snd = "dz_ents/kevlar" .. math.random(1, 5) .. ".wav"
            if GetConVar("dzents_armor_eff_heavy"):GetBool() and ply:DZ_ENTS_HasHeavyArmor() then
                local eff = EffectData()
                eff:SetOrigin(dmginfo:GetDamagePosition())
                eff:SetNormal((dmginfo:GetDamageForce() * -1):GetNormalized())
                util.Effect("StunstickImpact", eff)
            end
        end
    elseif hitgroup == HITGROUP_HEAD then
        -- ply:EmitSound("dz_ents/headshot" .. math.random(1, 2) .. ".wav")
        snd = "dz_ents/headshot" .. math.random(1, 2) .. ".wav"
    end

    if snd then
        if shooter:IsPlayer() then
            local filter = RecipientFilter()
            filter:AddPAS(ply:GetPos())
            filter:RemovePlayer(shooter)
            local snd1 = CreateSound(ply, snd, filter)
            snd1:SetSoundLevel(75)
            snd1:PlayEx(0.75, 100)

            if shooter:IsPlayer() then
                local filter2 = RecipientFilter()
                filter2:AddPlayer(shooter)
                local snd2 = CreateSound(shooter, snd, filter2)
                snd2:PlayEx(shooter:GetInfoNum("cl_dzents_volume_hit", 0.75), 100)
            end
        else
            ply:EmitSound(snd, 75, 100, 0.75)
        end
    end

    ply.PendingArmor = nil
    ply.DZENTS_ArmorHit = nil

    -- print("POST", ply:Health(), ply:Armor(), took)

    -- Let's make fall damage hurt heavy armor... for funsies.
    if dmginfo:IsFallDamage() and ply:DZ_ENTS_HasHeavyArmor() then
        ply:SetArmor(math.max(0, ply:Armor() - dmginfo:GetDamage() * GetConVar("dzents_armor_heavy_durability"):GetFloat()))
    end

    -- If armor value hits zero, we will lose our armor and helmet
    if ply:Alive() and ply:Armor() <= 0 then
        if ply:DZ_ENTS_HasHeavyArmor() then
            -- break if convar allows, otherwise do nothing
            if GetConVar("dzents_armor_heavy_break"):GetBool() then
                ply:DZ_ENTS_RemoveHelmet()
                ply:DZ_ENTS_RemoveArmor()

                if ply.DZ_ENTS_OldPlayerModel then
                    ply:SetModel(ply.DZ_ENTS_OldPlayerModel[1])
                    ply:SetSkin(ply.DZ_ENTS_OldPlayerModel[2])
                    for k, v in pairs(ply.DZ_ENTS_OldPlayerModel[3]) do
                        ply:SetBodygroup(k, v)
                    end
                    ply.DZ_ENTS_OldPlayerModel = nil
                end
                ply:SetupHands()

                ply:EmitSound("physics/metal/metal_box_break2.wav", 80, 100, 0.5)

                -- if ply.DZ_ENTS_OriginalSpeed then
                --     ply:SetSlowWalkSpeed(ply.DZ_ENTS_OriginalSpeed[1])
                --     ply:SetWalkSpeed(ply.DZ_ENTS_OriginalSpeed[2])
                --     ply:SetRunSpeed(ply.DZ_ENTS_OriginalSpeed[3])
                -- end
                -- ply.DZ_ENTS_OriginalSpeed = nil
            end
        else
            if ply:DZ_ENTS_HasArmor() then
                ply:DZ_ENTS_RemoveArmor()
            end
            if ply:DZ_ENTS_HasHelmet() then
                ply:DZ_ENTS_RemoveHelmet()
            end
        end
    end
end)