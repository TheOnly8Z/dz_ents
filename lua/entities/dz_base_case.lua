AddCSLuaFile()

ENT.Base = "dz_base"

ENT.PrintName = "Base DZ Case"
ENT.Spawnable = false

ENT.CollisionGroup = COLLISION_GROUP_NONE

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

DEFINE_BASECLASS(ENT.Base)

if SERVER then

    function ENT:Initialize()
        BaseClass.Initialize(self)

        local max = math.ceil(self.MaxHealth * DZ_ENTS.ConVars["case_health"]:GetFloat())
        self:SetMaxHealth(max)
        self:SetHealth(max)
        self:PrecacheGibs()
    end

    function ENT:BreakAndDrop(force)

        -- prevent duplicate spawning
        if self.Dying then return end
        self.Dying = true

        local class = DZ_ENTS:GetCrateDrop(self:GetClass())
        if not class then
            PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] Failed to create crate drop for " .. self.PrintName .. "!")
            PrintMessage(HUD_PRINTTALK, "[DZ_ENTS] The whitelist may have been configured incorrectly!")
            SafeRemoveEntity(self)
            return
        end
        local ent = ents.Create(class)
        if IsValid(ent) then
            ent:SetPos(self.Center and self:LocalToWorld(self.Center) or self:WorldSpaceCenter())
            ent:SetAngles(self:GetAngles())
            ent:Spawn()

            if IsValid(ent:GetPhysicsObject()) then
                ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + Vector(0, 0, 64) + VectorRand() * 32)
            end

            ent.DZENTS_Pickup = CurTime() + 1

            if DZ_ENTS.ConVars["case_cleanup"]:GetFloat() > 1 then
                timer.Simple(DZ_ENTS.ConVars["case_cleanup"]:GetFloat(), function()
                    if IsValid(ent) and not IsValid(ent:GetOwner()) then
                        SafeRemoveEntity(ent)
                    end
                end)
            end
        end

        self:EmitSound("dz_ents/container_death_0" .. math.random(1, 3) .. ".wav", 80, math.Rand(97, 103), 1)

        local gibmode = DZ_ENTS.ConVars["case_gib"]:GetInt()
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
        if self.Reinforced and DZ_ENTS:IsFistDamage(dmginfo) and DZ_ENTS.ConVars["case_reinforced"]:GetBool() then
            self:EmitSound(punchsounds[math.random(1, #punchsounds)])
            if (self.LastHit or 0) + 5 <= CurTime() and dmginfo:GetAttacker():IsPlayer() then
                DZ_ENTS:Hint(dmginfo:GetAttacker(), 1, self)
            end
            return 0
        end

        if dmginfo:IsExplosionDamage() then
            dmginfo:ScaleDamage(2)
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

    function ENT:Use(ply)
        if self:Health() >= self:GetMaxHealth() then
            DZ_ENTS:Hint(ply, 17, self)
        end
    end
else
    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:ImpactTrace(trace, dmgtype, customimpactname)
        return
    end
end