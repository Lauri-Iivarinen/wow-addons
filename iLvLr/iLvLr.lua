-- Title: iLvLr
-- Author: JerichoHM / LownIgnitus
-- Version: 2.4.4
-- Desc: iLvL identifier

--Version Information
local iLvLr = {}
local addon = iLvLr
local ADDON_NAME = "iLvLr"
local Title = "|cff00ff00iLvLr|r"
local Core = "|cffFF45002|r"
local Revision = "|cffFF45004|r"
local Build = "|cffFF45002|r"
SLASH_ILVLR1, SLASH_ILVLR2 = '/ilvlr', '/iLvLr'

local frameDB = {CharacterHeadSlot,
					CharacterNeckSlot,
					CharacterShoulderSlot,
					CharacterBackSlot,
					CharacterChestSlot,
					CharacterWristSlot,
					CharacterShirtSlot,
					CharacterTabardSlot,
					CharacterMainHandSlot,
					CharacterSecondaryHandSlot,
					CharacterHandsSlot,
					CharacterWaistSlot,
					CharacterLegsSlot,
					CharacterFeetSlot,
					CharacterFinger0Slot,
					CharacterFinger1Slot,
					CharacterTrinket0Slot,
					CharacterTrinket1Slot
				}

local slotDB = {"HeadSlot",
					"NeckSlot",
					"ShoulderSlot",
					"BackSlot",
					"ChestSlot",
					"WristSlot",
					"ShirtSlot",
					"TabardSlot",
					"MainHandSlot",
					"SecondaryHandSlot",
					"HandsSlot",
					"WaistSlot",
					"LegsSlot",
					"FeetSlot",
					"Finger0Slot",
					"Finger1Slot",
					"Trinket0Slot",
					"Trinket1Slot"
				}

local isEnchantable = {"ShoulderSlot",
					"BackSlot",
					"ChestSlot",
					"MainHandSlot",
					"SecondaryHandSlot",
					"LegsSlot",
					"FeetSlot"
					}

local isEnchantableWoD = {"NeckSlot",
							"ShoulderSlot",
							"BackSlot",
							"HandsSlot",
							"MainHandSlot",
							"Finger0Slot",
							"Finger1Slot"
							}

local isEnchantableBfA = {"HandsSlot",
							"MainHandSlot",
							"SecondaryHandSlot",
							"Finger0Slot",
							"Finger1Slot"
							}

local isEnchantableSL = {"BackSlot",
							"ChestSlot",
							"WristSlot",
							"MainHandSlot",
							"HandsSlot",
							"FeetSlot",
							"Finger0Slot",
							"Finger1Slot"
							}

local dualWield = {251, -- Frost DK
					577, -- Havoc
					581, -- Vengeance
					103, -- Feral
					268, -- Brewmaster
					296, -- Windwalker
					259, -- Assassination
					260, -- Outlaw
					261, -- Subtlety
					263, -- Enhancement
					72, -- Fury
					}

local iLevelFilter = "^" .. gsub(ITEM_LEVEL, "%%d", "(%%d+)")
local iEqAvg, iAvg

local z            = 0
local iLvlFrames   = {}
local iLvlAR1Frame = {}
local iLvlAR2Frame = {}
local iLvlAR3Frame = {}
local iDuraFrames  = {}
local iModFrames   = {}

local iLvLrReportFrame = CreateFrame("Frame", "iLvLrInspecFrame")
iLvLrReportFrame:ClearAllPoints()
iLvLrReportFrame:SetHeight(300)
iLvLrReportFrame:SetWidth(1000)
iLvLrReportFrame.text = iLvLrReportFrame:CreateFontString(nil, "BACKGROUND", "PVPInfoTextFont")
iLvLrReportFrame.text:SetAllPoints()
iLvLrReportFrame.text:SetTextHeight(13)
iLvLrReportFrame:SetAlpha(1)

