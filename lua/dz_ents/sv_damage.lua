local armorregions = {
    [HITGROUP_GENERIC] = true, -- blast damage etc.
    [HITGROUP_GEAR] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
    [HITGROUP_LEFTARM] = true,
    [HITGROUP_RIGHTARM] = true,
}

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
    local uselogic = DZ_ENTS.ConVars["armor_enabled"]:GetInt()

    -- Block the blood effects on a headshot
    if CLIENT and ply:Armor() > 0 and (uselogic >= 2 or uselogic == 1 and ply:DZ_ENTS_HasArmor())
            and bit.band(dmginfo:GetDamageType(), bitflags_nohitgroup) == 0
            and bit.band(dmginfo:GetDamageType(), bitflags_blockable) ~= 0
            and ((DZ_ENTS.ConVars["armor_eff_head"]:GetBool() and hitgroup == HITGROUP_HEAD)
            or (DZ_ENTS.ConVars["armor_eff_body"]:GetBool() and armorregions[hitgroup])) then
        return true
    end
end)
]]

hook.Add("EntityTakeDamage", "ZZZZZ_dz_ents_damage", function(ply, dmginfo)

    if ply:GetNWFloat("DZ_Ents.Healthshot", 0) > CurTime() then
        dmginfo:ScaleDamage(DZ_ENTS.ConVars["healthshot_damage_taken"]:GetFloat())
    end

    if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():GetNWFloat("DZ_Ents.Healthshot", 0) > CurTime() then
        dmginfo:ScaleDamage(DZ_ENTS.ConVars["healthshot_damage_dealt"]:GetFloat())
    end

    if not ply:IsPlayer() then return end

    if dmginfo:IsFallDamage() then

        -- Nasty. Do it late here and with a hard-coded fall damage check in case some other addon is doing their own fall damage thing.
        -- Don't want to mess with hook loading orders now, do we?
        if engine.ActiveGamemode() ~= "terrortown" and not GetConVar("mp_falldamage"):GetBool() and dmginfo:GetDamage() == 10 and (
            (ply:DZ_ENTS_HasHeavyArmor() and DZ_ENTS.ConVars["armor_heavy_falldamage"]:GetBool())
            or (ply.DZENTS_BumpMine_Launched and DZ_ENTS.ConVars["bumpmine_damage_fall"]:GetFloat() > 0)) then
            -- SDK2013 damage calc. gets pretty close, the difference is probably related to velocity being a tick off or whatever
            dmginfo:SetDamage(math.max(math.abs(ply:GetVelocity().z) - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED, 0) * DZ_ENTS.DAMAGE_FOR_FALL_SPEED)
        end

        -- goomba stomp
        local groundent = ply:GetGroundEntity()
        if ply:DZ_ENTS_HasHeavyArmor() and DZ_ENTS.ConVars["armor_heavy_fallstomp"]:GetBool() and IsValid(groundent) then
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
            dmginfo:ScaleDamage(DZ_ENTS.ConVars["exojump_falldamage"]:GetFloat())
        end

        -- bump mine launch damage multiplier
        if (ply.DZENTS_BumpMine_Launched and DZ_ENTS.ConVars["bumpmine_damage_fall"]:GetFloat() > 0) then
            dmginfo:ScaleDamage(DZ_ENTS.ConVars["bumpmine_damage_fall"]:GetFloat())
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

    local uselogic = DZ_ENTS.ConVars["armor_enabled"]:GetInt()

    if ply:DZ_ENTS_HasHeavyArmor() then
        dmginfo:ScaleDamage(DZ_ENTS.ConVars["armor_heavy_damage"]:GetFloat())
    elseif ply:DZ_ENTS_HasArmor() then
        dmginfo:ScaleDamage(DZ_ENTS.ConVars["armor_damage"]:GetFloat())
    end

    -- this function allows us to do our armor logic without any hacks...
    -- but it's only on dev branch as of right now. if it exists, don't do the hacky method.
    if isfunction(GAMEMODE.HandlePlayerArmorReduction) then return end

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
            heavyarmorbonus = 0.33 * DZ_ENTS.ConVars["armor_heavy_durability"]:GetFloat()

            if hitgroup == HITGROUP_HEAD then
                dmginfo:ScaleDamage(0.5) -- csgo does it, so do we
            end
        elseif ply:DZ_ENTS_HasArmor() then
            armorbonus = armorbonus * DZ_ENTS.ConVars["armor_durability"]:GetFloat()
        end

        -- print("Dealing " .. dmginfo:GetDamage() .. " to " .. tostring(ply) .. " (hp: " .. ply:Health() .. ", armor:" .. ply:Armor() .. ")")
        -- print("Armored: " .. tostring(armored) .. "; Blockable: " .. tostring(blockable))

        if armored and blockable then -- Blockable damage is hitting a protected part. Do our job!
            local ap = hook.Run("dz_ents_armorpenetration", ply, dmginfo, wep) -- penetration value. 1 means fully penetrate, 0 means no penetration
            local ab = hook.Run("dz_ents_armorbonus", ply, dmginfo, wep) or 1
            if ap then
                ap = math.max(ap, 0)
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
        elseif dmginfo:IsDamageType(DMG_SHOCK) or not DZ_ENTS.ConVars["armor_fallback"]:GetBool() then
            -- If fallback is on, use HL2 logic. Otherwise we are unprotected
            -- Also, Zeus ignores armor so do it like this
            ply.PendingArmor = ply:Armor()
            ply:SetArmor(0)
        end
    end
end)

