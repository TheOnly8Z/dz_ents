AddCSLuaFile()

ENT.Base = "dz_proj_base"
DEFINE_BASECLASS(ENT.Base)

ENT.PrintName = "Bump Mine"
ENT.Spawnable = false

ENT.Model = "models/weapons/dz_ents/w_bumpmine_dropped.mdl"
ENT.WeaponClass = "weapon_dz_bumpmine"
-- ENT.MinS = Vector(-8, -8, -2)
-- ENT.MaxS = Vector(8, 8, 6)
ENT.MinS = Vector(-4, -4, -4)
ENT.MaxS = Vector(4, 4, 6)

ENT.ArmDelay = 0.3
ENT.DetonateDelay = 0.25

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        --Particles
        -- local attachment = self:LookupAttachment("glow")
        -- local attachment2 = self:LookupAttachment("glow_mid")
        -- local data = self:GetAttachment(attachment)
        -- local data2 = self:GetAttachment(attachment2)
        -- if not data or not data2 then return end
        -- local attachment_pos, attachment_ang, attachment2_pos, attachment2_ang
        -- attachment_pos = data.Pos
        -- attachment_ang = data.Ang
        -- attachment2_pos = data2.Pos
        -- attachment2_ang = data2.Ang
        -- local randomnum = math.random(1, 2)
        -- local randomnum2 = math.random(1, 2)
        -- local randomnum3 = math.random(1, 2)
        -- local randomnum4 = math.random(1, 2)
        -- local randomnum5 = math.random(1, 2)

        -- if (self.NextRing == nil or self.NextRing < CurTime()) and self:GetArmed() then
        --     self.NextRing = CurTime() + 0.02
        --     local emitter = ParticleEmitter(attachment_pos, true)
        --     local particle = emitter:Add("particle/particle_ring_wave_12", attachment_pos)
        --     if not particle then return end
        --     particle:SetVelocity(self:GetUp() * 75)
        --     particle:SetLifeTime(0)
        --     particle:SetDieTime(0.2)

        --     if randomnum2 == 1 then
        --         particle:SetStartAlpha(240)
        --     else
        --         particle:SetStartAlpha(250)
        --     end

        --     if randomnum3 == 1 then
        --         particle:SetEndAlpha(240)
        --     else
        --         particle:SetEndAlpha(250)
        --     end

        --     particle:SetStartSize(9.5)
        --     particle:SetEndSize(9.5)
        --     particle:SetAngles(self:GetUp():Angle())
        --     particle:SetAngleVelocity(Angle(0, 0, math.random(0, 360)))

        --     if randomnum == 1 then
        --         particle:SetColor(25, 90, 255)
        --     else
        --         particle:SetColor(28, 122, 251)
        --     end

        --     emitter:Finish()
        --     --MIDDLE RING
        --     local emitter2 = ParticleEmitter(attachment2_pos, true)
        --     local particle2 = emitter2:Add("particle/particle_ring_wave_12", attachment2_pos)
        --     if not particle2 then return end
        --     particle2:SetVelocity(self:GetUp() * 65)
        --     particle2:SetLifeTime(0)
        --     particle2:SetDieTime(0.2)

        --     if randomnum4 == 1 then
        --         particle2:SetStartAlpha(220)
        --     else
        --         particle2:SetStartAlpha(250)
        --     end

        --     if randomnum5 == 1 then
        --         particle2:SetEndAlpha(220)
        --     else
        --         particle2:SetEndAlpha(250)
        --     end

        --     particle2:SetStartSize(6)
        --     particle2:SetEndSize(6)
        --     particle2:SetAngles(self:GetUp():Angle())
        --     particle2:SetAngleVelocity(Angle(0, 0, math.random(0, 360)))

        --     if randomnum == 1 then
        --         particle2:SetColor(20, 86, 254)
        --     else
        --         particle2:SetColor(6, 0, 255)
        --     end

        --     emitter2:Finish()
        -- end
    end

    function ENT:DrawTranslucent()
        self:Draw()
    end
end