function iLvLrVariableCheck()
	if iDuraState == nil then
		iDuraState = true
	elseif iDuraState == "enabled" or iDuraState == "disabled" then
		if iDuraState == "enabled" then
			iDuraState = true
		elseif iDuraState == "disabled" then
			iDuraState = false
		end
	else
		-- do nothing
	end

	if iDuraState == false then
		iDuraToggle(iDuraState)
	end

	if iColourState == nil then
		iColourState = true
	elseif iColourState == "enabled" or iColourState == "disabled" then 
		if iColourState == "enabled" then
			iColourState = true
		elseif  iColourState == "disabled" then
			iColourState = false
		end
	else
	-- do nothing
	end

	if iRelicState == nil then
		iRelicState = true
	elseif iRelicState == "enabled" or iRelicState == "disabled" then 
		if iRelicState == "enabled" then
			iRelicState = true
		elseif  iRelicState == "disabled" then
			iRelicState = false
		end
	else
		-- do nothing
	end
end

addon.f = CreateFrame("Frame", "iLvLrmain", CharacterFrame, "BackdropTemplate")
addon.f:SetScript("OnShow", function(self)
	--print("ILvLrOnLoad call @showpaperdoll")
	iLvLrOnLoad()
end)
				
function iLvLrMain()
	iLvLrFrame = CreateFrame("Frame", "iLvLrFrame", UIParent)
	iLvLrFrame:RegisterEvent("ADDON_LOADED")
	iLvLrFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	iLvLrFrame:RegisterEvent("SOCKET_INFO_UPDATE")
	iLvLrFrame:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
	iLvLrFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	iLvLrFrame:SetScript("OnEvent", iLvLrOnEvent)
end

function SlashCmdList.ILVLR(msg)
	if msg == "durability" then
		if iDuraState == true then
			iDuraState = false
			iDuraToggle(iDuraState)
			print("Durability turned |cffff0000off|r!")
		elseif iDuraState == false then
			iDuraState = true
			iDuraToggle(iDuraState)
			print("Durability turned |cff00ff00on|r!")
		end
	elseif msg == "colour" then
		if iColourState == true then
			iColourState = false
			print("ilvl colour turned |cffff0000off|r!")
		elseif iColourState == false then
			iColourState = true
			print("ilvl colour turned |cff00ff00on|r!")
		end
	else
		print("Thank you for using " .. Title)
		print("Version: " .. Core .. "." .. Revision .. "." .. Build)
		print("Author: |cffffcc00JerichoHM|r / Maintainer: |cffDA70D6LownIgnitus|r")
		print("Slash Commands are listed below and start with /iLvLr")
		print("      durability - Disables or Enables the durability tracker")
		print("      colour - Disables colouring ilvl by +/- avg")
	end
end

--Thanks to John454ss for code help
function iLvLrOnEvent(self, event, what)
	if event == "ADDON_LOADED" then
		iLvLrVariableCheck()
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
--		print("Talent Change.")
		mainSave = 0
		offSave  = 0
--		print("Saves cleared.")
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		iLvLrFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
		iLvLrFrame:RegisterEvent("BAG_UPDATE_DELAYED")
	elseif event == "BAG_UPDATE_DELAYED" then
		iLvLrFrame:UnregisterEvent("BAG_UPDATE_DELAYED")
		if not InCombatLockdown() then
			--print("Equipment Update")
			iLvLrOnItemUpdate()
			iLvLrOnDuraUpdate()
			iLvLrOnModUpdate()
			iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		else
			iLvLrFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		--print("Equipment Update")
		iLvLrFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		iLvLrOnItemUpdate()
		iLvLrOnModUpdate()
		iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	elseif event == "SOCKET_INFO_UPDATE" or event == "ITEM_UPGRADE_MASTER_UPDATE" then
		--print("Gem Change/Upgrade Update")
		iLvLrOnItemUpdate()
		iLvLrOnModUpdate()
	elseif event == "UPDATE_INVENTORY_DURABILITY" then
		--print("Durability Update")
		iLvLrOnDuraUpdate()
	end
end

function iLvLrOnLoad()
	--print("in OnLoad")
	for k ,v in pairs(slotDB) do
		--print("k: " .. k .. ", v: " .. v)
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeIlvl(frameDB[k], v)
				makeDurability(frameDB[k], v)
				makeMod(frameDB[k], v)
			end
		end
	end
end

