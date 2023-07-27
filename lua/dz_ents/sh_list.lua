-- Add weapons to the equipment list so they're in one place.
-- DZ_ENTS.AddList = {
--     "weapon_dz_healthshot",
--     "weapon_dz_bumpmine",
-- }
-- local function addlist()
--     for k, v in pairs(DZ_ENTS.AddList) do
--         local wep = weapons.Get(v)

--         list.Set("SpawnableEntities", v, {
--             PrintName = wep.PrintName,
--             ClassName = v,
--             Category = "Danger Zone",
--             NormalOffset = 32,
--             DropToFloor = true,
--             Spawnable = wep.Spawnable,
--             AdminOnly = wep.AdminOnly,
--         })
--     end

-- end
-- hook.Add("Initialize", "dz_ents_list", addlist)
-- addlist()

-- Heavy playermodels ported by ArachnitCZ: http://steamcommunity.com/profiles/76561198015206549/
player_manager.AddValidModel( "CS:GO Heavy CT Enhanced", "models/arachnit/csgo/ctm_heavy/ctm_heavy_player.mdl" );
player_manager.AddValidHands( "CS:GO Heavy CT Enhanced", "models/arachnit/csgo/weapons/c_arms_ctm_heavy.mdl", 0, "00000000" )
player_manager.AddValidModel( "CS:GO Phoenix Heavy Enhanced", "models/arachnit/csgoheavyphoenix/tm_phoenix_heavyplayer.mdl" );
player_manager.AddValidHands( "CS:GO Phoenix Heavy Enhanced", "models/arachnit/csgoheavyphoenix/c_arms/c_arms_tm_heavy.mdl", 0, "00000000" )

DZ_ENTS.UserDefLists = {}
DZ_ENTS.UserDefListsDict = {}

function DZ_ENTS.InUserDefList(list_name, entry)
    return DZ_ENTS.UserDefListsDict[list_name] ~= nil and DZ_ENTS.UserDefListsDict[list_name][entry] ~= nil
end

function DZ_ENTS.CountUserDefList(list_name)
    return DZ_ENTS.UserDefLists[list_name] and #DZ_ENTS.UserDefLists[list_name] or 0
end

function DZ_ENTS.AddToUserDefList(list_name, entry)
    DZ_ENTS.UserDefLists[list_name] = DZ_ENTS.UserDefLists[list_name] or {}
    DZ_ENTS.UserDefListsDict[list_name] = DZ_ENTS.UserDefListsDict[list_name] or {}
    if DZ_ENTS.UserDefListsDict[list_name][entry] then return end

    table.insert(DZ_ENTS.UserDefLists[list_name], entry)
    DZ_ENTS.UserDefListsDict[list_name][entry] = true
end

function DZ_ENTS.RemoveFromUserDefList(list_name, entry)
    DZ_ENTS.UserDefLists[list_name] = DZ_ENTS.UserDefLists[list_name] or {}
    DZ_ENTS.UserDefListsDict[list_name] = DZ_ENTS.UserDefListsDict[list_name] or {}
    if not DZ_ENTS.UserDefListsDict[list_name][entry] then return end

    table.RemoveByValue(DZ_ENTS.UserDefLists[list_name], entry)
    DZ_ENTS.UserDefListsDict[list_name][entry] = nil
end

function DZ_ENTS.ClearUserDefList(list_name)
    DZ_ENTS.UserDefLists[list_name] = nil
    DZ_ENTS.UserDefListsDict[list_name] = nil
end

function DZ_ENTS.WriteUserDefList(list_name, ply)
    DZ_ENTS.UserDefLists[list_name] = DZ_ENTS.UserDefLists[list_name] or {}
    net.Start("dz_ents_list")
    net.WriteString(list_name)
    net.WriteUInt(table.Count(DZ_ENTS.UserDefLists[list_name]), 8)
    for k, v in pairs(DZ_ENTS.UserDefLists[list_name]) do
        net.WriteString(v)
    end
    if CLIENT then
        net.SendToServer()
    else
        net.Send(ply)
    end
end

function DZ_ENTS.ReadUserDefList(list_name)
    DZ_ENTS.UserDefLists[list_name] = {}
    DZ_ENTS.UserDefListsDict[list_name] = {}
    local len = net.ReadUInt(8)
    for i = 1, len do
        local str = net.ReadString()
        table.insert(DZ_ENTS.UserDefLists[list_name], str)
        DZ_ENTS.UserDefListsDict[list_name][str] = true
    end

    print("[DZ_ENTS] Received " .. len .. " entries for user defined list '" .. list_name .. "'.")
end

if SERVER then
    net.Receive("dz_ents_list", function(len, ply)
        if not ply:IsAdmin() then return end
        local list_name = net.ReadString()
        DZ_ENTS.ReadUserDefList(list_name)
        DZ_ENTS.SaveUserDefList(list_name)

        if list_name == "case_category" then
            -- force re-cache
            DZ_ENTS.LootTypeList = {}
            DZ_ENTS.LootTypeListLookup = {}
        end
    end)
elseif CLIENT then
    net.Receive("dz_ents_list", function()
        local list_name = net.ReadString()
        DZ_ENTS.ReadUserDefList(list_name)
    end)
end