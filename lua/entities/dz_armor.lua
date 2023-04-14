AddCSLuaFile()

ENT.Base = "base_anim"

ENT.PrintName = "Base Armor"
ENT.Spawnable = false

ENT.IsDZEnt = true
ENT.SubCategory = "Pickups"
ENT.SortOrder = 0

ENT.Model = "models/props_survival/upgrades/upgrade_dz_armor.mdl"
ENT.Bodygroups = nil

ENT.GiveArmor = nil
ENT.GiveArmorType = nil
ENT.GiveHelmet = false
if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        if self.Bodygroups then
            self:SetBodyGroups(self.Bodygroups)
        end
        self:PhysicsInit(SOLID_VPHYSICS)
        self:PhysWake()
        self:SetUseType(SIMPLE_USE)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end

    function ENT:Use(ply)
        local helmet = false
        local armor = false
        if self.GiveHelmet then
            if not ply:DZ_ENTS_HasHelmet() then
                ply:DZ_ENTS_GiveHelmet()
                helmet = true
            end
        end

        if  (self.GiveArmor or 0) > 0 and ply:Armor() < self.GiveArmor then
            -- ply:SetMaxArmor(math.max(ply:GetMaxArmor(), self.GiveArmor))
            ply:SetArmor(self.GiveArmor)
            armor = true
            if self.GiveArmorType and ply:DZ_ENTS_GetArmor() <= self.GiveArmorType then
                ply:DZ_ENTS_SetArmor(self.GiveArmorType)
            end
        end

        if helmet or armor then
            if self.HeavyArmor then
                DZ_ENTS:Hint(ply, 8)
                self:EmitSound( "dz_ents/armor_pickup_02.wav")
                self:Remove()
                return
            elseif self.GiveHelmet and not helmet then
                local ent = ents.Create("dz_armor_helmet")
                if IsValid(ent) then
                    ent:SetPos(self:GetPos() + Vector(0, 0, 4))
                    ent:SetAngles(self:GetAngles())
                    ent:Spawn()
                end
                DZ_ENTS:Hint(ply, 3)
            elseif (self.GiveArmor or 0) > 0 and not armor then
                local ent = ents.Create("dz_armor_kevlar")
                if IsValid(ent) then
                    ent:SetPos(self:GetPos() + Vector(0, 0, 10))
                    ent:SetAngles(self:GetAngles())
                    ent:Spawn()
                end
                DZ_ENTS:Hint(ply, 4)
            elseif helmet and armor then
                DZ_ENTS:Hint(ply, 2)
            elseif helmet then
                DZ_ENTS:Hint(ply, 4)
            elseif armor then
                DZ_ENTS:Hint(ply, 3)
            end

            self:EmitSound("dz_ents/armor_pickup_01.wav")
            self:Remove()
        else
            if self.HeavyArmor then
                DZ_ENTS:Hint(ply, 9)
            elseif self.GiveHelmet and (self.GiveArmor or 0) > 0 then
                DZ_ENTS:Hint(ply, 7)
            elseif self.GiveHelmet then
                DZ_ENTS:Hint(ply, 5)
            else
                DZ_ENTS:Hint(ply, 6)
            end
        end
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
end