function iLvLrOnItemUpdate()
	--print("in OnItemUpdate")
	for k ,v in pairs(slotDB) do
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeIlvl(frameDB[k], v)
				makeDurability(frameDB[k], v)
				makeMod(frameDB[k], v)
			end
		else
			if iLvlFrames[v] then
				iLvlFrames[v]:Hide()
			end
			if iDuraFrames[v] then
				iDuraFrames[v]:Hide()
			end
			if iModFrames[v] then
				iModFrames[v]:Hide()
			end
		end
	end
end

function iLvLrOnDuraUpdate()
	--print("in OnDuraUpdate")
	for k ,v in pairs(slotDB) do
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			makeDurability(frameDB[k], v)
		else
			if iDuraFrames[v] then
				iDuraFrames[v]:Hide()
			end
		end
	end
end

function iLvLrOnModUpdate()
	for k ,v in pairs(slotDB) do
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeMod(frameDB[k], v)
			end
		else
			if iModFrames[v] then
				iModFrames[v]:Hide()
			end
		end
	end
end

function GetItemLinkInfo(link)
	local itemColor, itemString, itemName
	if ( link ) then
		itemColor, itemString, itemName = link:match("(|c%x+)|Hitem:([-%d:%a]+)|h%[(.-)%]|h|r");
	end
	return itemName, itemString, itemColor
end

function SplitString(seperator, value)
	local list = {}
	gsub(value..seperator, "([^"..seperator.."]*)"..seperator, function(v) table.insert(list, v) end);
	return list
end

function SplitValue(value)
	if ( value == "" ) then
		value = "0"
	end
	return tonumber(value)
end

function getIlvlTooltip(itemLink)
	--print("In getIlvlToolyip")
	if itemLink ~= nil then
		local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(itemLink)
		return effectiveILvl
	end
	
	return ""
end

function fetchProfs()
	local prof1, prof2 = GetProfessions()
	local profs = {prof1, prof2}
	local profIDs = {}
	
	for k, v in pairs(profs) do
		local _,_,_,_,_,_,skillID = GetProfessionInfo(v)
		tinsert(profIDs, skillID)
	end
	
	return profIDs
end

function fetchIlvl(slotName, unit)
	--print("in fetchIlvl")
	--print(slotName)
	local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(slotName))
	
	if itemLink ~= nil then
		local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(itemLink)
		--print(effectiveILvl)
		return effectiveILvl
	end
	
	return nil
end

function fetchDura(slotName)
	--print("in fetchDura")
	local slotId, texture = GetInventorySlotInfo(slotName)
	if slotId then
		local itemDurability, itemMaxDurability = GetInventoryItemDurability(slotId)
		if itemDurability and itemMaxDurability then
			return itemDurability, itemMaxDurability
		else
			return -1, -1
		end
	end
end

function fetchSocketCount(slotName)
	local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
	local socketCount = 0
	
	local stats = GetItemStats(itemLink)

	socketCount = (stats["EMPTY_SOCKET_RED"] or 0) +
					(stats["EMPTY_SOCKET_YELLOW"] or 0) +
					(stats["EMPTY_SOCKET_BLUE"] or 0) +
					(stats["EMPTY_SOCKET_META"] or 0) +
					(stats["EMPTY_SOCKET_PRISMATIC"] or 0)

	return socketCount
end

function fetchGem(slotName)
	local itemLink      = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
	local foundGems   = 0
							
	local _, itemString, _ = GetItemLinkInfo(itemLink)
	local ids = SplitString(":", itemString)
	local gem1 = SplitValue(ids[3])
	local gem2 = SplitValue(ids[4])
	local gem3 = SplitValue(ids[5])
	local gem4 = SplitValue(ids[6])

	if gem1 > 0 then foundGems = foundGems + 1 end
	if gem2 > 0 then foundGems = foundGems + 1 end
	if gem3 > 0 then foundGems = foundGems + 1 end
	if gem4 > 0 then foundGems = foundGems + 1 end
	
	return foundGems
end