hook.Add("PostEntityTakeDamage", "ZZZZZ_dz_ents_damage", function(ply, dmginfo, took)
    if not ply:IsPlayer() or DZ_ENTS.ConVars["armor_enabled"]:GetInt() == 0 then return end
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
            if DZ_ENTS.ConVars["armor_eff_head"]:GetBool() then
                local eff = EffectData()
                eff:SetOrigin(dmginfo:GetDamagePosition())
                eff:SetNormal((dmginfo:GetDamageForce() * -1):GetNormalized())
                util.Effect("MetalSpark", eff)
            end
        elseif armorregions[hitgroup] or ply:DZ_ENTS_HasHeavyArmor() then
            -- ply:EmitSound("dz_ents/kevlar" .. math.random(1, 5) .. ".wav")
            snd = "dz_ents/kevlar" .. math.random(1, 5) .. ".wav"
            if DZ_ENTS.ConVars["armor_eff_heavy"]:GetBool() and ply:DZ_ENTS_HasHeavyArmor() then
                local eff = EffectData()
                eff:SetOrigin(dmginfo:GetDamagePosition())
                eff:SetNormal((dmginfo:GetDamageForce() * -1):GetNormalized())
                util.Effect("StunstickImpact", eff)
            end
        end
    elseif DZ_ENTS.ConVars["armor_snd_dink"]:GetBool() and hitgroup == HITGROUP_HEAD then
        -- ply:EmitSound("dz_ents/headshot" .. math.random(1, 2) .. ".wav")
        snd = "dz_ents/headshot" .. math.random(1, 2) .. ".wav"
    end

    if snd then
        if shooter:IsPlayer() then
            if DZ_ENTS.ConVars["armor_snd_world"]:GetBool() then
                local filter = RecipientFilter()
                filter:AddPAS(ply:GetPos())
                filter:RemovePlayer(shooter)
                local snd1 = CreateSound(ply, snd, filter)
                snd1:SetSoundLevel(75)
                snd1:PlayEx(0.75, 100)
            end

            local filter2 = RecipientFilter()
            filter2:AddPlayer(shooter)
            if shooter.DZENTS_HitSound then shooter.DZENTS_HitSound:Stop() end
            shooter.DZENTS_HitSound = CreateSound(shooter, snd, filter2)
            shooter.DZENTS_HitSound:SetSoundLevel(75)
            shooter.DZENTS_HitSound:PlayEx(shooter:GetInfoNum("cl_dzents_volume_hit", 0.75), 100)
        elseif DZ_ENTS.ConVars["armor_snd_world"]:GetBool() then
            ply:EmitSound(snd, 75, 100, 0.75)
        end
    end

    ply.PendingArmor = nil
    ply.DZENTS_ArmorHit = nil

    -- print("POST", ply:Health(), ply:Armor(), took)

    -- Let's make fall damage hurt heavy armor... for funsies.
    if dmginfo:IsFallDamage() and ply:DZ_ENTS_HasHeavyArmor() then
        ply:SetArmor(math.max(0, ply:Armor() - dmginfo:GetDamage() * DZ_ENTS.ConVars["armor_heavy_durability"]:GetFloat()))
    end

    -- If armor value hits zero, we will lose our armor and helmet
    if ply:Alive() and ply:Armor() <= 0 then
        if ply:DZ_ENTS_HasHeavyArmor() then
            -- break if convar allows, otherwise do nothing
            if DZ_ENTS.ConVars["armor_heavy_break"]:GetBool() then
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

hook.Add("HandlePlayerArmorReduction", "dz_ents_damage", function(ply, dmginfo)
    local uselogic = DZ_ENTS.ConVars["armor_enabled"]:GetInt()
    if dmginfo:IsFallDamage() then return end
    if uselogic > 0 and (ply:DZ_ENTS_HasArmor() or ply:DZ_ENTS_HasHelmet()) then
        local hitgroup = ply:LastHitGroup()
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
            heavyarmorbonus = 0.33 * DZ_ENTS.ConVars["armor_heavy_durability"]:GetFloat()

            if hitgroup == HITGROUP_HEAD then
                dmginfo:ScaleDamage(0.5) -- csgo does it, so do we
            end
        elseif ply:DZ_ENTS_HasArmor() then
            armorbonus = armorbonus * DZ_ENTS.ConVars["armor_durability"]:GetFloat()
        end

        -- print("Dealing " .. dmginfo:GetDamage() .. " to " .. tostring(ply) .. " (hp: " .. ply:Health() .. ", armor:" .. ply:Armor() .. ")")
        -- print("Armored: " .. tostring(armored) .. "; Blockable: " .. tostring(blockable))

        if armored and blockable then -- Blockable damage is hitting a protected part. Do our job!
            local ap = hook.Run("dz_ents_armorpenetration", ply, dmginfo, wep) -- penetration value. 1 means fully penetrate, 0 means no penetration
            local ab = hook.Run("dz_ents_armorbonus", ply, dmginfo, wep) or 1
            if ap then
                ap = math.max(ap, 0)
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
            ply.DZENTS_ArmorHit = hitgroup ~= HITGROUP_GENERIC
            ply:SetArmor(newarmor)
            dmginfo:SetDamage(healthdmg)

            return true
        elseif armored and not dmginfo:IsDamageType(DMG_SHOCK) then -- Damage is not blockable, but is hitting an armored part. Still do armor reduction, but don't use AP
            local healthdmg, newarmor = calcarmor(dmginfo, ply:Armor(), armorbonus, armorratio, heavyarmorbonus)
            ply:SetArmor(newarmor)
            dmginfo:SetDamage(healthdmg)

            return true
        elseif dmginfo:IsDamageType(DMG_SHOCK) or not DZ_ENTS.ConVars["armor_fallback"]:GetBool() then
            -- If fallback is on, use HL2 logic. Otherwise we are unprotected
            -- Also, Zeus ignores armor so do it like this
            return true
        end
    end
end)