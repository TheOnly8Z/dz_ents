AddCSLuaFile()

ENT.Base = "dz_proj_base"
DEFINE_BASECLASS(ENT.Base)

ENT.PrintName = "Bump Mine"
ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_BOTH

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
    end

    function ENT:DrawTranslucent()
        if (self.NextRing == nil or self.NextRing < CurTime()) and self:GetArmed() then

            self.NextRing = CurTime() + 0.02

            local attachment = self:LookupAttachment("glow")
            local attachment2 = self:LookupAttachment("glow_mid")
            local data = self:GetAttachment(attachment)
            local data2 = self:GetAttachment(attachment2)
            if not data or not data2 then return end
            local attachment_pos, attachment2_pos
            attachment_pos = data.Pos
            attachment2_pos = data2.Pos
            local randomnum = math.random(1, 2)

            local emitter = ParticleEmitter(attachment_pos, true)
            local particle = emitter:Add("particle/particle_ring_wave_12_eff", attachment_pos)
            if not particle then return end
            particle:SetVelocity(self:GetUp() * 75)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.2)
            particle:SetStartAlpha(math.Rand(220, 250))
            particle:SetEndAlpha(0)

            particle:SetStartSize(9.5)
            particle:SetEndSize(9.5)
            particle:SetAngles(self:GetUp():Angle())
            particle:SetAngleVelocity(Angle(0, 0, math.Rand(-180, 180)))

            if randomnum == 1 then
                particle:SetColor(25, 90, 255)
            else
                particle:SetColor(28, 122, 251)
            end
            particle:SetLighting(false)

            emitter:Finish()

            --MIDDLE RING

            local emitter2 = ParticleEmitter(attachment2_pos, true)
            local particle2 = emitter2:Add("particle/particle_ring_wave_12_eff", attachment2_pos)
            if not particle2 then return end
            particle2:SetVelocity(self:GetUp() * 65)
            particle2:SetLifeTime(0)
            particle2:SetDieTime(0.2)
            particle2:SetStartAlpha(math.Rand(220, 250))
            particle2:SetEndAlpha(0)

            particle2:SetStartSize(6)
            particle2:SetEndSize(6)
            particle2:SetAngles(self:GetUp():Angle())
            particle2:SetAngleVelocity(Angle(0, 0, math.Rand(-180, 180)))

            if randomnum == 1 then
                particle2:SetColor(20, 86, 254)
            else
                particle2:SetColor(6, 0, 255)
            end
            particle:SetLighting(false)

            emitter2:Finish()
        end
    end
end