function fetchBaseSocket(slotName)
	local itemLink    = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
	
	local parsedItemDataTable = {}
	local foundStart, foundEnd, parsedItemData = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
	
	for v in string.gmatch(parsedItemData, "[^:]+") do
		tinsert(parsedItemDataTable, v)
	end
	
	local baseItem = "|Hitem:" .. parsedItemDataTable[2] .. ":0"
	local itemName, itemLink, itemQuality, itemLevel, itemReqLevel, itemClass, itemSubclass, itemMaxStack, itemEquipSlot, itemTexture, itemVendorPrice = GetItemInfo(baseItem)
	local baseSocketCount = 0
	for i = 1, 4 do
		if  _G["iLvLrScannerTexture" .. i]  then
	 		_G["iLvLrScannerTexture" .. i]:SetTexture("")
	 	end
	end
	
	if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
	local ttScanner = iLvLrScanner
	
	ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
	ttScanner:ClearLines()
	if itemLink == nil or itemLink == "" or itemLink == "0" then
		print("Hyperlink has not loaded fully yet.")
	else
		ttScanner:SetHyperlink(itemLink)
		if ttScanner == nil then
			print("Hyperlink has not loaded fully yet.")
		end
	end
	
	for i = 1, 4 do
		local texture = _G["iLvLrScannerTexture" .. i]:GetTexture()
		if texture then
			baseSocketCount = baseSocketCount + 1
		end
	end
		
	ttScanner:Hide()
	
	return baseSocketCount
end

function fetchChant(slotName)
	local itemLink            = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
	local parsedItemDataTable = {}
	local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId,
    linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemLink)
--[[    print(itemId .. ", " .. enchantId .. ", " .. jewelId1 .. ", " .. jewelId2 .. ", " .. jewelId3 .. ", " .. jewelId4 .. ", " .. suffixId .. ", " .. uniqueId .. ", " .. 
    linkLevel .. ", " .. specializationID .. ", " .. reforgeId .. ", " .. unknown1 .. ", " .. unknown2)]]
	if enchantId == "" then
			return 0
		else
			return enchantId
	end
end

function makeIlvl(frame, slotName)
	--print("in makeText")
	iAvg, iEqAvg,iAvgPvp = GetAverageItemLevel()
	
	local iLvl = iLvlFrames[slotName]

	--print("Slot: " .. slotName .. ", iLevel: " .. iLevel)
	if not iLvl then
		iLvl = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
			iLvl:SetPoint("CENTER", frame, "CENTER", 38, -1)
		elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
			iLvl:SetPoint("CENTER", frame, "CENTER", -38, -1)
		elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
			iLvl:SetPoint("CENTER", frame, "CENTER", 0, 41)
		end
		
		iLvl:SetSize(10,10)
		iLvl:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iLvl:SetBackdropColor(0,0,0,0)
		
		local iLvlText = iLvl:CreateFontString(nil, "ARTWORK")
		isValid = iLvlText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		iLvlText:SetPoint("CENTER", iLvl, "CENTER", 0, 0)
		iLvl.text = iLvlText
	end
	
	local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
	local iLevel = getIlvlTooltip(itemLink)

	--print("Slot " .. slotName .. ": ilvl :")
	--print(iLevel)
	if iColourState == true then
		if iLevel <= iEqAvg - 10 then
			iLvl.text:SetFormattedText("|cffff0000%i|r", iLevel)
		elseif iLevel >= iEqAvg + 10 then
			iLvl.text:SetFormattedText("|cff00ff00%i|r", iLevel)
		else
			iLvl.text:SetFormattedText("|cffffffff%i|r", iLevel)
		end
	elseif iColourState == false then
		iLvl.text:SetFormattedText("|cffffffff%i|r", iLevel)
	end

	iLvlFrames[slotName] = iLvl

	iLvl:Show()
end

