local _, ns = ...
local itemsToTradeSTR = ""
local tconcat, tinsert, sformat, CopyTable, strsplit = table.concat, table.insert, string.format, CopyTable, strsplit
local itemsToTrade = {}
local itemWhitelist = {}

for _,v in pairs(ns.cacheConfigs.tierTokens) do
	itemWhitelist[v] = true
end

ns.items = {}
do
	function ns.items:InitItems()
		if LiquidCharDB.items then
			local _n, _s = UnitFullName('player')
			if not _s then
				print("Liquid: Server was returned as nil, trying again in 5 seconds (trading will not work before this goes through)")
				C_Timer.After(5, function()
					ns.items:InitItems()
				end)
				return
			end
			if ns.debugMode then
				DevTool:AddData({name = _n, server = _s, time = GetTime()}, "Init")
				print("Liquid debug (name/server):", _n, _s,UnitFullName('player'))
				DevTool:AddData({UnitFullName('player')}, "AfterPrint")
			end
			local _player = _n.. "-".. _s
			local toBeTraded = {}
			for k,v in pairs({strsplit(";",itemsToTradeSTR)}) do
				local guid, receiver = strsplit(":", v)
				if not (guid and receiver) then return end -- basicly nil check for empty string
				if not receiver:find("-") then
					receiver = receiver.."-Illidan"
				end
				itemsToTrade[guid] = receiver
				if LiquidCharDB.items[guid] then
					toBeTraded[receiver] = toBeTraded[receiver] and toBeTraded[receiver] + 1 or 1
				end
			end
			local isFirst = true
			for k,v in pairs(toBeTraded) do
				if k ~= _player then
					if isFirst then
						print("You have loot to be traded in your bags:")
						isFirst = false
					end
					print(k,v)
				end
			end
		end
	end
end
local validDifs = { -- Legacy difIds are added for easier debugging if needed, cba to turn them on and off again
	[3] = true, -- 10 Player
	[4] = true, -- 25 Player
	[7] = true, -- Legacy LFR
	[9] = true, -- 40 Player
	[14] = true, -- Normal
	[15] = true, -- Heroic
	[16] = true, -- Mythic
	[17] = true, -- LFR
	[33] = true, -- Timewalking raid
	[151] = true, -- Timewalking LFR
}
local currentGuildMembers = {}
local currentEncounter
local currentRoster = {}
local proposedKillId
local function GetNewKillId()
		local chars = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890"
		local t = {}
		for i = 1, 8 do
			local charIndex = math.random(1, #chars)
			tinsert(t, chars:sub(charIndex, charIndex))
		end
		return tconcat(t, "")
end
local currentItemsInRoll = {}
local currentlyInEncounter = false
function ns.items:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
	currentlyInEncounter = true
	if not validDifs[difficultyID] then
		currentEncounter = nil
		LiquidCharDB.lastEncounter = nil
		return
	end
	currentItemsInRoll = {}
	proposedKillId = {
		sender = 1000,
		killId = ""
	}
	currentGuildMembers = {}
	currentRoster = {}
	currentEncounter = encounterID
	-- Check if player can loot
	local instanceName = GetInstanceInfo()
	if not validDifs[difficultyID] then return end
	for i = 1, GetNumSavedInstances() do
		local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters = GetSavedInstanceInfo(i)
		if name == instanceName and difficulty == difficultyID then
			if not locked then break end
			for j = 1, numEncounters do
				local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
				if bossName == encounterName then
					if isKilled then return end
					break
				end
			end
			break
		end
	end
	-- not saved
	local raidIndex = UnitInRaid('player') or 100
	local _proposedKillId = GetNewKillId()
	C_ChatInfo.SendAddonMessage('Liquid', sformat("gimmeloot:%s:%s:%s",encounterID, raidIndex, _proposedKillId), IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
end

--[[
	LiquidCharDB.charData -- gear etc data
	LiquidCharDB.oldGuid -- guid for old character with same name, so we can delete it in server (faction/race change)
	LiquidCharDB.raids -- raids that you have been a part of
	LiquidCharDB.items -- seen items
]]

function ns.items:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
	currentlyInEncounter = false
	if not validDifs[difficultyID] then return end
	if success == 0 then return end
	local instanceID = select(8, GetInstanceInfo())
	local guildMemberCount = 0
	for _ in pairs(currentGuildMembers) do
		guildMemberCount = guildMemberCount + 1
	end
	--if guildMemberCount <= 8 then return end -- ignore kill if there are only few guild members
	-- TODO whitelist instances here in the future?
	--LiquidCharDB.items
	if not LiquidCharDB.raids[encounterID] then
		LiquidCharDB.raids[encounterID] = {
			name = encounterName,
			kills = {},
		}
	end
	local serverTime = GetServerTime()
	if LiquidCharDB.raids[encounterID].kills[serverTime] then return end -- i don't think this will ever happen, but might as well check it
	local t = {}
	for k,v in pairs(currentRoster) do -- just change format before saving for LiquidClient
		tinsert(t, CopyTable(v))
	end
	LiquidCharDB.raids[encounterID].kills[serverTime] = {
		dif = difficultyID,
		players = t,
		itemsWaiting = {},
		itemsFound = {},
		instanceID = instanceID,
		killId = proposedKillId and proposedKillId.killId or "UNKNOWN",
		itemLinks = currentItemsInRoll, -- in case we procced loots before encounter_end, no idea if there can be a scenario like this
	}
	LiquidCharDB.lastEncounter = {
		encounterID = encounterID,
		killTime = serverTime,
		playerGUID = ns.playerGUID,
		killId = proposedKillId and proposedKillId.killId or "UNKNOWN"
	}
end
function ns.items:START_LOOT_ROLL(lootID)
	local itemLink = GetLootRollItemLink(lootID)
	if not itemLink then
		print("Error: itemlink now found on START_LOOT_ROLL - report to Ironi")
		return
	end
	if currentlyInEncounter then
		currentItemsInRoll[lootID] = itemLink
	end
	if (not (LiquidCharDB.lastEncounter and LiquidCharDB.lastEncounter.killTime)) or LiquidCharDB.lastEncounter.killTime < (GetServerTime()-60) then
		ns.PrintDebug(">>>Error: recent kill is too old<<<")
		return
	end
	if LiquidCharDB.raids and LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID] and LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID].kills[LiquidCharDB.lastEncounter.killTime] then
		if not LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID].kills[LiquidCharDB.lastEncounter.killTime].itemLinks then -- shouldnt actually happen
			LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID].kills[LiquidCharDB.lastEncounter.killTime].itemLinks = {}
		end
		LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID].kills[LiquidCharDB.lastEncounter.killTime].itemLinks[lootID] = itemLink
	end
