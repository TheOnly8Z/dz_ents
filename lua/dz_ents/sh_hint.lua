DZ_ENTS.Hints = {
    [1] = {"Reinforced crates require tools or weapons to open", true},
    [2] = {"Armor and Helmet equipped.", false},
    [3] = {"Armor equipped.", false},
    [4] = {"Helmet equipped.", false},
    [5] = {"You already have a helmet.", true},
    [6] = {"You already have full armor.", true},
    [7] = {"You already have a helmet and full armor.", true},
    [8] = {"Heavy Assault Suit equipped.", false},
    [9] = {"You already have a Heavy Assault Suit.", true},
    [10] = {"You picked up a Parachute.", false},
    [11] = {"You picked up an ExoJump.", false},
    [12] = {"You already have a Parachute.", true},
    [13] = {"You already have an ExoJump.", true},
}
DZ_ENTS.HintBits = 6

if SERVER then
    function DZ_ENTS:Hint(ply, i, ent)
        ply.DZ_ENTS_Hinted = ply.DZ_ENTS_Hinted or {}
        if (ply.DZ_ENTS_Hinted[i] or 0) > CurTime() then return end
        net.Start("dz_ents_hint")
            if ent then
                net.WriteBool(true)
                net.WriteEntity(ent)
            else
                net.WriteBool(false)
            end
            net.WriteUInt(i, DZ_ENTS.HintBits)
        net.Send(ply)
        ply.DZ_ENTS_Hinted[i] = CurTime() + 3
    end
end