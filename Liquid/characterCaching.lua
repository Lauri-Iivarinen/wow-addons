local _, ns = ...
ns.isLegitChar = false
local sformat, SendAddonMessage, CopyTable = string.format, C_ChatInfo.SendAddonMessage, CopyTable
ns.characterCaching = {}
local db
--[[
	LiquidCharDB.charData -- gear etc data
	LiquidCharDB.oldGuid -- guid for old character with same name, so we can delete it in server (faction/race change)
	LiquidCharDB.raids -- raids that you have been a part of
	LiquidCharDB.items -- seen items
]]
local difIDToIndicator = {
	[16] = "M",
	[15] = "H",
	[14] = "N",
	[17] = "L",
}
local diffPrio = {
	[14] = 2, -- Normal
	[15] = 3, -- Heroic
	[16] = 4, -- Mythic
	[17] = 1, -- LFR
}
local function loadCharDefaults()
	if LiquidDB.tradeableSlots and LiquidDB.tradeableSlots[ns.playerGUID] then -- TODO remove at some point, this db isn't being updated anymore
		local old = LiquidDB.tradeableSlots[ns.playerGUID]
		db.charData = {
			name = UnitName('player'),
			server = GetRealmName(),
			class = ns.playerClass,
			maxilvl = old.maxilvl,
			level = UnitLevel('player'),
			gear = {  -- TODO remove with db3 clean up
				Head = old.history.Head,
				Neck = old.history.Neck,
				Shoulders = old.history.Shoulders,
				Cloak = old.history.Cloak,
				Chest = old.history.Chest,
				Wrists = old.history.Wrists,
				Hands = old.history.Hands,
				Belt = old.history.Belt,
				Legs = old.history.Legs,
				Boots = old.history.Boots,
				Ring = old.history.Ring,
				Ring2 = old.history.Ring2,
				Trinket = old.history.Trinket,
				Trinket2 = old.history.Trinket2,
				Weapon2H = old.history.Weapon2H,
				MainHand = old.history.MainHand,
				OffHand = old.history.OffHand,
			},
			updated = old.updated,
			tierSlots = CopyTable(old.tierSlots), -- TODO remove with db3 clean up
			currency = CopyTable(old.currency),
			faction = UnitFactionGroup('player'),
			guid = ns.playerGUID,
			simc = {},
		}
	else
		db.charData = {
			name = UnitName('player'),
			server = GetRealmName(),
			class = ns.playerClass,
			maxilvl = 0,
			level = UnitLevel('player'),
			gear = {  -- TODO remove with db3 clean up
				Head = 0,
				Neck = 0,
				Shoulders = 0,
				Cloak = 0,
				Chest = 0,
				Wrists = 0,
				Hands = 0,
				Belt = 0,
				Legs = 0,
				Boots = 0,
				Ring = 0,
				Ring2 = 0,
				Trinket = 0,
				Trinket2 = 0,
				Weapon2H = 0,
				MainHand = 0,
				OffHand = 0,
			},
			updated = 0,
			tierSlots = { 0, 0, 0, 0, 0, 0, 0, 0 }, -- TODO remove with db3 clean up
			currency = { 0, 0, 0, 0, 0 },
			faction = UnitFactionGroup('player'),
			guid = ns.playerGUID,
		}
	end
end
local function loadRaidDefaults()
	db.raids = {}
end
local function loadItemDefaults()
	db.items = {}