function makeDurability(frame, slot)
	--print("in makeDurability")
	local iDura = iDuraFrames[slot]
	if not iDura then
		iDura = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		
		if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", 38, 0)
			elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", -38, 0)
			elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", 0, 42)
			end
		
		iDura:SetSize(10,10)
		iDura:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iDura:SetBackdropColor(0,0,0,0)
		
		local iDuraText = iDura:CreateFontString(nil, "ARTWORK")
		isValid = iDuraText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		iDuraText:SetPoint("CENTER", iDura, "CENTER", 0, 0)
		iDura.text = iDuraText
		itemDurability, itemMaxDurability = fetchDura(slot, "player")
	else
		itemDurability, itemMaxDurability = fetchDura(slot, "player")
	end
	
	if itemDurability == -1 and itemMaxDurability == -1 then
		iDura.text:SetFormattedText("|cffffffff|r")
	else
		if itemDurability then
			local itemDurabilityPercentage = (itemDurability / itemMaxDurability) * 100
			if itemDurabilityPercentage > 25 then
				iDura.text:SetFormattedText("|cff00ff00%i%%|r", itemDurabilityPercentage)
				elseif itemDurabilityPercentage > 0 and itemDurabilityPercentage <= 25 then
				iDura.text:SetFormattedText("|cff00ffff%i%%|r", itemDurabilityPercentage)
			elseif itemDurabilityPercentage == 0 then
				iDura.text:SetFormattedText("|cffff0000%i%%|r", itemDurabilityPercentage)
			end
		else
			iDura.text:SetFormattedText("")
		end
		iDuraFrames[slot] = iDura
	end
	
    if iDuraState == true then
    	iDura:Show()
    end
end