if SERVER then

    function ENT:Initialize()
        BaseClass.Initialize(self)

        self.ArmDelay = GetConVar("dzents_bumpmine_armdelay"):GetFloat()
        self.DetonateDelay = GetConVar("dzents_bumpmine_detdelay"):GetFloat()
    end

    function ENT:OnPlant()
        self:EmitSound("DZ_Ents.BumpMine.SetArmed")

        timer.Simple(self.ArmDelay, function()
            if IsValid(self) then
                local attach = self:LookupAttachment("glow_start")
                ParticleEffectAttach("bumpmine_active_glow2", PATTACH_POINT_FOLLOW, self, attach)

                local data = self:GetAttachment(attach)
                local attpos, attang = data.Pos, data.Ang
                ParticleEffect("bumpmine_active", attpos, attang,self)
                self:SetBodygroup(1, 1)

                if IsValid(self:GetParent()) and (self:GetParent():IsPlayer() or self:GetParent():IsNPC() or self:GetParent():IsNextBot()) then
                    self:Detonate()
                end
            end
        end)

        self:SetTrigger(true)
        self:UseTriggerBounds(true, 8)

        self.idlesound = CreateSound(self, "DZ_Ents.BumpMine.Idle")
        self.idlesound:Play()
    end

    function ENT:Detonate()
        if self:GetNoDraw() then return end
        self:EmitSound("DZ_Ents.BumpMine.Detonate")
        self:SetNoDraw(true)

        util.ScreenShake(self:GetPos(), 25.0, 150.0, 1.0, 750)

        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        eff:SetEntity(self)
        eff:SetScale(128)
        util.Effect("ThumperDust", eff)
        local entsph2 = ents.FindInSphere(self:GetPos(), 156)

        local force = GetConVar("dzents_bumpmine_force"):GetFloat()
        local upadd = GetConVar("dzents_bumpmine_upadd"):GetFloat()

        for k, v in pairs(entsph2) do
            if not IsValid(v) or v == self or v == self:GetParent() then continue end

            local dir = (v:GetPos() - (self:GetPos() - Vector(0, 0, 20))):GetNormalized()

            if v:GetClass() == self:GetClass() and v:GetArmed() then
                v:Detonate()
            elseif IsValid(v:GetPhysicsObject()) then
                if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
                    local trail = ents.Create("info_particle_system")
                    trail:SetKeyValue("effect_name", "bumpmine_player_trail")
                    trail:SetPos(v:GetPos())
                    trail:SetAngles(self:GetAngles())
                    trail:SetParent(v)
                    trail:Spawn()
                    trail:Activate()
                    trail:Fire("Start", "", 0)
                    trail:Fire("Kill", "", 8)

                    v:SetGroundEntity(NULL)
                    v:SetVelocity((dir * force + Vector(0, 0, upadd * (v:IsPlayer() and (v:Crouching() and 0 or 1) or 2))) * (v:IsPlayer() and v:Crouching() and v:IsOnGround() and 1.5 or 1))

                    v.DZENTS_BumpMine_Launched = true

                    if GetConVar("dzents_bumpmine_damage_crash"):GetFloat() > 0 then
                        v.DZENTS_BumpMine_LaunchTime = CurTime() -- only used for wall crash detection
                    end

                    -- Start checking for wall crashing.
                    -- For NPCs/nextbots, this will also handle fall damage
                    table.insert(DZ_ENTS.PhysicsMonitorList, v)
                else
                    v:GetPhysicsObject():ApplyForceCenter((dir * (force + upadd)) * (v:GetPhysicsObject():GetMass() ^ 0.9))
                    v:GetPhysicsObject():AddAngleVelocity(VectorRand() * Lerp(v:GetPhysicsObject():GetMass() / 500, 360, 5))
                    v:SetPhysicsAttacker(self.Attacker or v, 6)

                    local dmginfo = DamageInfo()
                    dmginfo:SetDamagePosition(self:GetPos())
                    dmginfo:SetDamageForce(dir * force)
                    dmginfo:SetDamageType(DMG_GENERIC)
                    dmginfo:SetDamage(200)
                    dmginfo:SetAttacker(self.Attacker or v)
                    dmginfo:SetInflictor(self)
                    v:TakeDamageInfo(dmginfo)
                end

                -- Attribute fall damage to the attacker if possible
                v.DZENTS_BumpMine_Attacker = self.Attacker
            end
        end

        local explo = ents.Create("info_particle_system")
        explo:SetKeyValue("effect_name", "bumpmine_detonate")
        explo:SetPos(self:GetPos())
        explo:SetAngles(self:GetAngles())
        explo:SetParent(self)
        explo:Spawn()
        explo:Activate()
        explo:Fire("Start", "", 0)
        explo:Fire("Kill", "", 8)

        local parent = self:GetParent()
        if IsValid(parent) then
            if parent:IsPlayer() or parent:IsNPC() or parent:IsNextBot() then
                local dir = parent:WorldSpaceCenter() - self:GetPos()
                dir.z = 0
                dir:Normalize()
                parent:SetVelocity(dir * force + Vector(0, 0, upadd + force * 0.5))

                parent.DZENTS_BumpMine_Launched = true
                if GetConVar("dzents_bumpmine_damage_crash"):GetFloat() > 0 then
                    parent.DZENTS_BumpMine_LaunchTime = CurTime() -- only used for wall crash detection
                end
            else
                local phys = parent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(phys:GetMass() ^ 0.9 * self:GetAngles():Up() * (force * -2))
                end
            end
        end
        parent.DZENTS_BumpMine_Attacker = self.Attacker

        SafeRemoveEntityDelayed(self, 0.02)
    end

    function ENT:Touch(v)
        if self:GetArmed() and IsValid(v) and (v:IsPlayer() or v:IsNPC() or v:IsNextBot()) then
            self:SetArmTime(-1)
            self:EmitSound("DZ_Ents.BumpMine.PreDetonate")
            timer.Simple(self.DetonateDelay, function()
                if IsValid(self) then self:Detonate() end
            end)
        end
    end

    function ENT:OnRemove()
        if self.idlesound then
            self.idlesound:Stop()
        end
    end
end