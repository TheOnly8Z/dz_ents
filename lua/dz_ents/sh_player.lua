local PLAYER = FindMetaTable("Player")

-- CS values
DZ_ENTS_ARMOR_RATIO = 0.5
DZ_ENTS_ARMOR_BONUS = 0.5

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
    if drop and self:DZ_ENTS_HasHelmet() and self:DZ_ENTS_GetArmor() <= DZ_ENTS_ARMOR_KEVLAR then
        local ent = ents.Create("dz_armor_helmet")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:SetVelocity(self:GetVelocity() + VectorRand() * 256)
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

function PLAYER:DZ_ENTS_SetArmor(armor)
    self:SetNWInt("DZ_Ents.Armor", armor)
end

function PLAYER:DZ_ENTS_RemoveArmor(drop)
    if drop and self:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_KEVLAR and self:Armor() > 0 then
        local ent = ents.Create("dz_armor_kevlar")
        if IsValid(ent) then
            ent.GiveArmor = math.min(self:Armor(), 100)
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:SetVelocity(self:GetVelocity() + VectorRand() * 256)
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
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
    [HITGROUP_LEFTARM] = true,
    [HITGROUP_RIGHTARM] = true,
}
-- Does not check for armor value... do that in the hook
function PLAYER:DZ_ENTS_IsArmoredHitGroup(hitgroup)
    local uselogic = GetConVar("dzents_armor_enabled"):GetInt()
    if uselogic == 0 then return false end

    local armor = self:DZ_ENTS_GetArmor()
    return (armor == DZ_ENTS_ARMOR_HEAVY_CT or armor == DZ_ENTS_ARMOR_HEAVY_T) -- heavy armor covers all regions
            or (hitgroup == HITGROUP_HEAD and (uselogic == 2 or self:DZ_ENTS_HasHelmet())) -- if hit head, check helmet
            or (armorregions[hitgroup] and (uselogic == 2 or self:DZ_ENTS_HasArmor())) -- otherwise check armored regions
end

hook.Add("DoPlayerDeath", "dz_ents_player", function(ply)
    local drop = GetConVar("dzents_armor_deathdrop"):GetBool() and ply:Armor() > 0
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
local function calcarmor(dmginfo, armor, flBonus, flRatio)
    local old = GetConVar("player_old_armor"):GetBool()
    if not flBonus then
        flBonus = old and 0.5 or 1
    end
    flRatio = flRatio or 0.2

    local dmg = dmginfo:GetDamage()
    if dmginfo:IsDamageType(DMG_BLAST) and not game.SinglePlayer() then
        flBonus = flBonus * 2
    end
    if armor > 0 and bit.band(dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) == 0 then
        local flNew = dmg * flRatio
        local flArmor = (dmg - flNew) * flBonus

        if not old then
            flArmor = math.max(1, flArmor)
        end

        if flArmor > armor then
            flArmor = armor * (1 / flBonus)
            flNew = dmg - flArmor
            -- m_DmgSave = armor -- ?
            armor = 0
        else
            -- m_DmgSave = flArmor
            armor = armor - flArmor
        end

        dmg = flNew
    end
    return dmg, armor
end

hook.Add("EntityTakeDamage", "ZZZZZ_dz_ents_damage", function(ply, dmginfo)
    if not ply:IsPlayer() or not ply:LastHitGroup() then return end
    local hitgroup = ply:LastHitGroup()
    local uselogic = GetConVar("dzents_armor_enabled"):GetInt()

    if uselogic > 0 and (ply:DZ_ENTS_HasArmor() or ply:DZ_ENTS_HasHelmet()) then
        local armored = ply:DZ_ENTS_IsArmoredHitGroup(hitgroup)
        local wep = dmginfo:GetInflictor()
        if wep:IsPlayer() then wep = wep:GetActiveWeapon() end
        local class = IsValid(wep) and wep:GetClass()

        local ap = hook.Run("dz_ents_armorpenetration", ply, dmginfo) or 1 -- this is the penetration multiplier
        if DZ_ENTS:GetCanonicalClass(class) then
            ap = DZ_ENTS.CanonicalWeapons[DZ_ENTS:GetCanonicalClass(class)].ArmorPenetration
        else
            local ammocat = DZ_ENTS:GetWeaponAmmoCategory(game.GetAmmoName(wep:GetPrimaryAmmoType() or -1) or "")
            if ammocat then
                ap = DZ_ENTS.AmmoTypeAP[ammocat]
            end
        end

        if armored then
            local healthdmg2, newarmor2 = calcarmor(dmginfo, ply:Armor(), 0.5, 1 * ap)
            -- print("Dealing " .. dmginfo:GetDamage() .. " to " .. tostring(ply) .. " (hp: " .. ply:Health() .. ", armor:" .. ply:Armor() .. ") with " .. ap .. " armor pen")
            -- print("WANT", ply:Health() - healthdmg2, newarmor2, "(" .. healthdmg2 .. " dmg, " .. (ply:Armor() - newarmor2) .. " armor)")
            ply.PendingArmor = newarmor2
            ply:SetArmor(0) -- don't let engine do armor calculation
            dmginfo:SetDamage(healthdmg2)
        else
            -- ignore armor since the body part isn't protected
            ply.PendingArmor = ply:Armor()
            ply:SetArmor(0)
        end
    end
end)

hook.Add("PostEntityTakeDamage", "dz_ents_damage", function(ply, dmginfo, took)
    if not ply:IsPlayer() then return end
    if ply.PendingArmor then
        ply:SetArmor(ply.PendingArmor)
        if ply:LastHitGroup() == HITGROUP_HEAD then
            ply:EmitSound("dz_ents/headshot" .. math.random(1, 2) .. ".wav")
        elseif armorregions[ply:LastHitGroup()] then
            ply:EmitSound("dz_ents/kevlar" .. math.random(1, 5) .. ".wav")
        end
    end
    ply.PendingArmor = nil
    -- print("POST", ply:Health(), ply:Armor())

    -- it may break
    if ply:Armor() <= 0 then
        if ply:DZ_ENTS_HasArmor() then
            ply:DZ_ENTS_RemoveArmor()
        end
        if ply:DZ_ENTS_HasHelmet() then
            ply:DZ_ENTS_RemoveHelmet()
        end
    end
end)