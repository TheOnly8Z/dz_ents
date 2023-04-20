util.AddNetworkString("dz_ents_damage")
util.AddNetworkString("dz_ents_takeammo")
util.AddNetworkString("dz_ents_hint")
util.AddNetworkString("dz_ents_interact")
util.AddNetworkString("dz_ents_list")
util.AddNetworkString("dz_ents_listrequest")
util.AddNetworkString("dz_ents_cvarrequest")

net.Receive("dz_ents_cvarrequest", function(len, ply)
    if not ply:IsAdmin() then return end

    local cvar = net.ReadString()
    local val = net.ReadString()

    GetConVar(cvar):SetString(val)
end)