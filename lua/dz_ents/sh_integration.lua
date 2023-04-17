hook.Add("M_Hook_Mult_DrawTime", "dz_ents_integration", function(wep, data)
    local ply = wep:GetOwner()
    if IsValid(ply) and ply:IsPlayer() and ply:DZ_ENTS_HasHeavyArmor() then
        data.mult = data.mult / GetConVar("dzents_armor_heavy_deployspeed"):GetFloat()
    end
end)

-- hook.Add("ARC9_DeployTimeHook", "dz_ents_integration", function(wep, data)
--     local ply = wep:GetOwner()
--     if IsValid(ply) and ply:IsPlayer() and ply:DZ_ENTS_HasHeavyArmor() then
--         print(data)
--         return data / GetConVar("dzents_armor_heavy_deployspeed"):GetFloat()
--     end
-- end)

hook.Add("TacRP_Stat_DeployTimeMult", "dz_ents_integration", function(wep, modifiers)
    local ply = wep:GetOwner()
    if IsValid(ply) and ply:IsPlayer() and ply:DZ_ENTS_HasHeavyArmor() then
        modifiers.mul = modifiers.mul / GetConVar("dzents_armor_heavy_deployspeed"):GetFloat()
    end
end)

hook.Add("TFA_GetStat", "dz_ents_integration", function(wep, stat, value)
    local ply = wep:GetOwner()
        -- 172 is ACT_VM_DRAW
    if stat == "SequenceRateOverride.172" and IsValid(ply) and ply:IsPlayer() and ply:DZ_ENTS_HasHeavyArmor() then
        return (value or 1) * GetConVar("dzents_armor_heavy_deployspeed"):GetFloat()
    end
end)

hook.Add("InitPostEntity", "dz_ents_integration", function()

    -- dirty, but should be fine
    local swcs_base = weapons.GetStored("weapon_swcs_base")
    if swcs_base then
        local old_deploy = swcs_base.GetDeploySpeed
        swcs_base.GetDeploySpeed = function(self)
            local rate = old_deploy(self)
            local ply = self:GetOwner()
            if IsValid(ply) and ply:IsPlayer() and ply:DZ_ENTS_HasHeavyArmor() then
                rate = rate * GetConVar("dzents_armor_heavy_deployspeed"):GetFloat()
            end
            return rate
        end
    end
end)