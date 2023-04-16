DZ_ENTS.CL_PlayerAttachModels = DZ_ENTS.CL_PlayerAttachModels or {}


function DZ_ENTS.CleanupCSModels()
    for ply, tbl in pairs(DZ_ENTS.CL_PlayerAttachModels) do
        for _, mdl in pairs(tbl) do
            SafeRemoveEntity(mdl)
        end
    end
end
concommand.Add("cl_dzents_debug_cleanupcsmodel", DZ_ENTS.CleanupCSModels)

function DZ_ENTS.CollectGarbage()
    local removed = 0
    local newpile = {}
    for ply, tbl in pairs(DZ_ENTS.CL_PlayerAttachModels) do
        if IsValid(ply) and ply:Alive() then
            newpile[ply] = tbl
            continue
        end
        for _, mdl in pairs(tbl) do
            SafeRemoveEntity(mdl)
        end
        removed = removed + 1
    end
    DZ_ENTS.CL_PlayerAttachModels = newpile
    if GetConVar("developer"):GetBool() and removed > 0 then
        print("Removed " .. tostring(removed) .. " CSModels")
    end
end
hook.Add("PostCleanupMap", "dz_ents_model", function()
    DZ_ENTS.CollectGarbage()
end)
timer.Create("DZ_ENTS CSModel Garbage Collector", 5, 0, DZ_ENTS.CollectGarbage)

local offset = Vector(0, 0, -10)
local offset_crouch = Vector(0, 0, -20)
hook.Add("PostPlayerDraw", "dzents_model", function(ply, flags)
    DZ_ENTS.CL_PlayerAttachModels[ply] = DZ_ENTS.CL_PlayerAttachModels[ply] or {}

    if ply:GetNWBool("DZ_Ents.Para.Open") then
        if not IsValid(DZ_ENTS.CL_PlayerAttachModels[ply].chute) then
            local model = ClientsideModel("models/props_survival/parachute/chute.mdl")
            model:DrawShadow(false)
            model:SetNoDraw(false)
            model:SetColor(Color(255, 255, 255, 0))
            model:SetRenderFX(kRenderFxSolidFast)
            model:SetRenderMode(RENDERMODE_TRANSADD)
            model:ResetSequence(2)
            DZ_ENTS.CL_PlayerAttachModels[ply].chute = model
        end
    else
        if IsValid(DZ_ENTS.CL_PlayerAttachModels[ply].chute) then
            local clr = DZ_ENTS.CL_PlayerAttachModels[ply].chute:GetColor()
            if DZ_ENTS.CL_PlayerAttachModels[ply].chute:GetRenderFX() ~= kRenderFxFadeFast then
                DZ_ENTS.CL_PlayerAttachModels[ply].chute:SetRenderFX(kRenderFxFadeFast)
                DZ_ENTS.CL_PlayerAttachModels[ply].chute:ResetSequence(1)
            elseif clr.a == 0 then
                SafeRemoveEntity(DZ_ENTS.CL_PlayerAttachModels[ply].chute)
                DZ_ENTS.CL_PlayerAttachModels[ply].chute = nil
            end
        end
    end

    if IsValid(DZ_ENTS.CL_PlayerAttachModels[ply].chute) then

        local pos, ang = ply:GetPos() + (ply:Crouching() and offset_crouch or offset), ply:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90)

        local model = DZ_ENTS.CL_PlayerAttachModels[ply].chute
        model:SetPos(pos)
        model:SetAngles(ang)
        model:SetRenderOrigin(pos)
        model:SetRenderAngles(ang)
        model:FrameAdvance()
        if model:GetSequence() == 2 and model:GetCycle() == 1 then
            model:ResetSequence(0) -- idle animation
        end

        -- Refuse to draw the model on ourselves if we are in first person, since the parachute model lines up poorly.
        -- This typically only happens when we are visible in a mirror.
        model:SetNoDraw(ply == LocalPlayer() and EyePos() == LocalPlayer():EyePos())

        model.ActiveFrame = FrameNumber()
    end
end)

hook.Add("PostDrawTranslucentRenderables", "dzents_model", function()
    if not DZ_ENTS.CL_PlayerAttachModels then return end
    for ply, tbl in pairs(DZ_ENTS.CL_PlayerAttachModels) do

        for name, mdl in pairs(tbl) do
            if not IsValid(mdl) then continue end
            if not IsValid(ply) or not ply:Alive() then
                tbl[name] = nil
                mdl:SetRenderFX(kRenderFxFadeFast)
                SafeRemoveEntityDelayed(mdl, 1)
            elseif ply == LocalPlayer() and EyePos() == LocalPlayer():EyePos() then
                -- Hide the model. We have to do this here because we can't DrawModel() every frame (renderfx will not work)
                -- and PostPlayerDraw won't be called if we stopped drawing the player (switching from thirdperson, walking away from mirror, etc).
                mdl:SetNoDraw(true)
            end
        end
    end
end)

hook.Add("PostDrawViewModel", "dzents_model", function(vm, ply, weapon)
    if vm ~= ply:GetViewModel(0) then return end
    DZ_ENTS.CL_PlayerAttachModels[ply] = DZ_ENTS.CL_PlayerAttachModels[ply] or {}

    local model = DZ_ENTS.CL_PlayerAttachModels[ply].parastrap
    if ply:GetNWBool("DZ_Ents.Para.Open") then
        if GetConVar("cl_dzents_vmparachute"):GetBool() and not IsValid(DZ_ENTS.CL_PlayerAttachModels[ply].parastrap) then
            DZ_ENTS.CL_PlayerAttachModels[ply].parastrap = ClientsideModel("models/weapons/v_parachute.mdl")
            model = DZ_ENTS.CL_PlayerAttachModels[ply].parastrap
            model:DrawShadow(false)
            model:SetNoDraw(true)
            model:ResetSequence(1)
        end
    else
        if IsValid(model) then
            if model:GetSequence() ~= 2 then
                model:ResetSequence(2)
                model:SetCycle(0)
            elseif model:GetCycle() == 1 then
                SafeRemoveEntity(model)
                DZ_ENTS.CL_PlayerAttachModels[ply].parastrap = nil
            end
        end
    end

    if IsValid(model) then
        local pos, ang = ply:EyePos(), ply:EyeAngles() --vm:GetPos(), vm:GetAngles()
        model:SetPos(pos)
        model:SetAngles(ang)
        model:SetRenderOrigin(pos)
        model:SetRenderAngles(ang)
        model:FrameAdvance()
        model:DrawModel()
        if model:GetSequence() == 1 and model:GetCycle() == 1 then
            model:ResetSequence(0)
            model:SetCycle(0)
        end
    end
end)