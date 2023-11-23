DZ_ENTS.PhysicsMonitorList = {}

hook.Add("Think", "dz_ents_phys", function()
    for i, ent in pairs(DZ_ENTS.PhysicsMonitorList) do
        if not IsValid(ent) or ent:WaterLevel() > 0 or (ent:IsPlayer() and (not ent:Alive() or ent:GetMoveType() ~= MOVETYPE_WALK)) then
            table.remove(DZ_ENTS.PhysicsMonitorList, i)
            continue
        end

        local last, cur = (ent.DZENTS_LastVel or ent:GetVelocity()), ent:GetVelocity()

        -- NPCs don't typically take fall damage so let's introduce them to the world of pain
        if ent.DZENTS_BumpMine_Launched and not ent:IsPlayer() and ent:IsOnGround() then

            if DZ_ENTS.ConVars["bumpmine_damage_fall"]:GetFloat() > 0 and last.z < -DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED / 2 then
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(math.max(math.abs(last.z) - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED / 2, 0) * DZ_ENTS.DAMAGE_FOR_FALL_SPEED * 2 * DZ_ENTS.ConVars["bumpmine_damage_fall"]:GetFloat())
                dmginfo:SetDamageForce(Vector(0, 0, dmginfo:GetDamage() * -100))
                dmginfo:SetDamagePosition(ent:GetPos())
                dmginfo:SetDamageType(DMG_CRUSH + DMG_NEVERGIB + DMG_FALL)
                dmginfo:SetAttacker(IsValid(ent.DZENTS_BumpMine_Attacker) and ent.DZENTS_BumpMine_Attacker or ent)
                dmginfo:SetInflictor(game.GetWorld())
                ent:TakeDamageInfo(dmginfo)
            end

            ent.DZENTS_BumpMine_Launched = nil
            ent.DZENTS_BumpMine_LaunchTime = nil
            table.remove(DZ_ENTS.PhysicsMonitorList, i)
            continue
        end

        -- crash into walls. Only check horizontal velocity so launching into ceilings doesn't kill you
        local v2dlast, v2dcur = last:Length2D(), cur:Length2D()
        if ent.DZENTS_BumpMine_LaunchTime and ent.DZENTS_BumpMine_LaunchTime + 1.5 > CurTime()
                and v2dlast > DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED and v2dlast - v2dcur > 100 then
            local mins, maxs = ent:GetCollisionBounds()
            mins = mins - Vector(0, 0, 8)
            local dir = last:GetNormalized()
            local tr = util.TraceHull({
                start = ent:GetPos(),
                endpos = ent:GetPos() + dir * ent:BoundingRadius(),
                mins = mins,
                maxs = maxs,
                filter = ent,
                mask = ent:IsPlayer() and MASK_PLAYERSOLID or MASK_NPCSOLID
            })

            debugoverlay.Box(tr.StartPos, mins, maxs, 3, Color(255, 255, 255, 0))
            debugoverlay.Box(tr.HitPos, mins, maxs, 3, Color(255, 0, 0, 0))
            debugoverlay.Box(tr.StartPos + dir * ent:BoundingRadius(), mins, maxs, 3, Color(0, 0, 255, 0))

            if tr.Hit then

                ent:EmitSound(util.GetSurfaceData(tr.SurfaceProps).bulletImpactSound)
                ent:EmitSound(util.GetSurfaceData(tr.SurfaceProps).impactHardSound)

                local dmg = Lerp((v2dlast - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED) / 5000, 20, 200) * (ent:IsPlayer() and 1 or 3) * DZ_ENTS.ConVars["bumpmine_damage_crash"]:GetFloat()
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(dmg)
                dmginfo:SetDamageForce(last)
                dmginfo:SetDamagePosition(ent:GetPos())
                dmginfo:SetDamageType(DMG_CRUSH + DMG_NEVERGIB + DMG_FALL)
                dmginfo:SetAttacker(IsValid(ent.DZENTS_BumpMine_Attacker) and ent.DZENTS_BumpMine_Attacker or ent)
                dmginfo:SetInflictor(game.GetWorld())

                -- Owner can take less crash damage
                if IsValid(ent.DZENTS_BumpMine_Attacker) and ent.DZENTS_BumpMine_Attacker == ent then
                    dmginfo:ScaleDamage(DZ_ENTS.ConVars["bumpmine_damage_selfcrash"]:GetFloat())
                end

                -- slightly less damage if we hit a thing
                if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot()) then
                    dmginfo:ScaleDamage(0.75)
                end

                ent:TakeDamageInfo(dmginfo)

                -- If we land into some unfortunate bloke, they take a hit too
                if IsValid(tr.Entity) and DZ_ENTS.ConVars["bumpmine_damage_crashchain"]:GetBool() then --  and not tr.Entity.DZENTS_BumpMine_LaunchTime
                    tr.Entity:TakeDamageInfo(dmginfo)
                    if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() then
                        tr.Entity:SetVelocity(last)
                    elseif IsValid(tr.Entity:GetPhysicsObject()) then
                        tr.Entity:GetPhysicsObject():ApplyForceCenter(last)
                    end
                    dmginfo:SetDamage(dmg * 2)
                    tr.Entity:TakeDamageInfo(dmginfo)

                    if not IsValid(tr.Entity) or (tr.Entity:IsPlayer() and not tr.Entity:Alive()) or (not tr.Entity:IsPlayer() and tr.Entity:Health() < 0) then
                        -- punch through destroyed props and dead NPCs/players
                        ent.DZENTS_BumpMine_LaunchTime = CurTime() + 0.5
                        ent:SetVelocity(last - cur)
                    -- else
                        -- ent.DZENTS_BumpMine_LaunchTime = nil
                    end
                -- else
                    -- ent.DZENTS_BumpMine_LaunchTime = nil
                end
            end
        end

        ent.DZENTS_LastVel = ent:GetVelocity()
        if ent:IsOnGround() and ent:IsPlayer() then
            table.remove(DZ_ENTS.PhysicsMonitorList, i)
            continue
        end
    end
end)