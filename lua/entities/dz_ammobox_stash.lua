AddCSLuaFile()

ENT.Base = "dz_ammobox"

ENT.PrintName = "Ammo Box (Stash)"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 3

ENT.Model = "models/dz_ents/ammo_stash.mdl"

ENT.MaxBoxCount = 20
ENT.PickupDelay = 0.3
ENT.BoxCost = 2

if SERVER then
    function ENT:UpdateBoxes()
        local d = math.ceil(self:GetBoxes() / self.MaxBoxCount * 5)
        self:SetBodygroup(1, 5 - d)
    end
end