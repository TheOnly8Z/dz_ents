AddCSLuaFile()

ENT.Base = "dz_base"

ENT.PrintName = "Base DZ Armor"
ENT.Spawnable = false

ENT.GiveArmor = nil
ENT.GiveArmorType = nil
ENT.GiveHelmet = false

if SERVER then
    function ENT:Use(ply)
        local bGaveHelmet = false
        local bGaveArmor = false
        local bIsHeavyArmor = self.GiveArmorType == DZ_ENTS_ARMOR_HEAVY_CT or self.GiveArmorType == DZ_ENTS_ARMOR_HEAVY_T

        if self.GiveHelmet then
            local iHelmetArmorValue = DZ_ENTS.ConVars["armor_helmet_amt"]:GetInt()

            if not ply:DZ_ENTS_HasHelmet() then
                ply:DZ_ENTS_GiveHelmet()
                bGaveHelmet = true
                if (self.GiveArmor or 0) <= 0 then
                    ply:SetArmor(math.max(ply:Armor(), iHelmetArmorValue))
                end
            elseif (iHelmetArmorValue > 0 and (self.GiveArmor or 0) <= 0) then
                local iCurrentArmor = ply:Armor()
                local iFutureArmor = math.min(ply:GetMaxArmor(), iCurrentArmor + iHelmetArmorValue)

                if iFutureArmor > iCurrentArmor then
                    ply:SetArmor(iFutureArmor)
                    bGaveHelmet = true
                end
            end
        end

        if (self.GiveArmor or 0) > 0 and ply:Armor() < (self.GiveArmorType == DZ_ENTS_ARMOR_KEVLAR and 100 or 200) then
            bGaveArmor = true

            if self.GiveArmorType and (ply:DZ_ENTS_GetArmor() <= self.GiveArmorType or bIsHeavyArmor) then
                if self.GiveArmorType == DZ_ENTS_ARMOR_KEVLAR then
                    ply:SetMaxArmor(100)
                elseif bIsHeavyArmor then
                    ply:SetMaxArmor(200)
                    -- local speed = DZ_ENTS.ConVars["armor_heavy_speed"]:GetInt()
                    -- if speed > 0 and not ply:DZ_ENTS_HasHeavyArmor() then
                    --     ply.DZ_ENTS_OriginalSpeed = {ply:GetSlowWalkSpeed(), ply:GetWalkSpeed(), ply:GetRunSpeed()}
                    --     ply:SetSlowWalkSpeed(math.min(ply:GetSlowWalkSpeed(), speed))
                    --     ply:SetWalkSpeed(speed)
                    --     ply:SetRunSpeed(speed * 2)
                    -- end

                    ply:DZ_ENTS_ApplyHeavyArmorModel(self.GiveArmorType)

                    if IsValid(ply:GetActiveWeapon()) and DZ_ENTS.ConVars["armor_heavy_norifle"]:GetBool() and not DZ_ENTS.HeavyArmorCanPickup(ply:GetActiveWeapon():GetClass()) then
                        ply:DropWeapon(ply:GetActiveWeapon())
                    end
                end
                ply:DZ_ENTS_SetArmor(self.GiveArmorType)
            end
            ply:SetArmor(math.min(ply:GetMaxArmor(), ply:Armor() + self.GiveArmor))
        end

        if bGaveHelmet or bGaveArmor then
            if bIsHeavyArmor then
                DZ_ENTS:Hint(ply, 8) -- "Heavy suit equipped"
                ply:EmitSound("dz_ents/armor_pickup_02.wav", 80, 90)
                ply:EmitSound("items/ammopickup.wav", 80, 90)
                self:Remove()
                return
            elseif self.GiveHelmet and not bGaveHelmet then
                local ent = ents.Create("dz_armor_helmet")
                if IsValid(ent) then
                    ent:SetPos(self:GetPos() + Vector(0, 0, 4))
                    ent:SetAngles(self:GetAngles())
                    ent:Spawn()

                    if undo then
                        undo.ReplaceEntity(self, ent)
                    end
                    if cleanup then
                        cleanup.ReplaceEntity(self, ent)
                    end
                end
                DZ_ENTS:Hint(ply, 3)
            elseif (self.GiveArmor or 0) > 0 and not bGaveArmor then
                local ent = ents.Create("dz_armor_kevlar")
                if IsValid(ent) then
                    ent:SetPos(self:GetPos() + Vector(0, 0, 10))
                    ent:SetAngles(self:GetAngles())
                    ent:Spawn()

                    if undo then
                        undo.ReplaceEntity(self, ent)
                    end
                    if cleanup then
                        cleanup.ReplaceEntity(self, ent)
                    end
                end
                DZ_ENTS:Hint(ply, 4)
            elseif bGaveHelmet and bGaveArmor then
                DZ_ENTS:Hint(ply, 2)
            elseif bGaveHelmet then
                DZ_ENTS:Hint(ply, 4)
            elseif bGaveArmor then
                DZ_ENTS:Hint(ply, 3)
            end

            ply:EmitSound("dz_ents/armor_pickup_01.wav")
            self:Remove()
        else
            if bIsHeavyArmor then
                DZ_ENTS:Hint(ply, 9) -- "You already have a Heavy Assault Suit"
            elseif (self.GiveArmor or 0) > 0 then
                DZ_ENTS:Hint(ply, 6) -- "You cannot pick up any more armor"
            elseif (self.GiveHelmet) then
                DZ_ENTS:Hint(ply, 5) -- "You aready have a helmet"
            else
                -- unhandled
                --print("something went wrong!", self, self.GiveArmor, self.GiveHelmet)
            end
        end
    end
end