AddCSLuaFile()

ENT.Base = "base_anim"

ENT.PrintName = "Ammo Box"
ENT.Spawnable = true
ENT.Category = "Danger Zone"

ENT.IsDZEnt = true
ENT.SubCategory = "Pickups"
ENT.SortOrder = 1

ENT.Model = "models/props_survival/crates/crate_ammobox.mdl"
ENT.Center = nil

ENT.MaxBoxCount = 4
ENT.PickupDelay = 0.6
ENT.BoxCost = 1

-- uses DZ_ENTS.SortingAmmoTypes for my sanity
ENT.AmmoGiven = {
    ["pistol"] = 10,
    ["smg"] = 6, -- could be either smg or carbine. awkward!
    ["rifle"] = 5,
    ["shotgun"] = 4,
    ["magnum"] = 2,
    ["sniper"] = 1,
}

ENT.WeaponAmmoGiven = {
    ["weapon_swcs_revolver"] = 1,
    ["weapon_swcs_awp"] = 1,
    ["weapon_swcs_scar20"] = 1,
    ["weapon_swcs_g3sg1"] = 1,
    ["weapon_swcs_deagle"] = 2,
    ["weapon_swcs_ssg08"] = 2,
    ["weapon_swcs_sg556"] = 4,
    ["weapon_swcs_aug"] = 4,
    ["weapon_swcs_mag7"] = 5,
    ["weapon_swcs_sawedoff"] = 5,
    ["weapon_swcs_nova"] = 5,
    ["weapon_swcs_xm1014"] = 5,
    ["weapon_swcs_ak47"] = 5,
    ["weapon_swcs_fiveseven"] = 6,
    ["weapon_swcs_cz75"] = 6,
    ["weapon_swcs_usp_silencer"] = 6,
    ["weapon_swcs_m4a1"] = 6,
    ["weapon_swcs_m4a1_silencer"] = 6,
    ["weapon_swcs_hkp2000"] = 7,
    ["weapon_swcs_p250"] = 7,
    ["weapon_swcs_galilar"] = 7,
    ["weapon_swcs_famas"] = 7,
    ["weapon_swcs_elite"] = 10,
    ["weapon_swcs_glock"] = 10,
    ["weapon_swcs_mac10"] = 10,
    ["weapon_swcs_mp5sd"] = 10,
    ["weapon_swcs_mp7"] = 10,
    ["weapon_swcs_mp9"] = 10,
    ["weapon_swcs_p90"] = 10,
    -- not technically true to game but they deserve it <3
    ["weapon_swcs_m249"] = 12,
    ["weapon_swcs_bizon"] = 15,
    ["weapon_swcs_negev"] = 20,
}


function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Boxes")
    self:NetworkVar("Float", 0, "RegenTime")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:PhysWake()

        self:SetUseType(CONTINUOUS_USE)

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
        ply:GiveAmmo(adjustedammo, ammotype, true)
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

    function ENT:PhysicsCollide(colData, collider)
        -- https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/game/server/physics.cpp
        if colData.DeltaTime >= 0.05 and colData.Speed >= 70 then
            -- can't use EmitSound since volume is not controllable with soundscripts
            local surfdata = util.GetSurfaceData(colData.OurSurfaceProps)
            self.ImpactSound = CreateSound(self, colData.Speed > 200 and surfdata.impactHardSound or surfdata.impactSoftSound)
            self.ImpactSound:PlayEx(math.Clamp(colData.Speed / 320, 0, 1), 100)
        end
    end

    function ENT:OnRemove()
        if self.ImpactSound then
            self.ImpactSound:Stop()
            self.ImpactSound = nil
        end
    end
end