hook.Add("PopulateEntities", "dz_ents", function(pnlContent, tree, anode)

    if not GetConVar("cl_dzents_subcat"):GetBool() then return end

    timer.Simple(0, function()
        -- Loop through the weapons and add them to the menu
        local SpawnableEntities = list.Get("SpawnableEntities")
        local Categorised = {}
        local DZEntCats = {}

        -- Build into categories + subcategories
        for k, ent in pairs(SpawnableEntities) do
            local EntTable = scripted_ents.Get(ent.ClassName)
            if not EntTable then
                EntTable = weapons.Get(ent.ClassName)
            end
            if not EntTable then continue end

            -- Get the ent category as a string
            local Category = ent.Category or "Other2"
            if not isstring(Category) then
                Category = tostring(Category)
            end

            -- Get the ent subcategory as a string
            local SubCategory = "Other"
            if EntTable and EntTable.SubCategory then
                SubCategory = EntTable.SubCategory
                if (not isstring(SubCategory)) then
                    SubCategory = tostring(SubCategory)
                end
            end

            ent.SpawnName = k
            ent.SortOrder = EntTable.SortOrder or ent.SpawnName

            -- Insert it into our categorised table
            Categorised[Category] = Categorised[Category] or {}
            Categorised[Category][SubCategory] = Categorised[Category][SubCategory] or {}
            table.insert(Categorised[Category][SubCategory], ent)
            DZEntCats[Category] = true
        end

        -- Iterate through each category in the weapons table
        for _, node in pairs(tree:Root():GetChildNodes()) do

            if not DZEntCats[node:GetText()] then continue end

            -- Get the subcategories registered in this category
            local catSubcats = Categorised[node:GetText()]

            if not catSubcats then continue end

            -- Overwrite the icon populate function with a custom one
            node.DoPopulate = function(self)

                -- If we've already populated it - forget it.
                if (self.PropPanel) then return end

                -- Create the container panel
                self.PropPanel = vgui.Create("ContentContainer", pnlContent)
                self.PropPanel:SetVisible(false)
                self.PropPanel:SetTriggerSpawnlistChange(false)

                -- Iterate through the subcategories
                for subcatName, subcatWeps in SortedPairs(catSubcats) do

                    -- Create the subcategory header, if more than one exists for this category
                    if (table.Count(catSubcats) > 1) then
                        local label = vgui.Create("ContentHeader", container)
                        label:SetText(subcatName)
                        self.PropPanel:Add(label)
                    end

                    -- Create the clickable icon
                    for _, ent in SortedPairsByMemberValue(subcatWeps, "SortOrder") do
                        spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", self.PropPanel, {
                            nicename  = ent.PrintName or ent.ClassName,
                            spawnname = ent.SpawnName,
                            material  = ent.IconOverride or "entities/" .. ent.SpawnName .. ".png",
                            admin     = ent.AdminOnly
                        })
                    end
                end
            end

            -- If we click on the node populate it and switch to it.
            node.DoClick = function(self)
                self:DoPopulate()
                pnlContent:SwitchPanel(self.PropPanel)
            end

            -- InternalDoClick is called on the first child node before our function override.
            -- Remove its results and regenerate our cool tab
            if tree:Root():GetChildNode(0) == node then
                node.PropPanel:Remove()
                node.PropPanel = nil
                node:InternalDoClick()
            end
        end

        -- Select the first node
        local FirstNode = tree:Root():GetChildNode(0)
        if (IsValid(FirstNode)) then
            FirstNode:InternalDoClick()
        end
    end)
end)

list.Set( "ContentCategoryIcons", "Danger Zone", "dz_ents/icon_16.png" )