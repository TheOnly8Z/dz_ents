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
        if (self.MaxBoxCount > 0 and box <= 0) or (ply.DZ_ENTS_NextUse or 0) > CurTime()
                or (self.DZ_ENTS_NextUse or 0) > CurTime()
                or not ply:Alive() or not IsValid(ply:GetActiveWeapon())
                or ply:GetPos():DistToSqr(self:GetPos()) >= 10000 then return end
        local wep = ply:GetActiveWeapon()
        local ammotype = game.GetAmmoName(wep:GetPrimaryAmmoType() or -1) or ""
        local canonclass = DZ_ENTS:GetCanonicalClass(wep:GetClass())
        local ammogiven
        local ammocat = DZ_ENTS:GetWeaponAmmoCategory(ammotype)

        if GetConVar("dzents_ammo_clip"):GetBool() then
            ammogiven = wep:GetMaxClip1()
        else
            ammogiven = canonclass and DZ_ENTS.CanonicalWeapons[canonclass].AmmoPickup or DZ_ENTS.AmmoTypeGiven[ammocat]
        end

        if (ammogiven or 0) <= 0 then return end
        ammogiven = ammogiven * self.AmmoMult * GetConVar("dzents_ammo_mult"):GetFloat()

        local adjustedammo = ammogiven / self.BoxCost
        self.Remainder = (self.Remainder or 0) + (adjustedammo - math.floor(adjustedammo)) / adjustedammo
        adjustedammo = math.floor(adjustedammo)

        local remainderammo = math.floor(self.Remainder * ammogiven / self.BoxCost)
        if remainderammo > 0 then
            self.Remainder = self.Remainder - remainderammo / ammogiven * self.BoxCost
            adjustedammo = adjustedammo + remainderammo
        end

        if self.MaxBoxCount > 0 and box == 1 and self.Remainder > 0 then
            adjustedammo = adjustedammo + math.Round(self.Remainder * ammogiven / self.BoxCost)
            self.Remainder = 0
        end

        -- the player cannot use other ammo boxes while this one is on cooldown.
        -- we also go on cooldown ourselves so other players can't pick us up.
        ply.DZ_ENTS_NextUse = CurTime() + self.PickupDelay
        self.DZ_ENTS_NextUse = CurTime() + self.PickupDelay

        if self.MaxBoxCount > 0 then
            self:SetBoxes(box - 1)
            self:UpdateBoxes()

            -- TODO: Maybe give some sort of indication for infinite ammo box being used
            net.Start("dz_ents_takeammo")
                net.WriteEntity(self)
                net.WriteUInt(box, 6)
            net.Send(ply)
        end

        if swcs and wep.IsSWCSWeapon and wep.GetReserveAmmo then
            wep:SetReserveAmmo(wep:GetReserveAmmo() + adjustedammo)
        else
            ply:GiveAmmo(adjustedammo, ammotype, true)
        end

        self:EmitSound("dz_ents/pickup_ammo_0" .. math.random(1, 2) .. ".wav")

        if self.ShellEffects then
            local eff = EffectData()
            eff:SetOrigin(self:GetPos())

            local shelltype = "RifleShellEject" -- used for effect
            if canonclass then
                if DZ_ENTS.CanonicalWeapons[canonclass].Category == "Pistol" or DZ_ENTS.CanonicalWeapons[canonclass].Category == "SMG" then
                    shelltype = "ShellEject"
                elseif DZ_ENTS.CanonicalWeapons[canonclass].Type == "Shotgun" then
                    shelltype = "ShotgunShellEject"
                end
            elseif ammocat == "shotgun" then
                shelltype = "ShotgunShellEject"
            elseif ammocat == "pistol" then
                shelltype = "ShellEject"
            end

            for i = 1, math.random(1, 4) do
                eff:SetAngles((self:GetUp() + VectorRand() * 0.1):Angle())
                util.Effect(shelltype, eff)
            end
        end

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