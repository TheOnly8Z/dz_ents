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

local sqrt2 = 1.4142135
hook.Add("SetupMove", "dz_ents_move", function(ply, mv, cmd)

    local ang = ply:GetAngles()
    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    -- Open the parachute
    if (ply.DZ_ENTS_ParachutePending or mv:KeyPressed(IN_JUMP)) and ply:GetMoveType() == MOVETYPE_WALK
            and not ply:IsOnGround() and ply:WaterLevel() == 0 and not ply:GetNWBool("DZ_Ents.Para.Open")
            and ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) and ply:GetVelocity().z < -600 then
        ply:SetNWBool("DZ_Ents.Para.Open", true)
        ply.DZ_ENTS_ParachutePending = nil
        if SERVER then
            -- local chute = ents.Create("DZ_Ents.Para.Open")
            -- chute:SetOwner(ply)
            -- chute:Spawn()
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
    if ply:IsOnGround() or ply:WaterLevel() > 0 or ply:GetMoveType() ~= MOVETYPE_WALK then
        if ply:GetNWBool("DZ_Ents.Para.Open") then
            ply:SetNWBool("DZ_Ents.Para.Open", false)
            if ply.DZ_ENTS_ParachuteSound then
                ply.DZ_ENTS_ParachuteSound:FadeOut(1)
                ply.DZ_ENTS_ParachuteSound = nil
            end
            if GetConVar("dzents_parachute_consume"):GetBool() then
                ply:DZ_ENTS_RemoveEquipment(DZ_ENTS_EQUIP_PARACHUTE)
                DZ_ENTS:Hint(ply, 14)
            end
        end
        ply:SetNWBool("DZ_Ents.Para.Auto", false)
        ply.DZ_ENTS_ParachutePending = nil
    elseif ply:GetNWBool("DZ_Ents.Para.Open") then

        local slowfall = -200
        local horiz_max = 300
        if vel.z < slowfall then
            vel.z = math.Approach(vel.z, slowfall, -FrameTime() * (1200 + math.abs(vel.z * 3)))
        else
            vel.z = math.Approach(vel.z, slowfall, -FrameTime() * 600)
        end

        -- vel = vel + eyeangles:Forward() * 100 * FrameTime()

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -50, 150)
        desiredmoveleft = math.Clamp(desiredmoveleft, -50, 50)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()


        local speedSqr = vel.x * vel.x + vel.y * vel.y
        local diff = speedSqr / (horiz_max * horiz_max)
        -- print(math.sqrt(speedSqr), horiz_max, diff)

        local xsign, ysign = (vel.x >= 0 and 1 or -1), (vel.y >= 0 and 1 or -1)
        local xabs, yabs = math.abs(vel.x), math.abs(vel.y)
        vel.x = xsign * math.Approach(xabs, 0, FrameTime() * 100 * diff / sqrt2)
        vel.y = ysign * math.Approach(yabs, 0, FrameTime() * 100 * diff / sqrt2)

        mv:SetVelocity(vel)
    elseif ply:GetNWBool("DZ_Ents.Para.Auto") then
        local trlen = math.Clamp(vel.z * 0.4, -1024, -328)
        local tr = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() + Vector(0, 0, trlen),
            mask = MASK_PLAYERSOLID,
            filter = ply
        })
        if tr.Hit then
            ply.DZ_ENTS_ParachutePending = true
            ply:SetNWBool("DZ_Ents.Para.Auto", false)
            -- if SERVER then
            --     local chute = ents.Create("DZ_Ents.Para.Open")
            --     chute:SetOwner(ply)
            --     chute:Spawn()
            --     ply:EmitSound("profiteers/para_open.wav", 110)
            -- end
        end
    end
end)

hook.Add("Move", "dz_ents_move", function(ply, mv)

end)

hook.Add("FinishMove", "dz_ents_move", function(ply, mv)

end)