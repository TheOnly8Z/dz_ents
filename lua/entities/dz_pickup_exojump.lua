AddCSLuaFile()

ENT.Base = "dz_base_pickup"

ENT.PrintName = "ExoJump"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 21

ENT.Model = "models/props_survival/upgrades/exojump.mdl"

ENT.InteractTime = 1

if SERVER then

    function ENT:InteractFinish(ply)
        self:EmitSound("dz_ents/parachute_pickup_success_01.wav")
        ply:DZ_ENTS_GiveEquipment(DZ_ENTS_EQUIP_EXOJUMP)
        DZ_ENTS:Hint(ply, 11)
        return true -- true to remove entity
    end

    function ENT:InteractStart(ply)
        self:EmitSound("dz_ents/parachute_pickup_start_01.wav")
    end

    function ENT:InteractCancel(ply)
    end

    function ENT:CanInteract(ply)
        if ply:DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then
            DZ_ENTS:Hint(ply, 13)
            return false
        end
        return true
    end
end