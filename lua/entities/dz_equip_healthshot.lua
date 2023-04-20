AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Medi-Shot"
ENT.Spawnable = true

ENT.Category = "Danger Zone"
ENT.SubCategory = "Equipment"
ENT.SortOrder = 2

ENT.ActualEntity = "weapon_dz_healthshot"
ENT.IconOverride = "materials/entities/weapon_dz_healthshot.png"

function ENT:SpawnFunction(ply, tr, classname)
    if not tr.Hit then return end

    local ang = ply:EyeAngles()
    ang.p = 0
    ang.y = ang.y + 180

    local ent = ents.Create(self.ActualEntity)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self:Remove()
end