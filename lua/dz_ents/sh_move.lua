sound.Add({
    name = "DZ_ENTS.ParachuteOpen",
    channel = CHAN_STATIC,
    volume = 0.6,
    sound = "dz_ents/dropzone_parachute_deploy.wav",
})

sound.Add({
    name = "DZ_ENTS.ParachuteDeploy",
    channel = CHAN_STATIC,
    volume = 0.6,
    sound = "dz_ents/dropzone_parachute_success_02.wav",
})

hook.Add("StartCommand", "zzz_dz_ents_move", function(ply, cmd)
    if ply:DZ_ENTS_HasHeavyArmor() and DZ_ENTS.ConVars["armor_heavy_nosprint"]:GetBool() and ply:GetMoveType() == MOVETYPE_WALK then
        cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_SPEED)))
    end

    -- if ply:GetNWFloat("DZ_Ents.ExoJump.NextUse", 0) > CurTime() then
    --     cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
    -- end
end)

local function movedir(ang, cmd)
    local forward = cmd:GetForwardMove() / 10000
    local side = cmd:GetSideMove() / 10000

    local abs_xy_move = math.abs(forward) + math.abs(side)
    local vec = Vector()
    if abs_xy_move == 0 then
        vec = Vector(0, 0, 1)
    else
        local div = (forward ^ 2 + side ^ 2) ^ 0.5
        vec:Add(ang:Forward() * forward / div)
        vec:Add(ang:Right() * side / div)
    end

    return vec
end