end
do
	local whitelistedUnits = {}
	for i = 1, 40 do
		whitelistedUnits["raid"..i] = true
	end
	local ownRealm -- not available on *login* -> check on first event
	function ns.items:UNIT_SPELLCAST_SUCCEEDED(unitID) -- TODO figure out cheaper event to use
		if not whitelistedUnits[unitID] then return end
		local guid = UnitGUID(unitID)
		if not guid then return end
		if currentRoster[guid] then return end
		local n,s = UnitNameUnmodified(unitID)
		if not s then -- same realm
			if not ownRealm then
				ownRealm = select(2, UnitFullName('player'))
			end
			s = ns.items.serverSlugs[ownRealm] or ownRealm
		else
			if ns.items.serverSlugs[s] then -- should always be found
				s = ns.items.serverSlugs[s]
			end
		end
		currentRoster[guid]= {
			Name = n,
			Server = s,
			Guid = guid,
			IsMember = currentGuildMembers[guid] or false,
			Faction = UnitFactionGroup(unitID)
		}
	end
end
function ns.items:AddToLootRoster(sender, msg)
	if not proposedKillId then return end
	local _, eid, raidIndex, proposedId = strsplit(":", msg)
	eid = tonumber(eid)
	if not eid == currentEncounter then return end
	-- just test it, cba to do anything smarter and unitguid call is cheap anyway (afaik)
	local g = UnitGUID(sender)
	if not g then
		local n,s = strsplit("-", sender)
		g = UnitGUID(n)
	end
	raidIndex = tonumber(raidIndex) or 1000
	if proposedKillId.sender > raidIndex then
		proposedKillId.sender = raidIndex
		proposedKillId.killId = sformat("%s-%s", sender, proposedId)
	end
	if not g then
		print("Liquid: Something went wrong with items:AddToLootRoster report this ASAP to Ironi on discord, sender:", sender)
		return
	end
	currentGuildMembers[g] = true
	if currentRoster[g] then
		currentRoster[g].IsMember = true
	end
end
local function canTrade(guid)
	local d = C_TooltipInfo.GetItemByGUID(guid)
	if not d then return end
	if not d.lines then return end
	for _,lineData in pairs(d.lines) do
		if lineData.leftText then
			if lineData.leftText and lineData.leftText:match("^You may trade this item with players that were also") then
				return true
			end
		end
	end
	return false
end
function ns.tradeCheck(guid)
	return canTrade(guid)
end
local _timer
local function findItemByLink(itemData)
	for bagID = 0, 4 do
		for invID = 1, C_Container.GetContainerNumSlots(bagID) do
			local item = Item:CreateFromBagAndSlot(bagID, invID)
			if not item:IsItemDataCached() then
				item:ContinueOnItemLoad(function()
					if _timer then _timer:Cancel() end
					_timer = C_Timer.NewTimer(1, function()
						ns.items:BAG_UPDATE_DELAYED()
					end)
				end)
			elseif item:GetItemID() == itemData.id then
				local t = {strsplit(":",item:GetItemLink())}
				table.sort(t)
				if tconcat(t, "") == itemData.sortedLink then
					if not (LiquidCharDB.items[item:GetItemGUID()]
						and LiquidCharDB.items[item:GetItemGUID()].source
						and LiquidCharDB.items[item:GetItemGUID()].source.encounterID) then -- only accept items that doesn't have source yet (duplicate items)
						return item
					end
				end
			end
		end
	end
	print("didn't find item", itemData.sortedLink)
end

local function findKillForItem(itemGUID)
	--LiquidDB.lootTrading.encounters[v.encounterID].kills[v.killKey].itemsFound[guid]
	for eID, eData in pairs(LiquidCharDB.raids) do
		for killTime, killData in pairs(eData.kills) do
			if killData.itemsFound[itemGUID] then
				return {encounterID = eID, killKey = killTime}
			end
		end
	end
