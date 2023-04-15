AddCSLuaFile()

ENT.Base = "dz_base_ammo"

ENT.PrintName = "Ammo Box (Stash)"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 3

ENT.Model = "models/dz_ents/ammo_stash.mdl"

ENT.MaxBoxCount = 5
ENT.PickupDelay = 0.8
ENT.BoxCost = 1
ENT.AmmoMult = 2

if SERVER then
    function ENT:UpdateBoxes()
        local d = math.ceil(self:GetBoxes() / self.MaxBoxCount * 5)
        self:SetBodygroup(1, 5 - d)
    end
end