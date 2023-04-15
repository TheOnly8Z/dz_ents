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

        local giveheavyarmor = self.GiveArmorType == DZ_ENTS_ARMOR_HEAVY_CT or self.GiveArmorType == DZ_ENTS_ARMOR_HEAVY_T

        if self.GiveHelmet then
            if not ply:DZ_ENTS_HasHelmet() then
                ply:DZ_ENTS_GiveHelmet()
                helmet = true
                if (self.GiveArmor or 0) <= 0 then
                    ply:SetArmor(math.max(ply:Armor(), 10))
                end
            end
        end

        if (self.GiveArmor or 0) > 0 and ply:Armor() < self.GiveArmor then
            armor = true
            ply:SetArmor(self.GiveArmor)
            if self.GiveArmorType and ply:DZ_ENTS_GetArmor() <= self.GiveArmorType then
                ply:DZ_ENTS_SetArmor(self.GiveArmorType)
                if self.GiveArmorType == DZ_ENTS_ARMOR_KEVLAR then
                    ply:SetMaxArmor(100)
                elseif giveheavyarmor then
                    ply:SetMaxArmor(200)

                    local speed = GetConVar("dzents_armor_heavy_speed"):GetInt()
                    if speed > 0 then
                        ply.DZ_ENTS_OriginalSpeed = {ply:GetSlowWalkSpeed(), ply:GetWalkSpeed(), ply:GetRunSpeed()}
                        ply:SetSlowWalkSpeed(math.min(ply:GetSlowWalkSpeed(), speed))
                        ply:SetWalkSpeed(speed)
                        ply:SetRunSpeed(speed * 2)
                    end
                end
            end
        end

        if helmet or armor then
            if giveheavyarmor then
                DZ_ENTS:Hint(ply, 8)
                ply:EmitSound("dz_ents/armor_pickup_02.wav", 80, 90)
                ply:EmitSound("items/ammopickup.wav", 80, 90)
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

            ply:EmitSound("dz_ents/armor_pickup_01.wav")
            self:Remove()
        else
            if giveheavyarmor then
                DZ_ENTS:Hint(ply, 9)
            elseif (self.GiveArmor or 0) > 0 then
                DZ_ENTS:Hint(ply, 6)
            else
                DZ_ENTS:Hint(ply, 5)
            end
        end
    end
end