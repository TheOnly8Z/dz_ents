
function DZ_ENTS.SaveUserDefList(list_name)
    local str = util.TableToJSON(DZ_ENTS.UserDefLists[list_name] or {}) or ""

    file.Write("dz_ents/" .. list_name .. ".txt", str)

    print("[DZ_ENTS] Saved user defined list '" .. list_name .. "' with " .. #DZ_ENTS.UserDefLists[list_name] .. " entries.")
end

function DZ_ENTS.LoadUserDefList(list_name)
    local tbl = util.JSONToTable(file.Read("dz_ents/" .. list_name .. ".txt", "DATA") or "")

    DZ_ENTS.UserDefLists[list_name] = tbl or {}
    DZ_ENTS.UserDefListsDict[list_name] = {}
    for _, v in pairs(DZ_ENTS.UserDefLists[list_name]) do
        DZ_ENTS.UserDefListsDict[list_name][v] = true
    end

    print("[DZ_ENTS] Loaded user defined list '" .. list_name .. "' with " .. #DZ_ENTS.UserDefLists[list_name] .. " entries.")
end

net.Receive("dz_ents_listrequest", function(len, ply)
    if not ply:IsAdmin() then return end
    local list_name = net.ReadString()
    DZ_ENTS.WriteUserDefList(list_name, ply)
end)

hook.Add("Initialize", "dz_ents_list", function()
    file.CreateDir("dz_ents")
    for k, v in pairs(file.Find("dz_ents/*.txt", "DATA")) do
        DZ_ENTS.LoadUserDefList(string.sub(v, 0, -5))
    end
end)

concommand.Add("dzents_debug_userdef_read", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    for k, v in pairs(file.Find("dz_ents/*.txt", "DATA")) do
        DZ_ENTS.LoadUserDefList(string.sub(v, 0, -5))
    end
end)

concommand.Add("dzents_debug_userdef_clear", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    if not args[1] then
        DZ_ENTS.UserDefLists = {}
        DZ_ENTS.UserDefListsDict = {}
    else
        DZ_ENTS.UserDefLists[tostring(args[1])] = {}
        DZ_ENTS.UserDefListsDict[tostring(args[1])] = {}
    end
end)