AddCSLuaFile()

ENT.Base = "dz_base_ammo"

ENT.PrintName = "Ammo Box (Belt)"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Ammo"
ENT.SortOrder = 2

ENT.Model = "models/props_survival/crates/crate_ammobox_belt.mdl"

ENT.MaxBoxCount = 16
ENT.PickupDelay = 0.35
ENT.BoxCost = 3.2

if SERVER then
    function ENT:UpdateBoxes()
        for i = 1, self.MaxBoxCount do
            self:SetBodygroup(i, self:GetBoxes() <= (self.MaxBoxCount - i) and 1 or 0)
        end
        self:SetBodygroup(self.MaxBoxCount + 1, self:GetBoxes() == 0 and 1 or 0)
        self:SetSkin(self:GetBoxes() == 0 and 1 or 0)
    end
end