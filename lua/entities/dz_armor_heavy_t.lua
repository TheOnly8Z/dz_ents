AddCSLuaFile()

ENT.Base = "dz_base_armor"

ENT.PrintName = "Heavy Assault Suit (T)"
ENT.Spawnable = true
ENT.AdminOnly = GetConVar("dzents_armor_heavy_adminonly"):GetBool()
ENT.Category = "Danger Zone"

ENT.SubCategory = "Pickups"
ENT.SortOrder = 100

ENT.Model = "models/props_survival/upgrades/upgrade_heavy_armor.mdl"
ENT.Bodygroups = "0"
ENT.GiveArmor = 200
ENT.GiveHelmet = true
ENT.HeavyArmor = true
ENT.GiveArmorType = DZ_ENTS_ARMOR_HEAVY_T