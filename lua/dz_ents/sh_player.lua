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
            ent:GetPhysicsObject():SetVelocityInstantaneous(ent:GetVelocity() + VectorRand() * 32)
            SafeRemoveEntityDelayed(ent, 60)
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
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(ent:GetVelocity() + VectorRand() * 32)
            SafeRemoveEntityDelayed(ent, 60)
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

function PLAYER:DZ_ENTS_RemoveEquipment(equip)
    if equip then
        self:DZ_ENTS_SetEquipment(bit.band(self:DZ_ENTS_GetEquipment(), bit.bnot(equip)))
    else
        self:DZ_ENTS_SetEquipment(DZ_ENTS_EQUIP_NONE)
    end
end

local armorregions = {
    [HITGROUP_GENERIC] = true, -- blast damage etc.
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

-- DoPlayerDeath happens _before_ PostEntityTakeDamage, so Armor is 0 for purposes of damage calc.
hook.Add("DoPlayerDeath", "dz_ents_player", function(ply)
    local drop = GetConVar("dzents_armor_deathdrop"):GetBool() and (ply:Armor() > 0 or (ply.PendingArmor or 0) > 0)
    ply.DZ_ENTS_OriginalSpeed = nil
    ply:DZ_ENTS_RemoveHelmet(drop)
    ply:DZ_ENTS_RemoveArmor(drop)
    ply:DZ_ENTS_RemoveEquipment()
end)

hook.Add("PlayerLoadout", "dz_ents_player", function(ply)
    timer.Simple(0, function()
        local give = GetConVar("dzents_armor_onspawn"):GetInt()
        if give >= 1 then
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
            ply:SetArmor(100)
        end
        if give >= 2 then
            ply:DZ_ENTS_GiveHelmet()
        end
    end)
end)

-- Simulate armor calculation
-- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/server/player.cpp#L1061
local function calcarmor(dmginfo, armor, flBonus, flRatio, no_partial)
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
        local flArmor = (dmg - flNew) * flBonus

        if not old then
            flArmor = math.max(1, flArmor)
        end

        -- In CS:GO, armor will always fully reduce damage even if the amount is insufficient (at least the wiki claims so).
        if not no_partial and flArmor > armor then
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

-- affects how much armor is reduced from damage
local armorbonus = 0.5
-- affects what fraction of damage is converted to armor damage (1 means none)
local armorratio = 0.5

local bitflags_blockable = DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST
local bitflags_nohitgroup = DMG_FALL + DMG_BLAST + DMG_RADIATION + DMG_CRUSH + DMG_DROWN + DMG_POISON
hook.Add("EntityTakeDamage", "ZZZZZ_dz_ents_damage", function(ply, dmginfo)
    if not ply:IsPlayer() then return end
    if dmginfo:IsFallDamage() then return end

    -- Check the hitgroup of the damage. Certain damage types should not have hitgroups so strip hitgroup if that's the case.
    local hitgroup = ply:LastHitGroup()
    if bit.band(dmginfo:GetDamageType(), bitflags_nohitgroup) ~= 0 then
        hitgroup = HITGROUP_GENERIC
    end

    local uselogic = GetConVar("dzents_armor_enabled"):GetInt()

    -- Heavy Assault Suit reduces incoming damage before armor (even to non blockable damage).
    if uselogic and ply:DZ_ENTS_HasHeavyArmor() then
        dmginfo:ScaleDamage(GetConVar("dzents_armor_heavy_damage"):GetFloat())
    end

    if uselogic > 0 and (ply:DZ_ENTS_HasArmor() or ply:DZ_ENTS_HasHelmet()) then
        local blockable = bit.band(dmginfo:GetDamageType(), bitflags_blockable) ~= 0
        local armored = ply:DZ_ENTS_IsArmoredHitGroup(hitgroup)
        local wep = dmginfo:GetInflictor()
        if wep:IsPlayer() then wep = wep:GetActiveWeapon() end
        local class = IsValid(wep) and wep:GetClass() or ""

        if armored and blockable then -- Blockable damage is hitting a protected part. Do our job!
            local ap = hook.Run("dz_ents_armorpenetration", ply, dmginfo) or 1 -- penetration value. 1 means fully penetrate, 0 means no penetration
            if DZ_ENTS:GetCanonicalClass(class) then
                ap = DZ_ENTS.CanonicalWeapons[DZ_ENTS:GetCanonicalClass(class)].ArmorPenetration
            else
                -- Fallback AP value based on ammo category if possible
                local ammocat = DZ_ENTS:GetWeaponAmmoCategory(game.GetAmmoName(wep:IsWeapon() and wep:GetPrimaryAmmoType() or -1) or "")
                if ammocat then
                    ap = DZ_ENTS.AmmoTypeAP[ammocat]
                end
            end

            local healthdmg, newarmor = calcarmor(dmginfo, ply:Armor(), armorbonus, math.Clamp(armorratio * ap * 2, 0, 1), true)
            -- print("Dealing " .. dmginfo:GetDamage() .. " to " .. tostring(ply) .. " (hp: " .. ply:Health() .. ", armor:" .. ply:Armor() .. ") with " .. ap .. " armor pen")
            -- print("WANT", ply:Health() - healthdmg2, newarmor2, "(" .. healthdmg2 .. " dmg, " .. (ply:Armor() - newarmor2) .. " armor)")
            ply.PendingArmor = newarmor
            ply.DZENTS_ArmorHit = hitgroup ~= HITGROUP_GENERIC
            ply:SetArmor(0) -- don't let engine do armor calculation
            dmginfo:SetDamage(healthdmg)
        elseif armored and hitgroup ~= HITGROUP_GENERIC then -- Damage is not blockable, but is hitting an armored part. Still do armor reduction, but don't use AP
            local healthdmg, newarmor = calcarmor(dmginfo, ply:Armor(), armorbonus, armorratio)
            ply.PendingArmor = newarmor
            ply:SetArmor(0)
            dmginfo:SetDamage(healthdmg)
        elseif not GetConVar("dzents_armor_fallback"):GetBool() then -- If fallback is on, use HL2 logic. Otherwise we are unprotected
            ply.PendingArmor = ply:Armor()
            ply:SetArmor(0)
        end
    end
end)

hook.Add("PostEntityTakeDamage", "dz_ents_damage", function(ply, dmginfo, took)
    if not took or not ply:IsPlayer() then return end
    if ply.PendingArmor then
        ply:SetArmor(ply.PendingArmor)
    end
    if ply.DZENTS_ArmorHit then
        if ply:LastHitGroup() == HITGROUP_HEAD then
            ply:EmitSound("dz_ents/headshot" .. math.random(1, 2) .. ".wav")
        elseif armorregions[ply:LastHitGroup()] then
            ply:EmitSound("dz_ents/kevlar" .. math.random(1, 5) .. ".wav")
        end
    end
    ply.PendingArmor = nil
    ply.DZENTS_ArmorHit = nil
    -- print("POST", ply:Health(), ply:Armor())

    -- If armor value hits zero, we will lose our armor and helmet
    if ply:Alive() and ply:Armor() <= 0 then
        if ply:DZ_ENTS_HasHeavyArmor() then
            ply:DZ_ENTS_RemoveArmor()
            if ply.DZ_ENTS_OriginalSpeed then
                ply:SetSlowWalkSpeed(ply.DZ_ENTS_OriginalSpeed[1])
                ply:SetWalkSpeed(ply.DZ_ENTS_OriginalSpeed[2])
                ply:SetRunSpeed(ply.DZ_ENTS_OriginalSpeed[3])
            end
            ply.DZ_ENTS_OriginalSpeed = nil
        elseif ply:DZ_ENTS_HasArmor() then

            ply:DZ_ENTS_RemoveArmor()
        end
        if ply:DZ_ENTS_HasHelmet() then
            ply:DZ_ENTS_RemoveHelmet()
        end
    end
end)