if SERVER then

    function ENT:Initialize()
        BaseClass.Initialize(self)

        self.ArmDelay = DZ_ENTS.ConVars["bumpmine_armdelay"]:GetFloat()
        self.DetonateDelay = DZ_ENTS.ConVars["bumpmine_detdelay"]:GetFloat()

        local t = DZ_ENTS.ConVars["bumpmine_lifetime"]:GetFloat()
        if t > 0 then
            timer.Simple(t, function()
                if IsValid(self) then
                    SafeRemoveEntity(self)
                end
            end)
        end
    end

    function ENT:OnPlant()
        self:EmitSound("DZ_Ents.BumpMine.SetArmed")

        timer.Simple(self.ArmDelay, function()
            if IsValid(self) then
                -- The rings on the original effect don't rotate. Matsilagi provided this lua alternative - thanks!
                local attach = self:LookupAttachment("glow")
                ParticleEffectAttach("bumpmine_active_glow2", PATTACH_POINT_FOLLOW, self, attach)

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

        -- local eff = EffectData()
        -- eff:SetOrigin(self:GetPos())
        -- eff:SetEntity(self)
        -- eff:SetNormal(self:GetUp())
        -- eff:SetScale(128)
        -- util.Effect("ThumperDust", eff)

        local radius = 150
        local force = DZ_ENTS.ConVars["bumpmine_force"]:GetFloat()
        local upadd = DZ_ENTS.ConVars["bumpmine_upadd"]:GetFloat()

        -- bias it downwards so the force trends upwards
        local origin = self:GetPos() - Vector(0, 0, 24)

        if DZ_ENTS.ConVars["bumpmine_stack"]:GetBool() then
            local mult = 1
            local count = 1
            for k, v in pairs(ents.FindByClass(self:GetClass())) do
                if v ~= self and (v:GetArmed() or v:GetArmTime() == -1) and v:GetPos():DistToSqr(self:GetPos()) <= 96 * 96 then
                    SafeRemoveEntity(v)
                    count = count + 1
                    mult = mult + (1 / count)
                end
            end
            force = force * mult
            upadd = upadd * mult
            radius = radius + (mult - 1) * 50
        end

        for k, v in pairs(ents.FindInSphere(self:GetPos(), 156)) do
            if not IsValid(v) or v == self then continue end --  or v == self:GetParent()

            local dir = (v:GetPos() - origin):GetNormalized()
            if v == self:GetParent() then
                dir = -self:GetUp() --(v:WorldSpaceCenter() - self:GetPos() - self:GetUp() * 16):GetNormalized()
            end

            if v:GetClass() == self:GetClass() and v:GetArmed() then
                -- v:Detonate()
                continue
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

                    local fmult = 1
                    local umult = 1
                    if v == self:GetParent() then umult = umult + 2 end
                    if v:IsPlayer() then
                        if v:Crouching() and v ~= self:GetParent() then
                            umult = 0
                        end
                        if v:DZ_ENTS_HasHeavyArmor() then
                            fmult = fmult / (1 + DZ_ENTS.ConVars["armor_heavy_gravity"]:GetFloat() * 0.5)
                            umult = umult / (1 + DZ_ENTS.ConVars["armor_heavy_gravity"]:GetFloat() * 0.5)
                        end
                    else
                        umult = umult * 2
                    end

                    v:SetGroundEntity(NULL)
                    v:SetVelocity(dir * force * fmult + Vector(0, 0, upadd * umult))

                    v.DZENTS_BumpMine_Launched = true
                    if DZ_ENTS.ConVars["bumpmine_damage_crash"]:GetFloat() > 0 then
                        timer.Simple(0.05, function()
                            if not IsValid(v) then return end
                            v.DZENTS_BumpMine_LaunchTime = CurTime() -- only used for wall crash detection
                        end)
                    end

                    -- Start checking for wall crashing.
                    -- For NPCs/nextbots, this will also handle fall damage
                    table.insert(DZ_ENTS.PhysicsMonitorList, v)
                else
                    if v == self:GetParent() then
                        v:GetPhysicsObject():ApplyForceCenter(v:GetPhysicsObject():GetMass() ^ 0.9 * self:GetAngles():Up() * (force * -2))
                    else
                        v:GetPhysicsObject():ApplyForceCenter((dir * (force + upadd)) * (v:GetPhysicsObject():GetMass() ^ 0.9))
                        v:GetPhysicsObject():AddAngleVelocity(VectorRand() * Lerp(v:GetPhysicsObject():GetMass() / 500, 360, 5))
                    end
                    v:SetPhysicsAttacker(self.Attacker or v, 6)

                    if v:GetClass() == "prop_physics" or v:GetClass() == "func_breakable" then
                        local dmginfo = DamageInfo()
                        dmginfo:SetDamagePosition(self:GetPos())
                        dmginfo:SetDamageForce(dir * force)
                        dmginfo:SetDamageType(DMG_GENERIC)
                        dmginfo:SetDamage(100)
                        dmginfo:SetAttacker(self.Attacker or v)
                        dmginfo:SetInflictor(self)
                        v:TakeDamageInfo(dmginfo)
                    end
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

        SafeRemoveEntityDelayed(self, 0.05)
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