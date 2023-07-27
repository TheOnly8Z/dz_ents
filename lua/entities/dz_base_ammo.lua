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
ENT.ConsumeOnUse = false

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

        if DZ_ENTS.ConVars["ammo_clip"]:GetBool() then
            ammogiven = wep:GetMaxClip1()
        else
            ammogiven = canonclass and DZ_ENTS.CanonicalWeapons[canonclass].AmmoPickup or DZ_ENTS.AmmoTypeGiven[ammocat]
        end

        -- ideal amount of ammo to give out, not counting box cost and limit
        if (ammogiven or 0) <= 0 then return end
        ammogiven = ammogiven * self.AmmoMult * DZ_ENTS.ConVars["ammo_mult"]:GetFloat()

        -- adjust ammo given with box cost ("efficiency" of each use) and store fractional boxes
        local adjustedammo = ammogiven / self.BoxCost
        self.Remainder = (self.Remainder or 0) + (adjustedammo - math.floor(adjustedammo)) / adjustedammo
        adjustedammo = math.floor(adjustedammo)

        -- see if fractional boxes is enough to give ammo and deduct if so
        local remainderammo = math.floor(self.Remainder * ammogiven / self.BoxCost)
        if remainderammo > 0 then
            self.Remainder = self.Remainder - remainderammo / ammogiven * self.BoxCost
            adjustedammo = adjustedammo + remainderammo
        end

        -- on the last box, give out all remainder
        if self.MaxBoxCount > 0 and box == 1 and self.Remainder > 0 then
            adjustedammo = adjustedammo + math.Round(self.Remainder * ammogiven / self.BoxCost)
            -- self.Remainder = 0
        end

        -- see if we are reaching ammo limit
        local max = 9999
        local limit = DZ_ENTS.ConVars["ammo_limit"]:GetFloat()
        if limit > 0 then
            if engine.ActiveGamemode() == "terrortown" then
                max = wep.Primary.ClipMax
                adjustedammo = math.min(adjustedammo, max - ply:GetAmmoCount(ammotype))
            elseif swcs and wep.IsSWCSWeapon and GetConVar("swcs_weapon_individual_ammo") and GetConVar("swcs_weapon_individual_ammo"):GetBool() and wep.GetReserveAmmo then
                max = math.ceil(wep:GetPrimaryReserveMax() * limit)
                adjustedammo = math.min(adjustedammo, max - wep:GetReserveAmmo())
            else
                max = DZ_ENTS.AmmoMaxReserveSWCS[ammotype] or game.GetAmmoMax(wep:GetPrimaryAmmoType() or -1)
                if not max or max == 9999 then
                    max = DZ_ENTS.AmmoMaxReserve[ammocat] or (GetConVar("gmod_maxammo"):GetInt() > 0 and GetConVar("gmod_maxammo"):GetInt()) or 100
                end
                max = math.ceil(max * limit)
                adjustedammo = math.min(adjustedammo, max - ply:GetAmmoCount(ammotype))
            end
            if adjustedammo <= 0 then
                if ply:GetAmmoCount(ammotype) >= max then
                    DZ_ENTS:Hint(ply, 16)
                end
                return
            end
        end

        -- the player cannot use other ammo boxes while this one is on cooldown.
        -- we also go on cooldown ourselves so other players can't pick us up.
        ply.DZ_ENTS_NextUse = CurTime() + self.PickupDelay
        self.DZ_ENTS_NextUse = CurTime() + self.PickupDelay

        if swcs and wep.IsSWCSWeapon and GetConVar("swcs_weapon_individual_ammo") and GetConVar("swcs_weapon_individual_ammo"):GetBool() and wep.GetReserveAmmo then
            wep:SetReserveAmmo(wep:GetReserveAmmo() + adjustedammo)
        else
            ply:GiveAmmo(adjustedammo, ammotype, true)
        end

        self:EmitSound("dz_ents/pickup_ammo_0" .. math.random(1, 2) .. ".wav")

        if self.ShellEffects then
            local eff = EffectData()
            eff:SetOrigin(self:GetPos())
            eff:SetEntity(self)

            local shelltype = "RifleShellEject" -- used for effect
            if canonclass then
                if DZ_ENTS.CanonicalWeapons[canonclass].Category == "Pistol" or DZ_ENTS.CanonicalWeapons[canonclass].Category == "SMG" then
                    shelltype = "ShellEject"
                elseif DZ_ENTS.CanonicalWeapons[canonclass].ShellType == "Shotgun" then
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

        if self.MaxBoxCount > 0 then
            self:SetBoxes(box - 1)
            self:UpdateBoxes()

            if self.ConsumeOnUse and self:GetBoxes() == 0 then
                self:Remove()
                return
            end

            -- TODO: Maybe give some sort of indication for infinite ammo box being used
            net.Start("dz_ents_takeammo")
                net.WriteEntity(self)
                net.WriteUInt(box, 6)
            net.Send(ply)

            if DZ_ENTS.ConVars["ammo_regen"]:GetBool() then
                local partial = DZ_ENTS.ConVars["ammo_regen_partial"]:GetBool() and self.MaxBoxCount or 1
                self:SetRegenTime(CurTime() + DZ_ENTS.ConVars["ammo_regen_delay"]:GetFloat() / partial)
            elseif DZ_ENTS.ConVars["ammo_cleanup"]:GetBool() and self:GetBoxes() == 0 then
                self:MarkForRemove(3)
            end
        end
    end

    function ENT:Think()
        if self:GetRegenTime() > 0 and self:GetRegenTime() <= CurTime() then
            if DZ_ENTS.ConVars["ammo_regen_partial"]:GetBool() and self:GetBoxes() + 1 < self.MaxBoxCount then
                self:SetRegenTime(CurTime() + DZ_ENTS.ConVars["ammo_regen_delay"]:GetFloat() / self.MaxBoxCount)
                self:SetBoxes(self:GetBoxes() + 1)
            else
                self:SetRegenTime(0)
                self:SetBoxes(self.MaxBoxCount)
                self.Remainder = 0
            end
            self:UpdateBoxes()
            -- self:EmitSound("items/ammocrate_close.wav", 80, 90)
        end
    end
end