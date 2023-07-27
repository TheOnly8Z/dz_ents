local function header(panel, text)
    local ctrl = panel:Help(text)
    ctrl:SetFont("DermaDefaultBold")
    return ctrl
end

local function combobox(panel, text, convar, options)
    local cb, lb = panel:ComboBox(text, convar)
    for k, v in pairs(options) do
        cb:AddChoice(k, v)
    end
    cb:DockMargin(8, 0, 0, 0)
    lb:SizeToContents()
end

local function menu_client(panel)
    header(panel, "Preference")
    panel:AddControl("checkbox", {
        label = "Automatically deploy parachute",
        command = "cl_dzents_parachute_autodeploy"
    })
    panel:ControlHelp("Parachute will deploy when your falling velocity becomes lethal.")
    panel:AddControl("checkbox", {
        label = "Show hints",
        command = "cl_dzents_hint"
    })

    header(panel, "\nInterface")
    panel:AddControl("checkbox", {
        label = "Use spawn menu subcategories",
        command = "cl_dzents_subcat"
    })
    panel:AddControl("checkbox", {
        label = "Armor / Equipment HUD",
        command = "cl_dzents_hud_enabled"
    })
    panel:AddControl("slider", {
        label = "HUD Scale",
        command = "cl_dzents_hud_scale",
        type = "float",
        min = 0.1,
        max = 3,
    })
    panel:AddControl("slider", {
        label = "HUD X Pos",
        command = "cl_dzents_hud_x",
        type = "float",
        min = -640,
        max = 640,
    })
    panel:AddControl("slider", {
        label = "HUD Y Pos",
        command = "cl_dzents_hud_y",
        type = "float",
        min = -640,
        max = 640,
    })
    panel:ControlHelp("Negative X/Y values align from the right and bottom.")

    header(panel, "\nVisuals")
    panel:AddControl("checkbox", {
        label = "Parachute viewmodel",
        command = "cl_dzents_parachute_vm"
    })
    panel:AddControl("checkbox", {
        label = "Parachute letterbox",
        command = "cl_dzents_parachute_frame"
    })
    panel:AddControl("checkbox", {
        label = "Medi-Shot overlay",
        command = "cl_dzents_healthshot_overlay"
    })
    panel:AddControl("checkbox", {
        label = "Heavy Assault Suit color correction",
        command = "cl_dzents_heavyarmor_cc"
    })

    header(panel, "\nAudio")
    panel:AddControl("slider", {
        label = "Armor hit volume",
        command = "cl_dzents_volume_hit",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:ControlHelp("Controls the sound you hear when you damage others' armor, regardless of distance.")

    header(panel, "\nCredits")
    panel:Help("Valve: CS:GO assets")
    panel:Help("ArachnitCZ: Heavy Assault Suit playermodel and hand port.")
    panel:Help("Twilight Sparkle: Medi-Shot and Bump Mine port.")
    panel:Help("Matsilagi: Bump Mine effects.")
    panel:ControlHelp("\n\tAn addon by 8Z")

end

local function menu_ammo(panel)

    header(panel, "Ammo Boxes")
    panel:AddControl("checkbox", {
        label = "Give clip size per use",
        command = "dzents_ammo_clip"
    })
    panel:ControlHelp("Uses Danger Zone values if not selected.")
    panel:AddControl("checkbox", {
        label = "Cleanup empty ammo boxes",
        command = "dzents_ammo_cleanup"
    })
    panel:ControlHelp("Does not clean up if ammo box regen is enabled.")
    panel:AddControl("checkbox", {
        label = "Limit maximum reserves",
        command = "dzents_ammo_limit"
    })
    panel:ControlHelp("Limit is based on ammo type (except for SWCS weapons).")
    panel:AddControl("slider", {
        label = "Ammo given",
        command = "dzents_ammo_mult",
        type = "float",
        min = 0,
        max = 5,
    })
    panel:AddControl("checkbox", {
        label = "Infinite ammo can is admin only",
        command = "dzents_ammo_adminonly"
    })
    panel:ControlHelp("Requires a map reload to take effect.")

    header(panel, "Regeneration")
    panel:AddControl("checkbox", {
        label = "Ammo boxes regenerate ammo",
        command = "dzents_ammo_regen"
    })
    panel:AddControl("checkbox", {
        label = "Gradual regeneration",
        command = "dzents_ammo_regen_partial"
    })
    panel:AddControl("slider", {
        label = "Regeneration delay",
        command = "dzents_ammo_regen_delay",
        type = "int",
        min = 1,
        max = 600,
    })
    panel:ControlHelp("Time it takes to fully regenerate all ammo.")

end

local function menu_cases(panel)
    panel:AddControl("checkbox", {
        label = "Reinforced cases",
        command = "dzents_case_reinforced"
    })
    panel:ControlHelp("Reinforced cases cannot be damaged by unarmed attacks.")
    panel:AddControl("checkbox", {
        label = "Shrink cases",
        command = "dzents_case_shrink"
    })
    panel:ControlHelp("Make cases smaller and disable player collision.")

    panel:AddControl("slider", {
        label = "Case health",
        command = "dzents_case_health",
        type = "float",
        min = 0,
        max = 5,
    })
    panel:AddControl("slider", {
        label = "Case loot cleanup",
        command = "dzents_case_cleanup",
        type = "int",
        min = 0,
        max = 600,
    })
    panel:ControlHelp("Case drops are removed after this much time. 0 - never remove.")

    combobox(panel, "Case gibs", "dzents_case_gib", {
        ["0 - No gibs"] = "0",
        ["1 - Clientside gibs"] = "1",
        ["2 - Serverside gibs"] = "2",
    })
    panel:ControlHelp("Serverside gibs may be more performance intensive.")

    local btn = vgui.Create("DButton")
    btn:Dock(TOP)
    btn:SetText("Case Category Filter")
    function btn.DoClick(self)
        if LocalPlayer():IsAdmin() then
            RunConsoleCommand("cl_dzents_menu_case_category")
        else
            notification.AddLegacy("This is admin only!", NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
        end
    end
    panel:AddPanel(btn)
    panel:ControlHelp("Use the menu to select categories and toggle the filter.\nWhen enabled, cases will only spawn weapons from the whitelisted categories.\nDoes not apply when the case has Custom Drops enabled.")

    local btn2 = vgui.Create("DButton")
    btn2:Dock(TOP)
    btn2:SetText("Case Custom Drops")
    function btn2.DoClick(self)
        if LocalPlayer():IsAdmin() then
            RunConsoleCommand("cl_dzents_menu_case_whitelist")
        else
            notification.AddLegacy("This is admin only!", NOTIFY_ERROR, 3)
            surface.PlaySound("buttons/button10.wav")
        end
    end
    panel:AddPanel(btn2)
    panel:ControlHelp("Use the menu to select specific weapons for each case.\nRight click the case and enable custom drops for it, then select weapons it should spawn.")

end

local function menu_armor(panel)

    header(panel, "Armor + Helmet")
    combobox(panel, "CS:GO behavior", "dzents_armor_enabled", {
        ["0 - Disabled"] = "0",
        ["1 - With armor/helmet"] = "1",
        ["2 - Always"] = "2",
    })
    panel:ControlHelp("Modifies damage and armor logic to closely match CS:GO.")
    panel:AddControl("checkbox", {
        label = "Protect against all damage",
        command = "dzents_armor_fallback"
    })
    panel:ControlHelp("Damage not protected by CS:GO armor will be handled like HL2 logic. If disabled, armor will be ignored.")
    panel:AddControl("checkbox", {
        label = "Helmet spark effect on hit",
        command = "dzents_armor_eff_head"
    })
    panel:AddControl("slider", {
        label = "Damage taken",
        command = "dzents_armor_damage",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:AddControl("slider", {
        label = "Durability loss",
        command = "dzents_armor_durability",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:ControlHelp("Multipliers do not stack with Heavy Assault Suit.")
    combobox(panel, "Armor on spawn", "dzents_armor_onspawn", {
        ["0 - Disabled"] = "0",
        ["1 - Armor only"] = "1",
        ["2 - Armor + Helmet"] = "2",
        ["3 - Heavy Assault Armor"] = "3",
    })
    panel:AddControl("checkbox", {
        label = "Drop armor on death",
        command = "dzents_drop_armor"
    })

    header(panel, "\nHeavy Assault Suit")
    panel:AddControl("checkbox", {
        label = "Set player model",
        command = "dzents_armor_heavy_playermodel"
    })
    panel:AddControl("checkbox", {
        label = "Randomize player skins",
        command = "dzents_armor_heavy_playermodel_skin"
    })
    panel:AddControl("checkbox", {
        label = "Restrict to admins only",
        command = "dzents_armor_heavy_adminonly"
    })
    panel:ControlHelp("Requires a map reload to take effect.")
    panel:AddControl("checkbox", {
        label = "Spark effect on hit",
        command = "dzents_armor_eff_heavy"
    })
    panel:AddControl("checkbox", {
        label = "Heavy Armor can break",
        command = "dzents_armor_heavy_break"
    })
    panel:ControlHelp("When broken, movement speed and other attributes will be restored.")
    panel:AddControl("checkbox", {
        label = "Disallow sprinting",
        command = "dzents_armor_heavy_nosprint"
    })
    panel:AddControl("checkbox", {
        label = "Always take realistic fall damage",
        command = "dzents_armor_heavy_falldamage"
    })
    panel:ControlHelp("Fall damage taken is identical to turning on 'Realistic fall damage'.")
    panel:AddControl("checkbox", {
        label = "Goomba stomp on landing",
        command = "dzents_armor_heavy_fallstomp"
    })
    panel:ControlHelp("Stomp damage is 3x fall damage.")
    panel:AddControl("checkbox", {
        label = "ROBERRRRRRRRRTTTTTTTTTTTTT",
        command = "dzents_armor_heavy_robert"
    })
    combobox(panel, "Restrict using rifles", "dzents_armor_heavy_norifle", {
        ["0 - No restriction"] = "0",
        ["1 - CS:GO rifles"] = "1",
        ["2 - All rifles"] = "2",
    })
    panel:ControlHelp("Restricted weapons cannot be picked up or switched to.\n'All rifles' option uses autodetection based on weapon base and may not be perfectly accurate.")
    panel:AddControl("slider", {
        label = "Damage taken",
        command = "dzents_armor_heavy_damage",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:AddControl("slider", {
        label = "Durability loss",
        command = "dzents_armor_heavy_durability",
        type = "float",
        min = 0,
        max = 10,
    })
    panel:AddControl("slider", {
        label = "Walk speed",
        command = "dzents_armor_heavy_speed",
        type = "int",
        min = 0,
        max = 200,
    })
    panel:ControlHelp("Set to 0 to not affect speed at all.")
    panel:AddControl("slider", {
        label = "Deploy speed",
        command = "dzents_armor_heavy_deployspeed",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:ControlHelp("Only affects certain weapon bases.")
    panel:AddControl("slider", {
        label = "Additional gravity",
        command = "dzents_armor_heavy_gravity",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:ControlHelp("Makes you fall faster, and reduces effectiveness of Parachutes, Bump Mines and ExoJumps.")
    panel:AddControl("slider", {
        label = "ExoJump strength",
        command = "dzents_armor_heavy_exojump",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:ControlHelp("Velocity multiplier when using the ExoJump with the Heavy Assault Armor.")
end

local function menu_pickups(panel)

    header(panel, "Pickups")
    panel:AddControl("checkbox", {
        label = "Instantly use pickups",
        command = "dzents_pickup_instantuse"
    })
    panel:AddControl("checkbox", {
        label = "Drop armor on death",
        command = "dzents_drop_armor"
    })
    panel:AddControl("checkbox", {
        label = "Drop equipment on death",
        command = "dzents_drop_equip"
    })
    panel:AddControl("slider", {
        label = "Drop cleanup delay",
        command = "dzents_drop_cleanup",
        type = "int",
        min = 0,
        max = 300,
    })
    panel:ControlHelp("Timer for removing items dropped on death. 0 - never remove.")

    -- header(panel, "\nGive on Spawn")
    combobox(panel, "Armor on spawn", "dzents_armor_onspawn", {
        ["0 - Disabled"] = "0",
        ["1 - Armor only"] = "1",
        ["2 - Armor + Helmet"] = "2",
        ["3 - Heavy Assault Armor"] = "3",
    })
    panel:AddControl("checkbox", {
        label = "ExoJump on spawn",
        command = "dzents_exojump_onspawn"
    })
    panel:AddControl("checkbox", {
        label = "Parachute on spawn",
        command = "dzents_parachute_onspawn"
    })

    header(panel, "\nExoJump")
    panel:AddControl("checkbox", {
        label = "Sprint boost",
        command = "dzents_exojump_runboost"
    })
    panel:ControlHelp("Allow using running speed to boost with the ExoJump. If disabled, drag will slow down velocity to walking speed.")

    panel:AddControl("slider", {
        label = "High jump boost",
        command = "dzents_exojump_boost_up",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:AddControl("slider", {
        label = "Long jump boost",
        command = "dzents_exojump_boost_forward",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:AddControl("slider", {
        label = "Fall damage",
        command = "dzents_exojump_falldamage",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:AddControl("slider", {
        label = "Drag",
        command = "dzents_exojump_drag",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:ControlHelp("Drag reduces horizontal velocity when it exceeds maximum.")

    header(panel, "\nParachute")
    panel:AddControl("checkbox", {
        label = "Consume on landing",
        command = "dzents_parachute_consume"
    })
    panel:AddControl("checkbox", {
        label = "Allow premature detach",
        command = "dzents_parachute_detach"
    })
    panel:AddControl("slider", {
        label = "Deploy threshold",
        command = "dzents_parachute_threshold",
        type = "float",
        min = 0,
        max = 1000,
    })
    panel:AddControl("slider", {
        label = "Fall velocity",
        command = "dzents_parachute_fall",
        type = "int",
        min = 50,
        max = 500,
    })
    panel:AddControl("slider", {
        label = "Horizontal speed",
        command = "dzents_parachute_speed",
        type = "float",
        min = 0,
        max = 400,
    })
    panel:AddControl("slider", {
        label = "Horizontal drag",
        command = "dzents_parachute_drag",
        type = "float",
        min = 0,
        max = 5,
    })
end

local function menu_equip(panel)
    header(panel, "Equipment")
    panel:AddControl("checkbox", {
        label = "Use SWCS base if available",
        command = "dzents_equipment_swcs"
    })
    panel:ControlHelp("Gives equipment crosshair and viewbob from SWCS if installed. Requires reload.")

    header(panel, "\nMedi-Shot")
    panel:AddControl("checkbox", {
        label = "Allow using at max health",
        command = "dzents_healthshot_use_at_full"
    })
    panel:AddControl("slider", {
        label = "Max ammo",
        command = "dzents_healthshot_maxammo",
        type = "int",
        min = 0,
        max = 10,
    })
    panel:ControlHelp("IMPORTANT: This only works if 'gmod_maxammo' is set to 0!")
    panel:AddControl("slider", {
        label = "Health given",
        command = "dzents_healthshot_health",
        type = "int",
        min = 0,
        max = 100,
    })
    panel:AddControl("slider", {
        label = "Health delay",
        command = "dzents_healthshot_healtime",
        type = "float",
        min = 0,
        max = 5,
    })
    panel:ControlHelp("Takes this amount of time to give all the health. Set to 0 for instant.")
    panel:AddControl("slider", {
        label = "Boost duration",
        command = "dzents_healthshot_duration",
        type = "float",
        min = 0,
        max = 10,
    })
    panel:AddControl("slider", {
        label = "Boost damage dealt",
        command = "dzents_healthshot_damage_dealt",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:AddControl("slider", {
        label = "Boost damage taken",
        command = "dzents_healthshot_damage_taken",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:AddControl("slider", {
        label = "Boost move speed",
        command = "dzents_healthshot_speed",
        type = "float",
        min = 0,
        max = 2,
    })

    header(panel, "\nBump Mine")
    panel:AddControl("checkbox", {
        label = "Crash chaining",
        command = "dzents_bumpmine_damage_crashchain"
    })
    panel:ControlHelp("Players and NPCs that crash into another entity will damage and launch that entity.")
    panel:AddControl("checkbox", {
        label = "Bump mine stacking",
        command = "dzents_bumpmine_stack"
    })
    panel:ControlHelp("Multiple mines in close proximity will create a bigger and more powerful explosion.")

    panel:AddControl("slider", {
        label = "Max ammo",
        command = "dzents_bumpmine_maxammo",
        type = "int",
        min = 0,
        max = 10,
    })
    panel:ControlHelp("IMPORTANT: This only works if 'gmod_maxammo' is set to 0!")

    panel:AddControl("slider", {
        label = "Launch force",
        command = "dzents_bumpmine_force",
        type = "int",
        min = 300,
        max = 3000,
    })
    panel:AddControl("slider", {
        label = "Bonus up force",
        command = "dzents_bumpmine_upadd",
        type = "int",
        min = 0,
        max = 1500,
    })
    panel:ControlHelp("Bonus force is angled upwards regardless of player's relative position to the mine. If crouching, it is not applied.")
    panel:AddControl("slider", {
        label = "Fall damage",
        command = "dzents_bumpmine_damage_fall",
        type = "float",
        min = 0,
        max = 3,
    })
    panel:ControlHelp("Players/NPCs will take velocity-based fall damage multiplied by this much.\nSet to 0 to not modify damage for players and apply no damage to NPCs.")
    panel:AddControl("slider", {
        label = "Wall crash damage",
        command = "dzents_bumpmine_damage_crash",
        type = "float",
        min = 0,
        max = 3,
    })
    panel:AddControl("slider", {
        label = "Self crash damage",
        command = "dzents_bumpmine_damage_selfcrash",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:ControlHelp("Self crash multiplier is applied on top of wall crash damage for the attacker of the mine.")
    panel:AddControl("slider", {
        label = "Arm delay",
        command = "dzents_bumpmine_armdelay",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:AddControl("slider", {
        label = "Detonation delay",
        command = "dzents_bumpmine_detdelay",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:AddControl("slider", {
        label = "Life time",
        command = "dzents_bumpmine_lifetime",
        type = "int",
        min = 0,
        max = 1200,
    })
    panel:ControlHelp("Clean up placed Bump Mines after this much time. 0 - never remove.")
end

local menus = {
    {
        text = "Client", func = menu_client
    },
    {
        text = "Server - Ammo", func = menu_ammo
    },
    {
        text = "Server - Cases", func = menu_cases
    },
    {
        text = "Server - Equipment", func = menu_equip
    },
    {
        text = "Server - Pickups", func = menu_pickups
    },
    {
        text = "Server - Armor", func = menu_armor
    },
}
hook.Add("PopulateToolMenu", "dz_ents_menu", function()
    for smenu, data in pairs(menus) do
        spawnmenu.AddToolMenuOption("Utilities", "Danger Zone", "DZ_Ents_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

surface.CreateFont("dz_ents_menu", {
    font = "Arial",
    size = 16,
    weight = 500,
    extended = true
})

surface.CreateFont("dz_ents_menu_bold", {
    font = "Arial",
    size = 16,
    weight = 1500,
    extended = true
})

local last_mouse_held_val

DZ_ENTS.Menu_Case_Category = DZ_ENTS.Menu_Case_Category or nil

local function makemenu_case_category()
    if not LocalPlayer():IsAdmin() then
        chat.AddText("[DZ_ENTS] Only admins can use this menu!")
        return
    end
    if DZ_ENTS.Menu_Case_Category then
        DZ_ENTS.Menu_Case_Category:Remove()
    end

    local list_name = "case_category"

    DZ_ENTS.Menu_Case_Category = vgui.Create("DFrame")
    DZ_ENTS.Menu_Case_Category:SetTitle("Danger Zone Case Category")
    DZ_ENTS.Menu_Case_Category:SetSize(300, 600)
    DZ_ENTS.Menu_Case_Category:Center()
    DZ_ENTS.Menu_Case_Category:MakePopup()

    local cb = vgui.Create("DCheckBoxLabel", DZ_ENTS.Menu_Case_Category)
    cb:Dock(TOP)
    cb:DockMargin(8, 4, 8, 4)
    cb:SetText("Enable Case Category Filter")
    cb:SetFont("dz_ents_menu_bold")
    cb:SetValue(DZ_ENTS.ConVars["case_userdef"]:GetBool())
    function cb.OnChange(self, val)
        net.Start("dz_ents_cvarrequest")
            net.WriteString("dzents_case_userdef")
            net.WriteString(val and "1" or "0") -- lol
        net.SendToServer()
    end

    local label1 = vgui.Create("DLabel", DZ_ENTS.Menu_Case_Category)
    label1:Dock(TOP)
    label1:DockMargin(4, 4, 4, 0)
    label1:SetText("Only selected categories will show up in cases.")
    label1:SetFont("dz_ents_menu")
    label1:SetContentAlignment(5)
    local label2 = vgui.Create("DLabel", DZ_ENTS.Menu_Case_Category)
    label2:Dock(TOP)
    label2:DockMargin(4, 0, 4, 4)
    label2:SetText("They will still be filtered by auto-detection.")
    label2:SetFont("dz_ents_menu")
    label2:SetContentAlignment(5)

    local apply = vgui.Create("DButton", DZ_ENTS.Menu_Case_Category)
    apply:Dock(BOTTOM)
    apply:DockMargin(16, 4, 16, 4)
    apply:SetText("Apply Changes")
    apply:SetFont("dz_ents_menu_bold")
    apply:SetContentAlignment(5)

    local c = DZ_ENTS.UserDefLists[list_name] and #DZ_ENTS.UserDefLists[list_name] or 0
    if c == 0 and apply:IsEnabled() then
        apply:SetEnabled(false)
        apply:SetText("Select at least one!")
    elseif c > 0 and not apply:IsEnabled() then
        apply:SetEnabled(true)
        apply:SetText("Apply Changes")
    end

    local scroll = vgui.Create("DScrollPanel", DZ_ENTS.Menu_Case_Category)
    scroll:Dock(FILL)
    scroll:DockMargin(8, 8, 8, 8)

    local layout = vgui.Create("DIconLayout", scroll)
    layout:Dock(FILL)
    layout:SetLayoutDir(TOP)
    layout:SetSpaceY(0)

    local categories = {}
    for k, ent in pairs(list.Get("Weapon")) do
        local wep = weapons.Get(ent.ClassName)
        if not wep or not wep.Spawnable or wep.AdminOnly then continue end

        -- Get the ent category as a string
        local cat = wep.Category or "Other"
        if not isstring(cat) or cat == "" then
            -- cat = tostring(cat)
            continue
        end

        if not categories[cat] then
            categories[cat] = true
        end
    end

    local category_boxes = {}
    for cat, v in SortedPairs(categories) do
        local panel = layout:Add("DPanel")
        panel:Dock(TOP)
        panel:SetTall(24)
        function panel.Paint(self, w, h)
            if categories[cat] then
                surface.SetDrawColor(255, 255, 255, 25)
                surface.DrawRect(0, 0, w, h)
            end
        end

        local cbox = vgui.Create("DCheckBox", panel)
        cbox:Dock(LEFT)
        cbox:DockMargin(4, 4, 4, 4)
        cbox:SetSize(15, 15)
        cbox:SetValue(v)
        function cbox.OnChange(self, val)
            categories[cat] = val
            if val then
                DZ_ENTS.AddToUserDefList(list_name, cat)
            else
                DZ_ENTS.RemoveFromUserDefList(list_name, cat)
            end
            local c2 = DZ_ENTS.UserDefLists[list_name] and #DZ_ENTS.UserDefLists[list_name] or 0
            if c2 == 0 and apply:IsEnabled() then
                apply:SetEnabled(false)
                apply:SetText("Select at least one!")
            elseif c2 > 0 and not apply:IsEnabled() then
                apply:SetEnabled(true)
                apply:SetText("Apply Changes")
            end
        end
        function cbox.DoClick(self)
            if last_mouse_held_val == nil then
                self:Toggle()
            end
        end

        function panel.Think(self)
            if input.IsMouseDown(MOUSE_LEFT) and (self:IsHovered() or cbox:IsHovered()) then
                if last_mouse_held_val == nil then
                    last_mouse_held_val = not cbox:GetChecked()
                end
                cbox:SetValue(last_mouse_held_val)
            elseif not input.IsMouseDown(MOUSE_LEFT) and last_mouse_held_val ~= nil then
                last_mouse_held_val = nil
            end
        end

        local label = vgui.Create("DLabel", panel)
        label:Dock(LEFT)
        label:SetText(cat)
        label:SetFont("dz_ents_menu")
        label:SizeToContents()

        category_boxes[cat] = cbox
    end

    function apply.DoClick(self, val)
        DZ_ENTS.WriteUserDefList(list_name)
        DZ_ENTS.Menu_Case_Category:Close()
        if not DZ_ENTS.ConVars["case_userdef"]:GetBool() then
            chat.AddText("[DZ_ENTS] Remember to enable the whitelist for it to take effect!")
        end
    end

    DZ_ENTS.ClearUserDefList(list_name)
    scroll:Hide()
    local labelwait = vgui.Create("DLabel", DZ_ENTS.Menu_Case_Category)
    labelwait:SetPos(150, 300)
    labelwait:DockMargin(4, 0, 4, 4)
    labelwait:SetText("Waiting for server...")
    labelwait:SetFont("dz_ents_menu_bold")
    labelwait:SizeToContents()
    labelwait:SetContentAlignment(5)
    labelwait:Center()

    function DZ_ENTS.Menu_Case_Category.Think(self)
        if not scroll:IsVisible() and DZ_ENTS.UserDefListsDict[list_name] ~= nil then
            for k, v in pairs(category_boxes) do
                v:SetValue(DZ_ENTS.UserDefListsDict[list_name][k])
            end
            scroll:SetVisible(true)
            labelwait:Hide()
        end
    end

    net.Start("dz_ents_listrequest")
        net.WriteString(list_name)
    net.SendToServer()
end
concommand.Add("cl_dzents_menu_case_category", makemenu_case_category)

DZ_ENTS.Menu_Case_WhiteList = DZ_ENTS.Menu_Case_WhiteList or nil

local icon16_help = Material("icon16/help.png")
local icon16_tick = Material("icon16/tick.png")
local icon16_cross = Material("icon16/cross.png")

local function makemenu_case_whitelist(list_name)
    if not LocalPlayer():IsAdmin() then return end
    if DZ_ENTS.Menu_Case_WhiteList then
        DZ_ENTS.Menu_Case_WhiteList:Remove()
    end

    local spawnmenu_border = GetConVar("spawnmenu_border")
    local MarginX = math.Clamp((ScrW() - 1024) * math.max(0.1, spawnmenu_border:GetFloat()), 25, 256)
    local MarginY = math.Clamp((ScrH() - 768) * math.max(0.1, spawnmenu_border:GetFloat()), 25, 256)
    if ScrW() < 1024 or ScrH() < 768 then
        MarginX = 0
        MarginY = 0
    end

    if list_name ~= nil and list_name ~= "" then
        net.Start("dz_ents_listrequest")
            net.WriteString(list_name)
        net.SendToServer()
    end

    local changed_lists = {}
    local dirty = false

    DZ_ENTS.Menu_Case_WhiteList = vgui.Create("DFrame")
    DZ_ENTS.Menu_Case_WhiteList:SetTitle("Danger Zone Case Custom Drops")
    DZ_ENTS.Menu_Case_WhiteList:Dock(FILL)
    DZ_ENTS.Menu_Case_WhiteList:DockPadding( 0, 0, 0, 0 )
    DZ_ENTS.Menu_Case_WhiteList:DockMargin( MarginX, MarginY, MarginX, MarginY )
    -- DZ_ENTS.Menu_Case_WhiteList:SetBackgroundColor(Color(255, 255, 255, 100))

    DZ_ENTS.Menu_Case_WhiteList:Center()
    DZ_ENTS.Menu_Case_WhiteList:MakePopup()

    local bottombar = vgui.Create("DPanel", DZ_ENTS.Menu_Case_WhiteList)
    bottombar:SetTall(128 + 16)
    bottombar:Dock(BOTTOM)
    bottombar:DockMargin(4, 4, 4, 4)
    bottombar.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 50)
        surface.DrawRect(0, 0, w, h)
    end

    local rightbox = vgui.Create("DPanel", bottombar)
    rightbox:SetWide(256)
    rightbox:Dock(RIGHT)
    rightbox.Paint = function() end

    local label1 = vgui.Create("DLabel", rightbox)
    label1:Dock(TOP)
    label1:DockMargin(8, 16, 8, 4)
    label1:SetFont("dz_ents_menu_bold")
    label1.Think = function(self)
        if list_name then
            self:SetText(scripted_ents.Get(list_name).PrintName .. (changed_lists[list_name] and " (Unsaved)" or ""))
            self:SetColor(changed_lists[list_name] and Color(255, 255, 100) or color_white)
        end
    end

    local label2 = vgui.Create("DLabel", rightbox)
    label2:Dock(TOP)
    label2:DockMargin(8, 0, 8, 4)
    label2:SetFont("dz_ents_menu_bold")
    label2.Think = function(self)
        if list_name then
            local c = DZ_ENTS.CountUserDefList(list_name)
            self:SetText("Selected drops: " .. c)
            self:SetColor(c > 0 and color_white or Color(255, 100, 100))
        end
    end

    local apply = vgui.Create("DButton", rightbox)
    apply:SetWide(256)
    apply:Dock(FILL)
    apply:DockMargin(16, 8, 16, 16)
    apply:SetText("Save All Changes")
    apply:SetFont("dz_ents_menu_bold")
    apply:SetContentAlignment(5)
    apply.Think = function(self)
        if dirty and not self:IsEnabled() then
            self:SetEnabled(true)
        elseif not dirty and self:IsEnabled() then
            self:SetEnabled(false)
        end
    end

    local scroll = vgui.Create("DHorizontalScroller", bottombar) -- DScrollPanel
    scroll:SetTall(128)
    scroll:Dock(FILL)
    scroll:DockMargin(4, 8, 4, 8)
    scroll.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    -- local cases = vgui.Create("DIconLayout", scroll)
    -- cases:SetTall(128)
    -- cases:Dock(TOP)
    -- cases:DockMargin(0, 0, 0, 0)
    -- cases:SetLayoutDir(LEFT)

    local propscroll = vgui.Create("DScrollPanel", DZ_ENTS.Menu_Case_WhiteList)
    propscroll:Dock(FILL)
    propscroll:DockMargin(16, 24, 16, 16)

    local proppanel = vgui.Create("DTileLayout", propscroll:GetCanvas())
    proppanel:Dock(FILL)

    local Categorised = {}

    for k, weapon in pairs(list.Get("Weapon")) do
        if not weapon.Spawnable then continue end
        local cat = weapon.Category or "Other"

        if not isstring(cat) then
            cat = tostring(cat)
        end

        local weptbl = weapons.Get(k)
        if istable(weptbl) then
            if weptbl.SubCategory then
                cat = cat .. " - " .. weptbl.SubCategory
            elseif weptbl.SubCatType then
                cat = cat .. " - " .. string.sub(weptbl.SubCatType, 2)
            end
        end

        Categorised[cat] = Categorised[cat] or {}
        table.insert(Categorised[cat], weapon)
    end
    -- for k, entity in pairs(list.Get("SpawnableEntities")) do
    --     local cat = entity.Category or "Other"

    --     if not isstring(cat) then
    --         cat = tostring(cat)
    --     end

    --     Categorised[cat] = Categorised[cat] or {}
    --     table.insert(Categorised[cat], entity)
    -- end

    for CategoryName, v in SortedPairs(Categorised) do
        local Header = vgui.Create("ContentHeader", proppanel)
        Header:SetText(CategoryName)
        proppanel:Add(Header)

        for k, WeaponTable in SortedPairsByMemberValue(v, "PrintName") do
            if WeaponTable.AdminOnly and not LocalPlayer():IsAdmin() then continue end
            local icon = vgui.Create("ContentIcon", proppanel)
            icon:SetMaterial(WeaponTable.IconOverride or "entities/" .. WeaponTable.ClassName .. ".png")
            icon:SetName(WeaponTable.PrintName or "#" .. WeaponTable.ClassName)
            icon:SetAdminOnly(WeaponTable.AdminOnly or false)

            function icon.DoClick(self)
                if last_mouse_held_val == nil then
                    if not DZ_ENTS.InUserDefList(list_name, WeaponTable.ClassName) then
                        DZ_ENTS.AddToUserDefList(list_name, WeaponTable.ClassName)
                    else
                        DZ_ENTS.RemoveFromUserDefList(list_name, WeaponTable.ClassName)
                    end
                    changed_lists[list_name] = true
                    dirty = true
                end
            end

            function icon.Think(self)
                if input.IsMouseDown(MOUSE_LEFT) and self:IsHovered() then
                    if last_mouse_held_val == nil then
                        last_mouse_held_val = DZ_ENTS.InUserDefList(list_name, WeaponTable.ClassName)
                        changed_lists[list_name] = true
                        dirty = true
                    end
                    if not last_mouse_held_val then
                        DZ_ENTS.AddToUserDefList(list_name, WeaponTable.ClassName)
                    else
                        DZ_ENTS.RemoveFromUserDefList(list_name, WeaponTable.ClassName)
                    end
                elseif not input.IsMouseDown(MOUSE_LEFT) and last_mouse_held_val ~= nil then
                    last_mouse_held_val = nil
                end
            end

            local oldp = icon.Paint
            icon.Paint = function(self, w, h)
                if DZ_ENTS.InUserDefList(list_name, WeaponTable.ClassName) then
                    if not changed_lists[list_name] then
                        draw.RoundedBox(4, 0, 0, w, h, Color(0, 200, 0, 100))
                    else
                        draw.RoundedBox(4, 0, 0, w, h, Color(255, 175, 0, 100))
                    end
                end
                oldp(self, w, h)
            end

            function icon.OpenMenu(self)
                local newmenu = DermaMenu()
                newmenu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText(self:GetSpawnName()) end):SetIcon( "icon16/page_copy.png" )
                newmenu:AddOption( "Add all from \"" .. CategoryName .. "\"", function()
                    for _, tbl in pairs(v) do
                        DZ_ENTS.AddToUserDefList(list_name, tbl.ClassName)
                    end
                    changed_lists[list_name] = true
                    dirty = true
                end):SetIcon("icon16/add.png")
                newmenu:AddOption( "Remove all from \"" .. CategoryName .. "\"", function()
                    for _, tbl in pairs(v) do
                        DZ_ENTS.RemoveFromUserDefList(list_name, tbl.ClassName)
                    end
                    changed_lists[list_name] = true
                    dirty = true
                end):SetIcon("icon16/delete.png")

                newmenu:Open()
            end

            proppanel:Add(icon)

        end
    end

    for k, v in SortedPairs(DZ_ENTS.CrateContents) do

        DZ_ENTS.ClearUserDefList(k) -- don't remember unsaved local changes

        local case = scripted_ents.Get(k)
        local icon = vgui.Create("ContentIcon", scroll)
        icon:SetMaterial(case.IconOverride or "entities/" .. case.ClassName .. ".png")
        icon:SetName(case.PrintName or "#" .. case.ClassName)
        icon:SetAdminOnly(case.AdminOnly or false)

        local oldp = icon.Paint
        icon.Paint = function(self, w, h)
            if list_name == k then
                draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200, 200))
            end
            if changed_lists[k] then
                draw.RoundedBox(4, 0, 0, w, h, Color(255, 200, 0, 75))
            end
            oldp(self, w, h)

            surface.SetDrawColor(255, 255, 255)
            if DZ_ENTS.UserDefLists[k] == nil or DZ_ENTS.UserDefLists[k] == {} then
                surface.SetMaterial(icon16_help)
            elseif DZ_ENTS.CountUserDefList(k) > 0 then
                surface.SetMaterial(icon16_tick)
            else
                surface.SetMaterial(icon16_cross)
            end
            surface.DrawTexturedRect(w - self.Border - 24, self.Border + 8, 16, 16)
        end
        icon.DoClick = function()
            list_name = k
            if DZ_ENTS.UserDefLists[list_name] == nil or DZ_ENTS.UserDefLists[list_name] == {} then
                net.Start("dz_ents_listrequest")
                    net.WriteString(list_name)
                net.SendToServer()
            end
        end
        function icon.OpenMenu(self)
            local newmenu = DermaMenu()
            newmenu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText(self:GetSpawnName()) end):SetIcon( "icon16/page_copy.png" )
            newmenu:AddOption("Add all weapons to case", function()
                for _, tbl in pairs(list.Get("Weapon")) do
                    DZ_ENTS.AddToUserDefList(list_name, tbl.ClassName)
                end
                changed_lists[list_name] = true
                dirty = true
            end):SetIcon("icon16/add.png")
            newmenu:AddOption("Remove all weapons from case", function()
                for _, tbl in pairs(list.Get("Weapon")) do
                    DZ_ENTS.RemoveFromUserDefList(list_name, tbl.ClassName)
                end
                changed_lists[list_name] = true
                dirty = true
            end):SetIcon("icon16/delete.png")

            newmenu:Open()
        end

        if list_name == "" or list_name == nil then
            list_name = k
            net.Start("dz_ents_listrequest")
                net.WriteString(list_name)
            net.SendToServer()
        end

        -- cases:Add(icon)
        scroll:AddPanel(icon)
    end

    function apply.DoClick(self)
        for k, _ in pairs(changed_lists) do
            DZ_ENTS.WriteUserDefList(k)
        end
        changed_lists = {}
        dirty = false
    end

end

concommand.Add("cl_dzents_menu_case_whitelist", function(ply, cmd, args, argstr)
    if not LocalPlayer():IsAdmin() then return end
    makemenu_case_whitelist(args[1] or "")
end)