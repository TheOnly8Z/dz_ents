AddCSLuaFile()

ENT.Base = "dz_base"

ENT.PrintName = "Base DZ Armor"
ENT.Spawnable = false

ENT.GiveArmor = nil
ENT.GiveArmorType = nil
ENT.GiveHelmet = false

if SERVER then
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
end