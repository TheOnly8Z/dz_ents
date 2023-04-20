local fade_lr = Material("dz_ents/fade-both-right-left.png", "smooth mips")

local armor = Material("dz_ents/select/armor.png", "smooth mips")
local shield = Material("dz_ents/select/shield.png", "smooth mips")
local helmet = Material("dz_ents/select/helmet.png", "smooth mips")
local exojump_hud = Material("dz_ents/select/exojump_hud.png", "smooth mips")
local parachute_hud = Material("dz_ents/select/parachute_hud.png", "smooth mips")

local function fadebox(fademat, x, y, w, h, fadelength)

    surface.SetDrawColor(0, 0, 0, 150)
    surface.SetMaterial(fademat)

    if fadelength * 2 > w then
        x = x - (fadelength * 2 - w) / 2
        w = fadelength * 2
    end

    render.SetScissorRect(x, y, x + fadelength, y + h, true)
    surface.DrawTexturedRect(x, y, fadelength * 2, h)
    render.SetScissorRect(x + w, y, x + w - fadelength, y + h, true)
    surface.DrawTexturedRect(x + w - fadelength * 2, y, fadelength * 2, h)
    render.SetScissorRect(0, 0, 0, 0, false)
    surface.DrawRect(x + fadelength, y, w - fadelength * 2, h)
end

hook.Add("HUDPaint", "dz_ents_hud", function()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() or not GetConVar("cl_dzents_hud_enabled"):GetBool() or not GetConVar("cl_drawhud"):GetBool() then return end

    local x = ScreenScale(GetConVar("cl_dzents_hud_x"):GetFloat())
    local y = ScreenScale(GetConVar("cl_dzents_hud_y"):GetFloat())
    local scale = GetConVar("cl_dzents_hud_scale"):GetFloat()

    if x < 0 then x = ScrW() + x end
    if y < 0 then y = ScrH() + y end


    local armor_type = LocalPlayer():DZ_ENTS_GetArmor()
    local has_helmet = LocalPlayer():DZ_ENTS_HasHelmet()

    local icons = 0
    if armor_type ~= DZ_ENTS_ARMOR_NONE or has_helmet then
        icons = icons + 1
    end
    if LocalPlayer():DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) then
        icons = icons + 1
    end
    if LocalPlayer():DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then
        icons = icons + 1
    end

    if icons == 0 then return end

    local sidegap = ScreenScale(2) * scale
    local icongap = ScreenScale(14) * scale
    local w = sidegap * 2 + icongap * icons
    local h = ScreenScale(16) * scale

    local s1 = ScreenScale(8) * scale
    local ss = ScreenScale(12) * scale

    local padding = ScreenScale(14) * scale
    local x_add = sidegap * scale

    surface.SetDrawColor(0, 0, 0, 150)
    fadebox(fade_lr, x, y, w, h, 32)

    surface.SetDrawColor(255, 255, 255, 255)

    -- for alignment purposes only
    -- surface.DrawLine(x, y, x, y + h)
    -- surface.DrawLine(x + w, y, x + w, y + h)
    -- surface.DrawLine(x + padding * 0.5 + x_add, y, x + padding * 0.5 + x_add, y + h)
    -- surface.DrawLine(x + padding * 1.5  + x_add, y, x + padding * 1.5 + x_add, y + h)
    -- surface.DrawLine(x + padding * 2.5  + x_add, y, x + padding * 2.5 + x_add, y + h)

    if armor_type ~= DZ_ENTS_ARMOR_NONE or has_helmet then
        if armor_type == DZ_ENTS_ARMOR_HEAVY_CT or armor_type == DZ_ENTS_ARMOR_HEAVY_T then
            surface.SetMaterial(shield)
            surface.DrawTexturedRect(x + x_add + padding / 2 - s1 / 2 - (ScreenScale(9) - s1) / 2, y + h / 2 - ScreenScale(9) / 2, ScreenScale(9), ScreenScale(9))
            surface.SetMaterial(armor)
        elseif armor_type == DZ_ENTS_ARMOR_KEVLAR and has_helmet then
            surface.SetMaterial(armor)
        elseif armor_type == DZ_ENTS_ARMOR_KEVLAR and not has_helmet then
            surface.SetMaterial(shield)
        elseif has_helmet then
            surface.SetMaterial(helmet)
        end
        surface.DrawTexturedRect(x + x_add + padding / 2 - s1 / 2, y + h / 2 - s1 / 2, s1, s1)
        x_add = x_add + padding
    end

    if LocalPlayer():DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_PARACHUTE) then
        surface.SetMaterial(parachute_hud)
        surface.DrawTexturedRect(x + x_add + padding / 2 - ss / 2, y + h / 2 - ss / 2, ss, ss)
        x_add = x_add + padding
    end

    if LocalPlayer():DZ_ENTS_HasEquipment(DZ_ENTS_EQUIP_EXOJUMP) then
        surface.SetMaterial(exojump_hud)
        surface.DrawTexturedRect(x + x_add + padding / 2 - ss / 2, y + h / 2 - ss / 2, ss, ss)
        x_add = x_add + padding
    end

end)