function makeMod(frame, slot)
	--print("in makeMod")
	local profIDs = fetchProfs() -- 164 Blacksmith, 333 Enchanting, 202 Engineer, 182 Herbalism, 186 Mining, 393 Skining, 197 Tailoring
	local foundGems, numSockets, isEnchanted, canEnchant
	local iMod   = {}
	iMod = iModFrames[slot]
	local iLevel = fetchIlvl(slot, "player")
	local _, englishClass, _ = UnitClass("player")
	local specIndex = GetSpecialization()
	local specID = GetSpecializationInfo(specIndex) 
	--print("Slot: " .. slot .. ", iLvL: " .. iLevel)
	if not iMod then
		iMod = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		
		if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
				iMod:SetPoint("TOP", frame, "TOP", 38, -3)
			elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
				iMod:SetPoint("TOP", frame, "TOP", -38, -3)
			elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
				iMod:SetPoint("TOP", frame, "TOP", 0, 39)
			end

		iMod:SetSize(10,10)
		iMod:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iMod:SetBackdropColor(0,0,0,0)
		
		local iModText = iMod:CreateFontString(nil, "ARTWORK")
		isValid        = iModText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		iModText:SetPoint("CENTER", iMod, "CENTER", 0, 0)
		iMod.text      = iModText
	end	

	foundGems = fetchGem(slot)
	numSockets = fetchSocketCount(slot)
	canEnchant = false
	missingSpecial = 0
	
	if iLevel  ~= "" and iLevel <= 50 then
		if slot == "WaistSlot" then
			canEnchant = true

			local baseSockets = fetchBaseSocket(slot)
			if (baseSockets - numSockets) == -1 then
				isEnchanted = 1
			else
				isEnchanted = 0
			end
		else
			for k ,v in pairs(isEnchantable) do
				if v == slot then
					canEnchant = true
					isEnchanted = fetchChant(slot)
				end
			end
		end
	elseif iLevel ~= "" and iLevel > 20 then
		if slot == "SecondaryHandSlot" and iLevel < 151 then
			local offHand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"))
			local _, _,itemRarity, _, _, itemClass, itemSubclass, _, _, _, _ = GetItemInfo(offHand)
			if itemClass == "Weapon" or itemRarity == 7 then
				canEnchant = true
				isEnchanted = fetchChant(slot)
			end
			--print(itemClass)
			--print(itemSubclass)
		elseif iLevel > 48 and iLevel < 61 then
			local mainHand = GetInventoryItemID("player", GetInventorySlotInfo("MainHandSlot"))
			if mainHand ~= nil then
				local _, _, _, _, _, itemClass, _, _, _, _, _ = GetItemInfo(mainHand)
				local _, englishClass, _ = UnitClass("player")
				if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
					if itemClass == "Weapon" then
						if englishClass == "DEATHKNIGHT" then
							canEnchant = true
							isEnchanted = fetchChant(slot)
						end
					else
						canEnchant = false
					end
				else 
					for k ,v in pairs(isEnchantableWoD) do
						if v == slot then
							canEnchant = true
							isEnchanted = fetchChant(slot)
						end
					end
				end
			end
		elseif iLevel > 60 and iLevel < 141 then
			if slot == "SecondaryHandSlot" then
				local offHand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"))
				-- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo()
				local _, _, _, _, _, itemType, _, _, _, _, _ = GetItemInfo(offHand)
				if offHand ~= nil then
					if itemType == "Weapon" then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					else
						canEnchant = false
					end
				end
			elseif slot == "WristSlot" then
				for k, v in pairs(profIDs) do
					if v == 333 then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			elseif slot == "WaistSlot" then
				for k, v in pairs(profIDs) do
					if v == 202 then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			elseif slot == "BackSlot" then
				for k, v in pairs(profIDs) do
					if v == 197 then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			else
				for k ,v in pairs(isEnchantableBfA) do
					if v == slot then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			end
		elseif iLevel > 140 then
			if slot == "SecondaryHandSlot" then
				for k,v in pairs(dualWield) do
					if v == specID then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			elseif slot == "HandsSlot" then				
				canEnchant = false
				if englishClass == "DEATHKNIGHT" or englishClass == "WARRIOR" or englishClass == "PALADIN" then
					canEnchant = true
					isEnchanted = fetchChant(slot)
				end
				for k,v in pairs(profIDs) do
					if v == 182 or v == 186 or v == 393 then --182 Herbalism, 186 Mining, 393 Skining
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			else
				for k,v in pairs(isEnchantableSL) do
					if v == slot then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			end
		else  
			for k ,v in pairs(isEnchantable) do
				if v == slot then
					canEnchant = true
					isEnchanted = fetchChant(slot)
				end
			end
		end
	end

	isEnchanted = tonumber(isEnchanted)
		
	if numSockets > 0 and canEnchant == true then
		if isEnchanted == 0 and foundGems < numSockets then -- Missing (Red) Enchant and Gem
			iMod.text:SetFormattedText("|cffff0000%s|r|cffff0000%s|r", "E", "G")
		elseif isEnchanted == 0 and foundGems == numSockets then -- Missing (Red) Enchant, Found (Green) Gem
			iMod.text:SetFormattedText("|cffff0000%s|r|cff00ff00%s|r", "E", "G")
		elseif isEnchanted > 0 and foundGems < numSockets then -- Found (Green) Enchant, Missing(Red) Gem
			iMod.text:SetFormattedText("|cff00ff00%s|r|cffff0000%s|r", "E", "G")
		elseif isEnchanted > 0 and foundGems == numSockets then -- Found (Green) Enchant and Gem
			iMod.text:SetFormattedText("|cff00ff00%s|r|cff00ff00%s|r", "E", "G")
		end
	elseif numSockets > 0 and canEnchant == false then
		if foundGems < numSockets then -- Missing (Red) Gem
			iMod.text:SetFormattedText("|cffff0000%s|r", "G")
		elseif foundGems == numSockets then -- Found (Green) Gem
			iMod.text:SetFormattedText("|cff00ff00%s|r", "G")
		end
	elseif numSockets == 0 and canEnchant == true then
		if isEnchanted == 0 then -- Missing (Red) Enchant
			iMod.text:SetFormattedText("|cffff0000%s|r", "E")
		elseif isEnchanted > 0 then -- Found (Green) Enchant
			iMod.text:SetFormattedText("|cff00ff00%s|r", "E")
		end
	elseif numSockets == 0 and canEnchant == false then
		iMod.text:SetFormattedText("")
	end
		
	iModFrames[slot] = iMod
		
	iMod:Show()
end

function iDuraToggle(state)
--[[	if iDuraState == false then
		print("iDuraState = false.")
	elseif iDuraState == true then
		print("iDuraState = true.")
	end]]
	for k, v in pairs(iDuraFrames) do
		if state == true then
			v:Show()
		elseif state == false then
			v:Hide()
		end
	end
end

iLvLrMain()
iLvLrReportFrame:SetScript("OnUpdate", onIUpdate)
