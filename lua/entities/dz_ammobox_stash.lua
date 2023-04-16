AddCSLuaFile()

ENT.Base = "dz_base_ammo"

ENT.PrintName = "Ammo Stash"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Ammo"
ENT.SortOrder = 3

ENT.Model = "models/dz_ents/ammo_stash.mdl"

ENT.MaxBoxCount = 10
ENT.PickupDelay = 0.25
ENT.BoxCost = 2
ENT.AmmoMult = 1
ENT.ShellEffects = true

if SERVER then
    function ENT:UpdateBoxes()
        local d = math.ceil(self:GetBoxes() / self.MaxBoxCount * 5)
        self:SetBodygroup(1, 5 - d)
    end
end