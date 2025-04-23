local _, LRP = ...

local windowWidth, windowHeight = 220, 100
local window, confirmButton, cancelButton, nameEditBox, colorPicker
local color = CreateColor(1, 1, 1)

function LRP:ShowAddProfileWindow(parent)
    if window:IsShown() then
        window:Hide()
    end

    window:Show()
    window:SetParent(parent)
    window:SetPoint("CENTER", parent, "CENTER")
    window:SetFrameLevel(parent:GetFrameLevel() + 10)

    parent:SetAlpha(0.5)

    confirmButton:SetScript(
        "OnClick",
        function()
            -- Hacky way to check if profile name is valid: if it's not, the edit box has a tooltip indicating why
            if nameEditBox.tooltipText and nameEditBox.tooltipText ~= "" then return end

            local profileName = nameEditBox:GetText()
            local hexColor = color:GenerateHexColor()
            
            LRP:AddReminderProfile(WrapTextInColorCode(profileName, hexColor))

            window:Hide()
        end
    )

    window:SetScript(
        "OnHide",
        function()
            parent:SetAlpha(1)
        end
    )

    nameEditBox:SetText("")
    colorPicker:SetColor(1, 1, 1, 1)
end

function LRP:InitializeAddProfileWindow()
    window = LRP:CreateWindow(nil)
    LRP.addProfileWindow = window

    window:SetSize(windowWidth, windowHeight)
    window:SetIgnoreParentAlpha(true)
    window:SetFrameStrata("DIALOG")
    window:Hide()

    confirmButton = LRP:CreateButton(window, "|cff00ff00Confirm|r", function() end)
    confirmButton:SetPoint("BOTTOMRIGHT", window, "BOTTOM", -4, 10)

    cancelButton = LRP:CreateButton(window, "|cffff0000Cancel|r", function() window:Hide() end)
    cancelButton:SetPoint("BOTTOMLEFT", window, "BOTTOM", 4, 10)

    nameEditBox = LRP:CreateEditBox(
        window,
        "Profile name",
        function(text)
            if text == "" then
                nameEditBox:ShowHighlight(1, 0, 0)

                LRP:AddTooltip(nameEditBox, "|cffff0000Profile name cannot be empty.|r")
                LRP:RefreshTooltip()

                return
            end

            local timelineInfo = LRP:GetCurrentTimelineInfo()
            local encounterID = timelineInfo.encounterID
            local difficulty = timelineInfo.difficulty
            local profileNames = LiquidRemindersSaved.reminders[encounterID][difficulty]

            for profileName in pairs(profileNames) do
                local profileNameNoColor = profileName:match("^|c%x%x%x%x%x%x%x%x(.+)|r$")

                if text == profileName or text == profileNameNoColor then
                    nameEditBox:ShowHighlight(1, 0, 0)

                    LRP:AddTooltip(nameEditBox, "|cffff0000A profile with that name already exists.|r")
                    LRP:RefreshTooltip()

                    return
                end
            end

            nameEditBox:HideHighlight()

            LRP:AddTooltip(nameEditBox) -- Input is valid, don't show a tooltip
            LRP:RefreshTooltip()
        end
    )
    nameEditBox:SetPoint("TOPLEFT", window, "TOPLEFT", 8, -20)
    nameEditBox:SetSize(140, 24)
    nameEditBox:SetMaxLetters(20)

    colorPicker = LRP:CreateColorPicker(
        window,
        "Color",
        function(r, g, b)
            color:SetRGB(r, g, b)
        end
    )
    colorPicker:SetPoint("LEFT", nameEditBox, "RIGHT", 8, 0)
    colorPicker:SetSize(20, 20)
end

-- When the user clicks outside the confirm window, hide it
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
eventFrame:SetScript(
    "OnEvent",
    function()
        if window:IsShown() then
            local frame = GetMouseFoci()[1]
            
            for _ = 1, 5 do
                if not frame then break end
                if frame:IsForbidden() then break end
                if frame == window or frame == ColorPickerFrame then return end
                
                frame = frame.GetParent and frame:GetParent()
            end

            window:Hide()
        end
    end
)