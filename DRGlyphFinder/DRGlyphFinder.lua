SLASH_DRGF1 = '/drgf'

local addonName, addon = ...
local DRGF = addon
local L = addon.L

-- Saved Variables
STOPPED = true

-- Data
DRGF_DATA = {
        --X coord, Y coord, achievement ID, map ID ~~ /dump C_Map. GetBestMapForUnit("player")
    { -- Waking Shores
	    {74.34, 57.54, 16668, 2022}, -- Skytop Observatory Rostrum
	    {75.27, 57.01, 15985, 2022}, -- Skytop Observatory Tower
	    {74.87, 37.33, 16051, 2022}, -- Dragonheart Outpost
	    {73.08, 20.51, 15986, 2022}, -- Wingrest Embassy
	    {57.70, 54.91, 15991, 2022}, -- Crumbling Life Archway
	    {54.46, 74.21, 15988, 2022}, -- Ruby Life Pools Peaks
        {58.09, 78.58, 16669, 2022}, -- Flashfrost Enclave
        {48.80, 86.72, 16670, 2022}, -- Rubyscale Outpost
        {40.95, 71.93, 15987, 2022}, -- Obsidian Bulwark
        {46.40, 52.14, 15989, 2022}, -- The Overflowing Spring
        {21.76, 51.40, 16053, 2022}, -- Obsidian Throne
        {52.60, 17.21, 15990, 2022}, -- Life-binder Observatory
        {69.27, 46.23, 16052, 2022} -- Scalecracker Peak
    },
    { -- Ohn'ahran Plains
	    {78.42, 21.17, 16671, 2023}, -- Mirewood Fen
	    {86.54, 39.32, 16062, 2023}, -- Rusa'thar Reach
	    {57.79, 30.81, 16054, 2023}, -- Ohn'ara's Roost
	    {30.39, 36.07, 16055, 2023}, -- Nokhudon Hold
	    {30.15, 61.56, 16056, 2023}, -- Emerald Gardens
	    {29.54, 75.43, 16057, 2023}, -- The Eternal Kurgans
        {44.73, 64.57, 16058, 2023}, -- Szar Skeleth
        {47.32, 72.16, 16059, 2023}, -- Mirror of the Sky
        {57.13, 80.10, 16060, 2023}, -- Ohn'iri Springs
        {61.37, 64.23, 16063, 2023}, -- Windsong Rise
        {70.02, 86.80, 16672, 2023}, -- Forkriver Crossing
        {84.07, 77.27, 16061, 2023} -- Dragonsprings Summit
    },
    { -- Azure Span
	    {56.81, 16.03, 16673, 2024}, -- The Fallen Course
	    {67.64, 29.11, 16072, 2024}, -- Kalthraz Fortress
	    {72.59, 39.86, 16073, 2024}, -- Vakthros Range
	    {70.58, 46.26, 16067, 2024}, -- Lost Ruins
	    {68.65, 60.35, 16066, 2024}, -- Ruins of Karnthar
	    {60.62, 69.99, 16070, 2024}, -- Imbu
        {52.97, 49.04, 16071, 2024}, -- Zelthrak Outpost
        {39.20, 63.01, 16065, 2024}, -- Azure Archives
        {26.73, 31.68, 16069, 2024}, -- Creektooth Den
        {10.39, 35.82, 16068, 2024}, -- Brackenhide Hollow
        {45.77, 25.69, 16064, 2024} -- Cobalt Assembly
    },
    { -- Thaldraszus
	    {35.56, 85.56, 16100, 2025}, -- South Hold Gate
	    {46.09, 73.88, 16099, 2025}, -- Stormshroud Peak
	    {52.65, 67.43, 16666, 2025}, -- Gelikyr Overlook
	    {55.76, 72.33, 16667, 2025}, -- Passage of Time
	    {61.57, 56.61, 16103, 2025}, -- Tyrhold
        {49.85, 40.23, 16102, 2025}, -- Algeth'era
        {62.41, 40.46, 16104, 2025}, -- Algeth'ar Academy
        {67.09, 11.76, 16105, 2025}, -- Veiled Ossuary
        {72.40, 51.71, 16106, 2025}, -- Vault of the Incarnates
        {72.96, 69.14, 16107, 2025}, -- Thaldraszus Apex
        {66.01, 82.34, 16098, 2025} -- Temporal Conflux
    },
    { -- Valdrakken
	    {59.26, 38.02, 16101, 2112} -- Valdrakken
    },
    { -- Forgotten Reach
	    {37.69, 30.69, 17405, 2151}, -- Caldera of the Menders
	    {79.55, 32.64, 17401, 2151}, -- Dragonskull Island
	    {62.54, 32.38, 17400, 2151}, -- Froststone Peak
	    {77.29, 55.10, 17402, 2151}, -- Stormsunder Mountain
	    {59.05, 65.08, 17404, 2151}, -- Talonlord's Perch
	    {20.56, 91.40, 17399, 2151}, -- Talon's Watch
	    {48.51, 68.97, 17403, 2151}, -- The Frosted Spine
	    {18.38, 13.20, 17398, 2151} -- Winglord's Perch
    },
    { -- Zaralek Cavern
	    {41.68, 80.30, 17510, 2133}, -- Glimmerogg
	    {54.72, 54.71, 17512, 2133}, -- Loamm
	    {55.38, 27.85, 17514, 2133}, -- Slitherdrake Roost
	    {47.45, 37.05, 17516, 2133}, -- Acidbite Ravine
	    {62.76, 70.32, 17511, 2133}, -- Nal ks'kol
	    {30.44, 45.35, 17513, 2133}, -- Naqali Caldera
	    {71.73, 48.25, 17515, 2133}, -- The Throughway
	    {48.02, 4.25, 17517, 2133} -- Aberrus Approach
    },
    { -- Emerald Dream
	    {60.36, 30.14, 19296, 2200}, -- Eye of Ysera
	    {33.80, 45.52, 19298, 2200}, -- Smoldering Copse
	    {45.48, 45.87, 19300, 2200}, -- Dreamsurge Basin
	    {31.79, 80.60, 19302, 2200}, -- Whorlwing Basin
	    {21.21, 26.71, 19297, 2200}, -- Furnace Coil
	    {29.88, 21.26, 19299, 2200}, -- Cinder Summit
	    {49.95, 64.41, 19301, 2200}, -- Amirdrassil
	    {61.53, 75.67, 19303, 2200} -- Wakeful Vista
    }
}

