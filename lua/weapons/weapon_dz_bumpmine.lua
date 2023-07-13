AddCSLuaFile()

game.AddAmmoType({
    name = "dz_bumpmine",
    maxcarry = "dzents_bumpmine_maxammo", -- woah, cool feature! doesn't fucking work because nobody sets gmod_maxammo!
})
if CLIENT then
    language.Add("dz_bumpmine_ammo", "Bump Mines")
end

SWEP.PrintName = "Bump Mine"
SWEP.Slot = 4
SWEP.Weight = 200

SWEP.Author = "8Z"
SWEP.Purpose = "Toss one of these on the ground and send your opponents flying. You can step on one, but make sure you have a parachute..."
SWEP.Instructions = "Primary Attack: Throw\nReload: Drop"

SWEP.Base = "weapon_base_dz"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Category = "CS:GO Equipment"
SWEP.Spawnable = true

SWEP.SubCategory = "Equipment"
SWEP.SortOrder = 1

SWEP.ViewModel = "models/weapons/dz_ents/c_bumpmine.mdl"
SWEP.WorldModel = "models/weapons/dz_ents/w_bumpmine.mdl"
SWEP.ViewModelFOV = 68
SWEP.UseHands = true

SWEP.WepSelectIcon = Material("dz_ents/select/bumpmine.png", "smooth")

SWEP.Primary.Ammo = "dz_bumpmine"
SWEP.Primary.DefaultClip = 3

SWEP.HoldType = "slam"

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Bool", 6, "Thrown")
end

function SWEP:OnDeploy()
    self:SetThrown(false)
end

function SWEP:Holster(nextWep)
    self:SetThrown(false)
    return BaseClass.Holster(self, nextWep)
end

function SWEP:CanPrimaryAttack()
    local ply = self:GetOwner()
    if not ply:IsPlayer() then return false end
    if self:GetNextPrimaryFire() > CurTime() then return false end

    if self:Ammo1() <= 0 then
        self:RemoveAndSwitch()
        return false
    end

    return true
end

function SWEP:PrimaryAttack()
    if self:CanPrimaryAttack() then

        self:TakePrimaryAmmo(1)
        self:SetThrown(true)

        self:SetWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:SetNextPrimaryFire(CurTime() + 0.75)
        self:SetWeaponIdleTime(CurTime() + 0.75)
        self:GetOwner():DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM)
        self:EmitSound("DZ_Ents.BumpMine.Throw")

        if SERVER then
            local ent = ents.Create("dz_proj_bumpmine")
            ent:SetPos(self:GetOwner():GetShootPos() - Vector(0, 0, 12))
            ent:SetAngles(self:GetOwner():EyeAngles() + AngleRand())
            ent:SetOwner(self:GetOwner())
            ent:Spawn()
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * 500 + self:GetOwner():GetVelocity())
                phys:AddAngleVelocity(VectorRand() * 200)
            end
        end
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    self:WeaponIdle()
end

function SWEP:WeaponIdle()
    if self:GetWeaponIdleTime() > CurTime() then return end

    if self:GetThrown() then
        if self:Ammo1() <= 0 then
            self:RemoveAndSwitch()
        else
            self:Deploy()
        end
    else
        self:SetWeaponIdleTime(math.huge) -- it's looping anyways
        self:SetWeaponAnim(ACT_VM_IDLE)
    end
end