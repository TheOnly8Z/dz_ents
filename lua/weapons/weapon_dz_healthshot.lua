AddCSLuaFile()

game.AddAmmoType({
    name = "dz_healthshot",
    maxcarry = "dzents_healthshot_maxammo", -- woah, cool feature! doesn't fucking work because nobody sets gmod_maxammo!
})
if CLIENT then
    language.Add("dz_healthshot_ammo", "Medi-Shots")
end

SWEP.PrintName = "Medi-Shot"
SWEP.Slot = 4
SWEP.Weight = 150

SWEP.Author = "8Z"
SWEP.Purpose = "Restores a portion of your health and provides a brief speed boost."
SWEP.Instructions = "Primary Attack: Inject\nReload: Drop"

SWEP.Base = "weapon_base_dz"
DEFINE_BASECLASS(SWEP.Base)

SWEP.Category = "CS:GO Equipment"
SWEP.Spawnable = true

SWEP.SubCategory = "Equipment"
SWEP.SortOrder = 2

SWEP.ViewModel = "models/weapons/dz_ents/c_eq_healthshot.mdl"
SWEP.WorldModel = "models/weapons/dz_ents/w_eq_healthshot.mdl"
SWEP.ViewModelFOV = 68
SWEP.UseHands = true

SWEP.WepSelectIcon = Material("dz_ents/select/healthshot.png", "smooth")
SWEP.WepSelectIconRatio = 0.75

SWEP.AmmoType = "dz_healthshot"

SWEP.Primary.Ammo = "dz_healthshot"
SWEP.Primary.DefaultClip = 1

SWEP.HoldType = "normal"

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Float", 16, "StimTime")
    self:NetworkVar("Bool", 6, "Stimmed")
end

function SWEP:Initialize()
    BaseClass.Initialize(self)

    self:SetHoldType(self.HoldType)
    self:SetStimTime(0)
    self:SetStimmed(false)
end

function SWEP:Deploy()
    local dep = BaseClass.Deploy(self)

    self:SetStimTime(0)
    self:SetStimmed(false)
    self:SetBodygroup(0, 0)

    return dep
end

function SWEP:Holster(nextWep)
    if SERVER and IsValid(self:GetOwner()) and self:Ammo1() <= 0 then
        self:Remove()
    end
    self:SetBodygroup(0, 0)
    self:SetStimTime(0)
    return BaseClass.Holster(self, nextWep)
end

function SWEP:CanPrimaryAttack()
    local ply = self:GetOwner()
    if not ply:IsPlayer() then return false end
    if self:GetStimTime() > 0 or self:GetNextPrimaryFire() > CurTime() then return false end
    if ply:Health() >= ply:GetMaxHealth() and not GetConVar("dzents_healthshot_use_at_full"):GetBool() then return false end

    if self:Ammo1() <= 0 then
        self:RemoveAndSwitch()
        return false
    end

    return true
end

function SWEP:PrimaryAttack()
    if self:CanPrimaryAttack() then
        self:SetNextPrimaryFire(CurTime() + 2)
        self:SetStimTime(CurTime() + 28 / 40)
        self:SetWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:SetHoldType("slam")
        self:SetBodygroup(0, 1)
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    if self:GetStimTime() > 0 and self:GetStimTime() < CurTime() and IsFirstTimePredicted() then
        self:SetStimTime(0)
        self:SetStimmed(true)
        self:EmitSound("DZ_Ents.Healthshot.Success")
        self:GetOwner():RemoveAmmo(1, self:GetPrimaryAmmoType())

        local ply = self:GetOwner()
        ply:SetNWFloat("DZ_Ents.Healthshot", CurTime() + GetConVar("dzents_healthshot_duration"):GetFloat())
        ply:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER)

        if SERVER and ply:GetMaxHealth() > ply:Health() then
            local amt = GetConVar("dzents_healthshot_health"):GetInt()
            local dur = GetConVar("dzents_healthshot_healtime"):GetFloat()
            if dur <= 0 then
                ply:SetHealth(math.min(ply:Health() + amt, ply:GetMaxHealth()))
            else
                -- Timers cannot run more frequently than the tick interval. If the duration is short enough, we must heal more than 1hp per tick.
                local lasttick = 0
                local tickheal = 1
                local tickamt = amt
                local interval = dur / amt
                while interval < engine.TickInterval() do
                    tickheal = tickheal + 1
                    tickamt = math.floor(amt / tickheal)
                    lasttick = amt - (tickheal * tickamt)
                    interval = dur / tickamt
                end
                local timername = "healthshot_" .. ply:EntIndex() -- timers of the same name will overwrite each other. This is intentional!
                timer.Create(timername, interval, tickamt, function()
                    if not ply:Alive() or ply:GetMaxHealth() <= ply:Health() then
                        timer.Remove(timername)
                        return
                    end
                    ply:SetHealth(math.min(ply:Health() + tickheal, ply:GetMaxHealth()))
                    if timer.RepsLeft(timername) == 0 then
                        ply:SetHealth(math.min(ply:Health() + lasttick, ply:GetMaxHealth()))
                    end
                end)
            end
        end
    end

    self:WeaponIdle()
end

function SWEP:WeaponIdle()
    if self:GetWeaponIdleTime() > CurTime() then return end

    if self:GetStimmed() then
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