DZ_ENTS = {}

--[[
Weapon bases that should be considered:
Tactical RP
ArcCW
ARC9
CW2 (Base, Extras, Unoffical Extras, KK, Snow White, Rinic)

Addons with canonical weapon integration (armor penetration, ammo pickup numbers)

SWCS CS:GO Weapons. Very accurate port with correct names - preferred pack.
https://steamcommunity.com/sharedfiles/filedetails/?id=2193997180

ArcCW Gunsmith Offensive
https://steamcommunity.com/workshop/filedetails/?id=2131057232

ArcCW Gunsmith Offensive Extras, by yours truly
https://steamcommunity.com/sharedfiles/filedetails/?id=2409364730

ARC9 Gunsmith Reloaded. I _am_ listed as a contributor so...
https://steamcommunity.com/sharedfiles/filedetails/?id=2910537020

TFA CS:GO. Original is long gone, so here's the most popular reupload.
https://steamcommunity.com/workshop/filedetails/?id=2839918331

RetroSource's CS:GO Weapons. They don't even fully function in singleplayer?
https://steamcommunity.com/sharedfiles/filedetails/?id=2180833718

This set of CSGO weapons from 2017. Popular, I guess
https://steamcommunity.com/sharedfiles/filedetails/?id=1254322322

NOT SUPPORTED:
Buu342's CS:GO SWEP Pack. Base does not even work.
https://steamcommunity.com/sharedfiles/filedetails/?id=239687689
]]

-- include("dz_ents/sh_util.lua")
-- AddCSLuaFile("dz_ents/sh_util.lua")

-- AddCSLuaFile("dz_ents/sh_hint.lua")
-- AddCSLuaFile("dz_ents/sh_loot.lua")
-- AddCSLuaFile("dz_ents/sh_player.lua")
-- AddCSLuaFile("dz_ents/sh_convar.lua")

-- include("dz_ents/sh_hint.lua")
-- include("dz_ents/sh_loot.lua")
-- include("dz_ents/sh_player.lua")
-- include("dz_ents/sh_convar.lua")

-- if CLIENT then
--     include("dz_ents/cl_draw.lua")
--     AddCSLuaFile("dz_ents/cl_draw.lua")
-- else
--     include("dz_ents/sv_net.lua")
-- end

local rootDir = "dz_ents"

local function AddFile(File, dir)
    local fileSide = string.lower(string.Left(File, 3))

    if SERVER and fileSide == "sv_" then
        include(dir .. File)
    elseif fileSide == "sh_" then
        if SERVER then
            AddCSLuaFile(dir .. File)
        end

        include(dir .. File)
    elseif fileSide == "cl_" then
        if SERVER then
            AddCSLuaFile(dir .. File)
        elseif CLIENT then
            include(dir .. File)
        end
    end
end

local function IncludeDir(dir)
    dir = dir .. "/"
    local File, Directory = file.Find(dir .. "*", "LUA")

    for k, v in ipairs(File) do
        if string.EndsWith(v, ".lua") then
            AddFile(v, dir)
        end
    end

    for k, v in ipairs(Directory) do
        IncludeDir(dir .. v)
    end
end

IncludeDir(rootDir)

list.Set( "ContentCategoryIcons", "CS:GO Equipment", "games/16/csgo.png" )
list.Set( "ContentCategoryIcons", "Danger Zone", "dz_ents/icon_16.png" )