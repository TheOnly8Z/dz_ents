AddCSLuaFile()

ENT.Base = "dz_base_pickup"

ENT.PrintName = "Parachute"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 20

ENT.Model = "models/props_survival/upgrades/parachutepack.mdl"

ENT.InteractTime = 1.5

if SERVER then

    function ENT:InteractFinish(ply)
        self:EmitSound("dz_ents/parachute_pickup_success_01.wav")
        return true -- true to remove entity
    end

    function ENT:InteractStart(ply)
        self:EmitSound("dz_ents/parachute_pickup_start_01.wav")
    end

    function ENT:InteractCancel(ply)
    end

    function ENT:CanInteract(ply)
        return true
    end
end