end
local timer2
function ns.items:cacheInventory()
	local temp = {}
	for bagID = 0, 4 do
		for invID = 1, C_Container.GetContainerNumSlots(bagID) do
			local item = Item:CreateFromBagAndSlot(bagID, invID)
			if not item:IsItemDataCached() then
				item:ContinueOnItemLoad(function()
					if timer2 then timer2:Cancel() end
					timer2 = C_Timer.NewTimer(1, function()
						ns.items:cacheInventory()
					end)
				end)
			elseif not item:IsItemEmpty() then
				local _type = select(6, C_Item.GetItemInfoInstant(item:GetItemID()))
				if (itemWhitelist[item:GetItemID()] or _type == Enum.ItemClass.Armor or _type == Enum.ItemClass.Weapon) then -- only check items we care about to save some resources
					--[[ if not LiquidDB.lootTrading.cachedItems[ns.playerGUID] then
						LiquidDB.lootTrading.cachedItems[ns.playerGUID] = {}
					end --]]
					local itemGUID = item:GetItemGUID()
					temp[itemGUID] = true
					if LiquidCharDB.items[itemGUID] and LiquidCharDB.items[itemGUID].canTrade then -- recheck if its still tradeable
						LiquidCharDB.items[itemGUID].canTrade = canTrade(itemGUID)
					elseif not LiquidCharDB.items[itemGUID] then
						local _canTrade = canTrade(itemGUID)
						LiquidCharDB.items[itemGUID] = {
							canTrade = _canTrade,
							source = _canTrade and findKillForItem(itemGUID) or {}, -- don't care where it came from if you can't trade it
						}
					end
				end
			end
		end
	end
	if not ns.isLegitChar then return end
	-- Clean up
	local toDelete = {}
	for k,v in pairs(LiquidCharDB.items) do
		if not temp[k] then
			toDelete[k] = true
		end
	end
	for k,v in pairs(toDelete) do
		LiquidCharDB.items[k] = nil
	end
	ns.items:SetTradeInfoText()
end
local itemsToCheck = {}

function ns.items:ENCOUNTER_LOOT_RECEIVED(encounterID, itemID, itemLink, quantity, receiverName, receiverClassFileName)
	if encounterID == 0 then return end -- some random shit
	local _type = select(6, C_Item.GetItemInfoInstant(itemID))
	if not (itemWhitelist[itemID] or _type == Enum.ItemClass.Armor or _type == Enum.ItemClass.Weapon) then return end
	local latest = 0
	if LiquidCharDB.raids[encounterID] then
		for k,v in pairs(LiquidCharDB.raids[encounterID].kills) do
			if k > latest then
				latest = k
			end
		end
	end
	if latest == 0 then
		return
	end
	if UnitIsUnit(receiverName, 'player') then
		local t = {strsplit(":",itemLink)}
		table.sort(t)
		tinsert(itemsToCheck, {id = itemID, sortedLink = tconcat(t, ""), encounterID = encounterID, killKey = latest})
	end
end

function ns.items:checkItems()
	-- find items
	local foundItems = {}
	for k,v in pairs(itemsToCheck) do
		local item = findItemByLink(v)
		if item then 
			foundItems[k] = true
			if LiquidCharDB.raids[v.encounterID].kills[v.killKey] then
				local guid = item:GetItemGUID()
				local temp = C_Item.GetItemStats(item:GetItemLink())
				local tertiary = sformat("%s%s%s%s",temp["EMPTY_SOCKET_PRISMATIC"] and "Socket" or "",
				temp["ITEM_MOD_CR_LIFESTEAL_SHORT"] and "Leech" or "",
				temp["ITEM_MOD_CR_SPEED_SHORT"] and "Speed" or "",
				temp["ITEM_MOD_CR_AVOIDANCE_SHORT"] and "Avoidance" or "")
				if ns.cacheConfigs.gear.showStatsForItems[item:GetItemID()] then
					local stats = {
						C = temp["ITEM_MOD_CRIT_RATING_SHORT"] or 0,
						M = temp["ITEM_MOD_MASTERY_RATING_SHORT"] or 0,
						H = temp["ITEM_MOD_HASTE_RATING_SHORT"] or 0,
						V = temp["ITEM_MOD_VERSATILITY"] or 0,
					}
					local sorted = {}
					for stat,_v in ns:spairs(stats, function(t,a,b) return t[b] < t[a] end) do
						if _v > 0 then
							tinsert(sorted, stat)
						end
					end
					if #sorted > 0 then
						tertiary = sformat("%s-%s", tconcat(sorted, "/"), tertiary)
					end
				end
				LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid] = {
					itemLevel = C_Item.GetDetailedItemLevelInfo(item:GetItemLink()),
					tertiary = tertiary,
						itemID = item:GetItemID(),
				}
				--[[ if not LiquidDB.lootTrading.cachedItems[ns.playerGUID] then
					LiquidDB.lootTrading.cachedItems[ns.playerGUID] = {}
				end --]]
				local killId = LiquidCharDB.raids[v.encounterID].kills[v.killKey].killId or ""
				if LiquidCharDB.items[guid] then -- was cached before we found it
					LiquidCharDB.items[guid].source = {encounterID = v.encounterID, killKey = v.killKey, killId = killId}
					LiquidCharDB.items[guid].itemInfo = {
						ItemLevel = LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].itemLevel,
						Tertiary = LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].tertiary,
						ItemId = LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].itemID
					}
				else
					LiquidCharDB.items[guid] = {
						canTrade = canTrade(guid),
						source = {encounterID = v.encounterID, killKey = v.killKey, killId = killId}, 
						itemInfo = {
							ItemLevel = LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].itemLevel,
							Tertiary = LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].tertiary,
							ItemId = LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].itemID
						}
					}
				end
				C_ChatInfo.SendAddonMessage('Liquid', sformat("lootCache;%s;%s;%s;%s;%s;%s", guid, v.encounterID, v.killKey,
				LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].itemLevel,
				LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].tertiary,
				LiquidCharDB.raids[v.encounterID].kills[v.killKey].itemsFound[guid].itemID),
				IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
			else
				print("Liquid: Error, no kill found for:", item:GetItemGUID())
			end
		end
	end
	for k,v in pairs(foundItems) do
		itemsToCheck[k] = nil
	end
	ns.items:cacheInventory()