end
function ns.characterCaching:SetupCharacter() -- setup new char and/or migrate from account wide DB to charDB
	db = LiquidCharDB
	if UnitLevel('player') < ns.cacheConfigs.minLevel then
		ns:LoadEvents(true) -- load cooldown events only
		return
	end
	local realm = GetRealmName()
	if realm:lower():match("mythic dungeons") or realm:lower():match("arena champions") then
		ns:LoadEvents(true) -- load cooldown events only
		return
	end
	db = LiquidCharDB
	if not db.raidLockouts then
		db.raidLockouts = {}
	end
	db.region = GetCurrentRegion()
	db.dbVersion = ns.cacheConfigs.dbVersion
	ns.isLegitChar = true
	ns:LoadEvents()
	local isNewOrChanged = false
	if not db.charData then
		loadCharDefaults()
		isNewOrChanged = true
	elseif db.charData.guid ~= ns.playerGUID then -- TODO do something else too?
		loadCharDefaults()
		isNewOrChanged = true
	else
		if not db.charData.simc then
			db.charData.simc = {}
		end
	end
	db.charData.faction = UnitFactionGroup('player')
	db.charData.name = UnitName('player')

	ns.addToWeeklyReset("characterCaching", function(resetTime)
		db.raidLockouts = {}
		db.vaultItems = nil
		ns.PrintDebug(">>> Reseting db.raidLockouts & db.vaultItems - Currently in loading screen: %s<<<", ns
		.InLoadingScreen)
	end)
	db.oldGuid = db.charData.guid
	if not db.charData.gear then -- fix for earlier bug, remove at some point
		db.charData.gear = {  -- TODO remove with db3 clean up
			Head = 0,
			Neck = 0,
			Shoulders = 0,
			Cloak = 0,
			Chest = 0,
			Wrists = 0,
			Hands = 0,
			Belt = 0,
			Legs = 0,
			Boots = 0,
			Ring = 0,
			Ring2 = 0,
			Trinket = 0,
			Trinket2 = 0,
			Weapon2H = 0,
			MainHand = 0,
			OffHand = 0,
		}
	end
	if not db.votes then
		db.votes = {}
	end
	if db.version then
		if db.version.major == 2 then
			if db.version.minor <= 11 and db.version.patch < 5 then -- add killId and itemInfo to items
				for itemGuid, v in pairs(db.items) do
					if v.source and v.source.killKey then
						if db.raids[v.source.encounterID] and db.raids[v.source.encounterID].kills[v.source.killKey] then
							local kill = db.raids[v.source.encounterID].kills[v.source.killKey]
							v.source.killId = kill.killId
							v.itemInfo = {
								ItemLevel = kill.itemsFound[itemGuid].itemLevel or 0,
								Tertiary = kill.itemsFound[itemGuid].tertiary or "",
								ItemId = kill.itemsFound[itemGuid].itemID or 0
							}
						end
					end
				end
			end
			if db.version.minor <= 11 and db.version.patch < 7 then -- reset currency and tier
				db.charData.currency = {}
				db.charData.tierSlots = { 0, 0, 0, 0, 0, 0, 0, 0 } -- TODO remove with db3 clean up
			end
			if db.version.minor < 25 then
				if LiquidCharDB and LiquidCharDB.charData and LiquidCharDB.charData.maxilvl then
					print("Liquid: ilvl cache reseted, please stay online for 20 seconds")
					LiquidCharDB.charData.maxilvl = 0
					-- Clean up currency and tier at the same version
					db.charData.currency = {}
					db.charData.tierSlots = { 0, 0, 0, 0, 0, 0, 0, 0 } -- TODO remove with db3 clean up
				end
			end
		end
	end
	if isNewOrChanged then
		loadRaidDefaults()
		loadItemDefaults()
	else -- clean up DB
		-- TODO actually clean up db based on timestamps from the server (use 3d timer for now)
		local tooOld = GetServerTime() - ns.cacheConfigs.raidDataPreserveTime
		local toDelete = {}
		for eID, eData in pairs(db.raids) do
			for timestamp, d in pairs(eData.kills) do
				if timestamp < tooOld then
					toDelete[timestamp] = eID
				end
			end
		end
		for k, v in pairs(toDelete) do
			if db.raids[v].kills[k] then
				db.raids[v].kills[k] = nil
			end
		end
		-- just clean up db on each login, cba to tie them to addon versions
		toDelete = {}
		for k, v in pairs(db.charData.simc) do
			if tonumber(k) then
				if not ns.cacheConfigs.simc.encounters[tonumber(k)] then
					toDelete[k] = true
				end
			end
		end
		for k, v in pairs(toDelete) do
			db.charData.simc[k] = nil
		end
	end
	db.version = ns.version
	db.charData.currency[10] = ns.version.str
	RequestRaidInfo()
	-- do some clean up that crashed horse when players opened vault on 11/02/25 TODO remove at later date
	if db.vaultItems then
		for k, v in pairs(db.vaultItems) do
			if not v.ilvl then
				db.vaultItems = nil
				break
			end
		end
	end
end

