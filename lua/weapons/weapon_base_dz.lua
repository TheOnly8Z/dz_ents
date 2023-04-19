AddCSLuaFile()

if GetConVar("dzents_equipment_swcs"):GetBool() and swcs then
    SWEP.Base = "weapon_swcs_base"
else
    SWEP.Base = "weapon_base"
end
DEFINE_BASECLASS(SWEP.Base)

SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Primary.DefaultClip = 1

SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = ""

SWEP.HoldType = "normal"

function SWEP:Ammo1()
    if self.Base == "weapon_swcs_base" then
        print(self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()))
        return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
    else
        return BaseClass.Ammo1(self)
    end
end

function SWEP:RemoveAndSwitch()
    if SERVER then
        self:Remove()
    end
    if (CLIENT and LocalPlayer() == self:GetOwner()) then
        local switch = self:GetOwner():GetPreviousWeapon()
        if not IsValid(switch) or not switch:IsWeapon() then
            for _, v in ipairs(self:GetOwner():GetWeapons()) do
                if IsValid(v) and v ~= self then switch = v break end
            end
        end
        input.SelectWeapon(switch)
    end
end

SWEP.WepSelectIcon = Material("dz_ents/select/healthshot.png", "smooth")
SWEP.WepSelectIconRatio = 0.75

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(self.WepSelectIcon)

    -- Borders
    y = y + 10
    x = x + 40
    wide = wide - 80

    surface.DrawTexturedRect(x, y, wide, wide * self.WepSelectIconRatio)
    self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
end

--------------------------------------- Override/re-implement some SWCS stuff

function SWEP:GetDeploySpeed()
    if GetConVar("dzents_equipment_swcs"):GetBool() and GetConVar("swcs_deploy_override") and GetConVar("swcs_deploy_override"):GetFloat() ~= 0 then
        return GetConVar("swcs_deploy_override"):GetFloat()
    end
    return engine.ActiveGamemode() == "terrortown" and 1.4 or (GetConVar("sv_defaultdeployspeed"):GetFloat() / 2)
end

function SWEP:SetWeaponAnim(idealAct, flPlaybackRate)
    local idealSequence = self:SelectWeightedSequence(idealAct)
    if idealSequence == -1 then return false end
    flPlaybackRate = isnumber(flPlaybackRate) and flPlaybackRate or 1

    self:SendWeaponAnim(idealAct)
    self:SendViewModelMatchingSequence(idealSequence)

    local owner = self:GetOwner()
    if owner:IsValid() then
        local vm = owner:GetViewModel()
        if vm:IsValid() and idealSequence then
            vm:SendViewModelMatchingSequence(idealSequence)
            vm:SetPlaybackRate(flPlaybackRate)
        end
    end

    -- Set the next time the weapon will idle
    self:SetWeaponIdleTime(CurTime() + (self:SequenceDuration() * flPlaybackRate))
    return true
end