end
local timer3
function ns.items:BAG_UPDATE_DELAYED()
	if timer3 then timer3:Cancel() end
	timer3 = C_Timer.NewTimer(.5, function()
			ns.items:checkItems()
		end)
end
function ns.items:LootCaching(msg)
	local _, itemGUID, encounterID, killTime, ilvl, tertiary, itemID = strsplit(";", msg)
	encounterID = tonumber(encounterID)
	killTime = tonumber(killTime)
	if not (itemGUID and encounterID and killTime) then return end
	if LiquidCharDB.raids and LiquidCharDB.raids[encounterID] and LiquidCharDB.raids[encounterID].kills then
		for k,v in pairs(LiquidCharDB.raids[encounterID].kills) do
			if k+10 >= killTime and k-10 <= killTime then
				if not v.itemsFound[itemGUID] then
					v.itemsFound[itemGUID] = {
						itemLevel = tonumber(ilvl),
						tertiary = tertiary or "",
						itemID = tonumber(itemID),
					}
				end
				return
			end
		end
	end
end
function ns.items:TRADE_SHOW()
	local n, server = UnitFullName("npc")
	if not server then
		local server = GetNormalizedRealmName()
		if ns.items.serverSlugs[server] then -- should always be found
			server = ns.items.serverSlugs[server]
		end
		n = n.."-"..server
	else
		if ns.items.serverSlugs[server] then -- should always be found
			server = ns.items.serverSlugs[server]
		end
		n = n.."-"..server
	end
	n = n:lower()
	local i = 1
	for k,v in pairs(itemsToTrade) do
		if n == v:lower() then
			if C_Item.IsItemGUIDInInventory(k) then
				if i >= 7 then print("Liquid: Trade is already full, trade again for the rest.") return end
				local itemLoc = C_Item.GetItemLocation(k)
				if itemLoc then
					local bagID, slotID = itemLoc:GetBagAndSlot()
					if not (bagID and slotID) then print("Liquid: Error, no bagID or slotID found.") end
					--C_Container.UseContainerItem(bagID, slotID)
					if not canTrade(k) then
						print("Liquid: Error, item can no longer be traded.", C_Container.GetContainerItemLink(bagID, slotID))
					else
						local index = i
						C_Timer.After(index*.3, function()
							C_Container.PickupContainerItem(bagID, slotID)
							ClickTradeButton(index)
						end)
						i = i + 1
					end
				end
			end
		end
	end
end
function ns.items:LOOT_ITEM_ROLL_WON(itemLink, rollQuantity, rollType, roll, upgraded)
	if not (LiquidCharDB.lastEncounter) then return end
	if not LiquidCharDB.lastEncounter.encounterID then print("Liquid: Error,no encounterID found (LOOT_ITEM_ROLL_WON)") return end
	if not (LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID] and LiquidCharDB.raids[LiquidCharDB.lastEncounter.encounterID].kills[LiquidCharDB.lastEncounter.killTime]) then print("Liquid: Error, no kill found (LOOT_ITEM_ROLL_WON)") return end
	local t = {strsplit(":",itemLink)}
	local itemID = C_Item.GetItemInfoInstant(itemLink)
	table.sort(t)
	tinsert(itemsToCheck, {id = itemID, sortedLink = tconcat(t, ""), encounterID = LiquidCharDB.lastEncounter.encounterID, killKey = LiquidCharDB.lastEncounter.killTime})