local shouldCacheAfterCombat
----------------------
--Gear-Caching
----------------------
do
	local setItemIDs = {}
	for setID in pairs(ns.cacheConfigs.gear.tierSets) do
		local allItems = C_LootJournal.GetItemSetItems(setID)
		if allItems then
			for _, itemData in pairs(allItems) do
				setItemIDs[itemData.itemID] = setID
			end
		end
	end
	local convertSlotIdToSlotNameForDB = {
		[INVSLOT_HEAD] = "Head",
		[INVSLOT_NECK] = "Neck",
		[INVSLOT_SHOULDER] = "Shoulders",
		[INVSLOT_CHEST] = "Chest",
		[INVSLOT_WAIST] = "Belt",
		[INVSLOT_LEGS] = "Legs",
		[INVSLOT_FEET] = "Boots",
		[INVSLOT_WRIST] = "Wrists",
		[INVSLOT_HAND] = "Hands",
		[INVSLOT_FINGER1] = "Ring",
		[INVSLOT_FINGER2] = "Ring2",
		[INVSLOT_TRINKET1] = "Trinket",
		[INVSLOT_TRINKET2] = "Trinket2",
		[INVSLOT_BACK] = "Cloak",
		[INVSLOT_MAINHAND] = "MainHand",
		[INVSLOT_OFFHAND] = "OffHand",
	}
	local function handleItemOnLoad(item, target, itemLink, instantItemData)
		-- only care about epic items
		if item:GetItemQuality() ~= Enum.ItemQuality.Epic then return end
		local itemLevel = item:GetCurrentItemLevel()
		if target ~= "equipment" and itemLevel < ns.cacheConfigs.gear.itemLevelRequirementForCaching then return end
		if target == "warbank" then
			if not C_Item.IsBoundToAccountUntilEquip(item:GetItemLocation()) then return end
			db.lastWarbankUpdate = GetServerTime()
			db.warbank[item:GetItemGUID()] = {
				il = itemLink,
				iloc = instantItemData[4] or "",
				id = instantItemData[1],
				ilvl = item:GetCurrentItemLevel(),
				iT = instantItemData[6],
				iST = instantItemData[7],
			}
			return
		end
		if target == "bank" then
			local warbound = C_Item.IsBoundToAccountUntilEquip(item:GetItemLocation())
			if not (warbound or (C_Item.IsBound(item:GetItemLocation()) and not ns.tradeCheck(item:GetItemGUID()))) then return end
			db.bank[item:GetItemGUID()] = {
				il = itemLink,
				iloc = instantItemData[4] or "",
				id = instantItemData[1],
				ilvl = item:GetCurrentItemLevel(),
				tier = setItemIDs[instantItemData[1]],
				wb = warbound,
				iT = instantItemData[6],
				iST = instantItemData[7],
			}
			return
		end
		if target == "equipment" then
			local slot = itemLink
			local itemlevel = item:GetCurrentItemLevel()
			local itemID, _, _, equipLoc, _, itemTypeID, itemSubTypeID = C_Item.GetItemInfoInstant(item:GetItemID())
			do
				local ilvl = select(2, GetAverageItemLevel())
				if not db.charData.maxilvl or ilvl > db.charData.maxilvl then
					db.charData.maxilvl = ilvl
				end
			end
			db.currentGear[slot] = { -- itemlink == slot
				il = item:GetItemLink(),
				iloc = equipLoc or "",
				id = itemID,
				ilvl = itemLevel,
				tier = setItemIDs[itemID],
				g = item:GetItemGUID(),
				iT = itemTypeID,
				iST = itemSubTypeID,
			}
			local itemType = item:GetInventoryType() -- used for highest ilvl caching
			if slot == INVSLOT_MAINHAND then  -- TODO remove with db3 clean up
				local _type = itemType == Enum.InventoryType.Index2HweaponType and "Weapon2H" or "MainHand"
				if not db.charData.gear[_type] or db.charData.gear[_type] < itemLevel then
					db.charData.gear[_type] = itemLevel
					print(sformat("Liquid: Updated ilvl (%d) for %s", itemLevel, _type))
				end
				return
			end
			if slot == INVSLOT_OFFHAND then
				--[[
				local offhandType = "Offhand"
				if itemType == Enum.InventoryType.Index2HweaponType or itemType == Enum.InventoryType.IndexWeaponType or itemType == Enum.InventoryType.IndexWeaponoffhandType then
					offhandType = "Weapon"
        elseif itemType == Enum.InventoryType.IndexShieldType then
          offhandType = "Shield"
				end
				--]]
				if not db.charData.gear.OffHand or db.charData.gear.OffHand < itemlevel then
					db.charData.gear.OffHand = itemlevel
					print(sformat("Liquid: Updated ilvl (%d) for offhand", itemlevel))
				end
				return
			end
			-- slot ~= weapon slots
			if not db.charData.gear[convertSlotIdToSlotNameForDB[slot]] or db.charData.gear[convertSlotIdToSlotNameForDB[slot]] < itemlevel then  -- TODO remove with db3 clean up
				db.charData.gear[convertSlotIdToSlotNameForDB[slot]] = itemlevel
				print(sformat("Liquid: Updated ilvl (%d) for slot: %s", itemlevel, convertSlotIdToSlotNameForDB[slot]))
				return
			end
			return
		end
		-- bags
		local warbound = C_Item.IsBoundToAccountUntilEquip(item:GetItemLocation())
		if not (warbound or (C_Item.IsBound(item:GetItemLocation()) and not ns.tradeCheck(item:GetItemGUID()))) then return end
		db.bagItems[item:GetItemGUID()] = {
			il = itemLink,
			iloc = instantItemData[4] or "",
			id = instantItemData[1],
			ilvl = item:GetCurrentItemLevel(),
			tier = setItemIDs[instantItemData[1]],
			wb = warbound,
			iT = instantItemData[6],
			iST = instantItemData[7],
		}
	end
	function ns.characterCaching:PLAYER_EQUIPMENT_CHANGED(slot, isEmpty)
		if not db.charData then return end
		if not db.currentGear then
			db.currentGear = {}
		end
		if isEmpty then
			db.currentGear[slot] = nil
			return
		else
			local item = Item:CreateFromEquipmentSlot(slot)
			if item:IsItemEmpty() then
				db.currentGear[slot] = nil
				return
			end
			item:ContinueOnItemLoad(function() handleItemOnLoad(item, "equipment", slot) end)
		end
		ns.characterCaching.cacheCrestDiscounts()
	end

	function ns.characterCaching:BANKFRAME_OPENED()
		db.charData.warbank = nil         -- TODO remove
		db.charData.lastWarbankUpdate = nil -- TODO remove
		if C_Bank.CanViewBank(Enum.BankType.Account) then
			db.warbank = {}                 -- just clean it and add everything again, easiest way to deal with it
			for _, bagID in pairs({ Enum.BagIndex.AccountBankTab_1, Enum.BagIndex.AccountBankTab_2, Enum.BagIndex.AccountBankTab_3, Enum.BagIndex.AccountBankTab_4, Enum.BagIndex.AccountBankTab_5 }) do
				for invID = 1, C_Container.GetContainerNumSlots(bagID) do
					-- this is faster than creating item
					local itemLink = C_Container.GetContainerItemLink(bagID, invID)
					if itemLink then
						local instantItemData = { C_Item.GetItemInfoInstant(itemLink) }
						if instantItemData[6] == Enum.ItemClass.Weapon or instantItemData[6] == Enum.ItemClass.Armor then
							local item = Item:CreateFromBagAndSlot(bagID, invID)
							if not item:IsItemEmpty() then
								item:ContinueOnItemLoad(function() handleItemOnLoad(item, "warbank", itemLink, instantItemData) end)
							end
						end
					end
				end
			end
		end
		if C_Bank.CanViewBank(Enum.BankType.Character) then
			db.bank = {}
			for _, bagID in pairs({ Enum.BagIndex.Bank, Enum.BagIndex.BankBag_1, Enum.BagIndex.BankBag_2, Enum.BagIndex.BankBag_3, Enum.BagIndex.BankBag_4, Enum.BagIndex.BankBag_5, Enum.BagIndex.BankBag_6, Enum.BagIndex.BankBag_7 }) do
				for invID = 1, C_Container.GetContainerNumSlots(bagID) do
					-- this is faster than creating item
					local itemLink = C_Container.GetContainerItemLink(bagID, invID)
					if itemLink then
						local instantItemData = { C_Item.GetItemInfoInstant(itemLink) }
						if instantItemData[6] == Enum.ItemClass.Weapon or instantItemData[6] == Enum.ItemClass.Armor then
							local item = Item:CreateFromBagAndSlot(bagID, invID)
							if not item:IsItemEmpty() then
								item:ContinueOnItemLoad(function() handleItemOnLoad(item, "bank", itemLink, instantItemData) end)
							end
						end
					end
				end
			end
		end
	end

	local scanBagsAfterCombat = false
	function ns.characterCaching:BAG_UPDATE_DELAYED(...)
		if not db.charData then return end
		-- check sparks etc
		if InCombatLockdown() then
			scanBagsAfterCombat = true
			return
		end
		if ns.InLoadingScreen then
			ns.dealAfterLoadingScreen(ns.characterCaching.BAG_UPDATE_DELAYED)
			ns.PrintDebug("Adding 'ns.characterCaching.BAG_UPDATE_DELAYED' to ns.dealAfterLoadingScreen.")
			return
		end
		for _, v in pairs(ns.cacheConfigs.items) do
			v(db.charData.currency)
		end
		-- just reset, cba to try to look what items have changed
		db.bagItems = {}
		local startTime = debugprofilestop() -- debug
		for bagID = 0, 4 do
			for invID = 1, C_Container.GetContainerNumSlots(bagID) do
				-- this is faster than creating item
				local itemLink = C_Container.GetContainerItemLink(bagID, invID)
				if itemLink then
					local instantItemData = { C_Item.GetItemInfoInstant(itemLink) }
					if instantItemData[6] == Enum.ItemClass.Weapon or instantItemData[6] == Enum.ItemClass.Armor then
						local item = Item:CreateFromBagAndSlot(bagID, invID)
						if not item:IsItemEmpty() then
							item:ContinueOnItemLoad(function() handleItemOnLoad(item, "bags", itemLink, instantItemData) end)
						end
					end
				end
			end
		end
		-- in case we changed bank items, this function is checking if we can actually view bank or not
		ns.characterCaching:BANKFRAME_OPENED()
	end

	function ns.characterCaching:PLAYER_REGEN_ENABLED()
		if scanBagsAfterCombat then
			scanBagsAfterCombat = false
			ns.characterCaching:BAG_UPDATE_DELAYED()
		end
		if shouldCacheAfterCombat then
			ns.characterCaching:CacheSimc(shouldCacheAfterCombat[1], shouldCacheAfterCombat[2], shouldCacheAfterCombat[3])
		end
	end

	function ns.characterCaching:ScanAllEquippedItems()
		if not db.currentGear then
			db.currentGear = {}
		end
		if ns.InLoadingScreen then
			ns.dealAfterLoadingScreen(ns.characterCaching.ScanAllEquippedItems)
			ns.PrintDebug("Adding 'ns.characterCaching.ScanAllEquippedItems' to ns.dealAfterLoadingScreen.")
			return
		end
		for _, slot in pairs({ INVSLOT_HEAD, INVSLOT_NECK, INVSLOT_SHOULDER, INVSLOT_CHEST, INVSLOT_WAIST, INVSLOT_LEGS, INVSLOT_FEET, INVSLOT_WRIST, INVSLOT_HAND, INVSLOT_FINGER1, INVSLOT_FINGER2, INVSLOT_TRINKET1, INVSLOT_TRINKET2, INVSLOT_BACK, INVSLOT_MAINHAND, INVSLOT_OFFHAND }) do
			local item = Item:CreateFromEquipmentSlot(slot)
			if item:IsItemEmpty() then
				db.currentGear[slot] = nil
			else
				item:ContinueOnItemLoad(function() handleItemOnLoad(item, "equipment", slot) end)
			end
		end
		ns.characterCaching.cacheCrestDiscounts()
	end

	do
		local alreadyHookedWeeklyRewards = false
		local alreadyPicked = false
		local scanTime
		local function scanVault()
			if ns.InLoadingScreen then
				ns.PrintDebug(">>> tring to scan vault during loading screen - GetTime: %s <<<", GetTime())
				C_Timer.After(0.5, scanVault)
			end
			ns.PrintDebug(">>> scanVault - GetTime: %s - ns.InLoadingScreen: %s <<<", GetTime(), ns.InLoadingScreen)
			if C_WeeklyRewards then
				if not alreadyHookedWeeklyRewards then
					hooksecurefunc(C_WeeklyRewards, "ClaimReward", function(claimID)
						if db.vaultItems then
							local found = false
							for k, v in pairs(db.vaultItems) do
								if v.claimID == claimID then
									v.picked = true
									found = true
									break
								end
							end
							if not found then -- assume we picked currency
								table.insert(db.vaultItems, {
									il = "",
									iloc = "INVTYPE_NON_EQUIP_IGNORE",
									id = 1,
									ilvl = 0,
									picked = true,
									claimID = claimID
								})
							end
							alreadyPicked = true
						end
					end)
					alreadyHookedWeeklyRewards = true
				end
				if C_WeeklyRewards.HasAvailableRewards() and not alreadyPicked then
					db.vaultItems = {}
					db.lastWeeklyReset = C_DateAndTime.GetWeeklyResetStartTime() --TODO remove after confirming new reset shit works
					scanTime = C_DateAndTime.GetWeeklyResetStartTime()
					ns.PrintDebug(">>> RESETING VAULT ITEMS - GetTime: %s - db.lastWeeklyReset: %s - ns.InLoadingScreen: %s <<<",
						GetTime(), db.lastWeeklyReset, ns.InLoadingScreen)
					local activities = C_WeeklyRewards.GetActivities()
					for _, activityInfo in ipairs(activities) do
						for _, rewardInfo in ipairs(activityInfo.rewards) do
							local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(
							rewardInfo.id)
							if itemEquipLoc and itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" then
								local itemLink = C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID)
								local itemLevel, _, _ = C_Item.GetDetailedItemLevelInfo(itemLink)
								table.insert(db.vaultItems, {
									il = itemLink,
									iloc = itemEquipLoc or "",
									id = itemID,
									ilvl = itemLevel or 0,
									tier = setItemIDs[itemID],
									picked = false,
									claimID = activityInfo.claimID,
									iT = classID,
									iST = subClassID,
								})
							end
						end
					end
				end
			end
		end
		function ns.characterCaching:WEEKLY_REWARDS_UPDATE()
			ns.PrintDebug(">>> WEEKLY_REWARDS_UPDATE - GetTime: %s - ns.InLoadingScreen: %s <<<", GetTime(), ns
			.InLoadingScreen)
			C_Timer.After(0.5, scanVault) -- gives time to get item data
		end

		ns.addToWeeklyReset("WeeklyVault", function(resetTime)
			if scanTime and scanTime == resetTime then
				return
			end
			ns.PrintDebug("would reset vault data")
		end)
	end
