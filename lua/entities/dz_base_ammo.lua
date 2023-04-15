AddCSLuaFile()

ENT.Base = "dz_base"

ENT.PrintName = "Base DZ Ammo"
ENT.Spawnable = false

ENT.UseType = CONTINUOUS_USE

ENT.Model = "models/props_survival/crates/crate_ammobox.mdl"
ENT.Center = nil

ENT.MaxBoxCount = 4
ENT.PickupDelay = 0.6
ENT.BoxCost = 1
ENT.AmmoMult = 1

-- uses DZ_ENTS.SortingAmmoTypes for my sanity
ENT.AmmoGiven = {
    ["pistol"] = 10,
    ["smg"] = 6, -- could be either smg or carbine. awkward!
    ["rifle"] = 5,
    ["shotgun"] = 4,
    ["magnum"] = 2,
    ["sniper"] = 1,
}

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Boxes")
    self:NetworkVar("Float", 0, "RegenTime")
end

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)

        self:SetBoxes(self.MaxBoxCount)
        self:UpdateBoxes()
    end

    function ENT:UpdateBoxes()
        for i = 1, self.MaxBoxCount do
            self:SetBodygroup(i, self:GetBoxes() < i and 1 or 0)
        end
        self:SetSkin(self:GetBoxes() == 0 and 1 or 0)
    end

    function ENT:Use(ply)
        local box = self:GetBoxes()
        if box <= 0 or (ply.DZ_ENTS_NextUse or 0) > CurTime()
                or not ply:Alive() or not IsValid(ply:GetActiveWeapon())
                or ply:GetPos():DistToSqr(self:GetPos()) >= 10000 then return end

        local wep = ply:GetActiveWeapon()
        local ammotype = game.GetAmmoName(wep:GetPrimaryAmmoType() or -1) or ""
        local canonclass = DZ_ENTS:GetCanonicalClass(wep:GetClass())
        local ammogiven = canonclass and DZ_ENTS.CanonicalWeapons[canonclass].AmmoPickup or self.AmmoGiven[DZ_ENTS:GetWeaponAmmoCategory(ammotype)]
        if not ammogiven then return end
        ammogiven = ammogiven * GetConVar("dzents_ammo_mult"):GetFloat()

        local adjustedammo = ammogiven / self.BoxCost
        self.Remainder = (self.Remainder or 0) + (adjustedammo - math.floor(adjustedammo)) / adjustedammo
        adjustedammo = math.floor(adjustedammo)

        local remainderammo = math.floor(self.Remainder * ammogiven / self.BoxCost)
        if remainderammo > 0 then
            self.Remainder = self.Remainder - remainderammo / ammogiven * self.BoxCost
            adjustedammo = adjustedammo + remainderammo
        end


        if box == 1 and self.Remainder > 0 then
            adjustedammo = adjustedammo + math.Round(self.Remainder * ammogiven / self.BoxCost)
            self.Remainder = 0
        end

        ply.DZ_ENTS_NextUse = CurTime() + self.PickupDelay
        self:SetBoxes(box - 1)
        self:UpdateBoxes()
        ply:GiveAmmo(math.min(adjustedammo * self.AmmoMult), ammotype, true)
        self:EmitSound("dz_ents/pickup_ammo_0" .. math.random(1, 2) .. ".wav")

        net.Start("dz_ents_takeammo")
            net.WriteEntity(self)
            net.WriteUInt(box, 6)
        net.Send(ply)

        if GetConVar("dzents_ammo_regen"):GetBool() then
            self:SetRegenTime(CurTime() + GetConVar("dzents_ammo_regen_delay"):GetFloat())
        elseif GetConVar("dzents_ammo_cleanup"):GetBool() and self:GetBoxes() == 0 then
            SafeRemoveEntityDelayed(self, 5)
        end
    end

    function ENT:Think()
        if self:GetRegenTime() > 0 and self:GetRegenTime() <= CurTime() then
            self:SetRegenTime(0)
            self:SetBoxes(self.MaxBoxCount)
            self:UpdateBoxes()
            self:EmitSound("items/ammocrate_close.wav", 80, 90)
        end
    end
end