hook.Add("SetupMove", "zzz_dz_ents_move", function(ply, mv, cmd)

    local ft = FrameTime()

    local gravity = GetConVar("sv_gravity"):GetFloat()

    if ply:DZ_ENTS_HasHeavyArmor() then
        local tgt = DZ_ENTS.ConVars["armor_heavy_speed"]:GetInt()
        if tgt > 0 then
            local speed = tgt / math.max(mv:GetMaxSpeed(), ply:GetWalkSpeed())
            mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * speed)
            mv:SetMaxSpeed(mv:GetMaxSpeed() * speed)
        end

        if ply:IsOnGround() and (ply:GetVelocity().z < (600 - gravity)) then
            local grav = DZ_ENTS.ConVars["armor_heavy_gravity"]:GetFloat()
            mv:SetVelocity(mv:GetVelocity() - Vector(0, 0, gravity * grav * ft))
        end
    end

    if ply:GetNWFloat("DZ_Ents.Healthshot", 0) > CurTime() then
        local mul = DZ_ENTS.ConVars["healthshot_speed"]:GetFloat()
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * mul)
        mv:SetMaxSpeed(mv:GetMaxSpeed() * mul)

        -- Seems like the engine likes to clamp our max speed below run speed.
        -- I'd like to avoid calling SetRunSpeed if possible but there seems to be no way around this.
        if mv:GetMaxSpeed() > ply:GetMaxSpeed() then
            ply.DZENTS_PendingMaxSpeed = ply:GetRunSpeed()
            ply:SetRunSpeed(mv:GetMaxSpeed())
        end
    end

    -- local ang = ply:GetAngles()
    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    -- Open the parachute
    if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) then
        local pending = ply.DZ_ENTS_ParachutePending
        if (pending or mv:KeyDown(IN_JUMP)) and ply:GetMoveType() == MOVETYPE_WALK
                and not ply:IsOnGround() and ply:WaterLevel() == 0 and not ply:GetNWBool("DZ_Ents.Para.Open") and (ply.DZ_ENTS_NextParachute or 0) < CurTime() then
            if ply:GetVelocity().z < -DZ_ENTS.ConVars["parachute_threshold"]:GetFloat() then
                ply:SetNWBool("DZ_Ents.Para.Open", true)
                ply:SetNWBool("DZ_Ents.Para.Consume", true)
                ply:SetNWBool("DZ_Ents.Para.Auto", false)
                if SERVER and not ply.DZ_ENTS_ParachutePending then
                    ply:EmitSound("DZ_ENTS.ParachuteOpen")
                end
                ply.DZ_ENTS_ParachutePending = nil
                if SERVER then
                    ply.DZ_ENTS_ParachuteSound = CreateSound(ply, "DZ_ENTS.ParachuteDeploy")
                    ply.DZ_ENTS_ParachuteSound:Play()
                end
            elseif ply.DZ_ENTS_ParachutePending == nil and ply:GetVelocity().z < 50 then
                local tr = util.TraceHull({
                    start = ply:GetPos(),
                    endpos = ply:GetPos() - Vector(0, 0, 128),
                    mask = bit.bor(MASK_PLAYERSOLID, MASK_WATER),
                    filter = ply
                })
                if not tr.Hit then
                    if SERVER then
                        ply:EmitSound("DZ_ENTS.ParachuteOpen")
                    end
                    ply.DZ_ENTS_ParachutePending = true
                end
            end
        elseif ply:GetNWBool("DZ_Ents.Para.Open") and mv:KeyPressed(IN_JUMP) and DZ_ENTS.ConVars["parachute_detach"]:GetBool() then
            ply:SetNWBool("DZ_Ents.Para.Open", false)
            ply.DZ_ENTS_NextParachute = CurTime() + 0.5
            if ply.DZ_ENTS_ParachuteSound then
                ply.DZ_ENTS_ParachuteSound:FadeOut(0.25)
                ply.DZ_ENTS_ParachuteSound = nil
            end
        end

    elseif DZ_ENTS.ConVars["armor_heavy_robert"]:GetBool() and ply:DZ_ENTS_HasHeavyArmor() and not ply:GetNWBool("DZ_Ents.Para.Open")
            and (GetConVar("mp_falldamage"):GetBool() or DZ_ENTS.ConVars["armor_heavy_falldamage"]:GetBool()) then
        if not ply.DZENTS_Robert and ply:GetMoveType() == MOVETYPE_WALK and mv:GetVelocity().z <= -600 then
            local dmg = math.max(-mv:GetVelocity().z - DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED) * DZ_ENTS.DAMAGE_FOR_FALL_SPEED
            if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then
                dmg = dmg * DZ_ENTS.ConVars["exojump_falldamage"]:GetFloat()
            end
            if SERVER and dmg > math.max(ply:Health(), 50) then
                ply.DZENTS_Robert = true
                local tr = util.TraceLine({
                    start = ply:GetPos(),
                    endpos = ply:GetPos() - Vector(0, 0, 50000),
                    mask = bit.bor(MASK_WATER, MASK_PLAYERSOLID),
                    filter = ply
                })
                if bit.band(tr.Contents, CONTENTS_WATER) == 0 then
                    if ply:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_HEAVY_CT then
                        ply:EmitSound("dz_ents/robert_en.mp3", 80)
                    else
                        ply:EmitSound("dz_ents/robert.mp3", 80)
                    end
                end
            end
        end
    end

    -- Parachute slow fall
    if not ply:Alive() or ply:IsOnGround() or ply:WaterLevel() > 0 or ply:GetMoveType() ~= MOVETYPE_WALK then
        if ply:GetNWBool("DZ_Ents.Para.Open") or ply:GetNWBool("DZ_Ents.Para.Consume") then
            if ply.DZ_ENTS_ParachuteSound then
                ply.DZ_ENTS_ParachuteSound:FadeOut(0.25)
                ply.DZ_ENTS_ParachuteSound = nil
            end
            if SERVER and ply:Alive() and ply:GetNWBool("DZ_Ents.Para.Consume") and DZ_ENTS.ConVars["parachute_consume"]:GetBool() then
                ply:DZ_ENTS_RemoveEquipment(false, DZ_ENTS_EQUIP_PARACHUTE)
                DZ_ENTS:Hint(ply, 14)
            end
            ply:SetNWBool("DZ_Ents.Para.Open", false)
            ply:SetNWBool("DZ_Ents.Para.Consume", false)
        end
        ply:SetNWBool("DZ_Ents.Para.Auto", true)
        ply.DZ_ENTS_ParachutePending = nil
    elseif ply:GetNWBool("DZ_Ents.Para.Open") then

        local slowfall = DZ_ENTS.ConVars["parachute_fall"]:GetFloat()
        local decel = slowfall * 5

        if ply:DZ_ENTS_HasHeavyArmor() then
            local grav = DZ_ENTS.ConVars["armor_heavy_gravity"]:GetFloat()
            decel = decel * 0.75 * (1 + grav)
            slowfall = slowfall * (1 + grav)
        end

        if vel.z < -slowfall then
            vel.z = math.Approach(vel.z, -slowfall, ft * (decel * Lerp(math.abs(vel.z) / 2500, 1, 5)))
        else
            vel.z = math.Approach(vel.z, -slowfall, ft * decel * 0.5)
        end

        -- vel = vel + eyeangles:Forward() * 100 * ft

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        local spd = DZ_ENTS.ConVars["parachute_speed"]:GetFloat()

        desiredmoveforward = math.Clamp(desiredmoveforward, -spd, spd)
        desiredmoveleft = math.Clamp(desiredmoveleft, -spd, spd)

        vel = vel + eyeangles:Forward() * desiredmoveforward * ft
        vel = vel + eyeangles:Right() * desiredmoveleft * ft

        -- Dampen horizontal velocity to simulate increased drag
        local drag = DZ_ENTS.ConVars["parachute_drag"]:GetFloat()
        if drag > 0 then
            local speedSqr = vel.x * vel.x + vel.y * vel.y
            local diff = speedSqr / (spd + ply:GetWalkSpeed()) ^ 2 - 1
            local damp = ft * (50 + Lerp(math.Clamp(diff / 5, 0, 1), 0, 1000)) * drag

            -- apply dampening to each axis relative to their magnitude to preserve direction
            local x_weight = math.abs(vel.x) / (math.abs(vel.x) + math.abs(vel.y))
            vel.x = math.Approach(vel.x, 0, damp * x_weight)
            vel.y = math.Approach(vel.y, 0, damp * (1 - x_weight))
        end

        -- you can't brake on a dime
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)

        mv:SetVelocity(vel)

    elseif ply:GetNWBool("DZ_Ents.Para.Auto") and ply:GetInfoNum("cl_dzents_parachute_autodeploy", 0) == 1 then
        local v = ply:Health() / DZ_ENTS.DAMAGE_FOR_FALL_SPEED + DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED
        if vel.z <= -v then
            ply.DZ_ENTS_ParachutePending = true
        end
    end

    vel = mv:GetVelocity()

    local ha = ply:DZ_ENTS_HasHeavyArmor() and DZ_ENTS.ConVars["armor_heavy_exojump"]:GetFloat() or 1
    local boostdur = 0.5 --DZ_ENTS.ConVars["exojump_boostdur"]:GetFloat()
    local acceldur = 0.15
    local boostvel = 700 * (1 + DZ_ENTS.ConVars["exojump_boost_up"]:GetFloat()) * ha * (ply:DZ_ENTS_HasHeavyArmor() and (1 / (1 + DZ_ENTS.ConVars["armor_heavy_gravity"]:GetFloat() * 2)) or 1)
    local longjumpvel = DZ_ENTS.ConVars["exojump_boost_forward"]:GetFloat() * ha
    local yawang = Angle(0, ply:GetAngles().y, 0)
    local horiz_max = DZ_ENTS.ConVars["exojump_runboost"]:GetBool() and 400 or ply:GetWalkSpeed()

    if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then

        if ply:KeyPressed(IN_JUMP) and ply:IsOnGround() and ply:GetMoveType() == MOVETYPE_WALK
                and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) == 0 and not ply:GetNWBool("DZ_Ents.ExoJump.BoostHeld") then

            ply:SetNWFloat("DZ_Ents.ExoJump.BoostTime", CurTime())
            ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", true)

            if ply:KeyDown(IN_DUCK) then
                ply:SetNWBool("DZ_Ents.ExoJump.BoostForward", true)

                ply.DZ_ENTS_ExoSound = true
                if SERVER then
                    ply:EmitSound("dz_ents/jump_ability_long_01.wav", 75, ha and 95 or 100, 1)
                end

                local vec = movedir(yawang, cmd)

                -- If we don't do this, we seem to lose a bit of vertical velocity for no reason?
                -- vel.z = vel.z + ply:GetJumpPower()
                -- ply:SetGroundEntity(NULL)

                local startvel = math.min(vel:Length2D() + horiz_max * 0.25, horiz_max)
                ply:SetNWFloat("DZ_Ents.ExoJump.Vel", startvel)

                vel = vel + vec * startvel * longjumpvel
            else
                ply:SetNWBool("DZ_Ents.ExoJump.BoostForward", false)
                ply.DZ_ENTS_ExoSound = false

                ply:SetNWFloat("DZ_Ents.ExoJump.Vel", vel:Length2D())

                -- feels very awful if we cancel the jump boost
                -- vel = vel / 2
                -- print(vel:Length2D())
            end

            ply.DZ_ENTS_NextParachute = CurTime() + 1

            -- there seems to be a convar for jump impulse boost in csgo.
            vel.z = vel.z + ply:GetJumpPower() * 0.25

        elseif ply:GetMoveType() == MOVETYPE_WALK and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) > 0
                and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + boostdur > CurTime() then

            local delta = math.Clamp((ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + boostdur - CurTime()) / boostdur, 0, 1)

            if ply:GetNWBool("DZ_Ents.ExoJump.BoostHeld") then

                if not mv:KeyDown(IN_JUMP) then
                    ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", false)
                else
                    local tgtvel = delta * boostvel
                    vel.z = vel.z + tgtvel * ft

                    local diff = vel:Length2D() - ply:GetNWFloat("DZ_Ents.ExoJump.Vel") * (1 + longjumpvel * 0.25)
                    if ply:GetNWBool("DZ_Ents.ExoJump.BoostForward") and diff > 0 then
                        local v2d = Vector(vel.x, vel.y, 0)
                        v2d = v2d:GetNormalized() * (v2d:Length() - FrameTime() * (diff / acceldur))
                        vel.x = v2d.x
                        vel.y = v2d.y
                    end
                end
            end

            local drag = DZ_ENTS.ConVars["exojump_drag"]:GetFloat()
            if not ply:GetNWBool("DZ_Ents.ExoJump.BoostForward") and drag > 0 then

                local speedSqr = vel.x * vel.x + vel.y * vel.y
                local diff = math.max(0, speedSqr / (horiz_max * horiz_max) - 1)
                local damp = ft * Lerp(math.Clamp(diff / 2, 0, 1), 0, 1500) * drag

                -- apply dampening to each axis relative to their magnitude to preserve direction
                local x_weight = math.abs(vel.x) / (math.abs(vel.x) + math.abs(vel.y))
                vel.x = math.Approach(vel.x, 0, damp * x_weight)
                vel.y = math.Approach(vel.y, 0, damp * (1 - x_weight))
            end

            if not ply.DZ_ENTS_ExoSound then
                local vol = math.Clamp(1 - (ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + 0.1 - CurTime()) / 0.1, 0, 1) ^ 2
                if vol == 1 or not ply:GetNWBool("DZ_Ents.ExoJump.BoostHeld") then
                    ply.DZ_ENTS_ExoSound = true
                    if SERVER then
                        ply:EmitSound("dz_ents/jump_ability_01.wav", 65 + vol * 10, ha and 95 or 100, vol)
                    end
                end
            end
        elseif ply:IsOnGround() and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + boostdur <= CurTime() then
            ply:SetNWFloat("DZ_Ents.ExoJump.BoostTime", 0)
            ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", false)
        end

        -- print(math.Round(vel:Length2D()), math.Round(vel.z))
    end

    mv:SetVelocity(vel)
end)

hook.Add("FinishMove", "zzz_dz_ents_move", function(ply, mv)
    if ply.DZENTS_PendingMaxSpeed then
        ply:SetRunSpeed(ply.DZENTS_PendingMaxSpeed)
        ply.DZENTS_PendingMaxSpeed = nil
    end

    if ply:IsOnGround() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:WaterLevel() > 0 then
        ply.DZENTS_BumpMine_Launched = nil
        ply.DZENTS_BumpMine_LaunchTime = nil
        ply.DZENTS_BumpMine_Attacker = nil
    end
end)