end
do
	local tradeInfo
	function ns.items:ShowTrade()
		if not tradeInfo then
			tradeInfo = CreateFrame("frame", nil, UIParent)
			tradeInfo:SetSize(1,1)
			tradeInfo:SetPoint("TOP", UIParent, "TOP", -200,-200)
			tradeInfo.text = tradeInfo:CreateFontString()
			tradeInfo.text:SetFont(STANDARD_TEXT_FONT, 20, 'OUTLINE')
			tradeInfo.text:SetPoint('TOPLEFT', tradeInfo, 'TOPLEFT', 0,0)
			tradeInfo.text:SetJustifyH("LEFT")
			tradeInfo.text:SetText("")
		elseif tradeInfo:IsShown() then
			tradeInfo:Hide()
			return
		end
		tradeInfo:Show()
		ns.items:SetTradeInfoText()
		--updateTradeWindow
	end
	function ns.items:SetTradeInfoText()
		if not (tradeInfo and tradeInfo:IsShown()) then return end
		local t = {}
		for itemGuid,targetName in pairs(itemsToTrade) do
			if C_Item.IsItemGUIDInInventory(itemGuid) and canTrade(itemGuid) then
				--if C_Item.IsItemGUIDInInventory(itemGuid) then
				local itemLoc = C_Item.GetItemLocation(itemGuid)
				--local bagID, slotID = itemLoc:GetBagAndSlot()
				if not itemLoc then return end
				local item = Item:CreateFromItemLocation(itemLoc)
				local icon = select(5, C_Item.GetItemInfoInstant(item:GetItemID()))
				if icon then
					if not t[targetName] then
						t[targetName] = {}
					end
					tinsert(t[targetName], sformat("\124T%s:18\124t", icon))
				else
					print("Error, no icon for:", itemGuid, targetName)
				end
			end
		end
		local lines = {}
		for k,v in ns:spairs(t) do
			tinsert(lines, sformat("%s (%s) %s", k, #v, tconcat(v)))
		end
		tradeInfo.text:SetText(tconcat(lines, "\n"))
	end
end
local function formatChars(t, tooltip)
	local temp = {}
	for _,v in pairs(t) do
		if v.IsMember then
			--if true then
			if v.Server == "Illidan" then
				tinsert(temp, v.Name)
			else
				tinsert(temp, v.Name.."-"..v.Server)
			end
		end
	end
	return tconcat(temp, tooltip and ", " or "\t")
end
do
	-- shortest time left
	local function timeLeft(guid)
    local d = C_TooltipInfo.GetItemByGUID(guid)
    if not d then return end
    for _,lineData in pairs(d.lines) do
			local s = lineData.leftText and lineData.leftText:match("^You may trade this item with players that were also eligible to loot this item for the next (.+).")
			if s then
				--            print(s)
				--            ViragDevTool:AddData(lineData, "title")
				local hours = s:match("(%d+) |4hour") or 0
				if tonumber(hours) then
						hours = tonumber(hours)
				else
						hours = s:match("hour") and 1 or 0
				end
				local mins = s:match("(%d+) min") or 0
				local secs = s:match("(%d+) sec") or 0
				return hours*60*60+mins*60+secs
			end
    end
	end
	local editbox
	local function getDifIndicator(id)
		local n = GetDifficultyInfo(id)
		if not n then return "" end
		return n:sub(1,1)
	end
	local function GetExportStr(fake)
		if type(fake) == "table" then
			return tconcat(fake, "\n")
		end

		local temp = {}
		--if not LiquidDB.lootTrading.cachedItems[ns.playerGUID] then return "" end
		local holder, holderRealm = UnitFullName("player")
		if holderRealm ~= "Illidan" then
			holder = holder.."-"..holderRealm
		end
		if fake == "trash" then
			if not IsInRaid() then return end
			local roster = {}
			local ownRealm
			for i = 1, GetNumGroupMembers() do
					local n,s = UnitNameUnmodified("raid"..i)
					local guid = UnitGUID("raid"..i)
					if guid then
						if not s then -- same realm
							if not ownRealm then
								ownRealm = select(2, UnitFullName('player'))
							end
							s = ns.items.serverSlugs[ownRealm] or ownRealm
						else
							if ns.items.serverSlugs[s] then -- should always be found
								s = ns.items.serverSlugs[s]
							end
						end
						roster[guid]= {
							Name = n,
							Server = s,
							Guid = guid,
							IsMember = LiquidAPI:IsPotentialMember(n),
						}
					end
			end
			local potentialLooters = formatChars(roster)
			local shortest
			for itemGUID,itemData in pairs(LiquidCharDB.items) do
				if itemData.canTrade then
					local itemID = C_Item.GetItemIDByGUID(itemGUID)
					if ns.cacheConfigs.itemsForTradingBoE[itemID] then
						local itemLink = C_Item.GetItemLinkByGUID(itemGUID)
						if itemLink then
							local _temp = C_Item.GetItemStats(itemLink)
							local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
							local tertiary = sformat("%s%s%s%s",_temp["EMPTY_SOCKET_PRISMATIC"] and "Socket" or "",
							_temp["ITEM_MOD_CR_LIFESTEAL_SHORT"] and "Leech" or "",
							_temp["ITEM_MOD_CR_SPEED_SHORT"] and "Speed" or "",
							_temp["ITEM_MOD_CR_AVOIDANCE_SHORT"] and "Avoidance" or "")
							print(sformat("Trash Item: itemid: %s - itemguid: %s - ilvl: %s - tertiary: %s", itemID, itemGUID, itemLevel, tertiary == "" and "N/A" or tertiary))
							tinsert(temp, sformat("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
								itemID,
								itemLevel,
								tertiary,
								itemGUID,
								"MISSING",
								"MISSING",
								holder,
								potentialLooters)
							)
						end
						local duration = timeLeft(itemGUID)
						if duration then
								if not shortest or shortest > duration then
										shortest = duration
								end
						end
					end
				end
			end
			if shortest then
				tinsert(temp, shortest + GetServerTime())
			end
		else
			local shortest
			for itemGUID,itemData in pairs(LiquidCharDB.items) do
				if itemData.canTrade and itemData.source and itemData.source.encounterID then
				--if itemData.source and itemData.source.encounterID then
					if LiquidCharDB.raids[itemData.source.encounterID]
					and LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey]
					and LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].itemsFound[itemGUID] then

						tinsert(temp, sformat("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
						LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].itemsFound[itemGUID].itemID,
						LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].itemsFound[itemGUID].itemLevel,
						LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].itemsFound[itemGUID].tertiary,
						itemGUID,
						LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].killId,
						getDifIndicator(LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].dif),
						holder,
						formatChars(LiquidCharDB.raids[itemData.source.encounterID].kills[itemData.source.killKey].players)
					))
						local duration = timeLeft(itemGUID)
						if duration then
								if not shortest or shortest > duration then
										shortest = duration
								end
						end
					else
						print("Error: no kill found:", itemData.source.encounterID, itemData.source.killKey)
					end
				end
			end
			if shortest then
				tinsert(temp, shortest + GetServerTime())
			end
		end
		return tconcat(temp, "\n")
	end
	function ns.items:Export(fake)
		if not editbox then
			editbox = CreateFrame("EditBox", nil, UIParent, "BackdropTemplate")
			editbox:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				edgeSize = 1,
				insets = {
					left = -1,
					right = -1,
					top = -1,
					bottom = -1,
				},
			})
			editbox:SetBackdropColor(.1,.1,.1,.8)
			editbox:SetBackdropBorderColor(1,0,0,1)
			editbox:SetScript("OnEditFocusGained", function(self)
				self:HighlightText()
			end)
			editbox:SetScript('OnEnterPressed', function(self)
				self:ClearFocus()
				self:Hide()
			end)
			editbox:SetWidth(300)
			editbox:SetHeight(40)
			editbox:SetTextInsets(2, 2, 1, 0)
			editbox:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
			editbox:SetAutoFocus(true)
			editbox:SetFont(STANDARD_TEXT_FONT, 16, "")
		end
		editbox:SetText(GetExportStr(fake))
		editbox:Show()
	end
