AddCSLuaFile()

ENT.Base = "dz_base_ammo"

ENT.PrintName = "Ammo Box"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.SubCategory = "Ammo"
ENT.SortOrder = 1

ENT.Model = "models/props_survival/crates/crate_ammobox.mdl"
ENT.Center = nil

ENT.MaxBoxCount = 4
ENT.PickupDelay = 0.5
ENT.BoxCost = 1

if SERVER then
    function ENT:UpdateBoxes()
        for i = 1, self.MaxBoxCount do
            self:SetBodygroup(i, self:GetBoxes() < i and 1 or 0)
        end
        self:SetSkin(self:GetBoxes() == 0 and 1 or 0)
    end
end