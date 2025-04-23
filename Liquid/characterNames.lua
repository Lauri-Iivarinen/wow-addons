local _, ns = ...
local sformat, CopyTable, UnitName, UnitGUID, UnitClass, UnitGroupRolesAssigned, CreateAtlasMarkup, GetUnitName, RAID_CLASS_COLORS = string.format, CopyTable, UnitName, UnitGUID, UnitClass, UnitGroupRolesAssigned, CreateAtlasMarkup, GetUnitName, RAID_CLASS_COLORS
local sortedCharList = {}

-- Creates a <nickname> to <table of character names> mapping
function ns:loadNames()
	for characterName, nickname in pairs(LiquidDB.nicknames) do
		if not sortedCharList[nickname] then
			sortedCharList[nickname] = {}
		end
		sortedCharList[nickname][characterName] = true
	end
	-- override WA functions for nicknames
	if WeakAuras then
		if WeakAuras.GetName then
			WeakAuras.GetName = function(n,a)
				if not n then return end
				return LiquidDB.nicknames[n] or n
			end
		end
		if WeakAuras.UnitName then
			WeakAuras.UnitName = function(unit)
				if not unit then return end
				local n,s = UnitName(unit)
				if not n then return end
				return LiquidDB.nicknames[n] or n, s
			end
		end
		if WeakAuras.GetUnitName then
			WeakAuras.GetUnitName = function(unit, showServer)
				if not unit then return end
				local unitName = GetUnitName(unit, showServer)
				if not unitName then return end
				if not UnitIsPlayer(unit) then
					return unitName
				end
				if showServer then
					local n,s = strsplit("-", unitName)
					if s then
						return sformat("%s-%s", (LiquidDB.nicknames[n] or n), s)
					end
					return LiquidDB.nicknames[n] or n
				else
					local n = unitName:match("^(%s*)")
					if unitName:find("%*") then
						return sformat("%s (*)", (LiquidDB.nicknames[n] or n))
					end
					return LiquidDB.nicknames[n] or n
				end
			end
		end
		if WeakAuras.UnitFullName then
			WeakAuras.UnitFullName = function(unit)
				if not unit then return end
				local n,s = UnitFullName(unit)
				if not n then return end
				if UnitIsPlayer(unit) then
					return LiquidDB.nicknames[n] or n, s
				end
				return n,s
			end
		end
	end
	if LiquidCharDB.btag and LiquidCharDB.btag ~= "" then
		ns:AddNewNickname(LiquidCharDB.btag:lower(), UnitName('player'))
	end
end
if ns.me.btag then
	if ns.battleTags[ns.me.btag:lower()] then
		ns.me.nickname = ns.battleTags[ns.me.btag:lower()]
	else
		ns.me.nickname = ""
	end
elseif LiquidCharDB and LiquidCharDB.btag then
	if ns.battleTags[LiquidCharDB.btag:lower()] then
		ns.me.nickname = ns.battleTags[LiquidCharDB.btag:lower()]
	else
		ns.me.nickname = ""
	end
else
	ns.me.nickname = ""
end
function ns:AddNewNickname(btag, char)
	if not (btag and char and ns.battleTags[btag]) then return end
		LiquidDB.nicknames[char] = ns.battleTags[btag]
	if not sortedCharList[ns.battleTags[btag]] then
		sortedCharList[ns.battleTags[btag]] = {}
	end
	sortedCharList[ns.battleTags[btag]][char] = true
end
-- yoinked from WA
local utf8Sub = function(input, size)
  local output = ""
  if type(input) ~= "string" then
    return output
  end
  local i = 1
  while (size > 0) do
    local byte = input:byte(i)
    if not byte then
      return output
    end
    if byte < 128 then
      -- ASCII byte
      output = output .. input:sub(i, i)
      size = size - 1
    elseif byte < 192 then
      -- Continuation bytes
      output = output .. input:sub(i, i)
    elseif byte < 244 then
      -- Start bytes
      output = output .. input:sub(i, i)
      size = size - 1
    end
    i = i + 1
  end

  -- Add any bytes that are part of the sequence
  while (true) do
    local byte = input:byte(i)
    if byte and byte >= 128 and byte < 192 then
      output = output .. input:sub(i, i)
    else
      break
    end
    i = i + 1
  end

  return output
end

