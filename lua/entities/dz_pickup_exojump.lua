AddCSLuaFile()

ENT.Base = "dz_base_pickup"

ENT.PrintName = "ExoJump"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 21

ENT.Model = "models/props_survival/upgrades/exojump.mdl"

ENT.InteractTime = 5

if SERVER then

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
end