end
local validLockoutDifIds = {
	[14] = true, -- Normal
	[15] = true, -- Heroic
	[16] = true, -- Mythic
}
do
	local scanTime
	function ns.characterCaching:UPDATE_INSTANCE_INFO()
		db.raidLockouts = {} -- reset old data everytime we loop through saved instances
		for i = 1, GetNumSavedInstances() do
			local difficultyId, locked, extended, _, isRaid, _, difficultyName, numEncounters, _, extendDisabled, instanceId =
			select(4, GetSavedInstanceInfo(i))
			if locked and isRaid and validLockoutDifIds[difficultyId] then
				for j = 1, numEncounters do
					local encounterName, _, isKilled, unknown4 = GetSavedInstanceEncounterInfo(i, j)
					if isKilled then
						if not db.raidLockouts[difficultyId] then
							db.raidLockouts[difficultyId] = {}
						end
						db.raidLockouts[difficultyId][encounterName] = true
					end
				end
			end
		end
		scanTime = C_DateAndTime.GetWeeklyResetStartTime()
		db.lastRaidReset = C_DateAndTime.GetWeeklyResetStartTime() --TODO remove after confirming new reset shit works
	end

	ns.addToWeeklyReset("WeeklyLockouts", function(resetTime)
		if scanTime and scanTime == resetTime then
			return
		end
		ns.PrintDebug("would reset lockout data")
		-- TODO actually reset data
	end)
