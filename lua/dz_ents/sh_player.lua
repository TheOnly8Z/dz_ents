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
    if PLAYER.GiveHelmet then -- swcs
        PLAYER.GiveHelmet(self)
    end
    self:SetNWBool("DZ_Ents.Helmet", true)
end

function PLAYER:DZ_ENTS_RemoveHelmet(drop)
    if drop and self:DZ_ENTS_HasHelmet() and PLAYER.DZ_ENTS_GetArmor(self) <= DZ_ENTS_ARMOR_KEVLAR and (self:Armor() > 0 or self.PendingArmor > 0) then
        local ent = ents.Create("dz_armor_helmet")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 72))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 64)
            ent:MarkForRemove()
        end
    end

    if PLAYER.RemoveHelmet then -- swcs
        PLAYER.RemoveHelmet(self)
    end
    self:SetNWBool("DZ_Ents.Helmet", false)
end

function PLAYER:DZ_ENTS_GetArmor()
    return self:GetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE)
end

function PLAYER:DZ_ENTS_HasArmor()
    return self:GetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE) ~= DZ_ENTS_ARMOR_NONE
end

function PLAYER:DZ_ENTS_HasHeavyArmor()
    return self:GetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE) > DZ_ENTS_ARMOR_KEVLAR
end

function PLAYER:DZ_ENTS_SetArmor(armor)
    self:SetNWInt("DZ_Ents.Armor", armor)
end

function PLAYER:DZ_ENTS_RemoveArmor(drop)
    if drop and PLAYER.DZ_ENTS_GetArmor(self) == DZ_ENTS_ARMOR_KEVLAR and (self:Armor() > 0 or  (self.PendingArmor or 0) > 0) then
        local ent = ents.Create("dz_armor_kevlar")
        if IsValid(ent) then
            ent.GiveArmor = math.min(self.PendingArmor or self:Armor(), 100)
            ent:SetPos(self:GetPos() + Vector(0, 0, 48))
            ent:SetAngles(self:GetAngles())
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 64)
            ent:MarkForRemove()
        end
    end
    self:SetNWInt("DZ_Ents.Armor", DZ_ENTS_ARMOR_NONE)
end

function PLAYER:DZ_ENTS_GetEquipment()
    return self:GetNWInt("DZ_Ents.Equipment", DZ_ENTS_EQUIP_NONE)
end

function PLAYER:DZ_ENTS_HasEquipment(equip)
    return bit.band(PLAYER.DZ_ENTS_GetEquipment(self), equip) == equip
end

function PLAYER:DZ_ENTS_SetEquipment(equip)
    self:SetNWInt("DZ_Ents.Equipment", equip)
end

function PLAYER:DZ_ENTS_GiveEquipment(equip)
    PLAYER.DZ_ENTS_SetEquipment(self, bit.bor(PLAYER.DZ_ENTS_GetEquipment(self), equip))
end

function PLAYER:DZ_ENTS_RemoveEquipment(drop, equip)
    local dropped = nil
    if equip then
        dropped = equip
        PLAYER.DZ_ENTS_SetEquipment(self, bit.band(PLAYER.DZ_ENTS_GetEquipment(self), bit.bnot(equip)))
    else
        dropped = PLAYER.DZ_ENTS_GetEquipment(self)
        PLAYER.DZ_ENTS_SetEquipment(self, DZ_ENTS_EQUIP_NONE)
    end

    if drop and bit.band(dropped, DZ_ENTS_EQUIP_PARACHUTE) ~= 0 then
        local ent = ents.Create("dz_pickup_parachute")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 40))
            local ang = self:GetAngles()
            ang:RotateAroundAxis(ang:Right(), 90)
            ent:SetAngles(ang)
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 96)
            ent:MarkForRemove()
        end
    end
    if drop and bit.band(dropped, DZ_ENTS_EQUIP_EXOJUMP) ~= 0 then
        local ent = ents.Create("dz_pickup_exojump")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0, 0, 20))
            local ang = self:GetAngles()
            ang:RotateAroundAxis(ang:Forward(), 90)
            ent:SetAngles(ang)
            ent:Spawn()
            ent:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() + VectorRand() * 96)
            ent:MarkForRemove()
        end
    end
end

local armorregions = {
    [HITGROUP_GENERIC] = true, -- blast damage etc.
    [HITGROUP_GEAR] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
    [HITGROUP_LEFTARM] = true,
    [HITGROUP_RIGHTARM] = true,
}
-- Does not check for armor value... do that in the hook
function PLAYER:DZ_ENTS_IsArmoredHitGroup(hitgroup)
    local uselogic = DZ_ENTS.ConVars["armor_enabled"]:GetInt()
    if uselogic == 0 then return false end

    return PLAYER.DZ_ENTS_HasHeavyArmor(self) -- heavy armor covers all regions
            or (hitgroup == HITGROUP_HEAD and (uselogic == 2 or PLAYER.DZ_ENTS_HasHelmet(self))) -- if hit head, check helmet
            or (armorregions[hitgroup] and (uselogic == 2 or PLAYER.DZ_ENTS_HasArmor(self))) -- otherwise check armored regions