end
do -- import, meant only for debugging
	local editbox
	function ns.items:Import()
		if not editbox then
			editbox = CreateFrame("EditBox", nil, UIParent, "BackdropTemplate")
			editbox:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				edgeSize = 1,
				insets = {
					left = -1,
					right = -1,
					top = -1,
					bottom = -1,
				},
			})
			editbox:SetBackdropColor(.1,.1,.1,.8)
			editbox:SetBackdropBorderColor(1,0,0,1)
			editbox:SetScript("OnEditFocusGained", function(self)
				self:HighlightText()
			end)
			editbox:SetScript('OnEnterPressed', function(self)
				itemsToTradeSTR = self:GetText()
				self:ClearFocus()
				self:Hide()
				ns.items:InitItems()
			end)
			editbox:SetWidth(300)
			editbox:SetHeight(40)
			editbox:SetTextInsets(2, 2, 1, 0)
			editbox:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
			editbox:SetAutoFocus(true)
			editbox:SetFont(STANDARD_TEXT_FONT, 16, "")
		end
		editbox:SetText("")
		editbox:Show()
	end
end
do
	local wl = {}
	for _,v in pairs(ns.cacheConfigs.itemsForTrading) do -- i'm lazy
		wl[v] = true
	end
	function ns.items:CheckBagsForProblems()
		local problems = false
		local problemItems = {}
		local holder, holderRealm = UnitFullName("player")
		if holderRealm ~= "Illidan" then
			holder = holder.."-"..holderRealm
		end
		for itemGUID,v in pairs(LiquidCharDB.items) do
			if v.canTrade then
				if v.source and not v.source.killKey then
					local itemID = C_Item.GetItemIDByGUID(itemGUID)
					if wl[itemID] then
						if not problems then
							print("Liquid: Problematic items found.")
						end
						problems = true
						local itemLink = C_Item.GetItemLinkByGUID(itemGUID)
						if itemLink then
							local temp = C_Item.GetItemStats(itemLink)
							local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
							local tertiary = sformat("%s%s%s%s",temp["EMPTY_SOCKET_PRISMATIC"] and "Socket" or "",
							temp["ITEM_MOD_CR_LIFESTEAL_SHORT"] and "Leech" or "",
							temp["ITEM_MOD_CR_SPEED_SHORT"] and "Speed" or "",
							temp["ITEM_MOD_CR_AVOIDANCE_SHORT"] and "Avoidance" or "")
							print(sformat("itemid: %s - itemguid: %s - ilvl: %s - tertiary: %s", itemID, itemGUID, itemLevel, tertiary == "" and "N/A" or tertiary))
							tinsert(problemItems, sformat("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
								itemID,
								itemLevel,
								tertiary,
								itemGUID,
								"MISSING",
								"MISSING",
								holder,
								"MISSING")
							)
						end
					end
				end
			end
		end
		if not problems then
			print("Liquid: All items are accounted for.")
		else
			ns.items:Export(problemItems)
		end
	end
end
local function OnTooltipSetItem(tooltip, data)
	if not (IsAltKeyDown() and IsControlKeyDown()) then return end
	if data.guid then
		tooltip:AddLine(data.guid)
		if itemsToTrade[data.guid] then
			tooltip:AddLine("Trade to: " .. itemsToTrade[data.guid])
		end
		local chars = {}
		if LiquidCharDB.items[data.guid] and LiquidCharDB.items[data.guid].canTrade and LiquidCharDB.items[data.guid].source and LiquidCharDB.items[data.guid].source.encounterID then
			tooltip:AddLine(formatChars(LiquidCharDB.raids[LiquidCharDB.items[data.guid].source.encounterID].kills[LiquidCharDB.items[data.guid].source.killKey].players, true))
		end
	end
end
if ns.configs.lootTracking then
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
end


do
	local itemStrings = {}
	function IMPECITEMFIX()
		itemStrings = {}
		for guid,v in pairs(LiquidCharDB.items) do
			if v.canTrade then
				if C_Item.IsItemGUIDInInventory(guid) then
					local itemLoc = C_Item.GetItemLocation(guid)
					if itemLoc then
						local item = Item:CreateFromItemLocation(itemLoc)
						item:ContinueOnItemLoad(function()
							local temp = C_Item.GetItemStats(item:GetItemLink())
							local itemLevel = C_Item.GetDetailedItemLevelInfo(item:GetItemLink())
							local tertiary = sformat("%s%s%s%s",temp["EMPTY_SOCKET_PRISMATIC"] and "Socket" or "",
								temp["ITEM_MOD_CR_LIFESTEAL_SHORT"] and "Leech" or "",
								temp["ITEM_MOD_CR_SPEED_SHORT"] and "Speed" or "",
								temp["ITEM_MOD_CR_AVOIDANCE_SHORT"] and "Avoidance" or "")
								tinsert(itemStrings, sformat("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
								item:GetItemID(),
								itemLevel,
								tertiary,
								guid,
								"MISSING",
								"N",
								"Bluemangood-Lethon",
								"MISSING"))
						end)
					end
				end
			end
		end
		C_Timer.After(5, function()
			ns.items:Export(itemStrings)
		end)
	end