end
--[[ currency slots in the addon:
1: sparks
2: mythic crest
3: heroic crest
4: mythic fragments total earned
5: heroic fragments total earned
6: normal crest
7: normal fragments total earned
8: dream warden renown
9:
10: version
]]

function ns.characterCaching:CURRENCY_DISPLAY_UPDATE(currencyType, quantity, quantityChange, quantityGainSource,
																										 destroyReason)
	ns.PrintDebug(
	"Currency - currencyType: %s - quantity: %s - quantityChange: %s - quantityGainSource: %s - destroyReason: %s",
		currencyType or "nil", quantity or "nil", quantityChange or "nil", quantityGainSource or "nil",
		destroyReason or "nil")
	if not db.charData then return end
	if not (ns.cacheConfigs.currency[currencyType]) then return end
	ns.cacheConfigs.currency[currencyType](db.charData.currency)
end

--PvP Rating
function ns:CheckRatings()
	if not db.charData then return end
	local highest = 0
	for _, i in pairs { 1, 2, 4 } do
		local r = GetPersonalRatedInfo(i)
		if r > highest then
			highest = r
		end
	end
	if db.charData.pvpRating ~= highest then
		--LiquidDB.tradeableSlots[ns.playerGUID].updated = GetServerTime()
		--LiquidDB.lastHistoryUpdate = GetServerTime()
		db.charData.pvpRating = highest
		--ns:AnnounceUpdate(ns.playerGUID, GetServerTime())
		print("Liquid: Highest pvp rating updated to:", highest)
	end
