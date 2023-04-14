local PLAYER = FindMetaTable("Player")

-- one type of armor (enum)
DZ_ENTS_ARMOR_NONE = 0
DZ_ENTS_ARMOR_KEVLAR = 1
DZ_ENTS_ARMOR_HEAVY_CT = 2
DZ_ENTS_ARMOR_HEAVY_T = 3

-- any number of equips (bitflag)
DZ_ENTS_EQUIP_NONE = 0
DZ_ENTS_EQUIP_PARACHUTE = 1
DZ_ENTS_EQUIP_EXOJUMP = 2

function PLAYER:DZ_ENTS_HasHelmet()
    return self:GetNWBool("DZ_Ents.Helmet", false)
end

function PLAYER:DZ_ENTS_GiveHelmet()
    if swcs then
        self:GiveHelmet()
    end
    self:SetNWBool("DZ_Ents.Helmet", true)
end

function PLAYER:DZ_ENTS_RemoveHelmet(drop)
    if drop and self:DZ_ENTS_HasHelmet() and self:DZ_ENTS_GetArmor() <= DZ_ENTS_ARMOR_KEVLAR then
        local ent = ents.Create("dz_armor_helmet")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:SetVelocity(self:GetVelocity() + VectorRand() * 256)
            SafeRemoveEntityDelayed(ent, 60)
        end
    end

    if swcs then
        self:RemoveHelmet()
    end
    self:SetNWBool("DZ_Ents.Helmet", false)
end

function PLAYER:DZ_ENTS_GetArmor()
    return self:GetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE)
end

function PLAYER:DZ_ENTS_HasArmor()
    return self:GetArmor() ~= DZ_ENTS_ARMOR_NONE
end

function PLAYER:DZ_ENTS_SetArmor(armor)
    self:SetNWInt("DZ_Ents.Armor", armor)
end

function PLAYER:DZ_ENTS_RemoveArmor(drop)
    if drop and self:DZ_ENTS_GetArmor() == DZ_ENTS_ARMOR_KEVLAR and self:Armor() > 0 then
        local ent = ents.Create("dz_armor_kevlar")
        if IsValid(ent) then
            ent.GiveArmor = math.min(self:Armor(), 100)
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:SetVelocity(self:GetVelocity() + VectorRand() * 256)
            SafeRemoveEntityDelayed(ent, 60)
        end
    end
    self:SetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE)
end

function PLAYER:DZ_ENTS_GetEquipment()
    return self:GetNWInt("DZ_Ents.Equipment", DZ_ENTS_EQUIP_NONE)
end

function PLAYER:DZ_ENTS_HasEquipment(equip)
    return bit.band(self:DZ_ENTS_GetEquipment(), equip) == equip
end

function PLAYER:DZ_ENTS_SetEquipment(equip)
    self:SetNWInt("DZ_Ents.Equipment", equip)
end

function PLAYER:DZ_ENTS_GiveEquipment(equip)
    self:DZ_ENTS_SetEquipment(bit.bor(self:DZ_ENTS_GetEquipment(), equip))
end

function PLAYER:DZ_ENTS_RemoveEquipment(equip)
    if equip then
        self:DZ_ENTS_SetEquipment(bit.band(self:DZ_ENTS_GetEquipment(), bit.bnot(equip)))
    else
        self:DZ_ENTS_SetEquipment(DZ_ENTS_EQUIP_NONE)
    end
end

hook.Add("DoPlayerDeath", "dz_ents_player", function(ply)
    local drop = GetConVar("dzents_armor_deathdrop"):GetBool()
    ply:DZ_ENTS_RemoveHelmet(drop)
    ply:DZ_ENTS_RemoveArmor(drop)
    ply:DZ_ENTS_RemoveEquipment()
end)