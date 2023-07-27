AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = nil

ENT.PrintName = "Base DZ Entity"
ENT.Spawnable = false

ENT.IsDZEnt = true

ENT.Model = ""
ENT.UseType = SIMPLE_USE
ENT.CollisionGroup = COLLISION_GROUP_WEAPON
ENT.Bodygroups = nil

ENT.PropertyBlacklist = {
    ["bodygroups"] = true,
    ["skin"] = true,
    ["drive"] = true,
    ["bone_manipulate"] = true,
}

if SERVER then

    ENT.Dying = false

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(self.UseType)
        self:SetCollisionGroup(self.CollisionGroup)

        if self.Bodygroups then
            self:SetBodyGroups(self.Bodygroups)
        end

        self:PhysWake()
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

    function ENT:FadeAndRemove()
        if self.Dying then return end
        self.Dying = true
        self:SetRenderMode(RENDERMODE_TRANSADD)
        self:SetRenderFX(kRenderFxFadeFast)
        self:DrawShadow(false)
        SafeRemoveEntityDelayed(self, 2)
    end

    function ENT:MarkForRemove(delay)
        if delay or DZ_ENTS.ConVars["drop_cleanup"]:GetFloat() > 0 then
            timer.Simple(delay or DZ_ENTS.ConVars["drop_cleanup"]:GetFloat(), function()
                if IsValid(self) and self:AllowMarkedRemove() then
                    self:FadeAndRemove()
                elseif IsValid(self) then
                    self:MarkForRemove(5) -- try again later
                end
            end)
        end
    end

    function ENT:AllowMarkedRemove()
        return true
    end
else
    function ENT:Initialize()
    end
end

function ENT:CanProperty(ply, prop)
    if self.PropertyBlacklist[prop] then return false end

    return true
end