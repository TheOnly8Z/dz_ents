AddCSLuaFile()

if GetConVar("dzents_equipment_swcs"):GetBool() and swcs then
    SWEP.Base = "weapon_swcs_base"
else
    SWEP.Base = "weapon_base"
end
DEFINE_BASECLASS(SWEP.Base)

SWEP.AmmoType = ""

SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Primary.DefaultClip = 1

SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = ""

SWEP.HoldType = "normal"

function SWEP:SetupDataTables()
    if BaseClass.SetupDataTables then
        BaseClass.SetupDataTables(self)
    end
    if not self.GetWeaponIdleTime then
        self:NetworkVar("Float", 1, "WeaponIdleTime")
    end
end


function SWEP:Ammo1()
    if self.Base == "weapon_swcs_base" then
        return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
    else
        return BaseClass.Ammo1(self)
    end
end

function SWEP:TakePrimaryAmmo(amt)
    self:GetOwner():RemoveAmmo(amt, self:GetPrimaryAmmoType())
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

function SWEP:Initialize()
    BaseClass.Initialize(self, false)

    -- SWCS hates ammo types apparently
    self.Primary.Ammo = self.AmmoType

    -- engine deploy blocks weapon from thinking and doing most stuff
    self.m_WeaponDeploySpeed = 255
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not owner or not owner:IsPlayer() then return end

    self:SetHoldType(self.HoldType)
    self:SetWeaponAnim(ACT_VM_DEPLOY)

    local vm = owner:GetViewModel(self:ViewModelIndex())
    if vm:IsValid() then
        vm:SetPlaybackRate(self:GetDeploySpeed())
        self:SetWeaponIdleTime(CurTime() + (self:SequenceDuration() * (1 / self:GetDeploySpeed())))
    end
    self:SetNextPrimaryFire(CurTime() + self:SequenceDuration() * (1 / self:GetDeploySpeed()) * 0.9)

    return true
end

function SWEP:Reload()
    local ply = self:GetOwner()
    if ply:KeyPressed(IN_RELOAD) and self:Ammo1() > 0 then

        self:SetNextPrimaryFire(CurTime() + 0.75)
        ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)

        if SERVER then
            ply:RemoveAmmo(1, self:GetPrimaryAmmoType())

            local ent = ents.Create(self:GetClass())
            ent:SetPos(ply:GetShootPos() - Vector(0, 0, 12))
            ent:SetAngles(ply:EyeAngles() + AngleRand())
            ent.Primary.DefaultClip = 1
            ent:Spawn()
            ent.DZENTS_Pickup = CurTime() + 1
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocityInstantaneous(ply:GetAimVector() * 400)
                phys:AddAngleVelocity(VectorRand() * 200)
            end

            if GetConVar("dzents_drop_cleanup"):GetFloat() > 0 then
                timer.Simple(GetConVar("dzents_drop_cleanup"):GetFloat(), function()
                    if IsValid(ent) and not IsValid(ent:GetOwner()) then
                        ent.DZENTS_Pickup = CurTime() + 2
                        ent:SetRenderMode(RENDERMODE_TRANSALPHA) -- doesn't seem to work but whatever
                        ent:SetRenderFX(kRenderFxFadeSlow)
                        SafeRemoveEntityDelayed(ent, 1)
                    end
                end)
            end
        end

        if self:Ammo1() <= 0 then
            self:SetWeaponAnim(ACT_VM_IDLE)
            self:RemoveAndSwitch()
        else
            self:Deploy()
        end
    end
end

SWEP.WepSelectIcon = Material("dz_ents/select/healthshot.png", "smooth")
SWEP.WepSelectIconRatio = 0.75

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(self.WepSelectIcon)

    -- Borders
    y = y + 10
    -- x = x + 20
    -- wide = wide - 20
    tall = tall - 50

    local h, w = tall, tall / self.WepSelectIconRatio

    surface.DrawTexturedRect(x - w / 2 + wide / 2, y, w, h)
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