do
	local unitIDs = {
		player = true,
		focus = true,
		focustarget = true,
		target = true,
		targettarget = true,
	}

	for i = 1, 4 do
		unitIDs["party" .. i] = true
		unitIDs["party" .. i .. "target"] = true
	end

	for i = 1, 40 do
		unitIDs["raid" .. i] = true
		unitIDs["raid" .. i .. "target"] = true
	end

	for i = 1, 40 do
		unitIDs["nameplate" .. i] = true
		unitIDs["nameplate" .. i .. "target"] = true
	end

	for i = 1, 15 do
		unitIDs["boss" .. i .. "target"] = true
	end

	local roleAtlases = {
		[1] = "adventures-tank", -- Tank
		[2] = "adventures-healer", -- Healer
		[3] = "groupfinder-icon-class-warrior", -- Melee dps
		[4] = "adventures-dps-ranged", -- Ranged dps
		[5] = "adventures-dps", -- General dps
	}

	function LiquidAPI:GetName(characterName, formatting, atlasSize)
		if not characterName then
			error("LiquidAPI:GetName(characterName[, formatting, atlasSize]), characterName is nil")
			return
		end

		local nickname

		if unitIDs[characterName:lower()] then
			local n = UnitNameUnmodified(characterName)
			if n then
				n = strsplit("-", n)
			end
			nickname = n and LiquidDB.nicknames[n] or n
		else
			characterName = strsplit("-", characterName)
			nickname = LiquidDB.nicknames[characterName] or characterName
		end

		if not formatting then
			return nickname
		end

		local guid = UnitGUID(characterName)

		if not guid then -- Character not found in group
			return nickname, "%s", ""
		end
		local _, spot = LiquidAPI:GetSpecInformation(guid)
		local classFileName = UnitClassBase(characterName)
		local colorStr = sformat("|c%s%%s|r", classFileName and RAID_CLASS_COLORS[classFileName] and RAID_CLASS_COLORS[classFileName].colorStr or "ffffff")

		if not spot then -- Not Liquid addon user or outside encounter
			if VMRT then
				spot = LiquidAPI:GetSpotForSpecID(VMRT.ExCD2.gnGUIDs[GetUnitName(characterName, true)])
			end

			if not spot then
				local role = UnitGroupRolesAssigned(characterName)
				spot = role == "TANK" and 1 or role == "HEALER" and 2 or role == "DAMAGER" and 5 or nil
			end
		end
		return nickname, colorStr, spot and spot ~= 9999 and CreateAtlasMarkup(roleAtlases[spot], atlasSize, atlasSize) or "", RAID_CLASS_COLORS[classFileName] or {}
	end

	function LiquidAPI:GetNameForUnitFrame(unitID, maxLength)
		if not unitID then return end
		local n = UnitNameUnmodified(unitID)
		if not n then return end
		if n then
			n = strsplit("-", n) -- check at some point if this is even necessary, cba to do it now (same on LiquidAPI:GetName())
		end
		if maxLength then
			return utf8Sub(LiquidDB.nicknames[n] or n, maxLength)
		end
		return LiquidDB.nicknames[n] or n
	end
end

function LiquidAPI:GetCharacters(nickname)
	if not nickname then
		error("LiquidAPI:GetCharacters(nickname), nickname is nil")
		return
	end
	if sortedCharList[nickname] then
		return CopyTable(sortedCharList[nickname])
	end
	nickname = nickname:gsub("^%l", string.upper) -- TODO: support utf8
	return sortedCharList[nickname] and CopyTable(sortedCharList[nickname])
end

-- Return the full list of nicknames an associated character names
function LiquidAPI:GetAllCharacters()
	return CopyTable(LiquidDB.nicknames)
end

-- For a known nickname, if any of their characters is in your group, return that character name.
-- Second return value is the class color format string. Retured separately so it can be used on the nickname as well.
---@param nickname string
---@return string? characterName character found in group
---@return string? formatedName color formated name
---@return string? guid
function LiquidAPI:GetCharacterInGroup(nickname)
	local characters = LiquidAPI:GetCharacters(nickname)
	if not characters then return end
	for character in pairs(characters) do
		if UnitExists(character) then
			local guid = UnitGUID(character)
			local classFileName = UnitClassBase(character)
			return character, string.format("|c%s%%s|r", RAID_CLASS_COLORS[classFileName].colorStr), guid
		end
	end
end
function LiquidAPI:IsPotentialMember(characterName)
	local n = LiquidAPI:GetName(characterName)
	if not n then return end
	for btag,nickName in pairs(ns.battleTags) do
		if nickName == n then
			return true
		end
	end
end