end

function PLAYER:DZ_ENTS_ApplyHeavyArmorModel(armor)
    if not DZ_ENTS.ConVars["armor_heavy_playermodel"]:GetBool() or (armor ~= DZ_ENTS_ARMOR_HEAVY_CT and armor ~= DZ_ENTS_ARMOR_HEAVY_T) then return end

    self.DZ_ENTS_OldPlayerModel = {self:GetModel(), self:GetSkin(), {}}
    for k, v in pairs(self:GetBodyGroups()) do
        self.DZ_ENTS_OldPlayerModel[3][v.id] = self:GetBodygroup(v.id)
    end
    if armor == DZ_ENTS_ARMOR_HEAVY_CT then
        self:SetModel("models/arachnit/csgo/ctm_heavy/ctm_heavy_player.mdl")
        local hands = self:GetHands()
        hands:SetModel("models/arachnit/csgo/weapons/c_arms_ctm_heavy.mdl")
    elseif armor == DZ_ENTS_ARMOR_HEAVY_T then
        self:SetModel("models/arachnit/csgoheavyphoenix/tm_phoenix_heavyplayer.mdl")
        local hands = self:GetHands()
        hands:SetModel("models/arachnit/csgoheavyphoenix/c_arms/c_arms_tm_heavy.mdl")
    end
    self:SetSkin(DZ_ENTS.ConVars["armor_heavy_playermodel_skin"]:GetBool() and math.random(1, self:SkinCount()) or 0)
    self:SetBodyGroups("00000000")
end

-- DoPlayerDeath happens _before_ PostEntityTakeDamage, so Armor is 0 for purposes of damage calc.
hook.Add("DoPlayerDeath", "dz_ents_player", function(ply)
    local drop = DZ_ENTS.ConVars["drop_armor"]:GetBool() and (ply:Armor() > 0 or (ply.PendingArmor or 0) > 0) and not ply:DZ_ENTS_HasHeavyArmor()
    local dropequip = DZ_ENTS.ConVars["drop_equip"]:GetBool()
    ply:DZ_ENTS_RemoveHelmet(drop)
    ply:DZ_ENTS_RemoveArmor(drop)
    ply:DZ_ENTS_RemoveEquipment(dropequip)
    ply:SetNWFloat("DZ_Ents.Healthshot", 0)

    ply.DZENTS_BumpMine_Launched = nil
    ply.DZENTS_BumpMine_LaunchTime = nil
    ply.DZENTS_BumpMine_Attacker = nil
end)

hook.Add("PlayerLoadout", "dz_ents_player", function(ply)
    ply.DZ_ENTS_OriginalSpeed = nil
    ply.DZ_ENTS_OldPlayerModel = nil
    ply.DZENTS_Robert = nil
    ply:DZ_ENTS_RemoveHelmet()
    ply:DZ_ENTS_RemoveArmor()
    ply:DZ_ENTS_RemoveEquipment()
    timer.Simple(0, function()
        local give = DZ_ENTS.ConVars["armor_onspawn"]:GetInt()
        if give == 3 then
            local armor = math.random() <= 0.5 and DZ_ENTS_ARMOR_HEAVY_CT or DZ_ENTS_ARMOR_HEAVY_T
            ply:DZ_ENTS_GiveHelmet() -- here for formality even though heavy armor protects all hitgroups (SWCS hit effects)
            ply:DZ_ENTS_SetArmor(armor)
            ply:SetArmor(200)
            ply:SetMaxArmor(200)
            ply:DZ_ENTS_ApplyHeavyArmorModel(armor)
            -- local speed = DZ_ENTS.ConVars["armor_heavy_speed"]:GetInt()
            -- if speed > 0 then
            --     ply.DZ_ENTS_OriginalSpeed = {ply:GetSlowWalkSpeed(), ply:GetWalkSpeed(), ply:GetRunSpeed()}
            --     ply:SetSlowWalkSpeed(math.min(ply:GetSlowWalkSpeed(), speed))
            --     ply:SetWalkSpeed(speed)
            --     ply:SetRunSpeed(speed * 2)
            -- end
        else
            if give >= 1 then
                ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
                ply:SetArmor(100)
                ply:SetMaxArmor(100)
            end
            if give >= 2 then
                ply:DZ_ENTS_GiveHelmet()
            end
        end

        local giveequip = 0
        if DZ_ENTS.ConVars["parachute_onspawn"]:GetBool() then
            giveequip = giveequip + DZ_ENTS_EQUIP_PARACHUTE
        end
        if DZ_ENTS.ConVars["exojump_onspawn"]:GetBool() then
            giveequip = giveequip + DZ_ENTS_EQUIP_EXOJUMP
        end
        if giveequip > 0 then
            ply:DZ_ENTS_GiveEquipment(giveequip)
        end
    end)
end)

