function DZ_ENTS:IsFistDamage(dmginfo)

    -- gmod_fists does this, probably some others
    if dmginfo:GetDamageType() == DMG_GENERIC then return true end

    -- mighty foot
    if dmginfo:GetDamageType() == DMG_CLUB and dmginfo:GetDamageCustom() == 67 and dmginfo:GetInflictor() == dmginfo:GetAttacker() then return true end

    return false
end
