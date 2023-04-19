DZ_ENTS.AddList = {
    "weapon_dz_healthshot"
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