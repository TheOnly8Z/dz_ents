DZ_ENTS.PhysicsMonitorList = {}

hook.Add("Think", "dz_ents_phys", function()
    for i, ent in pairs(DZ_ENTS.PhysicsMonitorList) do
        if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or ent:GetMoveType() ~= MOVETYPE_WALK)) then
            table.remove(DZ_ENTS.PhysicsMonitorList, i)
            continue
        end

        local last, cur = (ent.DZENTS_LastVel or ent:GetVelocity()), ent:GetVelocity()

        -- NPCs don't typically take fall damage so let's introduce them to the world of pain
        if ent.DZENTS_BumpMine_Launched and not ent:IsPlayer() and ent:IsOnGround() and last.z < -DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED / 2 then

            local dmginfo = DamageInfo()
            dmginfo:SetDamage(math.max(math.abs(last.z) - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED / 2, 0) * DZ_ENTS.DAMAGE_FOR_FALL_SPEED * 2 * GetConVar("dzents_bumpmine_damage_fall"):GetFloat())
            dmginfo:SetDamageForce(Vector(0, 0, dmginfo:GetDamage() * -100))
            dmginfo:SetDamagePosition(ent:GetPos())
            dmginfo:SetDamageType(DMG_CRUSH + DMG_NEVERGIB + DMG_FALL)
            dmginfo:SetAttacker(IsValid(ent.DZENTS_BumpMine_Attacker) and ent.DZENTS_BumpMine_Attacker or ent)
            dmginfo:SetInflictor(game.GetWorld())

            ent:TakeDamageInfo(dmginfo)
        end

        -- crash into walls. Only check horizontal velocity so launching into ceilings doesn't kill you
        local v2dlast, v2dcur = last:Length2D(), cur:Length2D()
        if ent.DZENTS_BumpMine_LaunchTime and ent.DZENTS_BumpMine_LaunchTime + 1 > CurTime()
                and v2dlast > DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED and v2dlast - v2dcur > DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED then
            local mins, maxs = ent:GetCollisionBounds()
            local dir = last:GetNormalized()
            local tr = util.TraceHull({
                start = ent:GetPos() - dir,
                endpos = ent:GetPos() + dir * 2,
                mins = mins,
                maxs = maxs,
                filter = ent,
                mask = ent:IsPlayer() and MASK_PLAYERSOLID or MASK_NPCSOLID
            })

            if tr.Hit then
                ent.DZENTS_BumpMine_LaunchTime = nil

                ent:EmitSound(util.GetSurfaceData(tr.SurfaceProps).bulletImpactSound)
                ent:EmitSound(util.GetSurfaceData(tr.SurfaceProps).impactHardSound)

                local dmginfo = DamageInfo()
                dmginfo:SetDamage(Lerp((v2dlast - v2dcur - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED) / 5000, 20, 200) * (ent:IsPlayer() and 1 or 3) * GetConVar("dzents_bumpmine_damage_crash"):GetFloat())
                dmginfo:SetDamageForce(last)
                dmginfo:SetDamagePosition(ent:GetPos())
                dmginfo:SetDamageType(DMG_CRUSH + DMG_NEVERGIB + DMG_FALL)
                dmginfo:SetAttacker(IsValid(ent.DZENTS_BumpMine_Attacker) and ent.DZENTS_BumpMine_Attacker or ent)
                dmginfo:SetInflictor(game.GetWorld())

                -- Owner can take less crash damage
                if IsValid(ent.DZENTS_BumpMine_Attacker) and ent.DZENTS_BumpMine_Attacker == ent then
                    dmginfo:ScaleDamage(GetConVar("dzents_bumpmine_damage_selfcrash"):GetFloat())
                end

                ent:TakeDamageInfo(dmginfo)

                -- If we land into some unfortunate bloke, they take a hit too
                if IsValid(tr.Entity) and not tr.Entity.DZENTS_BumpMine_LaunchTime then
                    dmginfo:ScaleDamage(2)
                    tr.Entity:TakeDamageInfo(dmginfo)
                end
            end
        end

        ent.DZENTS_LastVel = ent:GetVelocity()
        if ent:IsOnGround() then
            if not ent:IsPlayer() then -- players do this in FinishMove
                ent.DZENTS_BumpMine_Launched = nil
                ent.DZENTS_BumpMine_LaunchTime = nil
            end
            table.remove(DZ_ENTS.PhysicsMonitorList, i)
            continue
        end
    end
end)