end

function ns.characterCaching:PVP_RATED_STATS_UPDATE(currencyType, quantity)
	ns:CheckRatings()
end

function ns.characterCaching:UPDATE_FACTION()
	if not db.charData then return end
	for k, v in pairs(ns.cacheConfigs.reputations) do
		v(db.charData.currency)
	end
end

function ns.characterCaching:PLAYER_LEAVING_WORLD(...)
	db.lastLogout = GetServerTime()
end

--C_GossipInfo.GetFriendshipReputation 2517 2518
----------------
--Simc-caching--
----------------
StaticPopupDialogs["LIQUID_SAVE_SIMC"] = {
	text = "Save your current set as...\n(press esc to cancel)",
	button1 = "Single",
	button2 = "2 target",
	button3 = "AOE",
	button4 = "Bubba special",
	selectCallbackByIndex = true,
	OnButton1 = function(self)
		ns.characterCaching:CacheSimc("Manual (single)", "single")
	end,
	OnButton2 = function(self)
		ns.characterCaching:CacheSimc("Manual (2target)", "2target")
	end,
	OnButton3 = function(self)
		ns.characterCaching:CacheSimc("Manual (AOE)", "AOE")
	end,
	OnButton4 = function(self)
		ns.characterCaching:CacheSimc("Manual (bubbareq)", "bubbareq")
	end,
	hideOnEscape = true,
}
--/script StaticPopup_Show("LIQUID_SAVE_SIMC")
do
	local simcAddon
	function ns.characterCaching:CacheSimc(note, dbKey, prio)
		if ns.isTestRealm then return end
		if not dbKey then return print("Liquid addon error: no db key provided for simc export") end
		if InCombatLockdown() then
			shouldCacheAfterCombat = { note, dbKey, prio }
			return
		end
		if ns.InLoadingScreen then
			ns.dealAfterLoadingScreen(function()
				ns.characterCaching:CacheSimc(note, dbKey, prio)
			end)
			ns.PrintDebug(
			"Adding 'ns.characterCaching.CacheSimc' to ns.dealAfterLoadingScreen. note: %s - dbKey: %s - prio: %s",
				note or "nil", dbKey or "nil", prio or "nil")
			return
		end
		if shouldCacheAfterCombat then
			shouldCacheAfterCombat = false
		end
		if not ns.isLegitChar then
			if note:find("Manual") then
				StaticPopup_Show("LIQUID_WARNING_1", "Error: Current character is not considered legit character.")
			end
			return
		end
		local specName = select(2, GetSpecializationInfo(GetSpecialization()))
		if not specName then
			C_Timer.After(2, function()
				ns.characterCaching:CacheSimc(note, dbKey, prio)
			end)
			print("Liquid: Specialization is nil, trying to cache simc again in 2 seconds.")
			return
		end
		if not simcAddon then
			local ace3addon = LibStub("AceAddon-3.0", true)
			if ace3addon then
				simcAddon = ace3addon:GetAddon("Simulationcraft", true)
			end
			if not simcAddon then
				print("Liquid: ENABLE SimulationCraft addon")
				return
			end
		end
		local simcStr = simcAddon:GetSimcProfile(nil, true)
		if not simcStr then
			print("Liquid: Error, simcStr not found. >> REPORT TO IRONI <<")
			return
		end
		if not db.charData.simc then
			db.charData.simc = {}
		end
		local startingPoint = simcStr:find("### Additional Character Info")
		if startingPoint then
			simcStr = simcStr:sub(1, startingPoint)
		end
		local _date = C_DateAndTime.GetCurrentCalendarTime()
		simcStr = string.format("# %s %s-%02d-%s %02d:%02d %s\n%s", note, _date.year, _date.month, _date.monthDay, _date
		.hour, _date.minute, select(2, GetSpecializationInfo(GetSpecialization())), simcStr)
		db.charData.simc[dbKey] = {
			str = simcStr,
			dbKey = dbKey,
			timestamp = GetServerTime(),
			prio = prio
		}
		if note:find("Manual") then
			print(sformat('Liquid: Saved current set to addon as "%s" set.', dbKey))
		end
	end

	function ns.characterCaching:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
		--if success ~= 1 then return end
		-- highest kill
		if success == 1 then
			if ns.cacheConfigs.highestKill.orders[encounterID] then
				local current = ns.cacheConfigs.highestKill.getCurrent(db.charData.currency) or ""
				local dif, currentOrder = current:match("^(%a)(%d+)$")
				currentOrder = tonumber(currentOrder)
				local currentDif = (dif == "M" and 16) or (dif == "H" and 15) or (dif == "N" and 14) or (dif == "L" and 17)
				if (not (dif and currentOrder)) or (currentDif and ((diffPrio[difficultyID] > diffPrio[currentDif]) or (diffPrio[difficultyID] == diffPrio[currentDif] and ns.cacheConfigs.highestKill.orders[encounterID] > currentOrder))) then
					ns.cacheConfigs.highestKill.setFunc(db.charData.currency,
						string.format("%s%s", difIDToIndicator[difficultyID], ns.cacheConfigs.highestKill.orders[encounterID]))
				end
			end
		end
		-- lockouts
		if success == 1 and validLockoutDifIds[difficultyID] then
			-- TODO remove at db3 cleanup
			if C_DateAndTime.GetWeeklyResetStartTime() > (db.lastRaidReset or 0) then -- don't have time to proof check how we can actually handle when we are going to raid in the same session when reset is happening
				db.raidLockouts = {}
			end
			if not db.raidLockouts[difficultyID] then
				db.raidLockouts[difficultyID] = {}
			end
			db.raidLockouts[difficultyID][encounterName] = true
			db.lastRaidReset = C_DateAndTime.GetWeeklyResetStartTime() -- TODO remove with db3 cleanup
		end
		--simc stuff
		if ns.isTestRealm then return end
		if not ns.cacheConfigs.simc.encounters[encounterID] then return end
		local prio = diffPrio[difficultyID] or 0
		if db.charData.simc and db.charData.simc[encounterID] and db.charData.simc[encounterID].prio and db.charData.simc[encounterID].prio < prio then -- maybe change this behavior later on?
			return
		end
		ns.characterCaching:CacheSimc(
		sformat("%s (%s) %s - %s", encounterName, encounterID, GetDifficultyInfo(difficultyID),
			success == 1 and "Kill" or "Wipe"), tostring(encounterID), prio)
	end
