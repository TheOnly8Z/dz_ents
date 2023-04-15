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
        ply:DZ_ENTS_GiveEquipment(DZ_ENTS_EQUIP_PARACHUTE)
        DZ_ENTS:Hint(ply, 10)
        return true -- true to remove entity
    end

    function ENT:InteractStart(ply)
        self:EmitSound("dz_ents/parachute_pickup_start_01.wav")
    end

    function ENT:InteractCancel(ply)
    end

    function ENT:CanInteract(ply)
        if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) then
            DZ_ENTS:Hint(ply, 12)
            return false
        end
        return true
    end
end