if (select(4, GetBuildInfo()) > 100200) then
    print('|cff31d6bb' .. L["OUT_OF_DATE"]) -- Dragon Riding Glyph Finder addon out of date, please check for update.
end

function DRGF:AddWayPoint(m, x, y, zone, label)
    if (TomTom == nil) then
        return
    end
    if m and x and y then
        TomTom:AddWaypoint(m, x/100, y/100, {
            title = label,
            from = "Dragonriding Glyph Finder"
        })
    end
end

function DRGF:GetAchievement(id)
    local IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, isGuildAch = GetAchievementInfo(id)
    return strsub(DRGF:Split(Name, ":")[2], 2), Completed
end

function DRGF:GetZoneNameById(id)
    local mapname = C_Map.GetAreaInfo(id)
    return mapname
end

function DRGF:CheckList()
    for z=1,#DRGF_DATA,1 do
        local zone = '|cff31d6bb' .. DRGF:GetZoneName(z) .. ':'
        print (zone)
        local remaining = ''
        for i=1,#(DRGF_DATA[z]),1 do
            local name, completed = DRGF:GetAchievement(DRGF_DATA[z][i][3])
            if (not completed) then
                if (remaining == '') then
                    remaining = remaining .. name
                else
                    remaining = remaining .. ', ' .. name
                end
            end
        end
        if (remaining == '') then
            remaining = L["COMPLETE"]
        end
        print (remaining)
    end
end

function DRGF:Split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function DRGF:GetZoneName(zone)
    if (zone == 1) then
        return DRGF:GetZoneNameById(13644)
    elseif (zone == 2) then
        return DRGF:GetZoneNameById(13645)
    elseif (zone == 3) then
        return DRGF:GetZoneNameById(13646)
    elseif (zone == 4) then
        return DRGF:GetZoneNameById(13647)
    elseif (zone == 5) then
        return DRGF:GetZoneNameById(13862)
    elseif (zone == 6) then
        return DRGF:GetZoneNameById(13769)
    elseif (zone == 7) then
        return DRGF:GetZoneNameById(14022)
    elseif (zone == 8) then
        return DRGF:GetZoneNameById(14529)
    end
end

local function MyAddonCommands(msg, editbox)
    if (TomTom == nil) then
        print('|cff31d6bb' .. L["REQUIRES_TOMTOM"]) -- Dragon Riding Glyph Finder requires the TomTom addon.
        return
    end

    if msg == 'check' then
        DRGF:CheckList()
    elseif msg == 'auto' then
        STOPPED = not STOPPED
        if (STOPPED == true) then
            print('|cff31d6bb' .. L["AUTO_OFF"]) -- Auto-tracking to nearest waypoint off.
        else
            print('|cff31d6bb' .. L["AUTO_ON"]) -- Auto-tracking to nearest waypoint on.
        end
    elseif msg == 'set' then
        local zone = GetZoneText()
        local m,x,y = TomTom:GetCurrentPlayerPosition()
        local count = 0
        for z=1,#DRGF_DATA,1 do
            for i=1,#(DRGF_DATA[z]),1 do
                local name, completed = DRGF:GetAchievement(DRGF_DATA[z][i][3])
                if (completed == false) then -- Haven't hit this one yet.
                    DRGF:AddWayPoint(DRGF_DATA[z][i][4], DRGF_DATA[z][i][1], DRGF_DATA[z][i][2], zone, name)
                end
		    end
        end
    else
        print('|cff31d6bb/drgf set: ' .. L["COMMAND_SET"]) -- Sets waypoints to all glyphs in current zone, activates tracking.
        print('|cff31d6bb/drgf check: ' .. L["COMMAND_CHECK"]) -- List zones and indices of uncollected glyphs.
        print('|cff31d6bb/drgf auto: ' .. L["COMMAND_AUTO"]) -- Toggle auto-tracking to nearest waypoint.
    end
end

SlashCmdList["DRGF"] = MyAddonCommands

local drgfFrame = CreateFrame("Button", "drgfFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)

do
    local throttle = 0.1;
    function FindClosestWayPoint(self, elapsed)
        if (TomTom == nil or STOPPED == true) then
            return
        end
        local zone = GetZoneText()
        throttle = throttle + elapsed
        if (throttle > 0.1) then
            TomTom:SetClosestWaypoint()
            throttle = 0
        end
    end
end

drgfFrame:SetScript("OnUpdate", FindClosestWayPoint)
