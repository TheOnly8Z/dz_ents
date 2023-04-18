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

hook.Add("StartCommand", "dz_ents_move", function(ply, cmd)
    if ply:DZ_ENTS_HasHeavyArmor() and GetConVar("dzents_armor_heavy_nosprint"):GetBool() and ply:GetMoveType() == MOVETYPE_WALK then
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

hook.Add("SetupMove", "dz_ents_move", function(ply, mv, cmd)

    local ft = FrameTime()

    local gravity = GetConVar("sv_gravity"):GetFloat()

    if ply:DZ_ENTS_HasHeavyArmor() and not ply:IsOnGround() and (ply:GetVelocity().z < (600 - gravity)) then
        local grav = GetConVar("dzents_armor_heavy_gravity"):GetFloat()
        mv:SetVelocity(mv:GetVelocity() - Vector(0, 0, gravity * grav * ft))
    end

    -- local ang = ply:GetAngles()
    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    -- Open the parachute
    if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) then
        local pending = ply.DZ_ENTS_ParachutePending ~= nil and ply.DZ_ENTS_ParachutePending < CurTime()
        if (pending or mv:KeyDown(IN_JUMP)) and ply:GetMoveType() == MOVETYPE_WALK
                and not ply:IsOnGround() and ply:WaterLevel() == 0 and not ply:GetNWBool("DZ_Ents.Para.Open") and (ply.DZ_ENTS_NextParachute or 0) < CurTime() then
            if pending or (not ply:GetNWBool("DZ_Ents.Para.Consume") and ply:GetVelocity().z < -GetConVar("dzents_parachute_threshold"):GetFloat()) then
                ply:SetNWBool("DZ_Ents.Para.Open", true)
                ply:SetNWBool("DZ_Ents.Para.Consume", true)
                ply.DZ_ENTS_ParachutePending = nil
                if SERVER then
                    ply.DZ_ENTS_ParachuteSound = CreateSound(ply, "DZ_ENTS.ParachuteDeploy")
                    ply.DZ_ENTS_ParachuteSound:Play()
                end
            elseif ply.DZ_ENTS_ParachutePending == nil and ply:GetVelocity().z < -50 then
                local tr = util.TraceHull({
                    start = ply:GetPos(),
                    endpos = ply:GetPos() - Vector(0, 0, 196),
                    mask = bit.bor(MASK_PLAYERSOLID, MASK_WATER),
                    filter = ply
                })
                if not tr.Hit then
                    ply:EmitSound("DZ_ENTS.ParachuteOpen")
                    ply.DZ_ENTS_ParachutePending = CurTime() + 0.45
                end
            end
        elseif not ply:GetNWBool("DZ_Ents.Para.Auto") and ply:GetMoveType() == MOVETYPE_WALK
                and not ply:IsOnGround() and ply:GetVelocity().z < -400
                and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE)
                and ply:GetInfoNum("cl_dzents_parachute_autodeploy", 0) == 1 then
            ply:SetNWBool("DZ_Ents.Para.Auto", true)
        elseif ply:GetNWBool("DZ_Ents.Para.Open") and mv:KeyPressed(IN_JUMP) and GetConVar("dzents_parachute_detach"):GetBool() then
            ply:SetNWBool("DZ_Ents.Para.Open", false)
            ply.DZ_ENTS_NextParachute = CurTime() + 0.25
            if ply.DZ_ENTS_ParachuteSound then
                ply.DZ_ENTS_ParachuteSound:FadeOut(0.25)
                ply.DZ_ENTS_ParachuteSound = nil
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
            if SERVER and ply:Alive() and ply:GetNWBool("DZ_Ents.Para.Consume") and GetConVar("dzents_parachute_consume"):GetBool() then
                ply:DZ_ENTS_RemoveEquipment(false, DZ_ENTS_EQUIP_PARACHUTE)
                DZ_ENTS:Hint(ply, 14)
            end
            ply:SetNWBool("DZ_Ents.Para.Open", false)
            ply:SetNWBool("DZ_Ents.Para.Consume", false)
        end
        ply:SetNWBool("DZ_Ents.Para.Auto", false)
        ply.DZ_ENTS_ParachutePending = nil
    elseif ply:GetNWBool("DZ_Ents.Para.Open") then

        local slowfall = GetConVar("dzents_parachute_fall"):GetFloat()
        local decel = slowfall * 5

        if ply:DZ_ENTS_HasHeavyArmor() then
            local grav = GetConVar("dzents_armor_heavy_gravity"):GetFloat()
            decel = decel * 0.75 * (1 + grav)
            slowfall = slowfall * (1 + grav)
        end

        local horiz_max = ply:GetWalkSpeed() + 50 --250
        if vel.z < -slowfall then
            vel.z = math.Approach(vel.z, -slowfall, ft * (decel * Lerp(math.abs(vel.z) / 2500, 1, 5)))
        else
            vel.z = math.Approach(vel.z, -slowfall, ft * decel * 0.5)
        end

        -- vel = vel + eyeangles:Forward() * 100 * ft

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -25, 75)
        desiredmoveleft = math.Clamp(desiredmoveleft, -25, 25)

        vel = vel + eyeangles:Forward() * desiredmoveforward * ft
        vel = vel + eyeangles:Right() * desiredmoveleft * ft

        -- Dampen horizontal velocity to simulate increased drag
        local drag = GetConVar("dzents_parachute_drag"):GetFloat()
        if drag > 0 then
            local speedSqr = vel.x * vel.x + vel.y * vel.y
            local diff = speedSqr / (horiz_max * horiz_max) - 1
            local damp = ft * (50 + Lerp(math.Clamp(diff / 10, 0, 1), 0, 2000)) * drag

            -- apply dampening to each axis relative to their magnitude to preserve direction
            local x_weight = math.abs(vel.x) / (math.abs(vel.x) + math.abs(vel.y))
            vel.x = math.Approach(vel.x, 0, damp * x_weight)
            vel.y = math.Approach(vel.y, 0, damp * (1 - x_weight))
        end

        mv:SetVelocity(vel)

    elseif ply:GetNWBool("DZ_Ents.Para.Auto") then
        local v = ply:Health() / DZ_ENTS.DAMAGE_FOR_FALL_SPEED + DZ_ENTS.PLAYER_MAX_SAFE_FALL_SPEED
        if vel.z <= -v then
            ply.DZ_ENTS_ParachutePending = CurTime()
            ply:SetNWBool("DZ_Ents.Para.Auto", false)
        end
    end

    vel = mv:GetVelocity()

    local ha = ply:DZ_ENTS_HasHeavyArmor() and GetConVar("dzents_armor_heavy_exojump"):GetFloat() or 1
    local boostdur = 0.5 --GetConVar("dzents_exojump_boostdur"):GetFloat()
    local acceldur = 0.15
    local boostvel = 700 * (1 + GetConVar("dzents_exojump_boost_up"):GetFloat()) * ha * (ply:DZ_ENTS_HasHeavyArmor() and (1 / (1 + GetConVar("dzents_armor_heavy_gravity"):GetFloat() * 2)) or 1)
    local longjumpvel = GetConVar("dzents_exojump_boost_forward"):GetFloat() * ha
    local yawang = Angle(0, ply:GetAngles().y, 0)
    local horiz_max = (not GetConVar("dzents_exojump_runboost"):GetBool()) and ply:GetWalkSpeed() or ply:GetRunSpeed()

    if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then

        if ply:KeyPressed(IN_JUMP) and ply:IsOnGround() and ply:GetMoveType() == MOVETYPE_WALK
                and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) == 0 and not ply:GetNWBool("DZ_Ents.ExoJump.BoostHeld") then

            -- mv:SetMaxSpeed(ply:GetWalkSpeed())
            -- mv:SetMaxClientSpeed(ply:GetWalkSpeed())

            ply:SetNWFloat("DZ_Ents.ExoJump.BoostTime", CurTime())
            ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", true)

            if ply:KeyDown(IN_DUCK) then
                ply:SetNWBool("DZ_Ents.ExoJump.BoostForward", true)

                ply.DZ_ENTS_ExoSound = true
                ply:EmitSound("dz_ents/jump_ability_long_01.wav", 75, ha and 95 or 100, 1)

                local vec = movedir(yawang, cmd)

                -- If we don't do this, we seem to lose a bit of vertical velocity for no reason?
                vel.z = vel.z + ply:GetJumpPower()
                ply:SetGroundEntity(NULL)

                local startvel = math.min(vel:Length2D() + horiz_max * 0.25, horiz_max)
                ply:SetNWFloat("DZ_Ents.ExoJump.Vel", startvel)

                vel = vel + vec * startvel * longjumpvel
            else
                ply:SetNWBool("DZ_Ents.ExoJump.BoostForward", false)
                ply.DZ_ENTS_ExoSound = false

                -- cancel sandbox sprint jump boost
                vel = vel / 2
                -- print(vel:Length2D())
            end

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

            local drag = GetConVar("dzents_exojump_drag"):GetFloat()
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
                    ply:EmitSound("dz_ents/jump_ability_01.wav", 65 + vol * 10, ha and 95 or 100, vol)
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

hook.Add("Move", "dz_ents_move", function(ply, mv)

end)

hook.Add("FinishMove", "dz_ents_move", function(ply, mv)

end)