end
do
	local professions = {
		[171] = { -- Alchemy
			current = 423321,
			skillLineVariantID = 2871,
			shortName = "Alch"
		},
		[164] = { -- Blacksmithing
			current = 423332,
			skillLineVariantID = 2872,
			shortName = "BS"
		},
		[333] = { -- Enchanting
			current = 423334,
			skillLineVariantID = 2874,
			shortName = "Ench"
		},
		[202] = { -- Engineering
			current = 423335,
			skillLineVariantID = 2875,
			shortName = "Eng"
		},
		[182] = { -- Herbalism
			current = 441327,
			skillLineVariantID = 2877,
			shortName = "Herb"
		},
		[773] = { -- Inscription
			current = 423338,
			skillLineVariantID = 2878,
			shortName = "Insc"
		},
		[755] = { -- Jewelcrafting
			current = 423339,
			skillLineVariantID = 2879,
			shortName = "JC"
		},
		[165] = { -- Leatherworking
			current = 423340,
			skillLineVariantID = 2880,
			shortName = "LW"
		},
		[186] = { -- Mining
			current = 423341,
			skillLineVariantID = 2881,
			shortName = "Min"
		},
		[393] = { -- Skinning
			current = 423342,
			skillLineVariantID = 2882,
			shortName = "Skin"
		},
		[197] = { -- Tailoring
			current = 423343,
			skillLineVariantID = 2883,
			shortName = "Tail"
		},
	}
	function ns.characterCaching:CacheProfessions()
		local profession1, profession2 = GetProfessions()
		local temp = {}
		for _, profID in pairs({ profession1 or 0, profession2 or 0 }) do
			local added = false
			if profID then
				local _, _, skillLevel, _, _, _, skillLineID = GetProfessionInfo(profID)
				if skillLineID and professions[skillLineID] and IsPlayerSpell(professions[skillLineID].current) then
					local configID = C_ProfSpecs.GetConfigIDForSkillLine(professions[skillLineID].skillLineVariantID)
					local knowledgeSpent = 0
					local currencyInfo = C_ProfSpecs.GetCurrencyInfoForSkillLine(skillLineID)
					local unspentKnowledge = currencyInfo and currencyInfo.numAvailable or 0
					if configID and configID > 0 then
						local configInfo = C_Traits.GetConfigInfo(configID)
						if configInfo then
							local treeIDs = configInfo.treeIDs
							if treeIDs then
								for _, treeID in pairs(treeIDs) do
									local treeNodes = C_Traits.GetTreeNodes(treeID)
									if treeNodes then
										for _, treeNode in pairs(treeNodes) do
											local nodeInfo = C_Traits.GetNodeInfo(configID, treeNode)
											if nodeInfo then
												--characterProfession.knowledgeLevel = nodeInfo.ranksPurchased > 1 and characterProfession.knowledgeLevel + (nodeInfo.currentRank - 1) or characterProfession.knowledgeLevel
												if nodeInfo.ranksPurchased > 1 then
													knowledgeSpent = knowledgeSpent + (nodeInfo.currentRank - 1)
												end
											end
										end
									end
								end
							end
						end
						added = true
						table.insert(temp,
							sformat("%s:%s:%s:%s", professions[skillLineID].shortName, skillLevel, knowledgeSpent, unspentKnowledge))
					end
				end
			end
			if not added then
				table.insert(temp, "NONE:0:0:0")
			end
		end
		ns.cacheConfigs.professions(db.charData.currency, table.concat(temp, ";"))
	end

	function ns.characterCaching:TRAIT_CONFIG_UPDATED(configID)
		if not configID then return end
		local configInfo = C_Traits.GetConfigInfo(configID)
		if not configInfo then return end
		if configInfo.type == Enum.TraitConfigType.Profession then
			ns.characterCaching:CacheProfessions()
		end
	end
