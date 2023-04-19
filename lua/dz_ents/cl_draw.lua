surface.CreateFont("dz_ents_hint", {
    font = "Arial",
    size = ScreenScale(10),
    weight = 700,
    extended = true
})

local damaged = {}
local ammouse = {}
local hint = nil
net.Receive("dz_ents_damage", function()
    local ent = net.ReadEntity()
    local health = net.ReadFloat()
    if not IsValid(ent) then return end

    if damaged[ent] then
        damaged[ent][1] = CurTime()
        damaged[ent][3] = math.Clamp((damaged[ent][2] - ent:Health()) / ent:GetMaxHealth(), 0.15, 0.6)
    else
        damaged[ent] = {CurTime(), health, math.Clamp((health - ent:Health()) / ent:GetMaxHealth(), 0.15, 0.6)}
    end
end)
net.Receive("dz_ents_takeammo", function()
    local ent = net.ReadEntity()
    local lastbox = net.ReadUInt(6)
    if not IsValid(ent) then return end

    if ammouse[ent] then
        ammouse[ent][1] = CurTime()
    else
        ammouse[ent] = {CurTime(), lastbox}
    end
end)
net.Receive("dz_ents_hint", function()
    local useent = net.ReadBool()
    local ent = useent and net.ReadEntity() or false
    local i = net.ReadUInt(DZ_ENTS.HintBits)
    hint = {CurTime(), i, ent}

    if DZ_ENTS.Hints[i][2] then
        surface.PlaySound("dz_ents/info_tips_01.wav")
    end
end)

hook.Add("HUDPaint", "dz_ents_healthbar", function()
    local pos2d = {}
    local poshint
    cam.Start3D()
    for k, v in pairs(damaged) do
        if not IsValid(k) or v[1] + 3 <= CurTime() or k:Health() <= 0 then damaged[k] = nil continue end
        pos2d[k] = (k.Center and k:LocalToWorld(k.Center) or k:WorldSpaceCenter()):ToScreen()
    end
    for k, v in pairs(ammouse) do
        if not IsValid(k) or v[1] + 2 <= CurTime() then ammouse[k] = nil continue end
        pos2d[k] = (k.Center and k:LocalToWorld(k.Center) or k:WorldSpaceCenter()):ToScreen()
    end
    if hint and ((hint[1] or 0) + 5 <= CurTime() or (hint[3] ~= false and not IsValid(hint[3]))) then
        hint = nil
    elseif hint and hint[3] ~= false and IsValid(hint[3]) then
        poshint = (hint[3].Center and hint[3]:LocalToWorld(hint[3].Center) or hint[3]:WorldSpaceCenter()):ToScreen()
    end
    cam.End3D()

    if hint then
        local x, y = ScrW() * 0.5, ScrH() * 0.7
        local a = math.Clamp((hint[1] + 5 - CurTime()) / 1, 0, 1)
        local c = 255
        if DZ_ENTS.Hints[hint[2]][2] and  hint[1] + 0.5 > CurTime() then
            local flash = (math.sin(CurTime() * math.pi * 10) + 1) / 2
            a = flash * 0.4 + 0.6
            c = flash * 100 + 155
        end
        if poshint then
            x, y = poshint.x, poshint.y
        end
        draw.SimpleTextOutlined(DZ_ENTS.Hints[hint[2]][1], "dz_ents_hint", x, y, Color(c, c, c, 255 * a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 100 * a))
    end


    for k, v in pairs(damaged) do
        local s = math.Clamp(1 - (k:GetPos():DistToSqr(EyePos()) / 9437184), 0.25, 1)
        local w, h = 192 * s, 12 * s
        local edge = 2 * s
        local a = math.Clamp((v[1] + 3 - CurTime()) / 0.5, 0, 1)
        surface.SetDrawColor(0, 0, 0, a * 200)
        surface.DrawRect(pos2d[k].x - w / 2 - edge, pos2d[k].y - h / 2 - edge, w + edge * 2, h + edge * 2)

        local d1 = math.max(0, v[2] / k:GetMaxHealth())
        local d2 = math.max(0, k:Health() / k:GetMaxHealth())
        local w_diff = math.floor(w * d2)

        surface.SetDrawColor(240, 35, 20, a * 255)
        surface.DrawRect(pos2d[k].x - w / 2 + w_diff, pos2d[k].y - h / 2, w * math.max(0, d1 - d2), h)

        surface.SetDrawColor(155, 200, 75, a * 255)
        surface.DrawRect(pos2d[k].x - w / 2, pos2d[k].y - h / 2, w_diff, h)

        v[2] = math.Approach(v[2], k:Health(), FrameTime() * v[3] * 250)
    end

    for k, v in pairs(ammouse) do
        local w, h = 192, 12
        local edge = 2
        local a = math.Clamp((v[1] + 2 - CurTime()) / 0.5, 0, 1)

        surface.SetDrawColor(0, 0, 0, a * 200)
        surface.DrawRect(pos2d[k].x - w / 2 - edge, pos2d[k].y - 8 - edge, w + edge * 2, h + edge * 2)

        local d1 = math.max(0, v[2] / k.MaxBoxCount)
        local d2 = math.max(0, k:GetBoxes() / k.MaxBoxCount)
        local w_diff = math.floor(w * d2)

        surface.SetDrawColor(95, 95, 95, a * 255)
        surface.DrawRect(pos2d[k].x - w / 2 + w_diff, pos2d[k].y - 8, w * math.max(0, d1 - d2), h)

        surface.SetDrawColor(220, 150, 0, a * 255)
        surface.DrawRect(pos2d[k].x - w / 2, pos2d[k].y - 8, w_diff, h)

        v[2] = math.Approach(v[2], k:GetBoxes(), FrameTime() * (1 / k.PickupDelay) * 0.85)
    end
end)

-- CS:GO proper has a texture and some pixel shader that I don't want to bother looking at.
local overlay_healthshot = Material("dz_ents/overlay_healthshot.png")

local parachute_frame = 0
hook.Add("HUDPaintBackground", "dz_ents_overlays", function()

    if GetConVar("cl_dzents_healthshot_overlay"):GetBool() and ply:GetNWFloat("DZ_Ents.Healthshot", 0) > CurTime() then
        surface.SetMaterial(overlay_healthshot)
        surface.SetDrawColor(255, 255, 255, 100 * math.Clamp((ply:GetNWFloat("DZ_Ents.Healthshot", 0) - CurTime()) / 0.5, 0, 1))
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end

    if GetConVar("cl_dzents_parachute_frame"):GetBool() then
        if ply:GetNWBool("DZ_Ents.Para.Open") then
            parachute_frame = math.Approach(parachute_frame, 1, RealFrameTime() * 2)
        else
            parachute_frame = math.Approach(parachute_frame, 0, RealFrameTime() * 2)
        end
        if parachute_frame > 0 then
            local h = math.ceil(parachute_frame * ScrH() * 0.05)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, ScrW(), h)

            surface.DrawRect(0, ScrH() - h, ScrW(), h)
        end
    end
end)