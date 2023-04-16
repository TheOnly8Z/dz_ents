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
    if ply:DZ_ENTS_HasHeavyArmor() and not GetConVar("dzents_armor_heavy_sprint"):GetBool() then
        cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_SPEED)))
    end
end)

hook.Add("SetupMove", "dz_ents_move", function(ply, mv, cmd)

    local ang = ply:GetAngles()
    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    -- Open the parachute
    if (ply.DZ_ENTS_ParachutePending or mv:KeyPressed(IN_JUMP)) and ply:GetMoveType() == MOVETYPE_WALK
            and not ply:IsOnGround() and ply:WaterLevel() == 0 and not ply:GetNWBool("DZ_Ents.Para.Open")
            and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) and ply:GetVelocity().z < -GetConVar("dzents_parachute_threshold"):GetFloat() then
        ply:SetNWBool("DZ_Ents.Para.Open", true)
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
    end

    -- Parachute slow fall
    if not ply:Alive() or ply:IsOnGround() or ply:WaterLevel() > 0 or ply:GetMoveType() ~= MOVETYPE_WALK then
        if ply:GetNWBool("DZ_Ents.Para.Open") then
            ply:SetNWBool("DZ_Ents.Para.Open", false)
            if ply.DZ_ENTS_ParachuteSound then
                ply.DZ_ENTS_ParachuteSound:FadeOut(0.25)
                ply.DZ_ENTS_ParachuteSound = nil
            end
            if ply:Alive() and GetConVar("dzents_parachute_consume"):GetBool() then
                ply:DZ_ENTS_RemoveEquipment(false, DZ_ENTS_EQUIP_PARACHUTE)
                DZ_ENTS:Hint(ply, 14)
            end
        end
        ply:SetNWBool("DZ_Ents.Para.Auto", false)
        ply.DZ_ENTS_ParachutePending = nil
    elseif ply:GetNWBool("DZ_Ents.Para.Open") then

        local slowfall = GetConVar("dzents_parachute_fall"):GetFloat()
        local horiz_max = ply:GetWalkSpeed() + 50 --250
        if vel.z < -slowfall then
            vel.z = math.Approach(vel.z, -slowfall, FrameTime() * (slowfall * 6 + math.abs(vel.z * 3)))
        else
            vel.z = math.Approach(vel.z, -slowfall, FrameTime() * slowfall * 3)
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
        local trlen = math.Clamp(vel.z * 0.5, -1024, -328)
        local tr = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() + Vector(0, 0, trlen),
            mask = bit.bor(MASK_PLAYERSOLID, MASK_WATER),
            filter = ply
        })
        if tr.Hit and (tr.Fraction * -trlen) > 72 then
            ply.DZ_ENTS_ParachutePending = true
            ply:SetNWBool("DZ_Ents.Para.Auto", false)
        end
    end
end)

hook.Add("Move", "dz_ents_move", function(ply, mv)

end)

hook.Add("FinishMove", "dz_ents_move", function(ply, mv)

end)