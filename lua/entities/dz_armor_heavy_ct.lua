AddCSLuaFile()

ENT.Base = "dz_base_armor"

ENT.PrintName = "Heavy Assault Suit (CT)"
ENT.Spawnable = true
ENT.AdminOnly = DZ_ENTS.ConVars["armor_heavy_adminonly"]:GetBool()
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 101

ENT.Model = "models/props_survival/upgrades/upgrade_heavy_armor.mdl"
ENT.Bodygroups = "1"
ENT.GiveArmor = 200
ENT.GiveHelmet = true
ENT.HeavyArmor = true
ENT.GiveArmorType = DZ_ENTS_ARMOR_HEAVY_CT