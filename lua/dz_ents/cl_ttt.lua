if engine.ActiveGamemode() ~= "terrortown" then return end

hook.Add("InitPostEntity", "dz_ents_ttt", function()
    LANG.AddToLanguage("english", "dzents_menutitle", "Mobility Package")
    LANG.AddToLanguage("english", "dzents_menu_tooltip", "Control mobility equipment")
    LANG.AddToLanguage("english", "dzents_menu_parachute", "Auto-deploy Parachute")
    LANG.AddToLanguage("english", "dzents_menu_exojump", "Enable ExoJump")
end)

hook.Add("TTTEquipmentTabs", "dz_ents_ttt", function(dsheet)
    local GetTranslation = LANG.GetTranslation
    if LocalPlayer():DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) or LocalPlayer():DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then
        local dform = vgui.Create("DForm", parent)
        dform:SetName(GetTranslation("dzents_menutitle"))
        dform:StretchToParent(0,0,0,0)
        dform:SetAutoSize(false)

        local dcheck = vgui.Create("DCheckBoxLabel", dform)
        dcheck:SetText(GetTranslation("dzents_menu_parachute"))
        dcheck:SetIndent(5)
        dcheck:SetConVar("cl_dzents_parachute_autodeploy")
        dform:AddItem(dcheck)

        local dcheck2 = vgui.Create("DCheckBoxLabel", dform)
        dcheck2:SetText(GetTranslation("dzents_menu_exojump"))
        dcheck2:SetIndent(5)
        dcheck2:SetConVar("cl_dzents_ttt_exojump")
        dform:AddItem(dcheck2)

        dsheet:AddSheet(GetTranslation("dzents_menutitle"), dform, "icon16/user_go.png", false, false, GetTranslation("dzents_menu_tooltip"))
    end
end)