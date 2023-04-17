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

    if ply:GetNWFloat("DZ_Ents.ExoJump.NextUse", 0) > CurTime() then
        cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
    end
end)

hook.Add("SetupMove", "dz_ents_move", function(ply, mv, cmd)

    if ply:DZ_ENTS_HasHeavyArmor() and not ply:IsOnGround() and ply:GetVelocity().z < 0 then
        local grav = GetConVar("dzents_armor_heavy_gravity"):GetFloat()
        mv:SetVelocity(mv:GetVelocity() + physenv.GetGravity() * grav * FrameTime())
    end

    -- local ang = ply:GetAngles()
    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    -- Open the parachute
    if (ply.DZ_ENTS_ParachutePending or mv:KeyPressed(IN_JUMP)) and ply:GetMoveType() == MOVETYPE_WALK
            and not ply:IsOnGround() and ply:WaterLevel() == 0 and not ply:GetNWBool("DZ_Ents.Para.Open") and (ply.DZ_ENTS_NextParachute or 0) < CurTime()
            and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) and ply:GetVelocity().z < -GetConVar("dzents_parachute_threshold"):GetFloat() then
        ply:SetNWBool("DZ_Ents.Para.Open", true)
        ply:SetNWBool("DZ_Ents.Para.Consume", true)
        ply.DZ_ENTS_ParachutePending = nil
        if SERVER then
            ply.DZ_ENTS_ParachuteSound = CreateSound(ply, "DZ_ENTS.ParachuteDeploy")
            ply.DZ_ENTS_ParachuteSound:Play()
            ply:EmitSound("DZ_ENTS.ParachuteOpen")
        end
    elseif not ply:GetNWBool("DZ_Ents.Para.Auto") and ply:GetMoveType() == MOVETYPE_WALK
            and not ply:IsOnGround() and ply:GetVelocity().z < -400
            and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE)
            and ply:GetInfoNum("cl_dzents_autoparachute", 0) == 1 then
        ply:SetNWBool("DZ_Ents.Para.Auto", true)
    elseif ply:GetNWBool("DZ_Ents.Para.Open") and mv:KeyPressed(IN_JUMP) then
        ply:SetNWBool("DZ_Ents.Para.Open", false)
        ply.DZ_ENTS_NextParachute = CurTime() + 0.5
        if ply.DZ_ENTS_ParachuteSound then
            ply.DZ_ENTS_ParachuteSound:FadeOut(0.25)
            ply.DZ_ENTS_ParachuteSound = nil
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
            decel = decel * 0.5 * (1 + grav)
        end

        local horiz_max = ply:GetWalkSpeed() + 50 --250
        if vel.z < -slowfall then
            vel.z = math.Approach(vel.z, -slowfall, FrameTime() * (decel * Lerp(math.abs(vel.z) / 2500, 1, 5)))
        else
            vel.z = math.Approach(vel.z, -slowfall, FrameTime() * decel * 0.5)
        end

        -- vel = vel + eyeangles:Forward() * 100 * FrameTime()

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -25, 75)
        desiredmoveleft = math.Clamp(desiredmoveleft, -25, 25)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        -- Dampen horizontal velocity to simulate increased drag
        local drag = GetConVar("dzents_parachute_drag"):GetFloat()
        if drag > 0 then
            local speedSqr = vel.x * vel.x + vel.y * vel.y
            local diff = speedSqr / (horiz_max * horiz_max) - 1
            local damp = FrameTime() * (50 + Lerp(math.Clamp(diff / 10, 0, 1), 0, 2000)) * drag

            -- apply dampening to each axis relative to their magnitude to preserve direction
            local x_weight = math.abs(vel.x) / (math.abs(vel.x) + math.abs(vel.y))
            vel.x = math.Approach(vel.x, 0, damp * x_weight)
            vel.y = math.Approach(vel.y, 0, damp * (1 - x_weight))
        end

        mv:SetVelocity(vel)

    elseif ply:GetNWBool("DZ_Ents.Para.Auto") then
        local trlen = math.Clamp(vel.z * 0.5, -2048, -328) * (1 + (ply:DZ_ENTS_HasHeavyArmor() and GetConVar("dzents_armor_heavy_gravity"):GetFloat() or 0))
        local tr = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() + Vector(0, 0, trlen),
            mask = bit.bor(MASK_PLAYERSOLID, MASK_WATER),
            filter = ply
        })
        if tr.Hit and (tr.Fraction * -trlen) > 36 then
            ply.DZ_ENTS_ParachutePending = true
            ply:SetNWBool("DZ_Ents.Para.Auto", false)
        end
    end

    local ha = ply:DZ_ENTS_HasHeavyArmor() and GetConVar("dzents_armor_heavy_exojump"):GetFloat() or 1
    local boostdur = GetConVar("dzents_exojump_boostdur"):GetFloat()
    local boostvel = GetConVar("dzents_exojump_vel_up"):GetFloat() * ha
    local longjumpvel = GetConVar("dzents_exojump_vel_long"):GetFloat() * ha
    vel = mv:GetVelocity()
    if ply:KeyPressed(IN_JUMP) and ply:IsOnGround() and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) and ply:GetNWFloat("DZ_Ents.ExoJump.NextUse", 0) < CurTime()
            and ply:GetMoveType() == MOVETYPE_WALK
            and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) == 0 and not ply:GetNWBool("DZ_Ents.ExoJump.BoostHeld") then
        ply:SetNWFloat("DZ_Ents.ExoJump.BoostTime", CurTime())
        ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", true)
        if ply:KeyDown(IN_DUCK) then
            ply.DZ_ENTS_ExoSound = true
            ply:SetNWBool("DZ_Ents.ExoJump.BoostForward", true)
            ply:EmitSound("dz_ents/jump_ability_long_01.wav", 75, ha and 95 or 100, 1)
        else
            ply:SetNWBool("DZ_Ents.ExoJump.BoostForward", false)
            ply.DZ_ENTS_ExoSound = false
        end

        mv:SetMaxSpeed(ply:GetWalkSpeed())
        mv:SetMaxClientSpeed(ply:GetWalkSpeed())

    elseif ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) and ply:GetMoveType() == MOVETYPE_WALK
            and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) > 0 and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + boostdur > CurTime() then
        local vol = math.Clamp(1 - (ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + 0.2 - CurTime()) / 0.2, 0, 1) ^ 2
        if vol == 1 and not ply.DZ_ENTS_ExoSound then
            ply.DZ_ENTS_ExoSound = true
            ply:EmitSound("dz_ents/jump_ability_01.wav", 75, ha and 95 or 100, vol)
        end
        if (ply:GetNWBool("DZ_Ents.ExoJump.BoostForward") or ply:KeyDown(IN_JUMP)) and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) > 0 then
            local delta = math.Clamp((ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) + boostdur - CurTime()) / boostdur, 0, 1)

            -- If we're running up some slope or whatever it's possible we're still stuck on ground.
            local tgtvel = delta ^ 0.5 * (boostvel + (ply:IsOnGround() and 20000 or 0))

            if ply:GetNWBool("DZ_Ents.ExoJump.BoostForward") then
                local forward = Angle(-20, ply:GetAngles().y, 0):Forward()
                vel = LerpVector(delta ^ 2, vel, forward * longjumpvel)
                -- vel = vel + forward * longjumpvel * FrameTime() * 1
            else
                vel.z = vel.z + tgtvel * FrameTime()

                local drag = GetConVar("dzents_exojump_drag"):GetFloat()
                if drag > 0 then
                    local horiz_max = ply:GetWalkSpeed()
                    local speedSqr = vel.x * vel.x + vel.y * vel.y
                    local diff = math.max(0, speedSqr / (horiz_max * horiz_max) - 1)
                    local damp = FrameTime() * Lerp(math.Clamp(diff / 2, 0, 1), 0, 1000) * drag

                    -- apply dampening to each axis relative to their magnitude to preserve direction
                    local x_weight = math.abs(vel.x) / (math.abs(vel.x) + math.abs(vel.y))
                    vel.x = math.Approach(vel.x, 0, damp * x_weight)
                    vel.y = math.Approach(vel.y, 0, damp * (1 - x_weight))
                end
            end

            mv:SetVelocity(vel)
        else
            if not ply.DZ_ENTS_ExoSound then
                ply.DZ_ENTS_ExoSound = true
                ply:EmitSound("dz_ents/jump_ability_01.wav", 60 + vol * 20, 100, vol)
            end
            ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", false)
        end
    elseif ply:IsOnGround() and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) and ply:GetNWFloat("DZ_Ents.ExoJump.BoostTime", 0) > 0 then
        ply:SetNWFloat("DZ_Ents.ExoJump.BoostTime", 0)
        ply:SetNWBool("DZ_Ents.ExoJump.BoostHeld", false)
        ply:SetNWFloat("DZ_Ents.ExoJump.NextUse", CurTime() + GetConVar("dzents_exojump_cooldown"):GetFloat())
    end
end)

hook.Add("Move", "dz_ents_move", function(ply, mv)

end)

hook.Add("FinishMove", "dz_ents_move", function(ply, mv)

end)