DZ_ENTS.HeavyArmorWeaponCache = {}
function DZ_ENTS.HeavyArmorCanPickup(class, mode)
    mode = mode or DZ_ENTS.ConVars["armor_heavy_norifle"]:GetInt()
    if mode == 0 then
        return true
    end
    local canontbl = DZ_ENTS.CanonicalWeapons[DZ_ENTS:GetCanonicalClass(class)]
    if canontbl and canontbl.Category == "Rifle" then
        return false
    end
    if not canontbl and mode == 2 then
        if DZ_ENTS.HeavyArmorWeaponCache[class] == nil then
            local tbl = weapons.Get(class)
            local ammocat = tbl and DZ_ENTS:GetWeaponAmmoCategory((tbl.Primary.Ammo ~= "") and tbl.Primary.Ammo or tbl.Ammo or "")
            if not tbl then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(class == "weapon_ar2" or class == "weapon_crossbow")
            elseif tbl.ArcticTacRP then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.SubCatType or ""), "rifle"))
            elseif tbl.ARC9 and tbl.Class then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.Class), "rifle") or string.find(string.lower(tbl.Class), "carbine"))
            elseif weapons.IsBasedOn(class, "mg_base") then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.SubCategory), "rifle"))
            elseif weapons.IsBasedOn(class, "bobs_gun_base") then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(string.find(string.lower(tbl.Category or ""), "rifle"))
            elseif tbl.IsTFAWeapon then
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(tbl.Type == "Rifle" or (tbl.Slot == 2 and ammocat == "rifle"))
            elseif tbl.CW20Weapon then
                -- CW2 modders love putting assault rifles in slot 4
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool((tbl.Slot == 2 or tbl.Slot == 3) and ammocat == "rifle")
            else
                DZ_ENTS.HeavyArmorWeaponCache[class] = tobool(tbl.Slot == 2 and (ammocat == "smg" or ammocat == "rifle"))
            end
        end
        if DZ_ENTS.HeavyArmorWeaponCache[class] == true then return false end
    end
    return true
end
if SERVER then
    concommand.Add("dzents_debug_riflecheck", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        for _, tbl in pairs(weapons.GetList()) do
            local rifle = not DZ_ENTS.HeavyArmorCanPickup(tbl.ClassName, 2)
            if rifle then print(tbl.ClassName) end
        end
    end)
end

hook.Add("PlayerSwitchWeapon", "dz_ents_player", function(ply, oldwep, wep)
    if ply:DZ_ENTS_HasHeavyArmor() then
        local class = wep:GetClass()
        if not DZ_ENTS.HeavyArmorCanPickup(class) then
            if SERVER then
                DZ_ENTS:Hint(ply, 15)
                ply:DropWeapon(wep)
            end
            return true
        elseif DZ_ENTS.ConVars["armor_heavy_deployspeed"]:GetFloat() < 1 then
            local speed = DZ_ENTS.ConVars["armor_heavy_deployspeed"]:GetFloat()
            if weapons.IsBasedOn(class, "mg_base") then
                -- EWWWWWWWWWWWWWWWWWW
                -- mw base doesn't have cool live stats like arccw so we'll have to do this the ugly way
                local oldfps = wep.Animations.Draw.Fps
                wep.Animations.Draw.Fps = wep.Animations.Draw.Fps * speed
                timer.Simple(0, function()
                    if IsValid(wep) then wep.Animations.Draw.Fps = oldfps end
                end)
            elseif wep.CW20Weapon then
                local olddsm = wep.DrawSpeedMult
                wep.DrawSpeedMult = wep.DrawSpeedMult * speed
                wep:recalculateDeployTime()
                timer.Simple(0, function()
                    if IsValid(wep) then
                        wep.DrawSpeedMult = olddsm
                        wep:recalculateDeployTime()
                    end
                end)
            end
        end
    end
end)

hook.Add("PlayerGiveSWEP", "dz_ents_player", function(ply, class, swep)
    if ply:DZ_ENTS_HasHeavyArmor() and not DZ_ENTS.HeavyArmorCanPickup(class) then
        if SERVER then
            DZ_ENTS:Hint(ply, 15)
        end
        return false
    end
end)

hook.Add("PlayerCanPickupWeapon", "dz_ents_player", function(ply, wep)
    if ply:DZ_ENTS_HasHeavyArmor() and not DZ_ENTS.HeavyArmorCanPickup(wep:GetClass()) then
        -- if SERVER then
        --     DZ_ENTS:Hint(ply, 15)
        -- end
        return false
    end

    if (wep.DZENTS_Pickup or 0) > CurTime() then return false end
end)


hook.Add("InitPostEntity", "dz_ents_precache", function()
    util.PrecacheModel("models/arachnit/csgo/ctm_heavy/ctm_heavy_player.mdl")
    util.PrecacheModel("models/arachnit/csgoheavyphoenix/tm_phoenix_heavyplayer.mdl")
end)
