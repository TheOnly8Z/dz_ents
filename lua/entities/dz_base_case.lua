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

ENT.ShrinkScale = 0.75

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

        if DZ_ENTS.ConVars["case_shrink"]:GetBool() then
            self:SetModelScale(self.ShrinkScale, 0)
            self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        end
        self:Activate()

        self:GetPhysicsObject():SetMass(75)

        local max = math.ceil(self.MaxHealth * DZ_ENTS.ConVars["case_health"]:GetFloat())
        self:SetMaxHealth(max)
        self:SetHealth(max)
        self:PrecacheGibs()
    end

    local function drop(self, class, pos)
        local ent = ents.Create(class)
        if not IsValid(ent) then
            ErrorNoHalt(tostring(self) .. " tried to create nonexistent entity \"" .. class "\"! Check your custom drops list!\n")
            return
        end
        ent:SetPos(pos)
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
        local pos = self.Center and self:LocalToWorld(self.Center) or self:WorldSpaceCenter()
        if string.find(class, "|") then
            for i, v in pairs(string.Explode("|", class, false)) do
                drop(self, v, pos)
                pos = pos + Vector(0, 0, 4)
            end
        else
            drop(self, class, pos)
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
    function ENT:Initialize()
        BaseClass.Initialize(self)

        if DZ_ENTS.ConVars["case_shrink"]:GetBool() then
            self:SetModelScale(self.ShrinkScale, 0.0001)
        end
    end


    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:ImpactTrace(trace, dmgtype, customimpactname)
        return
    end
end

properties.Add("dz_custom_drops", {
    MenuLabel = "Configure Custom Drops",
    Order = 1,
    MenuIcon = "icon16/table_gear.png",
    Filter = function(self, ent, ply)
        if not IsValid(ent) or not DZ_ENTS.CrateContents[ent:GetClass()] or not ply:IsAdmin() then return false end
        if not gamemode.Call("CanProperty", ply, "dz_custom_drops", ent) then return false end
        return true
    end, -- A function that determines whether an entity is valid for this property
    Action = function(self, ent)
        RunConsoleCommand("cl_dzents_menu_case_whitelist", ent:GetClass())
    end,
})