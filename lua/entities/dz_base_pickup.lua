AddCSLuaFile()

ENT.Base = "dz_base"

ENT.PrintName = "Base DZ Interactable"
ENT.Spawnable = false

ENT.Model = "models/props_junk/cardboard_box004a.mdl"
ENT.UseType = CONTINUOUS_USE
ENT.InteractTime = 1

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "UsingPlayer")
    self:NetworkVar("Float", 0, "UseStart")
    self:NetworkVar("Float", 1, "UseTime")
end

local bits = 2
local none = 0
local start = 1
local cancel = 2
local finish = 3

if SERVER then

    ENT.NextUse = 0

    function ENT:InteractFinish(ply)
        return true -- true to remove entity
    end

    function ENT:InteractStart(ply)
    end

    function ENT:InteractCancel(ply)
    end

    function ENT:CanInteract(ply)
        return true
    end

    function ENT:GetInteractDuration(ply)
        return self.InteractTime
    end

    function ENT:IsUsing()
        return IsValid(self:GetUsingPlayer()) and self:GetUseStart() > 0
    end

    function ENT:CanUse(ply)
        return ply:Alive() and (not IsValid(ply.DZ_ENTS_Interacting) or ply.DZ_ENTS_Interacting == self)
                and ply:KeyDown(IN_USE) and ply:EyePos():DistToSqr(self:GetPos()) <= 10000 and
                (ply:GetEyeTrace().Entity == self or ply:GetAimVector():Dot((self:GetPos() - ply:EyePos()):GetNormalized()) >= 0.75)
    end

    function ENT:Use(ply)
        if self.NextUse > CurTime() then return end
        if self:IsUsing() then return end
        if not self:CanUse(ply) or not self:CanInteract(ply) then return end

        self.NextUse = CurTime() + 0.5

        if DZ_ENTS.ConVars["pickup_instantuse"]:GetBool() then
            local remove = self:InteractFinish(ply)
            if remove then SafeRemoveEntity(self) end
        else
            ply.DZ_ENTS_Interacting = self
            self:SetUsingPlayer(ply)
            self:SetUseStart(CurTime())
            self:SetUseTime(self:GetInteractDuration(ply))

            net.Start("dz_ents_interact")
                net.WriteEntity(self)
                net.WriteUInt(start, bits)
            net.Send(ply)

            self:InteractStart(ply)
        end
    end

    function ENT:Think()
        if self:IsUsing() then
            local ply = self:GetUsingPlayer()
            if not IsValid(ply) or self:GetUseStart() == 0 then
                self:SetUsingPlayer(NULL)
                self:SetUseStart(0)
                return
            end

            if not self:CanUse(ply) or not self:CanInteract(ply) then
                self:InteractCancel(ply)

                net.Start("dz_ents_interact")
                    net.WriteEntity(self)
                    net.WriteUInt(cancel, bits)
                net.Send(ply)

                ply.DZ_ENTS_Interacting = nil
                self:SetUsingPlayer(NULL)
                self:SetUseStart(0)
                self.NextUse = CurTime() + 0.5

            elseif self:GetUseStart() + self:GetUseTime() <= CurTime() then
                local remove = self:InteractFinish(ply)

                net.Start("dz_ents_interact")
                    net.WriteEntity(self)
                    net.WriteUInt(finish, bits)
                net.Send(ply)

                ply.DZ_ENTS_Interacting = nil
                if remove then
                    SafeRemoveEntity(self)
                else
                    self:SetUsingPlayer(NULL)
                    self:SetUseStart(0)
                    self.NextUse = CurTime() + 0.5
                end
            end

        end
    end

    function ENT:AllowMarkedRemove()
        return not self:IsUsing()
    end
else
    local state = none
    local ent = nil
    net.Receive("dz_ents_interact", function()
        ent = net.ReadEntity()
        state = net.ReadUInt(bits)

        -- TODO: UI
        -- print(ent, state)
    end)
end