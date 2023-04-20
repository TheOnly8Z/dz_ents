-- Add weapons to the equipment list so they're in one place.
DZ_ENTS.AddList = {
    "weapon_dz_healthshot",
    "weapon_dz_bumpmine",
}
local function addlist()
    for k, v in pairs(DZ_ENTS.AddList) do
        local wep = weapons.Get(v)

        list.Set("SpawnableEntities", v, {
            PrintName = wep.PrintName,
            ClassName = v,
            Category = "Danger Zone",
            NormalOffset = 32,
            DropToFloor = true,
            Spawnable = wep.Spawnable,
            AdminOnly = wep.AdminOnly,
        })
    end

end
hook.Add("Initialize", "dz_ents_list", addlist)
-- addlist()

-- Heavy playermodels ported by ArachnitCZ: http://steamcommunity.com/profiles/76561198015206549/
player_manager.AddValidModel( "CS:GO Heavy CT Enhanced", "models/arachnit/csgo/ctm_heavy/ctm_heavy_player.mdl" );
player_manager.AddValidHands( "CS:GO Heavy CT Enhanced", "models/arachnit/csgo/weapons/c_arms_ctm_heavy.mdl", 0, "00000000" )
player_manager.AddValidModel( "CS:GO Phoenix Heavy Enhanced", "models/arachnit/csgoheavyphoenix/tm_phoenix_heavyplayer.mdl" );
player_manager.AddValidHands( "CS:GO Phoenix Heavy Enhanced", "models/arachnit/csgoheavyphoenix/c_arms/c_arms_tm_heavy.mdl", 0, "00000000" )