end
ns.items.serverSlugs = {
["Azralon"] = "Azralon",
["Quel'Thalas"] = "QuelThalas",
["Illidan"] = "Illidan",
["WyrmrestAccord"] = "Wyrmrest-Accord",
["Barthilas"] = "Barthilas",
["Proudmoore"] = "Proudmoore",
["Thrall"] = "Thrall",
["Stormrage"] = "Stormrage",
["Hyjal"] = "Hyjal",
["Zul'jin"] = "Zuljin",
["Area52"] = "Area-52",
["AlteracMountains"] = "Alterac-Mountains",
["Ursin"] = "Ursin",
["Frostmourne"] = "Frostmourne",
["Kel'Thuzad"] = "KelThuzad",
["Tichondrius"] = "Tichondrius",
["Blackrock"] = "Blackrock",
["BleedingHollow"] = "Bleeding-Hollow",
["Skullcrusher"] = "Skullcrusher",
["Mal'Ganis"] = "MalGanis",
["Fizzcrank"] = "Fizzcrank",
["Sargeras"] = "Sargeras",
["Ragnaros"] = "Ragnaros",
["Onyxia"] = "Onyxia",
["ShadowCouncil"] = "Shadow-Council",
["BlackwaterRaiders"] = "Blackwater-Raiders",
["Arthas"] = "Arthas",
["EarthenRing"] = "Earthen-Ring",
["Llane"] = "Llane",
["Dalaran"] = "Dalaran",
["MoonGuard"] = "Moon-Guard",
["Whisperwind"] = "Whisperwind",
["Khaz'goroth"] = "Khazgoroth",
["Madoran"] = "Madoran",
["Eonar"] = "Eonar",
["Durotan"] = "Durotan",
["Malorne"] = "Malorne",
["Garona"] = "Garona",
["Frostmane"] = "Frostmane",
["Sen'jin"] = "Senjin",
["Anvilmar"] = "Anvilmar",
["Drakkari"] = "Drakkari",
["DarkIron"] = "Dark-Iron",
["EmeraldDream"] = "Emerald-Dream",
["Nagrand"] = "Nagrand",
["Elune"] = "Elune",
["Baelgun"] = "Baelgun",
["Maiev"] = "Maiev",
["AeriePeak"] = "Aerie-Peak",
["Saurfang"] = "Saurfang",
["Gurubashi"] = "Gurubashi",
["Lightbringer"] = "Lightbringer",
["Dawnbringer"] = "Dawnbringer",
["Greymane"] = "Greymane",
["Gundrak"] = "Gundrak",
["KhazModan"] = "Khaz-Modan",
["Rexxar"] = "Rexxar",
["Norgannon"] = "Norgannon",
["SilverHand"] = "Silver-Hand",
["Exodar"] = "Exodar",
["Mannoroth"] = "Mannoroth",
["Korgath"] = "Korgath",
["Deathwing"] = "Deathwing",
["Thunderhorn"] = "Thunderhorn",
["BurningBlade"] = "Burning-Blade",
["TarrenMill"] = "Tarren-Mill",
["Sylvanas"] = "Sylvanas",
["LaughingSkull"] = "Laughing-Skull",
["Dragonblight"] = "Dragonblight",
["Kazzak"] = "Kazzak",
["Silvermoon"] = "Silvermoon",
["Madmortem"] = "Madmortem",
["Draenor"] = "Draenor",
["TwistingNether"] = "Twisting-Nether",
["Spirestone"] = "Spirestone",
["CenarionCircle"] = "Cenarion-Circle",
["Archimonde"] = "Archimonde",
["Aman'thul"] = "Amanthul",
["Teldrassil"] = "Teldrassil",
["Nozdormu"] = "Nozdormu",
["Голдринн"] = "Голдринн",
["Blackmoore"] = "Blackmoore",
["Alleria"] = "Alleria",
["Drak'thul"] = "Drak-thul",
["Stormreaver"] = "Stormreaver",
["Ravencrest"] = "Ravencrest",
["DieArguswacht"] = "Die-Arguswacht",
["ArgentDawn"] = "Argent-Dawn",
["Outland"] = "Outland",
["Warsong"] = "Warsong",
["Frostwolf"] = "Frostwolf",
["Azgalor"] = "Azgalor",
["Kargath"] = "Kargath",
["Gnomeregan"] = "Gnomeregan",
["Gallywix"] = "Gallywix",
["Thunderlord"] = "Thunderlord",
["Quel'dorei"] = "Queldorei",
["Bloodscalp"] = "Bloodscalp",
["AzjolNerub"] = "Azjol-Nerub",
["Nathrezim"] = "Nathrezim",
["Bonechewer"] = "Bonechewer",
["Magtheridon"] = "Magtheridon",
["Shandris"] = "Shandris",
["Daggerspine"] = "Daggerspine",
["Moonrunner"] = "Moonrunner",
["Antonidas"] = "Antonidas",
["Lightning'sBlade"] = "Lightnings-Blade",
["Turalyon"] = "Turalyon",
["Shu'halo"] = "Shuhalo",
["Kil'jaeden"] = "Kiljaeden",
["Aegwynn"] = "Aegwynn",
["Eldre'Thalas"] = "EldreThalas",
["Doomhammer"] = "Doomhammer",
["Staghelm"] = "Staghelm",
["Uldaman"] = "Uldaman",
["Dragonmaw"] = "Dragonmaw",
["Khadgar"] = "Khadgar",
["Ner'zhul"] = "Nerzhul",
["Hellscream"] = "Hellscream",
["Eitrigg"] = "Eitrigg",
["Eredar"] = "Eredar",
["Lethon"] = "Lethon",
["Galakrond"] = "Galakrond",
["Boulderfist"] = "Boulderfist",
["Thaurissan"] = "Thaurissan",
["Caelestrasz"] = "Caelestrasz",
["Dreadmaul"] = "Dreadmaul",
["Goldrinn"] = "Goldrinn",
["Arathor"] = "Arathor",
["Mug'thol"] = "Mugthol",
["Gilneas"] = "Gilneas",
["Crushridge"] = "Crushridge",
["Sentinels"] = "Sentinels",
["Arygos"] = "Arygos",
["Misha"] = "Misha",
["Undermine"] = "Undermine",
["Nordrassil"] = "Nordrassil",
["Bladefist"] = "Bladefist",
["Icecrown"] = "Icecrown",
["Tanaris"] = "Tanaris",
["Kilrogg"] = "Kilrogg",
["Dunemaul"] = "Dunemaul",
["Firetree"] = "Firetree",
["Velen"] = "Velen",
["AltarofStorms"] = "Altar-of-Storms",
["Uldum"] = "Uldum",
["Ysera"] = "Ysera",
["Drenden"] = "Drenden",
["Dath'Remar"] = "DathRemar",
["Bloodhoof"] = "Bloodhoof",
["Cho'gall"] = "Chogall",
["Nemesis"] = "Nemesis",
["Gorefiend"] = "Gorefiend",
["Cenarius"] = "Cenarius",
["Azshara"] = "Azshara",
["Windrunner"] = "Windrunner",
["Ghostlands"] = "Ghostlands",
["ShatteredHand"] = "Shattered-Hand",
["Hakkar"] = "Hakkar",
["Lothar"] = "Lothar",
["BlackDragonflight"] = "Black-Dragonflight",
["Duskwood"] = "Duskwood",
["Terenas"] = "Terenas",
["Garrosh"] = "Garrosh",
["Gorgonnash"] = "Gorgonnash",
["Uther"] = "Uther",
["Blackhand"] = "Blackhand",
["Nazjatar"] = "Nazjatar",
["Destromath"] = "Destromath",
["Darkspear"] = "Darkspear",
["Dalvengyr"] = "Dalvengyr",
["Blade'sEdge"] = "Blades-Edge",
["Vek'nilash"] = "Veknilash",
["Bronzebeard"] = "Bronzebeard",
["Suramar"] = "Suramar",
["Shadowsong"] = "Shadowsong",
["ScarletCrusade"] = "Scarlet-Crusade",
["Draka"] = "Draka",
["Stonemaul"] = "Stonemaul",
["Skywall"] = "Skywall",
["Aggramar"] = "Aggramar",
["TheUnderbog"] = "The-Underbog",
["KirinTor"] = "Kirin-Tor",
["Zangarmarsh"] = "Zangarmarsh",
["Jubei'Thos"] = "JubeiThos",
["Agamaggan"] = "Agamaggan",
["Korialstrasz"] = "Korialstrasz",
["Mok'Nathal"] = "MokNathal",
["Nazgrel"] = "Nazgrel",
["Perenolde"] = "Perenolde",
["BloodFurnace"] = "Blood-Furnace",
["Kael'thas"] = "Kaelthas",
["Muradin"] = "Muradin",
["Smolderthorn"] = "Smolderthorn",
["Detheroc"] = "Detheroc",
["BurningLegion"] = "Burning-Legion",
["Aman'Thul"] = "AmanThul",
["Gul'dan"] = "Guldan",
["Darrowmere"] = "Darrowmere",
["Cairne"] = "Cairne",
["Malygos"] = "Malygos",
["Nesingwary"] = "Nesingwary",
["Ravenholdt"] = "Ravenholdt",
["Akama"] = "Akama",
["Executus"] = "Executus",
["GrizzlyHills"] = "Grizzly-Hills",
["Trollbane"] = "Trollbane",
["Jaedenar"] = "Jaedenar",
["Azuremyst"] = "Azuremyst",
["Hydraxis"] = "Hydraxis",
["KulTiras"] = "Kul-Tiras",
["Medivh"] = "Medivh",
["Alexstrasza"] = "Alexstrasza",
["TheForgottenCoast"] = "The-Forgotten-Coast",
["Vashj"] = "Vashj",
["Rivendare"] = "Rivendare",
["DemonSoul"] = "DemonSoul",
["Winterhoof"] = "Winterhoof",
["TolBarad"] = "Tol-Barad",
["Runetotem"] = "Runetotem",
["Wildhammer"] = "Wildhammer",
["Stormscale"] = "Stormscale",
["Malfurion"] = "Malfurion",
["Spinebreaker"] = "Spinebreaker",
["Coilfang"] = "Coilfang",
["ThoriumBrotherhood"] = "Thorium-Brotherhood",
["BoreanTundra"] = "Borean-Tundra",
["Dentarg"] = "Dentarg",
["Auchindoun"] = "Auchindoun",
["Chromaggus"] = "Chromaggus",
["Anub'arak"] = "Anubarak",
["Feathermoon"] = "Feathermoon",
["Ysondre"] = "Ysondre",
["Garithos"] = "Garithos",
["Fenris"] = "Fenris",
["Maelstrom"] = "Maelstrom",
["Dethecus"] = "Dethecus",
["TheVentureCo"] = "The-Venture-Co",
["Zuluhed"] = "Zuluhed",
["TheScryers"] = "The-Scryers",
["Andorhal"] = "Andorhal",
["Lightninghoof"] = "Lightninghoof",
["Anetheron"] = "Anetheron",
["SistersofElune"] = "Sisters-of-Elune",
["Kalecgos"] = "Kalecgos",
["Terokkar"] = "Terokkar",
["Shadowmoon"] = "Shadowmoon",
["Drak'Tharon"] = "DrakTharon",
["Haomarush"] = "Haomarush",
["Scilla"] = "Scilla",
["Farstriders"] = "Farstriders",
["SteamwheedleCartel"] = "Steamwheedle-Cartel",
["EchoIsles"] = "Echo-Isles",
["BlackwingLair"] = "Blackwing-Lair",
["Tortheldrin"] = "Tortheldrin",
}