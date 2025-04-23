local _, LRP = ...

local mrtExportString
local window, mrtExportEditBox

local eventToShorthand = {
    SPELL_CAST_START = "SCS",
    SPELL_CAST_SUCCESS = "SCC",
    SPELL_AURA_APPLIED = "SAA",
    SPELL_AURA_REMOVED = "SAR",
    UNIT_DIED = "UD",
    UNIT_SPELLCAST_START = "USS",
    UNIT_SPELLCAST_SUCCEEDED = "USC",
    CHAT_MSG_MONSTER_YELL = "CMMY"
}

local function ExportTrigger(trigger)
    local minutes = math.floor(trigger.time / 60)
    local seconds = trigger.time % 60
    local timeString = string.format("time:%02d:%04.1f", minutes, seconds)

    if trigger.relativeTo then
        local eventShorthand = eventToShorthand[trigger.relativeTo.event]
        local value = trigger.relativeTo.value or ""
        local count = trigger.relativeTo.count or 1

        return string.format("{%s,%s:%s:%s}", timeString, eventShorthand, tostring(value), count)
    else
        return string.format("{%s}", timeString)
    end
end

local function ExportLoad(load)
    local loadType = load.type

    if loadType == "ALL" then
        return "{everyone}"
    elseif loadType == "NAME" then
        return load.name
    elseif loadType == "POSITION" then
        return string.format("type:%s", load.position)
    elseif loadType == "CLASS_SPEC" then
        if load.class == load.spec then -- Class reminder
            return string.format("class:%s", load.class)
        else -- Spec reminder
            return string.format("spec:%s:%s", load.class, load.spec)
        end
    elseif loadType == "GROUP" then
        return string.format("group:%d", load.group)
    elseif loadType == "ROLE" then
        return string.format("role:%s", load.role)
    end
end

local function ExportDisplay(display)
    if display.type == "SPELL" then
        return string.format("{spell:%d}", display.spellID or 0)
    else
        return string.format("{text}%s{/text}", display.text or "")
    end
end

local function ExportGlow(glow)
    if not glow.enabled then return "" end
    if not next(glow.names) then return "" end

    local glowNames = "@"

    for _, glowName in ipairs(glow.names) do
        glowNames = string.format(glowNames == "@" and "%s%s" or "%s,%s", glowNames, glowName)
    end

    return glowNames
end

function LRP:CloseSingleExport()
    window:Hide()
end

function LRP:OpenSingleExport(reminderData)
    if window:IsShown() then return end

    window:Show()

    LRP:ExportSingleReminder(reminderData)
end

function LRP:ToggleSingleExport(reminderData)
    if window:IsShown() then
        LRP:CloseSingleExport()
    else
        LRP:OpenSingleExport(reminderData)
    end
end

function LRP:ExportSingleReminder(reminderData)
    -- This is called every time reminder data in config changes
    -- Only update the export strings while the window is open
    -- Doing it every time reminder data changes while the window is closed would be a lot of extra work
    -- When the window is opened we force an export anyway
    if not window then return end
    if not window:IsShown() then return end

    local triggerText = ExportTrigger(reminderData.trigger)
    local loadText = ExportLoad(reminderData.load)
    local displayText = ExportDisplay(reminderData.display)
    local glowText = ExportGlow(reminderData.glow)

    mrtExportString = string.format("%s - %s %s%s", triggerText, loadText, displayText, glowText)

    mrtExportEditBox:SetText(mrtExportString)
    mrtExportEditBox:ClearHighlightText()
    mrtExportEditBox:SetCursorPosition(0)
end

function LRP:InitializeSingleExport()
    window = LRP:CreateWindow()

    window:SetParent(LRP.reminderConfig)
    window:SetPoint("TOPLEFT", LRP.reminderConfig, "BOTTOMLEFT", 0, -4)
    window:SetPoint("TOPRIGHT", LRP.reminderConfig, "BOTTOMRIGHT", 0, -4)
    window:SetHeight(52)
    window:Hide()

    -- This window is an "extension" of the reminder config, so color it entirely dark blue
    window.upperTexture:Hide()
    window.lowerTexture:SetAllPoints()

    -- MRT export
    mrtExportEditBox = LRP:CreateEditBox(window, "MRT", function() end)

    mrtExportEditBox:SetPoint("TOPLEFT", window, "TOPLEFT", 8, -20)
    mrtExportEditBox:SetPoint("TOPRIGHT", window, "TOPRIGHT", -8, -20)
    mrtExportEditBox:SetHeight(24)

    mrtExportEditBox:SetScript(
        "OnCursorChanged",
        function()
            if mrtExportEditBox:HasFocus() then
                mrtExportEditBox:HighlightText()
            end
        end
    )

    mrtExportEditBox:SetScript(
        "OnTextChanged",
        function(_, userInput)
            if not userInput then return end

            mrtExportEditBox:SetText(mrtExportString or "")
            mrtExportEditBox:HighlightText()
            mrtExportEditBox:SetFocus()
        end
    )    
end
