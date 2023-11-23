AddCSLuaFile()

if DZ_ENTS.ConVars["equipment_swcs"]:GetBool() and swcs then
    SWEP.Base = "weapon_swcs_base"
else
    SWEP.Base = "weapon_base"
end

-- SWEP.Base = "weapon_base"
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

-- Bit of a hack, TTT doesn't like things with clip -1, but I like having the weapon not having a clip
function SWEP:GetAmmo()
    if engine.ActiveGamemode() == "terrortown" then
        return self:Clip1()
    else
        return self:GetOwner():GetAmmoCount(self.Primary.Ammo)
    end
end

function SWEP:TakePrimaryAmmo(amt)
    if engine.ActiveGamemode() == "terrortown" then
        self:SetClip1(self:Clip1() - amt)
    else
        self:GetOwner():RemoveAmmo(amt, self:GetPrimaryAmmoType())
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
        if IsValid(switch) then
            input.SelectWeapon(switch)
        end
    end
end

function SWEP:Initialize()
    local ourammoforreal = self.Primary.Ammo
    BaseClass.Initialize(self, false)

    -- SWCS hates ammo types apparently
    self.Primary.Ammo = ourammoforreal

    -- engine deploy blocks weapon from thinking and doing most stuff
    self.m_WeaponDeploySpeed = 255

    self:SetHoldType(self.HoldType)
end

function SWEP:OnDeploy()
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not owner or not owner:IsPlayer() then return end

    self:SetHoldType(self.HoldType)
    self:SetWeaponAnim(ACT_VM_DEPLOY, self:GetCustomDeploySpeed())

    local add_t = self:SequenceDuration() * (1 / self:GetCustomDeploySpeed())
    self:SetWeaponIdleTime(CurTime() + add_t)
    self:SetNextPrimaryFire(CurTime() + add_t * 0.9)

    self:OnDeploy()

    return true
end

function SWEP:Holster(nextWep)
    if IsValid(self:GetOwner()) and self:GetAmmo() <= 0 then
        if SERVER then
            self:Remove()
        end
        return true
    end
    return BaseClass.Holster(self, nextWep)
end

function SWEP:Reload()
    if engine.ActiveGamemode() == "terrortown" then return end
    local ply = self:GetOwner()
    if ply:KeyPressed(IN_RELOAD) and self:GetAmmo() > 0 then

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

            if DZ_ENTS.ConVars["drop_cleanup"]:GetFloat() > 0 then
                timer.Simple(DZ_ENTS.ConVars["drop_cleanup"]:GetFloat(), function()
                    if IsValid(ent) and not IsValid(ent:GetOwner()) then
                        ent.DZENTS_Pickup = CurTime() + 2
                        ent:SetRenderMode(RENDERMODE_TRANSALPHA) -- doesn't seem to work but whatever
                        ent:SetRenderFX(kRenderFxFadeSlow)
                        SafeRemoveEntityDelayed(ent, 1)
                    end
                end)
            end
        end

        if self:GetAmmo() <= 0 then
            self:SetWeaponAnim(ACT_VM_IDLE)
            self:RemoveAndSwitch()
        else
            self:Deploy()
        end
    end
end

function SWEP:EquipAmmo(ply)
    if weapons.IsBasedOn(self:GetClass(), "weapon_swcs_base") then
        ply:GiveAmmo(math.max(self:Clip1(), self.Primary.DefaultClip), self.Primary.Ammo)
    end
end

SWEP.WepSelectIcon = Material("dz_ents/select/healthshot.png", "smooth")
SWEP.WepSelectIconRatio = 1

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

SWEP.AmmoDisplay = {}
function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay.Draw = true
    self.AmmoDisplay.PrimaryClip = self:GetAmmo()
    self.AmmoDisplay.PrimaryAmmo = nil
    return self.AmmoDisplay
end
--------------------------------------- Override/re-implement some SWCS stuff

function SWEP:GetCustomDeploySpeed()
    if DZ_ENTS.ConVars["equipment_swcs"]:GetBool() and GetConVar("swcs_deploy_override") and GetConVar("swcs_deploy_override"):GetFloat() ~= 0 then
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

--------------------------------------- TTT integration
if engine.ActiveGamemode() ~= "terrortown" then return end

SWEP.AutoSpawnable = false
SWEP.AllowDrop = true
SWEP.IsSilent = false

function SWEP:PreDrop()
end

function SWEP:DampenDrop()
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocityInstantaneous(Vector(0, 0, -75) + phys:GetVelocity() * 0.001)
        phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
    end
end

function SWEP:IsEquipment()
    return WEPS.IsEquipment(self)
end

function SWEP:OnRestore()
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
    return 1
end

--- TTT2 uses this to populate custom convars in the equip menu
function SWEP:AddToSettingsMenu(parent)
end

function SWEP:Equip(newowner)
    if SERVER then
        if self:IsOnFire() then
            self:Extinguish()
        end

        self.fingerprints = self.fingerprints or {}

        if not table.HasValue(self.fingerprints, newowner) then
            table.insert(self.fingerprints, newowner)
        end
    end
end