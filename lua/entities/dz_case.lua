AddCSLuaFile()

ENT.Base = "base_anim"

ENT.PrintName = "Base DZ Case Entity"
ENT.Spawnable = false

ENT.IsDZEnt = true

ENT.SubCategory = "Cases"
ENT.SortOrder = 0

ENT.Model = "models/props_survival/cases/case_explosive.mdl"
ENT.MaxHealth = 60
ENT.Reinforced = false
ENT.Center = nil

local punchsounds = {
    "dz_ents/metal_vent_impact_02.wav",
    "dz_ents/metal_vent_impact_03.wav",
    "dz_ents/metal_vent_impact_05.wav",
    "dz_ents/metal_vent_impact_06.wav",
}

if SERVER then

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:PhysWake()

        self:SetMaxHealth(self.MaxHealth)
        self:SetHealth(self.MaxHealth)
        self:PrecacheGibs()
    end

    function ENT:BreakAndDrop(force)

        local class = DZ_ENTS:GetCrateDrop(self:GetClass())
        local ent = ents.Create(class)
        if IsValid(ent) then
            ent:SetPos(self.Center and self:LocalToWorld(self.Center) or self:WorldSpaceCenter())
            ent:SetAngles(self:GetAngles())
            ent:Spawn()

            if IsValid(ent:GetPhysicsObject()) then
                ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + Vector(0, 0, 64) + VectorRand() * 32)
            end
        end

        self:EmitSound("dz_ents/container_death_0" .. math.random(1, 3) .. ".wav", 80, math.Rand(97, 103), 1)

        local gibmode = GetConVar("dzents_crate_gib"):GetInt()
        if gibmode == 0 then
            local eff = EffectData()
            eff:SetOrigin(self:GetPos())
            eff:SetNormal(self:GetUp())
            util.Effect("cball_explode", eff)

        elseif gibmode == 1 then
            self:GibBreakClient(force)
        elseif gibmode == 2 then
            self:GibBreakServer(force)
        end

        SafeRemoveEntity(self)
    end

    function ENT:OnTakeDamage(dmginfo)

        if bit.band(dmginfo:GetDamageType(), DMG_DROWN + DMG_NERVEGAS + DMG_POISON + DMG_RADIATION + DMG_SONIC) > 0 then return 0 end
        if self.Reinforced and DZ_ENTS:IsFistDamage(dmginfo) then
            self:EmitSound(punchsounds[math.random(1, #punchsounds)])
            if (self.LastHit or 0) + 5 <= CurTime() and dmginfo:GetAttacker():IsPlayer() then
                DZ_ENTS:Hint(dmginfo:GetAttacker(), 1, self)
            end
            return 0
        end

        local health = self:Health()
        self:SetHealth(health - dmginfo:GetDamage())
        self.LastHit = CurTime()

        if self:Health() <= 0 then
            self:BreakAndDrop(self:GetVelocity())
        else
            if self:GetSkin() == 0 and self:Health() <= self:GetMaxHealth() * 0.9 then
                self:SetSkin(1)
            end

            self:EmitSound("dz_ents/container_damage_0" .. math.random(1, 5) .. ".wav", 80, math.Rand(97, 103))

            if dmginfo:GetAttacker():IsPlayer() then
                net.Start("dz_ents_damage")
                    net.WriteEntity(self)
                    net.WriteFloat(health)
                net.Send(dmginfo:GetAttacker())
            end
        end

        return dmginfo:GetDamage()
    end

    --[[]
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
    ]]
else
    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:ImpactTrace(trace, dmgtype, customimpactname)
        return
    end
end