end

do -- Highest kill data
	function ns.characterCaching.fetchHighestKill()
		for _, v in ipairs(ns.cacheConfigs.highestKill.statistics) do
			local count = GetStatistic(v.statisticID)
			---@diagnostic disable-next-line: cast-local-type
			count = tonumber(count)
			if count then
				ns.cacheConfigs.highestKill.setFunc(db.charData and db.charData.currency or {},
					string.format("%s%s", difIDToIndicator[v.dif], ns.cacheConfigs.highestKill.orders[v.encounterID]))
				return
			end
		end
		ns.cacheConfigs.highestKill.setFunc(db.charData and db.charData.currency or {}, "N/A")
	end
end

do -- Dungeon data
	--[[
C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid) -> level == dif id
C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World) -> level == delve tier
]]
	function ns.characterCaching:CHALLENGE_MODE_MAPS_UPDATE(...)
		local t = C_MythicPlus.GetRunHistory(false, true)
		local count = 0
		for _, v in pairs(t) do
			if v.level >= ns.cacheConfigs.minMythicPlus then
				count = count + 1
			end
		end
		ns.PrintDebug("CHALLENGE_MODE_MAPS_UPDATE - total run count %s - filtered: %s", #t, count)
		db.dungeonsDone = count
	end

	ns.addToWeeklyReset("ResetDungeonCounter", function(resetTime)
		ns.PrintDebug("would reset dungeon counter")
		-- TODO actually reset counter
	end)
end

function ns.characterCaching.cacheCrestDiscounts()
	if ns.InLoadingScreen then
		ns.dealAfterLoadingScreen(ns.characterCaching.cacheCrestDiscounts)
		ns.PrintDebug("Adding 'ns.characterCaching.cacheCrestDiscounts' to ns.dealAfterLoadingScreen.")
		return
	end
	db.crestDiscounts = {}
	for slotName, slot in pairs(Enum.ItemRedundancySlot) do
		local crestDiscountItemLevel, valorstoneDiscountItemLevel = C_ItemUpgrade.GetHighWatermarkForSlot(slot)
		db.crestDiscounts[slotName] = crestDiscountItemLevel
	end
end
