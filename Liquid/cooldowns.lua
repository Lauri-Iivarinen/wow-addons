---@diagnostic disable: inject-field, need-check-nil, param-type-mismatch
local _, ns = ...
ns.cooldowns = {}
-- disable stuff on beta for now
-- TODO fix hero talents from talentstrings
local _eventHandler = CreateFrame('Frame');
_eventHandler:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)
local _sendAddonMessage, tinsert, tconcat, sformat, IsSpellKnown, _GetSpellCooldown, _GetSpellCharges, strsplit, FindSpellOverrideByID, GetTime, wipe, CopyTable =
  C_ChatInfo.SendAddonMessage, table.insert, table.concat, string.format, IsSpellKnown, C_Spell.GetSpellCooldown, C_Spell.GetSpellCharges, strsplit, FindSpellOverrideByID, GetTime, table.wipe, CopyTable
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local private = {
  encounterStart = 0
}
local playerGUID = UnitGUID('player')
local ownCds = {}
local groupData = {}
local ticker
local playerClass = select(2,UnitClass('player'))
local raidHasWarlock = false
local currentGroupType = "raid"
local thingsToDo = {
  syncs = {},
  requests = {},
  updates = {},
}
local syncedServerTimeInformation = {
  set = false,
  order = 100,
  source = "",
  lastEncounterStart = 0,
  offSet = 0,
}
local currentlySyncing = false
local prefixToUse = "LiquidICDS" -- use var so its easy to change if and when lib is released
local prefixForSync = prefixToUse.."R"
local prefixForSyncAlt = prefixForSync .. "2"
C_ChatInfo.RegisterAddonMessagePrefix(prefixToUse)
C_ChatInfo.RegisterAddonMessagePrefix(prefixForSync)
C_ChatInfo.RegisterAddonMessagePrefix(prefixForSyncAlt)
local initialServerTimeDif = GetServerTime() - GetTime() -- init it with data so everything doesn't break
local serverTimeAccuracyReached = false
local isVeteranAccount = IsVeteranTrialAccount()
local function _GetServerTime() -- change this behavior once accuracy is reached
  return initialServerTimeDif+GetTime()
end
local cachedAddOnMessages = {}
local alreadyWarnedVeteranAccount = false
local isInGuild
local cachedTalents = {}
local function SendAddonMessage(prefix, msg, chatType, whisperTarget, ignoreCache)
  if chatType == "raid" and isVeteranAccount then
    if not alreadyWarnedVeteranAccount then
      alreadyWarnedVeteranAccount = true
      print("Liquid: You are on 'veteran' account, you cannot send chat messages to raid, some functions are disabled.")
    end
    return
  end
  if chatType == "GUILD" and not isInGuild then return end
  msg = msg:sub(0,255) -- just make sure its not too long, otherwise caching will fuck up
  if not ignoreCache and not whisperTarget and msg:len() <= 255 then -- don't cache whisper (we don't use any atm)
  --if not whisperTarget and msg:len() <= 255 then -- don't cache whisper (we don't use any atm)
    cachedAddOnMessages[msg] = GetTime() -- we don't need to cache chatType, since we are only sending to current group
  end
  local returnEnum = _sendAddonMessage(prefix, msg, chatType, whisperTarget)
  if ns.debugMode then
    if prefix == prefixToUse and returnEnum ~= Enum.SendAddonMessageResult.Success then
      ns.PrintDebug("Addon message failed - returnEnum: %s - msg: %s", returnEnum or "nil", msg or "nil")
    end
  end
end
local function sendDebugiEET(data)
  if not (LiquidDB.debugging and iEET_AddCustom) then return end
  iEET_AddCustom(data)
end
local function sendWeakAuraEvent(key, updateType, data)
  if not WeakAuras then return end
  WeakAuras.ScanEvents("LIQUID_CUSTOM_CDS", key, updateType, data)
end
local function sendWeakAuraEventForExternal(data, notifyType)
  if not WeakAuras then return end
  WeakAuras.ScanEvents("LIQUID_EXTERNAL_CALLS", notifyType, data)
end
local function sendWeakAuraEventForExternal_Personal(data)
  if not WeakAuras then return end
  WeakAuras.ScanEvents("LIQUID_EXTERNAL_CALLS_PERSONAL", data)
end
---@param guid string dest guid
---@param spellID number
---@param requiredSourceGUID string? source guid if needed
---@param buff boolean buff or debuff
---@return number? auraDuration
---@return number? auraExpirationTime
function private:fetchAuraData(guid, spellID, requiredSourceGUID, buff)
  local filter = buff and "HELPFUL" or "HARMFUL"
  local targetUnitID = groupData[guid] and groupData[guid].unitID or nil
  if not targetUnitID then
    targetUnitID = UnitTokenFromGUID(guid)
    if not targetUnitID then return end
  end
  local auraData
  for i = 1, 255 do
    auraData = C_UnitAuras.GetAuraDataByIndex(targetUnitID, i, filter)
    if not auraData then break end
---@diagnostic disable-next-line: param-type-mismatch
    if spellID == auraData.spellId and auraData.sourceUnit and requiredSourceGUID == UnitGUID(auraData.sourceUnit) then
      return auraData.duration, auraData.expirationTime
    end
  end
end
local specIDsToRole = {
  -- Tanks
  [250] = 1,  -- Death Knight, Blood
  [581] = 1,  -- Demon Hunter, Vengeance
  [104] = 1,  -- Druid, Guardian
  [268] = 1,  -- Monk, Brewmaster
  [66] = 1,   -- Paladin, Protection
	[73] = 1,   -- Warrior, Protection

	-- Healers
	[105] = 2,  -- Druid, Restoration
  [270] = 2,  -- Monk, Mistweaver
  [65] = 2,   -- Paladin, Holy
	[256] = 2,  -- Priest, Discipline
	[257] = 2,  -- Priest, Holy
	[264] = 2,  -- Shaman, Restoration
  [1468] = 2, -- Evoker, Preservation

  -- Melee dps
  [251] = 3,  -- Death Knight, Frost
  [252] = 3,  -- Death Knight, Unholy
  [577] = 3,  -- Demon Hunter, Havoc
  [103] = 3,  -- Druid, Feral
  [255] = 3,  -- Hunter, Survival
  [269] = 3,  -- Monk, Windwalker
  [70] = 3,   -- Paladin, Retribution
  [259] = 3,  -- Rogue, Assasination
  [260] = 3,  -- Rogue, Outlaw
  [261] = 3,  -- Rogue, Sublety
  [263] = 3,  -- Shaman, Enhancement
  [71] = 3,   -- Warrior, Arms
  [72] = 3,   -- Warrior, Fury

  -- Ranged dps
  [102] = 4,  -- Druid, Balance
  [253] = 4,  -- Hunter, Beast Mastery
  [254] = 4,  -- Hunter, Marksmanship
  [62] = 4,   -- Mage, Arcane
  [63] = 4,   -- Mage, Fire
  [64] = 4,   -- Mage, Frost
  [258] = 4,  -- Priest, Shadow
  [262] = 4,  -- Shaman, Elemental
  [265] = 4,  -- Warlock, Affliction
  [266] = 4,  -- Warlock, Demonology
  [267] = 4,  -- Warlock, Destruction
  [1467] = 4, -- Evoker, Devastation
  [1473] = 4, -- Evoker, Augmentation
}
local classIDsToSpecID = {
  [1] = { -- Warrior
    [71] = true, -- Arms
    [72] = true, -- Fury
    [73] = true, -- Protection
  },
  [2] = { -- Paladin
    [65] = true, -- Holy
    [66] = true, -- Protection
    [70] = true, -- Retribution
  },
  [3] = { -- Hunter
    [253] = true, -- Beast Mastery
    [254] = true, -- Marksmanship
    [255] = true, -- Survival
  },
  [4] = { -- Rogue
    [259] = true, -- Assasination
    [260] = true, -- Outlaw
    [261] = true, -- Sublety
  },
  [5] = { -- Priest
    [256] = true, -- Discipline
    [257] = true, -- Holy
    [258] = true, -- Shadow
  },
  [6] = { -- Death Knight
    [250] = true, -- Blood
    [251] = true, -- Frost
    [252] = true, -- Unholy
  },
  [7] = { -- Shaman
    [262] = true, -- Elemental
    [263] = true, -- Enhancement
    [264] = true, -- Restoration
  },
  [8] = { -- Mage
    [62] = true, -- Arcane
    [63] = true, -- Fire
    [64] = true, -- Frost
  },
  [9] = { -- Warlock
    [265] = true, -- Affliction
    [266] = true, -- Demonology
    [267] = true, -- Destruction
  },
  [10] = { -- Monk
    [268] = true, -- Brewmaster
    [269] = true, -- Windwalker
    [270] = true, -- Mistweaver
  },
  [11] = { -- Druid
    [102] = true, -- Balance
    [103] = true, -- Feral
    [104] = true, -- Guardian
    [105] = true, -- Restoration
  },
  [12] = { -- Demon Hunter
    [577] = true, -- Havoc
    [581] = true, -- Vengeance
  },
  [13] = { -- Evoker
    [1467] = true, -- Devastation
    [1468] = true, -- Preservation
    [1473] = true, -- Augmentation
  },
}
local rosterTalents = {}
do
  -- most of this is yoinked from Weakauras/LibSpecializationWrapper.lua
  local function ReadLoadoutHeader(importStream)
    local bitWidthHeaderVersion = 8
    local bitWidthSpecID = 16
    local headerBitWidth = bitWidthHeaderVersion + bitWidthSpecID + 128;

    local importStreamTotalBits = importStream:GetNumberOfBits();
    if( importStreamTotalBits < headerBitWidth) then
      return false, 0, 0, 0;
    end
    local serializationVersion = importStream:ExtractValue(bitWidthHeaderVersion);
    local specID = importStream:ExtractValue(bitWidthSpecID);

    -- treeHash is a 128bit hash, passed as an array of 16, 8-bit values
    local treeHash = {};
    for i=1,16,1 do
      treeHash[i] = importStream:ExtractValue(8);
    end
    return true, serializationVersion, specID, treeHash;
  end
  local validSerializationVersions = {
    [1] = true,
    [2] = true
  }
  local talentTreeData = {}
  local function GetClassId(classFile)
    for classID = 1, GetNumClasses() do
      local _, thisClassFile = GetClassInfo(classID)
      if classFile == thisClassFile then
        return classID
      end
    end
  end
  local function _GetTalentData(specId)
    if talentTreeData[specId] then
      return unpack(talentTreeData[specId])
    end
    local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
    local specData = {}
    local specDataByNodeId = {}
    local heroData = {}
    C_ClassTalents.InitializeViewLoadout(specId, 70)
    C_ClassTalents.ViewLoadout({})
    local configInfo = C_Traits.GetConfigInfo(configId)
    local subTreeIDs = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configId, specId) or {}
    if configInfo == nil then return end
    for _, treeId in ipairs(configInfo.treeIDs) do
      local nodes = C_Traits.GetTreeNodes(treeId)
      for _, nodeId in ipairs(nodes) do
        local node = C_Traits.GetNodeInfo(configId, nodeId)
        if node and node.ID ~= 0 then
          for idx, talentId in ipairs(node.entryIDs) do
            local entryInfo = C_Traits.GetEntryInfo(configId, talentId)
            local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
            if definitionInfo.spellID then
              --local spellName = Private.ExecEnv.GetSpellName(definitionInfo.spellID)
              --if spellName then
              local talentData = {
                talentId,
                definitionInfo.spellID,
                { node.posX, node.posY, idx, #node.entryIDs },
                {}, -- Target if it exists,
                node.maxRanks
              }
              
              specDataByNodeId[node.ID] = specDataByNodeId[node.ID] or {}
              specDataByNodeId[node.ID][idx] = talentData
              for _, edge in pairs(node.visibleEdges) do
                local targetNodeId = edge.targetNode
                local targetNode = C_Traits.GetNodeInfo(configId, targetNodeId)
                local targetNodeTalentId1 = targetNode.entryIDs[1]
                if targetNodeTalentId1 then
                  -- add as target 1st talentId
                  -- because we don't save nodes
                  tinsert(talentData[4], targetNodeTalentId1)
                end
              end
              local subTreeIndex = node.subTreeID and tIndexOf(subTreeIDs, node.subTreeID) or nil
              if subTreeIndex then
                local subTreeInfo = C_Traits.GetSubTreeInfo(configId, node.subTreeID)
                talentData[3][1] = node.posX - subTreeInfo.posX
                talentData[3][2] = node.posY - subTreeInfo.posY
                talentData[3][5] = subTreeIndex
                tinsert(heroData, talentData)
              elseif not node.subTreeID then
                tinsert(specData, talentData)
              end
              --end
            end
          end
        end
      end
    end
    local classFile = select(6, GetSpecializationInfoByID(specId))
    local classID = GetClassId(classFile)
    talentTreeData[specId] = { specData, heroData, specDataByNodeId }
    return specData, heroData, specDataByNodeId
  end
  local function LibSpecCallback(specID, role, position, sender, talentString)
    local guid = UnitGUID(Ambiguate(sender, "none"))
    if not guid then
      ns.PrintDebug("no guid found for - sender: %s - ambiguate: %s", sender or "nil", Ambiguate(sender, "none") or "nil")
      return
    end
    if rosterTalents[guid] and rosterTalents[guid].talentStr == talentString then -- already cached is the same
      return
    end
    local importStream = CreateAndInitFromMixin(ImportDataStreamMixin, talentString)
    local headerValid, serializationVersion, _specID, treeHash = ReadLoadoutHeader(importStream);
    local currentSerializationVersion = C_Traits.GetLoadoutSerializationVersion();
    if(not headerValid) then
      return nil
    end
    if(serializationVersion ~= currentSerializationVersion or not validSerializationVersions[serializationVersion]) then
      return nil
    end

    local treeID = C_ClassTalents.GetTraitTreeForSpec(specID)

    local results = {};
    local bitWidthRanksPurchased = 6
    --if node.subTreeID then
      --local subTreeInfo = C_Traits.GetSubTreeInfo(configId, node.subTreeID)
      --if subTreeInfo.isActive then
        --cachedTalents[node.activeEntry.entryID] = true
      --end
    --else
      --cachedTalents[node.activeEntry.entryID] = true
    --end
    local _, _, talentsData = _GetTalentData(specID)
    local treeNodes = C_Traits.GetTreeNodes(treeID);
    for _, nodeId in ipairs(treeNodes) do
      local nodeSelectedValue = importStream:ExtractValue(1)
      local isNodeSelected = nodeSelectedValue == 1
      local isPartiallyRanked = false
      local partialRanksPurchased = 0
      local isChoiceNode = false
      local choiceNodeSelection = 1
      if(isNodeSelected) then
        if serializationVersion == 2 then
          local nodePurchasedValue = importStream:ExtractValue(1)
          local isNodePurchased = nodePurchasedValue == 1
          if(isNodePurchased) then
            local isPartiallyRankedValue = importStream:ExtractValue(1)
            isPartiallyRanked = isPartiallyRankedValue == 1
            if(isPartiallyRanked) then
              partialRanksPurchased = importStream:ExtractValue(bitWidthRanksPurchased)
            end
            local isChoiceNodeValue = importStream:ExtractValue(1)
            isChoiceNode = isChoiceNodeValue == 1
            if(isChoiceNode) then
              choiceNodeSelection = importStream:ExtractValue(2) + 1
            end
          end
        else
          local isPartiallyRankedValue = importStream:ExtractValue(1)
          isPartiallyRanked = isPartiallyRankedValue == 1
          if(isPartiallyRanked) then
            partialRanksPurchased = importStream:ExtractValue(bitWidthRanksPurchased)
          end
          local isChoiceNodeValue = importStream:ExtractValue(1)
          isChoiceNode = isChoiceNodeValue == 1
          if(isChoiceNode) then
            choiceNodeSelection = importStream:ExtractValue(2) + 1
          end
        end
      end

      local talentData = talentsData and talentsData[nodeId] and talentsData[nodeId][choiceNodeSelection]
      if talentData then
        if isPartiallyRanked then
          results[talentData[1]] = partialRanksPurchased
        else
          results[talentData[1]] = nodeSelectedValue == 1 and talentData[5] or nil
        end
      end
      --if isChoiceNode then
        --local unselectedChoiceNodeIdx = choiceNodeSelection == 1 and 2 or 1
        --local unselectedTalentData = talentsData and talentsData[nodeId] and talentsData[nodeId][unselectedChoiceNodeIdx]
        --if unselectedTalentData then
          --results[unselectedTalentData[1]] = 0
        --end
      --end
    end
    rosterTalents[guid] = {
      talentStr = talentString,
      talents = results
    }
  end
  local LibSpec = LibStub("LibSpecialization")
  LibSpec:Register("Liquid", LibSpecCallback)
end
-- for now just default to UnitInRange if target doesn't have externals we care about TODO use spellids and find relevant spell for all specs 
local specIDsToClass = {} -- just so we don't have to loop looking for it later on
for classID,specs in pairs(classIDsToSpecID) do
  for specID in pairs(specs) do
    specIDsToClass[specID] = classID
  end
end
local damageReductionsPerSpec = {
  --[[ Don't care about tanks at this point
  [250] = function(talents, damageType, debuff, aoe) -- Death Knight, Blood
    local dmgTaken = 1
    if damageType == "magic" and talents[126016] then -- Null Magic
      dmgTaken = dmgTaken * (1-0.08)
    end
    return dmgTaken
  end,
  [581] = 1,  -- Demon Hunter, Vengeance
  [104] = function(talents, damageType, debuff, aoe) return 1 end,  -- Druid, Guardian
  [268] = 1,  -- Monk, Brewmaster
  [66] = 1,   -- Paladin, Protection
	[73] = 1,   -- Warrior, Protection
  --]]
	-- Healers
	[105] = function(talents, damageType, debuff, aoe) return 1 end,  -- Druid, Restoration
  --[270] = 2,  -- Monk, Mistweaver not currently played
  [65] = function(talents, damageType, debuff, aoe) -- Paladin, Holy
    local dmgTaken = 1
    if aoe and talents[102622] then -- Obduracy
      dmgTaken = dmgTaken * (1-0.02)
    end
    if aoe and talents[115034] then -- Sanctified Plates
      dmgTaken = dmgTaken * (1-0.03)
    end
    return dmgTaken
  end,
  [256] = function(talents, damageType, debuff, aoe) -- Priest, Discipline
    local dmgTaken = 1
    if talents[103858] then -- Protective Light, assume you can use this on yourself for big hits
      dmgTaken = dmgTaken * (1-0.10)
    end
    if damageType == "magic" and talents[103872] then
      dmgTaken = dmgTaken * (1-0.03)
    end
    if talents[103818] then -- Manipulation, assume this is active
      dmgTaken = dmgTaken * (1-0.02)
    end
    return dmgTaken
  end,
	[257] = function(talents, damageType, debuff, aoe) -- Priest, Holy
    local dmgTaken = 1
    if talents[103858] then -- Protective Light, assume you can use this on yourself for big hits
      dmgTaken = dmgTaken * (1-0.10)
    end
    if damageType == "magic" and talents[103872] then
      dmgTaken = dmgTaken * (1-0.03)
    end
    if talents[103818] then -- Manipulation, assume this is active
      dmgTaken = dmgTaken * (1-0.02)
    end
    return dmgTaken
  end,
  [264] = function(talents, damageType, debuff, aoe) -- Shaman, Restoration
    local dmgTaken = 1
    if damageType == "magic" and talents[127872] then -- Elemental Warding
      dmgTaken = dmgTaken * (1-0.06)
    end
    return dmgTaken
  end,
  [1468] = function(talents, damageType, debuff, aoe) -- Evoker, Preservation
    local dmgTaken = 1
    if damageType == "magic" and talents[115670] then -- Inherent Resistance, assume 2 points for now TODO fix
      dmgTaken = dmgTaken * (1-0.08)
    end
    return dmgTaken
  end,

  -- Melee dps
  [251] = function(talents, damageType, debuff, aoe) -- Death Knight, Frost
    local dmgTaken = 1
    if damageType == "magic" and talents[126016] then -- Null Magic
      dmgTaken = dmgTaken * (1-0.08)
    end
    return dmgTaken
  end,
  [252] = function(talents, damageType, debuff, aoe) -- Death Knight, Unholy
    local dmgTaken = 1
    if damageType == "magic" and talents[126016] then -- Null Magic
      dmgTaken = dmgTaken * (1-0.08)
    end
    return dmgTaken
  end,
  [577] = function(talents, damageType, debuff, aoe) -- Demon Hunter, Havoc
    local dmgTaken = 1
    if damageType == "magic" and talents[112846] then -- Illidari Knowledge
      dmgTaken = dmgTaken * (1-0.05)
    end
    if damageType == "magic" then
      dmgTaken = dmgTaken * (1-0.10) -- Demonic Wards
    end
    return dmgTaken
  end,
  [103] = function(talents, damageType, debuff, aoe) return 1 end,  -- Druid, Feral
  [255] = function(talents, damageType, debuff, aoe) -- Hunter, Survival
    local dmgTaken = 1
    if aoe and talents[126489] then -- Hunter's Avoidance
      dmgTaken = dmgTaken * (1-0.05)
    end
    return dmgTaken
  end,
  [269] = function(talents, damageType, debuff, aoe) -- Monk, Windwalker
    local dmgTaken = 1
    if talents[124944] then -- Calming Presence
      dmgTaken = dmgTaken * (1-0.03)
    end
    if aoe and talents[124976] then -- Martial Instincts
      dmgTaken = dmgTaken * (1-0.04)
    end
    return dmgTaken
  end,
  [70] = function(talents, damageType, debuff, aoe) -- Paladin, Retribution
    local dmgTaken = 1
    if aoe and talents[102622] then -- Obduracy
      dmgTaken = dmgTaken * (1-0.02)
    end
    if aoe and talents[115034] then -- Sanctified Plates
      dmgTaken = dmgTaken * (1-0.06)
    end
    return dmgTaken
  end,
  --[[ rogues dont have anything
  [259] = 3,  -- Rogue, Assasination
  [260] = 3,  -- Rogue, Outlaw
  [261] = 3,  -- Rogue, Sublety
  --]]
  [263] = function(talents, damageType, debuff, aoe) -- Shaman, Enhancement
    local dmgTaken = 1
    if damageType == "magic" and talents[127872] then -- Elemental Warding
      dmgTaken = dmgTaken * (1-0.06)
    end
    return dmgTaken
  end,
  [71] = function(talents, damageType, debuff, aoe) -- Warrior, Arms
    local dmgTaken = 0.85 -- Assume you can always go to defensive stance
    return dmgTaken
  end,
  [72] = function(talents, damageType, debuff, aoe) -- Warrior, Fury
    local dmgTaken = 0.85 -- Assume you can always go to defensive stance
    return dmgTaken
  end,

  -- Ranged dps
  [102] = function(talents, damageType, debuff, aoe) return 1 end,  -- Druid, Balance
  [253] = function(talents, damageType, debuff, aoe) -- Hunter, Beast Mastery
    local dmgTaken = 1
    if aoe and talents[126489] then -- Hunter's Avoidance
      dmgTaken = dmgTaken * (1-0.05)
    end
    return dmgTaken
  end,
  [254] = function(talents, damageType, debuff, aoe) -- Hunter, Marksmanship
    local dmgTaken = 1
    if aoe and talents[126489] then -- Hunter's Avoidance
      dmgTaken = dmgTaken * (1-0.05)
    end
    return dmgTaken
  end,
  [62] = function(talents, damageType, debuff, aoe) -- Mage, Arcane
    local dmgTaken = 1
    if damageType == "magic" and talents[80173] then -- Arcane Warding
      dmgTaken = dmgTaken * (1-0.04)
    end
    return dmgTaken
  end,
  [63] = function(talents, damageType, debuff, aoe) -- Mage, Fire
    local dmgTaken = 1
    if damageType == "magic" and talents[80173] then -- Arcane Warding
      dmgTaken = dmgTaken * (1-0.04)
    end
    return dmgTaken
  end,
  [64] = function(talents, damageType, debuff, aoe) -- Mage, Frost
    local dmgTaken = 1
    if damageType == "magic" and talents[80173] then -- Arcane Warding
      dmgTaken = dmgTaken * (1-0.04)
    end
    return dmgTaken
  end,
  [258] = function(talents, damageType, debuff, aoe) -- Priest, Shadow
    local dmgTaken = 1
    if talents[103858] then -- Protective Light, assume you can use this on yourself for big hits
      dmgTaken = dmgTaken * (1-0.10)
    end
    if damageType == "magic" and talents[103872] then
      dmgTaken = dmgTaken * (1-0.03)
    end
    if talents[103818] then -- Manipulation, assume this is active
      dmgTaken = dmgTaken * (1-0.02)
    end
    return dmgTaken
  end,
  --[262] = 4,  -- Shaman, Elemental not played currently
  --[[ Warlock doesnt have any passives we care about
  [265] = 4,  -- Warlock, Affliction
  [266] = 4,  -- Warlock, Demonology
  [267] = 4,  -- Warlock, Destruction
  --]]
  [1467] = function(talents, damageType, debuff, aoe) -- Evoker, Devastation
    local dmgTaken = 1
    if damageType == "magic" and talents[115670] then -- Inherent Resistance, assume 2 points for now TODO fix
      dmgTaken = dmgTaken * (1-0.08)
    end
    return dmgTaken
  end,
  [1473] = function(talents, damageType, debuff, aoe) -- Evoker, Augmentation
    local dmgTaken = 1
    if damageType == "magic" and talents[115670] then -- Inherent Resistance, assume 2 points for now TODO fix
      dmgTaken = dmgTaken * (1-0.04)
    end
    return dmgTaken
  end,
}
local spellData = {
  -- #region Death Knight
  [48707] = {p = 1, cd = 60, t = {magic = true, magicImmunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 0, displayName = "Anti-Magic Shell",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      if damageType ~= "magic" then return 0,0 end
      if immunity and immunity == "debuff" then return 100,0 end
      return 0, maxHealth * 0.3 -- base is 30% of max health
        * (talents[96174] and 1.40 or 1) -- Anti-Magic Barrier, class tree
        * (talents[96180] and 1.15 or 1) -- Gloom Ward
    end
  }, -- Anti-Magic Shell
  [49039] = {p = 2, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 0, displayName = "Lichborne",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return (talents[96187] and 15 or 0), 0
    end
  }, -- Lichborne
  [48265] = {p = 3, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 0, displayName = "Death's Advance"}, -- Death's Advance
  [48792] = {p = 4, cd = 180, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b= true}, class = 6, specID = 0, displayName = "Icebound Fortitude",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 30, 0
    end
  }, -- Icebound Fortitude
  [51052] = {p = 5, cd = 120, t = {magicRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 6, specID = 0, displayName = "Anti-Magic Zone"}, -- Anti-Magic Zone
  [48743] = {p = 6, cd = 120, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 6, specID = 0, displayName = "Death Pact"}, -- Death Pact
  [212552] = {p = 7, cd = 60, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 0, displayName = "Wraith Walk"}, -- Wraith Walk
  [383269] = {p = 8, cd = 120, t = {aoeUtilityGrip = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 0, displayName = "Abomination Limb"}, -- Abomination Limb
  -- Blood
  [55233] = {p = 10, cd = 90, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 250, displayName = "Vampiric Blood"}, -- Vampiric Blood
  [194679] = {p = 11, cd = 25, t = {all = true}, charges = 2, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 250, displayName = "Rune Tap"}, -- Rune Tap
  [49028] = {p = 12, cd = 120, t = {physical = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 250, displayName = "Dancing Rune Weapon"}, -- Dancing Rune Weapon
  [219809] = {p = 13, cd = 60, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 6, specID = 250, displayName = "Tombstone"}, -- Tombstone
  [108199] = {p = 14, cd = 120, t = {aoeUtilityGrip = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 6, specID = 250, displayName = "Gorefiend's Grasp"}, -- Gorefiend's Grasp
  [114556] = {p = 15, cd = 240,  debuffOnly = 123981, t = {cheatDeath = true}, activation = {e = "SPELL_AURA_APPLIED", b = 123981}, class = 6, specID = 250, displayName = "Purgatory"}, -- Purgatory
  -- Frost
  -- Unholy
  --#endregion
  -- #region Demon Hunter
  [198793] = {p = 101, cd = 25, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 0, displayName = "Vengeful Retreat"}, -- Vengeful Retreat
  [196718] = {p = 102, cd = 300, t = {allRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 0, displayName = "Darkness"}, -- Darkness
  -- Havoc
  [191427] = {p = 111, cd = 240, t = {immunity = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 577, displayName = "Metamorphosis"}, -- Metamorphosis
    [198589] = {p = 112, cd = 60, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = 212800}, class = 12, specID = 577, displayName = "Blur",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[115248] and 30 or 20, 0
    end
  }, -- Blur
  [195072] = {p = 113, cd = 10, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 577, displayName = "Fel Rush"}, -- Fel Rush
  [196555] = {p = 114, cd = 180, t =  {all = true, immunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 12, specID = 577, displayName = "Netherwalk",
  drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
    return 100, 0
  end
  }, -- Netherwalk
  -- Vengeance
  [203720] = {p = 121, cd = 20, t = {physical = true}, charges = 2, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 12, specID = 581, displayName = "Demon Spikes"}, -- Demon Spikes
  [204021] = {p = 122, cd = 60, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 581, displayName = "Fiery Brand"}, -- Fiery Brand
  [202137] = {p = 123, cd = 90, t = {aoeUtilitySilence = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 581, displayName = "Sigil of Silence"}, -- Sigil of Silence
  [202138] = {p = 124, cd = 60, t = {aoeUtilityGrip = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 581, displayName = "Sigil of Chains"}, -- Sigil of Chains
  [187827] = {p = 125, cd = 180, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 12, specID = 581, displayName = "Metamorphosis"}, -- Metamorphosis
  [209258] = {p = 126, cd = 300,  debuffOnly = 209261, t = {cheatDeath = true}, activation = {e = "SPELL_AURA_APPLIED", b = 209261}, class = 12, specID = 581, displayName = "Last Resort"}, -- Last Resort
  [189110] = {p = 127, cd = 20, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 12, specID = 581, displayName = "Infernal Strike"}, -- Infernal Strike
  --#endregion
  -- #region Druid
  [22812] = {p = 201, cd = 60, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 0, displayName = "Barkskin",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[123793] and 30 or 20, 0 -- Oakskin
    end
  }, -- Barkskin
  [22842] = {p = 202, cd = 36, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 0, displayName = "Frenzied Regeneration"}, -- Frenzied Regeneration
  [1850] = {p = 203, cd = 120, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 0, displayName = "Dash"}, -- Dash
  [252216] = {p = 204, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 0, displayName = "Tiger Dash"}, -- Tiger Dash
  [102401] = {p = 205, cd = 15, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, possibleSpellIDs = {16979, 49376, 102401, 102383, 102417}, class = 11, specID = 0, displayName = "Wild Charge"}, -- Wild Charge
  [132469] = {p = 206, cd = 30, t = {aoeUtility = true}, activation = {e = "SPELL_CAST_SUCCESS"}, possibleSpellIDs={61391}, class = 11, specID = 0, displayName = "Typhoon"}, -- Typhoon
  [106898] = {p = 207, cd = 120, t = {movementRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, possibleSpellIDs = {77764, 77761, 106898}, class = 11, specID = 0, displayName = "Stampeding Roar"}, -- Stampeding Roar
  [102793] = {p = 208, cd = 60, t = {aoeUtility = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 0, displayName = "Ursol's Vortex"}, -- Ursol's Vortex
  [108238] = {p = 209, cd = 90, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 0, displayName = "Renewal"}, -- Renewal
  [124974] = {p = 210, cd = 90, t = {healRaidDPS = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 0, displayName = "Nature's Vigil"}, -- Nature's Vigil
  [29166] = {p = 211, cd = 180, t = {mana = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 0, displayName = "Innervate"}, -- Innervate

  --Guardian & Feral
  [61336] = {p = 221, cd = 180, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = {104,103}, displayName = "Survival Instincts",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[123793] and 60 or 50, 0
    end
  }, -- Survival Instincts
  -- Balance
  [78675] = {p = 231, cd = 60, t = {aoeUtilitySilence = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 102, displayName = "Solar Beam"}, -- Solar Beam
  -- Feral  
  -- Guardian
  [80313] = {p = 241, cd = 45, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 104, displayName = "Pulverize"}, -- Pulverize
  [200851] = {p = 242, cd = 90, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 104, displayName = "Rage of the Sleeper"}, -- Rage of the Sleeper
  -- Restoration
  [102342] = {p = 251, cd = 90, t = {all= true, allExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 105, externalType = "DR", displayName = "Ironbark"}, -- Ironbark
  [740] = {p = 252, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 105, displayName = "Tranquility"}, -- Tranquility
  [33891] = {p = 253, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 11, specID = 105, displayName = "Incarnation: Tree of Life"}, -- Incarnation: Tree of Life
  [391528] = {p = 254, cd = 120, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 105, displayName = "Convoke the Spirits"}, -- Convoke the Spirits
  [197721] = {p = 256, cd = 120, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 11, specID = 105, displayName = "Flourish"}, -- Flourish
  --#endregion
  -- #region Hunter
  [186265] = {p = 301, cd = 180, t = {all = true, immunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 3, specID = 0, displayName = "Aspect of the Turtle",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return immunity and 100 or 30, 0
    end
  }, -- Aspect of the Turtle
  [186257] = {p = 302, cd = 180, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 3, specID = 0, displayName = "Aspect of the Cheetah"}, -- Aspect of the Cheetah
  [5384] = {p = 303, cd = 30, t = {targetDrop = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 3, specID = 0, displayName = "Feign Death"}, -- Feign Death
  [781] = {p = 304, cd = 20, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 3, specID = 0, displayName = "Disengage"}, -- Disengage
  [109304] = {p = 305, cd = 120, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 3, specID = 0, displayName = "Exhilaration"}, -- Exhilaration
  [264735] = {p = 306, cd = 180, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, possibleSpellIDs = {281195, 264735}, class = 3, specID = 0, displayName = "Survival of the Fittest",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 30, 0
    end
  }, -- Survival of the Fittest
  [272679] = {p = 307, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, possibleSpellIDs = {388035}, class = 3, specID = 0, displayName = "Fortitude of the Bear",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth*0.2 -- in reality increases health, but showing it was 20% absorb should be fine for this purpose
    end
  }, -- Fortitude of the Bear
  -- BM & MM
  --[392060] = {p = 311, cd = 60, t = {aoeUtilitySilence = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 3, specID = {253,254}, displayName = "Wailing Arrow"}, -- Wailing Arrow
  -- BM
  -- MM
  -- Survival
  --#endregion
  -- #region Mage
  [1953] = {p = 401, cd = 15, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 8, specID = 0, displayName = "Blink"}, -- Blink
  [212653] = {p = 402, cd = 25, t = {movement = true}, charges = 2, activation = {e = "SPELL_CAST_SUCCESS"}, class = 8, specID = 0, displayName = "Shimmer"}, -- Shimmer
  [66] = {p = 403, cd = 300, t = {targetDrop = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 8, specID = 0, displayName = "Invisibility"}, -- Invisibility
  [45438] = {p = 404, cd = 240, t = {all = true, immunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, preventUsage = 41425, class = 8, specID = 0, displayName = "Ice Block",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return immunity and 100 or 0, 0
    end
  }, -- Ice Block
  [414658] = {p = 405, cd = 240, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, preventUsage = 41425, class = 8, specID = 0, displayName = "Ice Cold",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 70, 0
    end
  }, -- Ice Cold
  [342245] = {p = 406, cd = 60, t = {heal = true}, activation = {e = "SPELL_SUMMON", b = 342246}, class = 8, specID = 0, displayName = "Alter Time"}, -- Alter Time
  [55342] = {p = 407, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 8, specID = 0, displayName = "Mirror Image",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[123417] and 25 or 20, 0 -- Phantasmal Image increases damage reduction by 5%
    end
  }, -- Mirror Image
  [110959] = {p = 408, cd = 120, t = {all = true, targetDrop = true}, activation = {e = "SPELL_CAST_SUCCESS", b = 113862}, class = 8, specID = 0, displayName = "Greater Invisibility",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 60, 0
    end
  }, -- Greater Invisibility
  [389713] = {p = 409, cd = 15, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 8, specID = 0, displayName = "Displacement"}, -- Displacement
  [414660] = {p = 410, cd = 120, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 8, specID = 0, displayName = "Mass Barrier"}, -- Mass Barrier
  -- Fire
  [235313] = {p = 411, cd = 25, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 8, specID = 63, displayName = "Blazing Barrier",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return aoe and talents[117252] and 5 or 0, maxHealth * (talents[117425] and 0.25 or 0.2) -- Imbued Warding procs another shield at 25% effectiveness
    end
  }, -- Blazing Barrier
  [86949] = {p = 412, cd = 300,  debuffOnly = 87024, t = {cheatDeath = true}, activation = {e = "SPELL_AURA_APPLIED", b = 87023}, class = 8, specID = 63, displayName = "Cauterize"}, -- Cauterize
  -- Frost
  [11426] = {p = 421, cd = 25, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 8, specID = 64, displayName = "Ice Barrier",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth * (talents[117425] and 0.25 or 0.2) -- Imbued Warding procs another shield at 25% effectiveness
    end
  }, -- Ice Barrier
  [235219] = {p = 422, cd = 300, t = {absorb = true, all = true, immunity = true}, activation = {e = "SPELL_CAST_SUCCESS"}, reset = {[11426] = true, [45438] = true, [414659] = true, [414658] = true}, class = 8, specID = 64, displayName = "Cold Snap"}, -- Cold Snap, reset Ice Barrier and Ice Block/Cold on use
  -- Arcane
  [235450] = {p = 431, cd = 25, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 8, specID = 62, displayName = "Prismatic Barrier",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return aoe and talents[117252] and 5 or 0, maxHealth * 0.2
    end
  }, -- Prismatic Barrier
  -- #endregion
  -- #region Monk
  [109132] = {p = 501, cd = 20, t = {movement = true}, charges = 2, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 0, displayName = "Roll"}, -- Roll
  [116841] = {p = 502, cd = 30, t = {movement = true, movementExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 0, displayName = "Tiger's Lust"}, -- Tiger's Lust
  [115008] = {p = 503, cd = 20, t = {movement = true}, charges = 2, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 0, displayName = "Chi Torpedo"}, -- Chi Torpedo
  [119996] = {p = 504, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 0, displayName = "Transcendence: Transfer"}, -- Transcendence: Transfer
  [116844] = {p = 505, cd = 30, t = {aoeUtility = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 0, displayName = "Ring of Peace"}, -- Ring of Peace
  [122783] = {p = 506, cd = 90, t = {magic = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 0, displayName = "Diffuse Magic",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return damageType == "magic" and 60, 0
    end
  }, -- Diffuse Magic
  [122278] = {p = 507, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 0, displayName = "Dampen Harm"}, -- Dampen Harm
  [115203] = {p= 509, cd = 360, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 0, displayName = "Fortifying Brew",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      local _dr = 20
      local _hpGain = 20
      if talents[124970] then -- Ironshell Brew
        _dr = _dr + 10
        _hpGain = _hpGain + 10
      end
      if talents[125057] then -- Niuzao's Protection, gives 25% of max hp absorb
        _hpGain = _hpGain + 25
      end
      return _dr, maxHealth*(_hpGain/100)
    end
  }, -- Fortifying Brew
  -- Brewmaster
  [322507] = {p = 511, cd = 60, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 268, displayName = "Celestial Brew"}, -- Celestial Brew
  [115176] = {p = 512, cd = 300, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 268, displayName = "Zen Meditation"}, -- Zen Meditation
  -- Windwalker
  [122470] = {p = 521, cd = 90, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 269, displayName = "Touch of Karma",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth*0.5
    end
}, -- Touch of Karma
  [101545] = {p = 522, cd = 25, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 269, displayName = "Flying Serpent Kick"}, -- Flying Serpent Kick
  -- Mistweaver
  [116849] = {p = 531, cd = 120, t = {absorb = true, absorbExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 10, specID = 270, externalType = "DR", displayName = "Life Cocoon"}, -- Life Cocoon
  [115310] = {p = 532, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 270, displayName = "Revival"}, -- Revival
  [388615] = {p = 533, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 270, displayName = "Restoral"}, -- Restoral
  [322118] = {p = 534, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 270, displayName = "Yu'lon"}, -- Invoke Yu'lon, the Jade Serpent
  [325197] = {p = 535, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 10, specID = 270, displayName = "Chi-ji"}, -- Invoke Chi-ji, the Red Crane
  --#endregion
  -- #region Paladin
  [642] = {p = 601, cd = 300, t = {all = true, immunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, preventUsage = 25771, class = 2, specID = 0, displayName = "Divine Shield",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return immunity and 100 or 0, 0
    end
  }, -- Divine Shield
  [1044] = {p = 602, cd = 25, t = {movement = true, movementExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 0, displayName = "Blessing of Freedom"}, -- Blessing of Freedom
  [190784] = {p = 603, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = 221886}, class = 2, specID = 0, displayName = "Divine Steed"}, -- Divine Steed
  [6940] = {p = 604, cd = 120, t = {allExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 0, externalType = "DR", displayName = " Blessing of Sacrifice"}, -- Blessing of Sacrifice
  [633] = {p = 605, cd = 600, t = {heal = true, healExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, preventUsage = 25771, class = 2, specID = 0, displayName = "Lay on Hands"}, -- Lay on Hands
  [1022] = {p = 606, cd = 300, t = {physical = true, physicalImmunity = true, physicalExt = true, physicalImmunityExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, preventUsage = 25771, class = 2, specID = 0, displayName = "Blessing of Protection"}, -- Blessing of Protection
  -- Holy & Retribution
  [498] = {p = 611, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = {65,70}, displayName = "Divine Protection",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[102526] and 40 or 20, 0 -- Aegis of Protection (Retribution)
    end
  }, -- Divine Protection
  -- Protection
  [31850] = {p = 621, cd = 120, t = {all = true, cheatDeath = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 66, displayName = "Ardent Defender"}, -- Ardent Defender
  [204018] = {p = 622, cd = 180, t = {magic = true, magicImmunity = true, magicExt = true, magicImmunityExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, preventUsage = 25771, class = 2, specID = 66, displayName = "Blessing of Spellwarding"}, -- Blessing of Spellwarding
  [86659] = {p = 623, cd = 300, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, possibleSpellIDs = {212641}, class = 2, specID = 66, displayName = "Guardian of Ancient Kings"}, -- Guardian of Ancient Kings
  [387174] = {p = 624, cd = 60, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 66, displayName = "Eye of Tyr"}, -- Eye of Tyr
  -- Holy
  [31884] = {p = 631, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 65, displayName = "Avenging Wrath"}, -- Avenging Wrath
  [216331] = {p = 632, cd = 60, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 65, displayName = "Avenging Crusader"}, -- Avenging Crusader
  --[105809] = {p = 633, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 65, displayName = "Holy Avenger"}, -- Holy Avenger
  [31821] = {p = 634, cd = 180, t = {allRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 65, displayName = "Aura Mastery"}, -- Aura Mastery
  [200652] = {p = 635, cd = 90, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 2, specID = 65, displayName = "Tyr's Deliverance"}, -- Tyr's Deliverance
  
  -- Retribution
  [184662] = {p = 641, cd = 120, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 70, displayName = "Shield of Vengeance",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth*0.30
    end
}, -- Shield of Vengeance
  --[205191] = {p = 642, cd = 60, t = {physical = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 2, specID = 70, displayName = "Eye for an Eye"}, -- Eye for an Eye
  --#endregion
  -- #region Priest
  [586] = {p = 701, cd = 30, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 0, displayName = "Fade",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[103835] and 10 or 0, 0 -- Translucent Image
    end
  }, -- Fade
  [19236] = {p = 702, cd = 90, t = {all = true, heal = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 0, displayName = "Desperate Prayer",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth*(talents[103826] and 0.4 or 0.25) -- Light's Inspiration increases health gain from 25% to 40%
    end
  }, -- Desperate Prayer
  [121536] = {p = 703, cd = 20, t = {movement = true}, charges = 3, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 0, displayName = "Angelic Feather"}, -- Angelic Feather
  [10060] = {p = 704, cd = 120, t = {dpsExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = {256,257}, displayName = "Power Infusion"}, -- Power Infusion
  [108968] = {p = 705, cd = 300, t = {healExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 0, displayName = "Void Shift"}, -- Void Shift
  [73325] = {p = 705, cd = 90, t = {movementExt = true, gripExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 0, externalType = "GRIP", displayName = "Leap of Faith"}, -- Leap of Faith
  [32375] = {p = 706, cd = 120, t = {dispelExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 0, displayName = "Mass Dispel"}, -- Mass Dispel
  -- Holy
  [47788] = {p = 711, cd = 180, t = {heal = true, healExt = true, cheatDeath = true, cheatDeathExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 257, externalType = "DR", displayName = "Guardian Spirit"}, -- Guardian Spirit
  [64843] = {p = 712, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 257, displayName = "Divine Hymn"}, -- Divine Hymn
  [64901] = {p = 713, cd = 180, t = {mana = true, aoeUtility = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 257, displayName = "Symbol of Hope"}, -- Symbol of Hope
  [200183] = {p = 714, cd = 120, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 257, displayName = "Apotheosis"}, -- Apotheosis
  [265202] = {p = 715, cd = 720, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 257, displayName = "Holy Word: Salvation"}, -- Holy Word: Salvation
  [391124] = {p = 716, cd = 600,  debuffOnly = 391124, t = {cheatDeath = true}, activation = {e = "SPELL_AURA_APPLIED"}, class = 5, specID = 257, displayName = "Restitution"}, -- Restitution
  [372835] = {p = 717, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 257, displayName = "Lightwell"}, -- Lightwell
  -- Disc
  [33206] = {p = 721, cd = 180, t = {all = true, allExt = true,}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 256, externalType = "DR", displayName = "Pain Suppression"}, -- Pain Suppression
  [62618] = {p = 722, cd = 180, t = {allRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 256, displayName = "Power Word: Barrier"}, -- Power Word: Barrier
  [47536] = {p = 723, cd = 90, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 256, displayName = "Rapture"}, -- Rapture
  [472433] = {p = 724, cd = 90, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 256, displayName = "Evangelism"}, -- Evangelism
  [421453] = {p = 725, cd = 240, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 5, specID = 256, displayName = "Ultimate Penitence"}, -- Ultimate Penitence
  
  -- Shadow
  [15286] = {p = 731, cd = 90, t = {healRaidDPS = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 258, displayName = "Vampiric Embrace"}, -- Vampiric Embrace
  [47585] = {p = 732, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 5, specID = 258, displayName = "Dispersion",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 75, 0
    end
  }, -- Dispersion
  --#endregion
  -- #region Rogue
  [185311] = {p = 801, cd = 30, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 4, specID = 0, displayName = "Crimson Vial"}, -- Crimson Vial
  [1856] = {p = 802, cd = 120, t = {targetDrop = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 4, specID = 0, displayName = "Vanish"}, -- Vanish
  [5277] = {p = 803, cd = 120, t = {physical = true, physicalImmunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 4, specID = 0, displayName = "Evasion",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return (talents[126029] and damageType == "magic" and 20 or 0) + (talents[112632] and 20 or 0), 0 -- Bait and Switch + Elusiveness
    end
  }, -- Evasion
  [1966] = {p = 804, cd = 15, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 4, specID = 0, displayName = "Feint",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return aoe and (talents[120130] and 50 or 40) or talents[112632] and 20 or 0, 0 -- Mirrors, Elusiveness
    end
  }, -- Feint
  [31224] = {p = 805, cd = 120, t = {magic = true, magicImmunity = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 4, specID = 0, displayName = "Cloak of Shadows",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return (damageType == "magic" and immunity and 100) or (damageType == "physical" and talents[126029] and 20) or 0, 0
    end
  }, -- Cloak of Shadows
  [36554] = {p = 806, cd = 30, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 4, specID = 0, displayName = "Shadowstep"}, -- Shadowstep
  [2983] = {p = 807, cd = 120, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 4, specID = 0, displayName = "Sprint"}, -- Sprint
  [31230] = {p = 808, cd = 360,  debuffOnly = 45181, t = {cheatDeath = true}, activation = {e = "SPELL_AURA_APPLIED", b = true}, class = 4, specID = 0, displayName = "Cheating Death"}, -- Cheating Death
  -- Assassination
  -- Sublety
  -- Outlaw
  [195457] = {p = 811, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 4, specID = 260, displayName = "Grappling Hook"}, -- Grappling Hook
  --#endregion
  -- #region Shaman
  [108271] = {p = 901, cd = 90, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 7, specID = 0, displayName = "Astral Shift",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[127887] and 60 or 40, 0 -- Astral Bulwark increases the DR from 40 to 60
    end
  }, -- Astral Shift
  [198103] = {p = 902, cd = 300, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b =  337984}, class = 7, specID = 0, displayName = "Earth Elemental",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth*0.15 -- This is actually hp increase
    end
  }, -- Earth Elemental
  [192077  ] = {p = 903, cd = 120, t = {movementRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 0, displayName = "Wind Rush Totem"}, -- Wind Rush Totem
  [58875] = {p = 904, cd = 60, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 7, specID = 0, displayName = "Spirit Walk"}, -- Spirit Walk
  [192063] = {p = 905, cd = 30, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 0, displayName = "Gust of Wind"}, -- Gust of Wind
  [108281] = {p = 906, cd = 120, t = {healRaidDPS = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 7, specID = 0, displayName = "Ancestral Guidance"}, -- Ancestral Guidance
  [20608] = {p = 907, cd = 1800, t = {cheatDeath = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 0, displayName = "Reincarnation"}, -- Reincarnation
  [108270] = {p = 908, cd = 180, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 0, displayName = "Stone Bulwark Totem",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, 2700000 -- This isnt actually correct, but should be on the lower side to give some room for error, TODO figure out whats the actual scaling, based on spell power?
    end
  }, -- Stone Bulwark Totem
  -- Elemental
  -- Enhancement
  [196884] = {p = 911, cd = 30, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 263, displayName = "Feral Lunge"}, -- Feral Lunge
  -- Restoration
  [98008] = {p = 921, cd = 180, t = {allRaid = true, healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 264, displayName = "Spirit Link Totem"}, -- Spirit Link Totem
  [16191] = {p = 922, cd = 180, t = {mana = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 264, displayName = "Mana Tide Totem"}, -- Mana Tide Totem
  [108280] = {p = 923, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 264, displayName = "Healing Tide Totem"}, -- Healing Tide Totem
  [207399] = {p = 924, cd = 300, t = {allRaid = true, cheatDeathExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 7, specID = 264, displayName = "Ancestral Protection Totem"}, -- Ancestral Protection Totem
  [114052] = {p = 925, cd = 180, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 7, specID = 264, displayName = "Ascendance"}, -- Ascendance
  --#endregion
  -- #region Warlock
  [104773] = {p = 1001, cd = 180, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 9, specID = 0, displayName = "Unending Resolve",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[91468] and 40 or 25, 0 -- Strength of Will increases the DR from 25 to 40
    end
  }, -- Unending Resolve
  [48020] = {p = 1002, cd = 30, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 9, specID = 0, displayName = "Demonic Circle: Teleport"}, -- Demonic Circle: Teleport
  [6789] = {p = 1003, cd = 45, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 9, specID = 0, displayName = "Mortal Coil"}, -- Mortal Coil
  [108416] = {p = 1004, cd = 60, t = {absorb = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 9, specID = 0, displayName = "Dark Pact",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, maxHealth*0.9*(talents[123840] and 0.5 or 0.4) -- Friends in Dark Places increases 50% of the sacrificed health, 10% of current health? Assume it is used at 90% to give some room for error TODO double check values
    end
  }, -- Dark Pact
  -- Destruction
  -- Affliction
  -- Demonology
  --#endregion
  -- #region Warrior
  [100] = {p = 1101, cd = 20, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 0, displayName = "Charge"}, -- Charge
  [202168] = {p = 1102, cd = 30, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 0, displayName = "Impending Victory"}, -- Impending Victory
  [3411] = {p = 1103, cd = 30, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 0, displayName = "Intervene"}, -- Intervene
  [97462] = {p = 1104, cd = 180, t = {allRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 0, displayName = "Rallying Cry"}, -- Rallying Cry
  [6544] = {p = 1105, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, possibleSpellIDs={6544, 52174}, class = 1, specID = 0, displayName = "Heroic Leap"}, -- Heroic Leap
  [383762] = {p = 1106, cd = 180, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 0, displayName = "Bitter Immunity"}, -- Bitter Immunity
  [23920] = {p = 1106, cd = 25, t = {magic = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 1, specID = 0, displayName = "Spell Reflection",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return damageType == "magic" and 20 or 0, 0
    end
  }, -- Spell Reflection
  [385952] = {p = 1134, cd = 45, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 73, displayName = "Intervene"}, -- Intervene
  -- Fury
  [184364] = {p = 1111, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 1, specID = 72, displayName = "Enraged Regeneration",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 30, 0
    end
  }, -- Enraged Regeneration
  -- Arms
  [118038] = {p = 1121, cd = 120, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 1, specID = 71, displayName = "Die by the Sword",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 30, 0
    end
  }, -- Die by the Sword
  -- Protection
  [1160] = {p = 1131, cd = 45, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 1, specID = 73, displayName = "Demoralizing Shout"}, -- Demoralizing Shout
  [12975] = {p = 1132, cd = 180, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 1, specID = 73, displayName = "Last Stand"}, -- Last Stand
  [871] = {p = 1133, cd = 210, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 1, specID = 73, displayName = "Shield Wall"}, -- Shield Wall
  --#endregion
  -- #region Evoker
  [363916] = {p = 1201, cd = 150, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 13, specID = 0, displayName = "Obsidian Scales",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return talents[117530] and 40 or 30, 0 -- Hardened Scales (Scalecommander)
    end
  }, -- Obsidian Scales
  [374348] = {p = 1202, cd = 90, t = {all = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 13, specID = 0, displayName = "Renewing Blaze"}, -- Renewing Blaze
  [370665] = {p = 1203, cd = 60, t = {movementExt = true, gripExt = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 0, externalType = "GRIP", displayName = "Rescue",
    drFunc = function(maxHealth, damageType, immunity, aoe, specID, talents)
      return 0, talents[115595] and maxHealth*0.30 or 0 -- Twin Guardian
    end
  }, -- Rescue
  [374968] = {p = 1204, cd = 120, t = {movementRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 0, displayName = "Time Spiral"}, -- Time Spiral
  [360995] = {p = 1205, cd = 24, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 0, displayName = "Verdant Embrace"}, -- Verdant Embrace
  [374251] = {p = 1207, cd = 60, t = {dispelExt = true}, activation = {e = "SPELL_DISPEL"}, class = 13, specID = 0, displayName = "Cauterizing Flame"}, -- Cauterizing Flame
  [372048] = {p = 1208, cd = 60, t = {aoeUtility = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 0, displayName = "Oppressing Roar"}, -- Oppressing Roar
  [406732] = {p = 1230, cd = 180, t = {mana = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 13, specID = 0, displayName = "Spatial Paradox"}, -- Spatial Paradox, set as "mana" category because there isn't anything else thats even close

  -- Devastation
  -- Preservation
  [363534] = {p = 1221, cd = 240, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 1468, displayName = "Rewind"}, -- Rewind
  [357170] = {p = 1222, cd = 60, t = {all = true, allExt = true}, activation = {e = "SPELL_CAST_SUCCESS", b=true}, class = 13, specID = 1468, externalType = "DR", displayName = "Time Dilation"}, -- Time Dilation
  [370960] = {p = 1223, cd = 180, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 13, specID = 1468, displayName = "Emerald Communion"}, -- Emerald Communion
  [359816] = {p = 1224, cd = 120, t = {healRaid = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 1468, displayName = "Dream Flight"}, -- Dream Flight
  [374227] = {p = -10, cd = 120, t = {allRaid = true, movementRaid = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 13, specID = 1468, displayName = "Zephyr"}, -- Zephyr
  -- Augmentation
  [395152] = {p = 1231, cd = 30, t = {other = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 13, specID = 1473, displayName = "Ebon Might"}, -- Ebon Might
  --[406732] = {p = 1230, cd = 120, t = {mana = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 13, specID = 1473}, -- Spatial Paradox, set as "mana" category because there isn't anything else thats even close
  --#endregion
  -- #region Racials
  -- Dark Iron Dwarf
  [265221] = {p = -1006, cd = 120, t = {dispelSelf = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 0, specID = 1, displayName = "Fireblood"}, -- Fireblood
  -- Draenei
  [59542] = {p = -1000, cd = 180, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 0, specID = 1, displayName = "Gift of the Naaru"}, -- Gift of the Naaru
  -- Dwarf
  [20594] = {p = -1010, cd = 120, t = {physical = true, dispelSelf = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 0, specID = 1, displayName = "Stoneform"}, -- Stoneform
  -- Gnome
  -- Human
  -- Kul Tiran
  -- Lightforged Draenei
  -- Mechagnome
  -- Night Elf
  [58984] = {p = -1001, cd = 120, t = {targetDrop = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 0, specID = 1, displayName = "Shadowmeld"}, -- Shadowmeld
  -- Pandaren
  -- Void Elf
  [256948] = {p = -1002, cd = 180, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 0, specID = 1, displayName = "Spatial Rift"}, -- Spatial Rift
  -- Worgen
  [68992] = {p = -1003, cd = 120, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 0, specID = 1, displayName = "Darkflight"}, -- Darkflight
  -- Blood Elf
  -- Goblin
  [69070] = {p = -1004, cd = 90, t = {movement = true}, activation = {e = "SPELL_CAST_SUCCESS"}, class = 0, specID = 1, displayName = "Rocket Jump"}, -- Rocket Jump
  -- Highmountain Tauren
  -- Mag'har Orc
  -- Nightborne
  -- Orc
  -- Tauren
  -- Troll
  -- Undead
  -- Vulpera
  -- Zandalari Troll
  [291944] = {p = -1005, cd = 210, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS", b = true}, class = 0, specID = 1, displayName = "Regeneratin'"}, -- Regeneratin'
  --#endregion
  -- #region Items
  [-5512] = {p = -100, cd = 180, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS", s = 6262}, class = 0, specID = 2, displayName = "Healthstone"}, -- Healthstone
  [-13446] = {p = -101, cd = 300, t = {heal = true}, activation = {e = "SPELL_CAST_SUCCESS"}, possibleSpellIDs = {423414, 415569}, class = 0, specID = 2, displayName = "Health Potion"}, -- spellIDs are listed for faster cd tracking, Potion of Withering Dreams, Dreamwalker's Healing Potion
  --#endregion
}
local cleuEventsToUse = {}
local currentSpecID = 0
local preventsUsageOfOtherSpells = {}
local morphedSpells = {}
local debuffsOnly = {}
local relevantAurasBySpec = {} -- so we don't have to look for them during OnUpdate
local checkDestOnly = {
  [388035] = true, -- Fortitude of the Bear (from pet)
}
do
  local prioMods = {
    -- Raid
    allRaid = 900000,
    magicRaid = 890000,
    healRaid = 880000,
    healRaidDPS = 870000,
    -- Externals
    allExt = 800000,
    absorbExt = 790000,
    cheatDeathExt = 780000,
    healExt = 770000,
    physicalExt = 760000,
    magicExt = 750000,
    physicalImmunityExt = 740000,
    magicImmunityExt = 730000,
    gripExt = 720000,
    dispelExt = 710000,
    -- Immunity
    immunity = 700000,
    magicImmunity = 690000,
    physicalImmunity = 680000,
    -- Cheat deaths
    cheatDeath = 600000,
    -- Personals
    all = 500000,
    magic = 490000,
    physical = 480000,
    absorb = 470000,
    heal = 460000,
    dispelSelf = 450000,
    -- Movement
    movementRaid = 400000,
    movement = 390000,
    movementExt = 380000,
    -- Mana
    mana = 300000,
    -- Utility
    aoeUtilityGrip = 200000,
    aoeUtilitySilence = 190000,
    aoeUtility = 180000,
    targetDrop = 170000,
    dpsExt = 160000,
    other = 100000,
  }
  for _,specs in pairs(classIDsToSpecID) do
    for specID in pairs(specs) do
      relevantAurasBySpec[specID] = {}
    end
  end
  local function addSpellToRelevantAuras(spellID, spellData)
    if spellData.class == 0 then return end -- class 0 = items
    if type(spellData.specID) == "table" then
      for _,specID in pairs(spellData.specID) do
        relevantAurasBySpec[specID][spellID] = true
      end
    elseif spellData.specID == 0 then -- specID 0 = all specs for that class
      for specID in pairs(classIDsToSpecID[spellData.class]) do
        relevantAurasBySpec[specID][spellID] = true
      end
    else
      relevantAurasBySpec[spellData.specID][spellID] = true
    end
  end
  for k,v in pairs(spellData) do
    if v.debuffOnly then
      debuffsOnly[k] = type(v.debuffOnly) == "number" and v.debuffOnly or k
    end
    if not cleuEventsToUse[v.activation.e] then
      cleuEventsToUse[v.activation.e] = {}
    end
    if v.activation.s and tonumber(v.activation.s) then -- specific spell id, don't use key
      cleuEventsToUse[v.activation.e][v.activation.s] = k
    else
      cleuEventsToUse[v.activation.e][k] = k
    end
    if v.activation.b or v.preventUsage then
      if v.activation.b then
        if not cleuEventsToUse["SPELL_AURA_APPLIED"] then
          cleuEventsToUse["SPELL_AURA_APPLIED"] = {}
          cleuEventsToUse["SPELL_AURA_REMOVED"] = {}
        end
        if tonumber(v.activation.b) then -- specific spell id, don't use key
          cleuEventsToUse["SPELL_AURA_APPLIED"][v.activation.b] = k
          cleuEventsToUse["SPELL_AURA_REMOVED"][v.activation.b] = k
          addSpellToRelevantAuras(v.activation.b, v)
        else
          cleuEventsToUse["SPELL_AURA_APPLIED"][k] = k
          cleuEventsToUse["SPELL_AURA_REMOVED"][k] = k
          addSpellToRelevantAuras(k, v)
        end
      end
      if v.preventUsage then
        if not preventsUsageOfOtherSpells[v.preventUsage] then
          preventsUsageOfOtherSpells[v.preventUsage] = {}
        end
        preventsUsageOfOtherSpells[v.preventUsage][k] = true
        addSpellToRelevantAuras(v.preventUsage, v)
      end
    end
    if v.possibleSpellIDs then
      for _,id in pairs(v.possibleSpellIDs) do
        morphedSpells[id] = k
      end
    end
    if k > 0 then -- spells
      local _spellData =  C_Spell.GetSpellInfo(k)
      v.icon = _spellData and _spellData.iconID or 134400 -- question mark to avoid errors later on
    else -- items
      local _iconID = select(5, C_Item.GetItemInfoInstant(k*-1)) -- ?? should return table?
      v.icon = _iconID or 134400 -- question mark to avoid errors later on
    end
    -- generate final prio value
    local _catPrio = 0
    for cat in pairs(v.t) do
      if not prioMods[cat] then print(cat) end
      if prioMods[cat] > _catPrio then
        _catPrio = prioMods[cat]
      end
    end
    v.finalPrio = _catPrio + v.p
  end
end
local rangeFuncsPerSpec = {
  [250] = function(unit) return UnitInRange(unit) end, -- Death Knight, Blood
  [251] = function(unit) return UnitInRange(unit) end, -- Death Knight, Frost
  [252] = function(unit) return UnitInRange(unit) end, -- Death Knight, Unholy
  [577] = function(unit) return UnitInRange(unit) end, -- Demon Hunter, Havoc
  [581] = function(unit) return UnitInRange(unit) end, -- Demon Hunter, Vengeance
  [102] = function(unit) return UnitInRange(unit) end, -- Druid, Balance
  [103] = function(unit) return UnitInRange(unit) end, -- Druid, Feral
  [104] = function(unit) return UnitInRange(unit) end, -- Druid, Guardian
  [105] = function(unit) -- Druid, Restoration
    if ns.isDragonflight then
      return IsSpellInRange("Rejuvenation", unit) == 1
    else
      return C_Spell.IsSpellInRange("Rejuvenation", unit)
    end
  end,
  [1467] = function(unit) -- Evoker, Devastation
    if cachedTalents[115596] then
      if ns.isDragonflight then
        return IsSpellInRange("Rescue", unit) == 1
      else
        return C_Spell.IsSpellInRange("Rescue", unit)
      end
    else
      return UnitInRange(unit)
    end
  end,
  [1468] = function(unit) -- Evoker, Preservation
    if ns.isDragonflight then
      return IsSpellInRange("Time Dilation", unit) == 1
    else
      return C_Spell.IsSpellInRange("Time Dilation", unit)
    end
  end,
  [1473] = function(unit) -- Evoker, Augmentation
    if cachedTalents[115596] then
      if ns.isDragonflight then
        return IsSpellInRange("Rescue", unit) == 1
      else
        return C_Spell.IsSpellInRange("Rescue", unit)
      end
    else
      return UnitInRange(unit)
    end
  end,
  [253] = function(unit) return UnitInRange(unit) end, -- Hunter, Beast Mastery
  [254] = function(unit) return UnitInRange(unit) end, -- Hunter, Marksmanship
  [255] = function(unit) return UnitInRange(unit) end, -- Hunter, Survival
  [62] = function(unit) return UnitInRange(unit) end, -- Mage, Arcane
  [63] = function(unit) return UnitInRange(unit) end, -- Mage, Fire
  [64] = function(unit) return UnitInRange(unit) end, -- Mage, Frost
  [268] = function(unit) -- Monk, Brewmaster
    if ns.isDragonflight then
      return IsSpellInRange("Vivify", unit) == 1
    else
      return C_Spell.IsSpellInRange("Vivify", unit)
    end
  end,
  [269] = function(unit) -- Monk, Windwalker
    if ns.isDragonflight then
      return IsSpellInRange("Vivify", unit) == 1
    else
      return C_Spell.IsSpellInRange("Vivify", unit)
    end
  end,
  [270] = function(unit) -- Monk, Mistweaver
    if ns.isDragonflight then
      return IsSpellInRange("Vivify", unit) == 1
    else
      return C_Spell.IsSpellInRange("Vivify", unit)
    end
  end,
  [65] = function(unit) -- Paladin, Holy
    if ns.isDragonflight then
      return IsSpellInRange("Flash of Light", unit) == 1
    else
      return C_Spell.IsSpellInRange("Flash of Light", unit)
    end
  end,
  [66] = function(unit) -- Paladin, Protection
    if ns.isDragonflight then
      return IsSpellInRange("Flash of Light", unit) == 1
    else
      return C_Spell.IsSpellInRange("Flash of Light", unit)
    end
  end,
  [70] = function(unit) -- Paladin, Retribution
    if ns.isDragonflight then
      return IsSpellInRange("Flash of Light", unit) == 1
    else
      return C_Spell.IsSpellInRange("Flash of Light", unit)
    end
  end,
  [256] = function(unit) -- Priest, Discipline
    if ns.isDragonflight then
      return IsSpellInRange("Pain Suppression", unit) == 1
    else
      return C_Spell.IsSpellInRange("Pain Suppression", unit)
    end
  end,
	[257] = function(unit) -- Priest, Holy
    if ns.isDragonflight then
      return IsSpellInRange("Guardian Spirit", unit) == 1
    else
      return C_Spell.IsSpellInRange("Guardian Spirit", unit)
    end
  end,
  [258] = function(unit) -- Priest, Shadow
    if cachedTalents[103868] then
      if ns.isDragonflight then
        return IsSpellInRange("Leap of Faith", unit) == 1
      else
        return C_Spell.IsSpellInRange("Leap of Faith", unit)
      end
    else
      return UnitInRange(unit)
    end
  end,
  [259] = function(unit) return UnitInRange(unit) end, -- Rogue, Assasination
  [260] = function(unit) return UnitInRange(unit) end, -- Rogue, Outlaw
  [261] = function(unit) return UnitInRange(unit) end, -- Rogue, Sublety
  [262] = function(unit) return UnitInRange(unit) end, -- Shaman, Elemental
  [263] = function(unit) return UnitInRange(unit) end, -- Shaman, Enhancement
  [264] = function(unit) return UnitInRange(unit) end, -- Shaman, Restoration
  
  [265] = function(unit) return UnitInRange(unit) end, -- Warlock, Affliction
  [266] = function(unit) return UnitInRange(unit) end, -- Warlock, Demonology
  [267] = function(unit) return UnitInRange(unit) end, -- Warlock, Destruction
  [71] = function(unit) return UnitInRange(unit) end, -- Warrior, Arms
  [72] = function(unit) return UnitInRange(unit) end, -- Warrior, Fury
	[73] = function(unit) return UnitInRange(unit) end, -- Warrior, Protection
}
local function fetchAllPossiblyRelevantAuras(guid, specID)
  local targetUnitID = groupData[guid] and groupData[guid].unitID or nil
  if not targetUnitID then
    targetUnitID = UnitTokenFromGUID(guid)
    if not targetUnitID then return {} end
  end
  local possiblyRelevantSpells = relevantAurasBySpec[specID]
  if not possiblyRelevantSpells then return {} end
  local auras = {}
  local auraSourceGUID, auraData
  for i = 1, 255 do
    auraData = C_UnitAuras.GetBuffDataByIndex(targetUnitID, i)
    if not auraData then break end
    if auraData.sourceUnit then -- we only care about self casted buffs
      auraSourceGUID = UnitGUID(auraData.sourceUnit)
      if auraSourceGUID == guid then
        auras[auraData.spellId] = {duration = auraData.duration, expirationTime = auraData.expirationTime}
      end
    end
  end
  for i = 1, 255 do
    auraData = C_UnitAuras.GetDebuffDataByIndex(targetUnitID, i)
    if not auraData then break end
    auras[auraData.spellId] = {duration = auraData.duration, expirationTime = auraData.expirationTime}
  end
  return auras
end
local function convertSpellToWAFormat(spellID, data, unitID)
  return {
    icon = spellData[spellID].icon,
    available = (data.currentCharges and data.currentCharges > 0) or (data.endTime == 0),
    maxCharges = data.maxCharges,
    currentCharges = data.maxCharges > 1 and data.charges or nil,
    endTime = data.endTime > 0 and data.endTime or 1,
    duration = data.duration,
    auraDuration = data.auraDuration,
    auraEndTime = data.auraEndTime,
    auraActive = data.auraEndTime and data.auraEndTime > 0,
    preventUsage = data.preventUsage,
    preventUsageDuration = data.preventUsageDuration,
    prio = spellData[spellID].finalPrio,
    unitID = unitID,
  }
end
local function convertExternalDataToWAFormat(requester, spellID, target, externalType)
  if not requester then
    error("no requester found")
    return
  end
  return {
      grip = externalType == "GRIP",
      requester = {
        name = requester.name,
        classColors = CopyTable(requester.classColors),
        colorFormat = requester.colorFormat,
        unitID = requester.unitID,
        guid = requester.guid,
      },
      external = target and {
        spellID = spellID,
        icon = spellData[spellID].icon,
        name = target.name,
        classColors = CopyTable(target.classColors),
        colorFormat = target.colorFormat,
        unitID = target.unitID,
        guid = target.guid
      } or {},
      isForPlayer = requester.guid == playerGUID or (target and target.guid == playerGUID)
    }
end
do
  local function generateSubsets(spells)
    local subsets = {{}}

    -- Iterate over each number and add it to all current subsets
    for _, spellID in ipairs(spells) do
        local newSubsets = {}

        -- Add current number to each of the existing subsets
        for _, subset in ipairs(subsets) do
            local newSubset = {unpack(subset)}
            table.insert(newSubset, spellID)
            table.insert(newSubsets, newSubset)
        end

        -- Merge the new subsets into the main subsets table
        for _, subset in ipairs(newSubsets) do
            table.insert(subsets, subset)
        end
    end
    return subsets
  end
  -- Function to sum the elements of a subset
  local function sumSubset(subset, spells)
    local dr = 1
    local absorb = 0
    for _, spellID in ipairs(subset) do
        dr = dr*spells[spellID].dr
        absorb = absorb + spells[spellID].absorb
    end
    return dr, absorb
  end
  local function findClosest(spells, spellIDs, amount, maxHealth)
    local subsets = generateSubsets(spellIDs)
    local bestSubset = {}
    local smallestCount = 100
    local hpLeft = 0

    for _, subset in ipairs(subsets) do
        local dr, absorb = sumSubset(subset, spells)
        local _hpLeft = maxHealth-(amount*dr-absorb)
        if _hpLeft > 0 and #subset < smallestCount then
          smallestCount = #subset
          bestSubset = subset
          hpLeft = _hpLeft
        end
    end
    return hpLeft, bestSubset
  end
  local blacklistedSpellsPerMechanic = {
    [438974] = { -- Royal Condemnantion
      [370665] = true, -- Rescue
    }
  }
  function private:fetchMaxDR(guid, timeToDamage, damageAmount, damageInfo, spellID)
    if not (guid and timeToDamage and damageAmount) then return end
    if not (groupData[guid] and groupData[guid].spells) then return end
    local _talents = guid == playerGUID and cachedTalents or rosterTalents[guid] and rosterTalents[guid].talents or {}
    local damageType = damageInfo and damageInfo.damageType or ""
    local aoe = damageInfo and damageInfo.aoe or false
    local debuff = damageInfo and damageInfo.debuff or false
    local immunity = damageInfo and damageInfo.immunity or false
    if damageReductionsPerSpec[groupData[guid].specID] then
      damageAmount = damageAmount*damageReductionsPerSpec[groupData[guid].specID](_talents, damageType, debuff, aoe)
    end
    if aoe then
      damageAmount = damageAmount * (1-GetAvoidance()/100)
    end
    local maxHealth = UnitHealthMax(groupData[guid].unitID) or 0
    local possibleDRs = {}
    for _spellID, data in pairs(groupData[guid].spells) do
      if not (spellID and blacklistedSpellsPerMechanic[spellID] and blacklistedSpellsPerMechanic[spellID][_spellID]) then
        local available = ((data.currentCharges and data.currentCharges > 0) or (data.endTime == 0) or (data.endTime - GetTime() < timeToDamage)) and not (data.preventUsage and data.preventUsage > GetTime() + timeToDamage)
        if available then
          if spellData[_spellID].drFunc then
            local spellDR, spellAbsorb = spellData[_spellID].drFunc(maxHealth, damageType, immunity, aoe, groupData[guid].specID, _talents)
            if spellDR > 0 or spellAbsorb > 0 then
              possibleDRs[_spellID] = {
                dr = (100-spellDR)/100,
                absorb = spellAbsorb
              }
            end
          end
        end
      end
    end
    local t = {}
    local maxDR, maxAbsorbs = 1, 0
    local _maxHealth = maxHealth * 0.95 -- assume you are at 95% when damage hits
    for _spellID,drData in pairs(possibleDRs) do
      tinsert(t, _spellID)
      maxDR = maxDR * drData.dr
      maxAbsorbs = maxAbsorbs + drData.absorb
    end
    local hpLeftWithFullUsage = (_maxHealth-((damageAmount*maxDR)-maxAbsorbs))/maxHealth
    if hpLeftWithFullUsage <= 0.1 or #t < 2 then -- dont try to optimize
      return hpLeftWithFullUsage*100, possibleDRs
    end
    local hpLeft, spellsUsed = findClosest(possibleDRs, t, damageAmount, _maxHealth)
    local _t = {}
    for _,_spellID in pairs(spellsUsed) do
      _t[_spellID] = possibleDRs[_spellID]
    end
    return hpLeft/maxHealth*100, _t
  end
end
function LiquidAPI:SuggestPersonals(timeToDamage, damageAmount, damageInfo, spellID, hide)
  local hpLeft, spellsUsed = private:fetchMaxDR(UnitGUID('player'), timeToDamage, damageAmount, damageInfo, spellID)
  if not hide and hpLeft then
    sendWeakAuraEventForExternal_Personal({duration = timeToDamage, hpLeft = hpLeft, spells = spellsUsed})
  end
  return hpLeft, spellsUsed -- in case someone needs these for something
end
--[[  also doubles as default prio list (high -> low)
  DRs
    Paladin, Protection: Blessing of Sacrifice - 9
    Paladin, Retribution: Blessing of Sacrifice - 8
    Evoker, Preservation: Time Dilation - 7
    Druid, Restoration: Ironbark - 6
    Priest, Discipline: Pain Suppression - 5
    Paladin, Holy: Blessing of Sacrifice - 4
    Monk, Mistweaver: Life Cocoon - 3
    Priest, Holy: Guardian Spirit - 2
  Grips
    Priest, Holy: Leap of Faith - 9
    Priest, Shadow: Leap of Faith - 8
    Priest, Discipline: Leap of Faith - 7
    Evoker, Preservation: Rescue - 6
    Evoker, Augmentation: Rescue - 5
    Evoker, Devastation: Rescue - 4
    
]]
local whitelistedExternals = { -- TODO change later to support all externals
  -- Death Knight
  [250] = {DR ={}, GRIP = {}}, -- Blood
  [251] = {DR ={}, GRIP = {}}, -- Frost
  [252] = {DR ={}, GRIP = {}}, -- Unholy
  -- Demon Hunter
  [577] = {DR ={}, GRIP = {}}, -- Havoc
  [581] = {DR ={}, GRIP = {}}, -- Vengeance
  -- Druid
  [102] = {DR ={}, GRIP = {}}, -- Balance
  [103] = {DR ={}, GRIP = {}}, -- Feral
  [104] = {DR ={}, GRIP = {}}, -- Guardian
  [105] = { -- Restoration
    DR ={
      [102342] = 6, -- Ironbark
    },
    GRIP = {},
  },
  -- Evoker
  [1467] = {  -- Devastation
    DR ={},
    GRIP = {
      [370665] = 4, -- Rescue
    }
  },
  [1468] = {  -- Preservation 
    DR ={
      [357170] = 7, -- Time Dilation
    },
    GRIP = {
      [370665] = 6, -- Rescue
    }
  },
  [1473] = {  -- Augmentation 
    DR ={},
    GRIP = {
      [370665] = 5, -- Rescue
    }
  },
  -- Hunter
  [253] = {DR ={}, GRIP = {}}, -- Beast Mastery
  [254] = {DR ={}, GRIP = {}}, -- Marksmanship
  [255] = {DR ={}, GRIP = {}}, -- Survival
  -- Mage
  [62] = {DR ={}, GRIP = {}}, -- Arcane
  [63] = {DR ={}, GRIP = {}}, -- Fire
  [64] = {DR ={}, GRIP = {}}, -- Frost
  -- Monk
  [268] = {DR ={}, GRIP = {}}, -- Brewmaster
  [269] = {DR ={}, GRIP = {}}, -- Windwalker
  [270] = { -- Mistweaver
    DR ={
      [116849] = 3, -- Life Cocoon
    },
    GRIP = {},
  },
  -- Paladin
  [65] = { -- Holy
    DR ={
      [6940] = 4, -- Blessing of Sacrifice
    },
    GRIP = {}
  },
  [66] = { -- Protection
    DR ={
      [6940] = 9, -- Blessing of Sacrifice
    },
    GRIP = {}
  },
  [70] = { -- Retribution
    DR ={
      [6940] = 8, -- Blessing of Sacrifice
    },
    GRIP = {}
  },
  -- Priest
  [256] = { -- Discipline
    DR ={
      [33206] = 5, -- Pain Suppression
    },
    GRIP = {
      [73325] = 7, -- Leap of Faith
    }
  },
  [257] = { -- Holy
    DR ={
      [47788] = 2, -- Guardian Spirit
    },
    GRIP = {
      [73325] = 9, -- Leap of Faith
    }
  },
  [258] = { -- Shadow
    DR ={},
    GRIP = {
      [73325] = 8, -- Leap of Faith
    }
  },
  -- Rogue
  [259] = {DR ={}, GRIP = {}}, -- Assasination
  [260] = {DR ={}, GRIP = {}}, -- Outlaw
  [261] = {DR ={}, GRIP = {}}, -- Sublety
  -- Shaman
  [262] = {DR ={}, GRIP = {}}, -- Elemental
  [263] = {DR ={}, GRIP = {}}, -- Enhancement
  [264] = {DR ={}, GRIP = {}}, -- Restoration
  -- Warlock
  [265] = {DR ={}, GRIP = {}}, -- Affliction
  [266] = {DR ={}, GRIP = {}}, -- Demonology
  [267] = {DR ={}, GRIP = {}}, -- Destruction
  -- Warrior
  [71] = {DR ={}, GRIP = {}}, -- Arms
  [72] = {DR ={}, GRIP = {}}, -- Fury
  [73] = {DR ={}, GRIP = {}}, -- Protection
}
local externalPrioData = {
  blacklist = {
    all = {},
  },
  longGrip = false,
  prio = CopyTable(whitelistedExternals)
}
local function isEligibleForExternal(externalRequestType, externalCategories, blacklistedSpells, targetGUID, requesterGUID, targetUnitID, currentTime)
  if UnitIsDeadOrGhost(targetUnitID) or UnitIsPossessed(targetUnitID) or not UnitIsConnected(targetUnitID) then
    return false
  end
  if not (groupData[targetGUID] and groupData[targetGUID].spells and groupData[targetGUID].specID) then return false end
  if not (externalPrioData.prio[groupData[targetGUID].specID] and externalPrioData.prio[groupData[targetGUID].specID][externalRequestType]) then return end
  local encounterTime = private.encounterStart == 0 and 0 or currentTime-private.encounterStart
  for spellID in pairs(externalPrioData.prio[groupData[targetGUID].specID][externalRequestType]) do -- TODO loop player spells instead of whitelist when supporting all spells
    if groupData[targetGUID].spells[spellID] then
      if groupData[targetGUID].spells[spellID].requested and currentTime - groupData[targetGUID].spells[spellID].requested <= 10 then -- ignore if it was requested in the last 10 seconds
      else
        local shouldSkip = false
        --[[ TODO not currently in use, fix when adding support for all spells
        if blacklistedSpells[spellID] then
          shouldSkip = true
        end
        --]]
        -- TODO check for forbearance when those spells are supported
        local d = groupData[targetGUID].spells[spellID]
        if not ((d.currentCharges and d.currentCharges > 0) or d.endTime == 0 or (d.endTime - GetTime() < 3)) then
          shouldSkip = true
        end
        local catFound = false
        for cat in pairs(externalCategories) do
          if d.defType[cat] then
            catFound = true
            break
          end
        end
        if not catFound then
          shouldSkip = true
        end
        -- check if the time is blacklisted by note
        if not shouldSkip and encounterTime > 0 then
          --externalPrioData.blacklist.all/guid/specid
          if externalPrioData.blacklist.all[spellID] then
            for from,to in pairs(externalPrioData.blacklist.all[spellID]) do
              if from <= encounterTime and to >= encounterTime then
                shouldSkip = true
                break
              end
            end
          end
          if not shouldSkip and externalPrioData.blacklist[groupData[targetGUID].specID] and externalPrioData.blacklist[groupData[targetGUID].specID][spellID] then
            for from,to in pairs(externalPrioData.blacklist[groupData[targetGUID].specID][spellID]) do
              if from <= encounterTime and to >= encounterTime then
                shouldSkip = true
                break
              end
            end
          end
          if not shouldSkip and externalPrioData.blacklist[targetGUID] and externalPrioData.blacklist[targetGUID][spellID] then
            for from,to in pairs(externalPrioData.blacklist[targetGUID][spellID]) do
              if from <= encounterTime and to >= encounterTime then
                shouldSkip = true
                break
              end
            end
          end
        end
        if not shouldSkip then
          return spellID
        end
      end
    end
  end
end
local cachedAssignments = {}
local function setAssignment(requesterGUID, targetGUID, spellID, requestData)
  --requestData.externalType
  if not targetGUID then
    --sendWeakAuraEvent(key, updateType, data, externalType)
    sendWeakAuraEventForExternal(convertExternalDataToWAFormat(groupData[requesterGUID], nil, nil, requestData.externalType), "new")
    return
  end
  -- cache assignment, in case we need to reassign it later
  cachedAssignments[requesterGUID] = {
    target = {
      spellID = spellID,
      guid = targetGUID,
      assignmentTime = GetTime()
    },
    request = requestData,
  }
  groupData[targetGUID].spells[spellID].requested = GetTime()
  sendWeakAuraEventForExternal(convertExternalDataToWAFormat(groupData[requesterGUID], spellID, groupData[targetGUID], requestData.externalType), "new")
end
local throttle = 0
local rangePrefix = true
local function handleQueue(_, elapsed)
  throttle = throttle + elapsed
  do
    for guid,playerData in ns:spairs(thingsToDo.syncs) do
      if groupData[guid] then -- just for safety, shouldn't actually be *needed*
        groupData[guid].specID = playerData.player.specID
        groupData[guid].classID = playerData.player.classID
        groupData[guid].realName = playerData.player.realName
        groupData[guid].name = playerData.player.name
        groupData[guid].colorFormat = playerData.player.colorFormat
        groupData[guid].classColors = playerData.player.classColors
        groupData[guid].position = specIDsToRole[playerData.player.specID] or 9999
        local relevantAuras = fetchAllPossiblyRelevantAuras(guid, playerData.player.specID)
        local t = {}
        local waUpdateData = {
          currentSpells = {},
          removedSpells = {},
          player = {
            guid = guid,
            specID = playerData.player.specID,
            classID = playerData.player.classID,
            realName = playerData.player.realName,
            name = playerData.player.name,
            colorFormat = playerData.player.colorFormat,
            classColors = playerData.player.classColors,
            playerPrio = groupData[guid].playerPrio or 999
          },
        }
        for spellID, cooldownData in pairs(playerData.spells) do
          --[[          thingsToDo.syncs[guid][spellID] = {
            endTime = cooldownLeft > 0 and (serverTime + cooldownLeft - stime + _time) or 0, -- convert to client time
            charges = maxCharges and maxCharges > 1 and currentCharges or 0,
            maxCharges = maxCharges or 1,
            duration = type(spellData[spellID].cd) == "table" and (spellData[spellID].cd[specID] or spellData[spellID].cd.default) or spellData[spellID].cd,
            defType = spellData[spellID].t and CopyTable(spellData[spellID].t) or {},
            sentServerTime = serverTime,
            preventAuraID = spellData[spellID].preventUsage,
            auraID = tonumber(spellData[spellID].activation.b) and spellData[spellID].activation.b or spellID,
          }
          groupCDs[guid][spellID].auraDuration = targetAuras[v].d
          groupCDs[guid][spellID].auraEndTime = targetAuras[v].et
          --]]
          local endTime
          local charges
          local sentTime = cooldownData.sentServerTime
          -- TODO maybe requires checking cached times, in case of *instant* usage of spells after changing talents?
          if thingsToDo.updates[guid] and thingsToDo.updates[guid][spellID] and thingsToDo.updates[guid][spellID].sentServerTime > cooldownData.sentServerTime then -- queued update is newer
            endTime = thingsToDo.updates[guid][spellID].endTime
            charges = thingsToDo.updates[guid][spellID].currentCharges
            sentTime = thingsToDo.updates[guid][spellID].sentServerTime
            thingsToDo.updates[guid][spellID] = nil
          else
            endTime = cooldownData.endTime
            charges = cooldownData.charges
          end
          --auras[auraSpellID] = {duration = auraDuration, expirationTime = auraExpirationTime}
          --groupCDs[guid][spellID].preventUsage = targetAuras[spellData[spellID].preventUsage].et
          t[spellID] = {
            endTime = endTime,
            charges = charges,
            maxCharges = cooldownData.maxCharges,
            duration = cooldownData.duration,
            defType = CopyTable(cooldownData.defType),
            auraDuration = cooldownData.auraID and (relevantAuras[cooldownData.auraID] and relevantAuras[cooldownData.auraID].duration or 0) or nil,
            auraEndTime = cooldownData.auraID and (relevantAuras[cooldownData.auraID] and relevantAuras[cooldownData.auraID].expirationTime or 0) or nil,
            preventUsage = cooldownData.preventAuraID and (relevantAuras[cooldownData.preventAuraID] and relevantAuras[cooldownData.preventAuraID].expirationTime) or nil,
            preventUsageDuration = cooldownData.preventAuraID and (relevantAuras[cooldownData.preventAuraID] and relevantAuras[cooldownData.preventAuraID].duration) or nil,
            sentServerTime = sentTime
          }
          waUpdateData.currentSpells[spellID] = convertSpellToWAFormat(spellID, t[spellID], groupData[guid].unitID)
        end
        if groupData[guid] and groupData[guid].spells then
          for spellID in pairs(groupData[guid].spells) do
            if not t[spellID] then
              waUpdateData.removedSpells[guid..spellID] = spellID
            end
          end
        end
        groupData[guid].spells = t
        sendWeakAuraEvent(guid, "fullPlayerUpdate", waUpdateData)
      end
    end
    wipe(thingsToDo.syncs)
  end
  do
    for guid,playerData in ns:spairs(thingsToDo.updates) do
      for spellID, cooldownData in pairs(playerData) do
        if groupData[guid] and groupData[guid].spells and groupData[guid].spells[spellID]  and (not groupData[guid].spells[spellID].sentServerTime or groupData[guid].spells[spellID].sentServerTime < cooldownData.sentServerTime) then -- just for safety, shouldn't actually be *needed*
          local endTime = cooldownData.endTime
          local currentCharges = cooldownData.currentCharges
          groupData[guid].spells[spellID].endTime = endTime
          groupData[guid].spells[spellID].charges = currentCharges
          groupData[guid].spells[spellID].sentServerTime = cooldownData.sentServerTime
          sendWeakAuraEvent(guid..spellID, "updateCD",{
            endTime = cooldownData.endTime > 0 and cooldownData.endTime or 1,
            currentCharges = groupData[guid].spells[spellID].maxCharges > 1 and cooldownData.currentCharges or nil,
            available = (cooldownData.currentCharges and cooldownData.currentCharges > 0) or (cooldownData.endTime == 0),
            guid = guid,
            spellID = spellID
          })
        end
      end
    end
    wipe(thingsToDo.updates)
  end
  do
    --[[
                tinsert(spellPrio, {guid = sortedGUIDs[k], prio = v}) 0's are omitted
        end
      end
      thingsToDo.requests[sourceGUID] = {
        externalType = externalType,
        prio = spellPrio,
    ]]
    -- safe assigned requests for 10 seconds or so before removing, incase we need to assign it again
    local currentTime = GetTime()
    --for requesterGUID,v in ns:spairs(thingsToDo.requests) do -- TODO change from guid sort to some sort of spec sort || use .sentTime to sort
    for requesterGUID,v in ns:spairs(thingsToDo.requests, function(t,a,b) return t[b].sentTime > t[a].sentTime end) do -- TODO change from guid sort to some sort of spec sort || use .sentTime to sort
      local found = false
      --for _, prioData in ipairs(v.prio) do
      for _, prioData in ns:spairs(v.prio, function(t,a,b) return t[b].prio < t[a].prio end) do
        local unitID = groupData[prioData.guid] and groupData[prioData.guid].unitID or UnitTokenFromGUID(prioData.guid)
        if unitID then
          local spellID = isEligibleForExternal(v.externalType, v.spells.types, v.spells.blacklistedSpells, prioData.guid, requesterGUID, unitID, currentTime)
          if spellID then
            setAssignment(requesterGUID, prioData.guid, spellID, CopyTable(v))
            found = true
            break
          end
        end
      end
      if not found then
        setAssignment(requesterGUID, nil, nil, CopyTable(v))
      end
    end
    wipe(thingsToDo.requests)
  end
  -- cache range stuff & check if we have dropped any addon messages
  if throttle > .5 then
    throttle = 0
    -- resend cached messages if needed
    for msg,sentTime in pairs(cachedAddOnMessages) do
      if GetTime()-sentTime > 1 then
        SendAddonMessage(prefixToUse, msg, currentGroupType) -- this will set a new time to the cache, so we don't have to clear this table there at all
      end
    end
    -- cache ranges
    local t = {}
    for guid,data in ns:spairs(groupData) do
      if data.unitID then
        groupData[playerGUID].range[guid] = private:getRange(data.unitID)
        tinsert(t, groupData[playerGUID].range[guid] and 1 or 0)
      else
        tinsert(t, 0)
      end
    end
    if rangePrefix then
      rangePrefix = false
    else
      rangePrefix = true
    end
    -- we don't care about too much when this one sent, so don't use timestamps at all, just send and ignore cache on addon messages
    SendAddonMessage(rangePrefix and prefixForSync or prefixForSyncAlt, sformat("range>%s<%s", playerGUID, tconcat(t, ";")), currentGroupType, nil, true)
  end
end
function private:checkTalents(configIdFromEvent)
  local configId = C_ClassTalents.GetActiveConfigID()
	if not configId then return end
	if not C_Traits.StageConfig(configId) then return end
	cachedTalents = {}
  local configInfo = C_Traits.GetConfigInfo(configId)
  for _, treeId in ipairs(configInfo.treeIDs) do
    local nodes = C_Traits.GetTreeNodes(treeId)
    for _, nodeId in ipairs(nodes) do
      local node = C_Traits.GetNodeInfo(configId, nodeId)
      if node.currentRank > 0 then
          if node.activeEntry and node.activeEntry.rank > 0 then
            if node.subTreeID then
              local subTreeInfo = C_Traits.GetSubTreeInfo(configId, node.subTreeID)
              if subTreeInfo.isActive then
                cachedTalents[node.activeEntry.entryID] = true
              end
            else
              cachedTalents[node.activeEntry.entryID] = true
            end
          end
      end
    end
  end
end
function private:getCooldowns()
  local t = {}
  local classTalentsToCheck = {}
  local specTalentsToCheck = {}
  local specID = GetSpecializationInfo(GetSpecialization())
  if playerClass == "DEATHKNIGHT" then
    t = {
        {48265, 126015}, -- Death Advance, (Death's Echo gives 1 extra charge)
        48707, -- Anti Magic Shell
      }
    classTalentsToCheck = {
      {96187, 49039}, -- Lichborne DR 
      {96210, 48792}, -- Icebound Fortitude
      {96194, 51052}, -- Anti-Magic Zone
      {96204, 48743}, -- Death Pact 
      {96206, 212552}, -- Wraith Walk
      {96177, 383269}, -- Abomination Limb
    }
    if specID == 250 then -- Blood
      specTalentsToCheck = {
        {96308, 55233}, -- Vampiric Blood
        {96301, 194679}, -- Rune Tap
        {96261, 49028}, -- Dancing Rune Weapon
        {96270, 219809}, -- Tombstone
        {96170, 108199}, -- Gorefiend's Grasp
        {96264, 114556}, -- Purgatory
      }
    --elseif specID == 251 then -- Frost
    --else -- Unholy (252)
    end
  elseif playerClass == "DEMONHUNTER" then
      t = {}
      classTalentsToCheck = {
        {112853, 198793}, -- Vengeful Retreat
        {112921, 196718}, -- Darkness
      }
    if specID == 577 then -- Demon Hunter, Havoc, Vengeance(581)
        tinsert(t, 191427) -- Metamorphosis
        tinsert(t, {195072, 112928}) -- Fel Rush (Blazing Path increases charges to 2)
        tinsert(t, 198589) -- Blur
      specTalentsToCheck = {
        {115247, 196555}, -- Netherwalk
      }
    else
        tinsert(t, 187827) -- Metamorphosis
        tinsert(t, 203720) -- Demon Spikes
        tinsert(t, {189110, 112928}) -- Infernal Strike (Blazing Path increases charges to 2)
      specTalentsToCheck = {
        {112864, 204021, 112876}, -- Fiery Brand (Down in Flames increases charges to 2)
        {112904, 202137}, -- Sigil of Silence
        {112867, 202138}, -- Sigil of Chains
        {112895, 209258}, -- Last Resort
      }
    end
  elseif playerClass == "DRUID" then
    t = {
      22812, -- Barkskin
    }
    classTalentsToCheck = {
      {103298, 22842}, -- Frenzied Regeneration
      {103276, 102401}, -- Wild Charge
      {-103275, 1850}, -- Dash
      {103275, 252216}, -- Tiger Dash
      {103287, 132469}, -- Typhoon
      {103312, 106898}, -- Stampeding Roar
      {103321, 102793}, -- Ursol's Vortex
      {103310, 108238}, -- Renewal
      {103324, 124974}, -- Nature's Vigil
      {103323, 29166}, -- Innervate
    }
    if specID == 102 then -- Balance (102)
      specTalentsToCheck = {
        {109867, 78675}, -- Solar Beam
      }
    elseif specID == 103 then -- Feral
      specTalentsToCheck = {
        {103180, 61336}, -- Survival Instincts
      }
    elseif specID == 104 then -- Guardian
      specTalentsToCheck = {
        {103193, 61336, 103192}, -- Survival Instincts (Improved Survival Instincts increases charges to 2)
        {103222, 80313}, -- Pulverize
        {103207, 200851}, -- Rage of the Sleeper
      }
    else -- Restoration (105)
      specTalentsToCheck = {
        {103141, 102342}, -- Ironbark
        {103108, 740}, -- Tranquility
        {103120, 33891}, -- Incarnation: Tree of Life
        {103119, 391528}, -- Convoke the Spirits
        {123776, 197721}, -- Flourish
      }
    end
  elseif playerClass == "EVOKER" then
    t = {}
    classTalentsToCheck = {
      {115613, 363916, 115597}, -- Obsidian Scales, Obsidian Bulwark increases charges by 1
      {115669, 374348}, -- Renewing Blaze
      {115596, 370665}, -- Rescue
      {115666, 374968}, -- Time Spiral
      {125610, 406732}, -- Spatial Paradox
      {115661, 374227}, -- Zephyr
      {115655, 360995}, -- Verdant Embrace
      {115602, 374251}, -- Cauterizing Flame
      {115607, 372048}, -- Oppressing Roar
    }
    if specID == 1467 then -- Devastation
      specTalentsToCheck = {
      }
    elseif specID == 1473 then -- Augmentation
      tinsert(t, 395152) -- Ebon Might
      specTalentsToCheck = {}
    else -- Preservation (1468)
      specTalentsToCheck = {
        {115651, 363534, 115570}, -- Rewind, Erasure increases charges by 1
        {115650, 357170}, -- Time Dilation
        {115549, 370960}, -- Emerald Communion
        {115573, 359816}, -- Dream Flight
      }
    end
  elseif playerClass == "HUNTER" then
    -- BM (253), MM (254), Survival (255)
    t = {
      109304, -- Exhilaration
      5384, -- Feign Death
      781, -- Disengage
      186257, -- Aspect of the Cheetah
      186265, -- Aspect of the Turtle
      272679, -- Fortitude of the Bear
    }
    classTalentsToCheck = {
      {126488, 264735, 126470}, -- Survival of the Fittest, Padded Armor increases charges by 1
    }
    if specID == 253 then -- BM
      specTalentsToCheck = {}
    elseif specID == 254 then -- MM
      specTalentsToCheck = {}
    --[[else -- Survival (255)
      specTalentsToCheck = {
      }
    --]]
    end
  elseif playerClass == "MAGE" then
    t = {}
    classTalentsToCheck = {
      {-80163, 1953}, -- Blink
      {80163, 212653}, -- Shimmer
      {80174, 342245}, -- Alter Time
      {80183, 55342}, -- Mirror Image
      {80152, 389713}, -- Displacement
      {125817, 414660}, -- Mass Barrier
    }
    -- lazy fixes for replacement abilities
    if cachedTalents[115877] then
      tinsert(classTalentsToCheck, {115877, 110959}) -- Greater Invisibility
    else
      tinsert(classTalentsToCheck, {80177, 66}) -- Invisibility
    end
    if cachedTalents[80141] then 
      tinsert(classTalentsToCheck, {80141, 414658}) -- Ice Cold
    else
      tinsert(classTalentsToCheck, {80181, 45438}) -- Ice Block
    end

    if specID == 62 then -- Arcane
      tinsert(t, 235450) -- Prismatic Barrier
      specTalentsToCheck = {

      }
    elseif specID == 63 then -- Fire
      tinsert(t, 235313) -- Blazing Barrier
      specTalentsToCheck = {
        --{80274, 86949}, -- Cauterize
      }
      tinsert(t, 86949) --Cauterize
    else -- Frost (64)
      tinsert(t, 11426) -- Ice Barrier
      specTalentsToCheck = {
        --{80239, 235219}, -- Cold Snap
      }
      tinsert(t, 235219) -- Cold Snap
    end
  elseif playerClass == "MONK" then
    t = {}
    classTalentsToCheck = {
      {124937, 116841}, -- Tiger's Lust
      {124981, 115008}, -- Chi Torpedo
      {-124981, 109132, 124982}, -- Roll (Celerity increases charges by 1)
      {124962, 119996}, -- Transcendence: Transfer
      {124926, 116844}, -- Ring of Peace
      {124959, 122783}, -- Diffuse Magic
      {124978, 122278}, -- Dampen Harm
      {124968, 115203}, -- Fortifying Brew
    }
    if specID == 268 then -- Brewmaster 
      specTalentsToCheck = {
          {124841, 322507}, -- Celestial Brew
          {125006, 115176}, -- Zen Meditation
      }
    elseif specID == 269 then -- Windwalker
      tinsert(t, 122470) -- Touch of Karma
      tinsert(t, 101545) -- Flying Serpent Kick
      specTalentsToCheck = {
      }
    else -- Mistweaver (270)
      specTalentsToCheck = {
        {124875, 116849}, -- Life Cocoon
        {124919, 115310}, -- Revival
        {124918, 388615}, -- Restoral
        {124915, 322118}, -- Invoke Yu'lon, the Jade Serpent
        {124914, 325197}, -- Invoke Chi-ji, the Red Crane
      }
    end
  elseif playerClass == "PALADIN" then
    t = {
      642, -- Divine Shield
    }
    classTalentsToCheck = {
      {102587, 1044}, -- Blessing of Freedom
      {102625, 190784, 102592}, -- Divine Steed (Cavalier increases charges by 1)
      {102602, 6940}, -- Blessing of Sacrifice
      {102604, 1022}, -- Blessing of Protection
      {102583, 633}, -- Lay on Hands
    }
    if specID == 65 then -- Holy
      tinsert(t, 498) -- Divine Protection
      specTalentsToCheck = {
        {102548, 31821}, -- Aura Mastery
        {102573, 200652}, -- Tyr's Deliverance
      }
      if cachedTalents[102568] then
        tinsert(specTalentsToCheck,{102568, 216331}) -- Avenging Crusader
      else
        tinsert(specTalentsToCheck, {102593, 31884}) -- Avenging Wrath
      end
    elseif specID == 66 then -- Protection
      specTalentsToCheck = {
        {102445, 31850}, -- Ardent Defender
        {111886, 204018}, -- Blessing of Spellwarding
        {102456, 86659}, -- Guardian of the Ancient Kings
        {102466, 387174}, -- Eye of Tyr
      }
    else -- Retribution (70)
      tinsert(t, 498) -- Divine Protection
      specTalentsToCheck = {
        {125130, 184662}, -- Shield of Vengeance
      }
    end
  elseif playerClass == "PRIEST" then
    t = {
      19236, -- Desperate Prayer
    }
    classTalentsToCheck = {
      {103835, 586}, -- Fade
      {103853, 121536}, -- Angelic Feather
      {103820, 108968}, -- Void Shift
      {103868, 73325}, -- Leap of Faith
      {103849, 32375} -- Mass Dispel
    }
    if specID == 256 then -- Discipline
      specTalentsToCheck = {
        {103844, 10060}, -- Power Infusion
        {103713, 33206, 103714}, -- Pain Suppression
        {103687, 62618}, -- Power Word: Barrier
        {103727, 472433}, -- Evangelism
        {103702, 421453}, -- Ultimate Penitence
      }
    elseif specID == 257 then -- Holy
      specTalentsToCheck = {
        {103844, 10060}, -- Power Infusion
        {103774, 47788}, -- Guardian Spirit
        {103755, 64843}, -- Divine Hymn
        {103751, 64901}, -- Symbol of Hope
        {103743, 200183}, -- Apotheosis
        {103733, 372835}, -- Lightwell
        {128315, 391124}, -- Restitution
      }
    else -- Shadow (258)
      specTalentsToCheck = {
        {103841, 15286}, -- Vampiric Embrace
        {103832, 10060}, -- Power Infusion, track only with Twins of the Sun Priestess
        {103806, 47585}, -- Dispersion
      }
    end
  elseif playerClass == "ROGUE" then
    t = {
      185311, -- Crimson Vial
      {1856, 125614}, -- Vanish (Without a Trace gives 1 additional charge)
      2983, -- Sprint
      1966, -- Feint
    }
    classTalentsToCheck = {
      {112657, 5277}, -- Evasion
      {112585, 31224}, -- Cloak of Shadows
      {114737, 31230}, -- Cheat Death
    }
    if specID == 259 then -- Assasination
      tinsert(t, {36554, 112583}) -- Extra Charge from general tree
      specTalentsToCheck = {}
    elseif specID == 260 then -- Outlaw

      tinsert(t, 195457) -- Grappling Hook
      specTalentsToCheck = {
        {112583, 36554}, -- Shadowstep
      }
    else -- Sublety (261)
      tinsert(t, {36554, 112583}) -- Extra Charge from general tree
      specTalentsToCheck = {}
    end
  elseif playerClass == "SHAMAN" then
    t = {
      20608, -- Reincarnation
    }
    classTalentsToCheck = {
      {127893, 108271}, -- Astral Shift
      {127858, 198103}, -- Earth Elemental
      {127909, 192077}, -- Wind Rush Totem
      {127865, 58875}, -- Spirit Walk
      {127864, 192063}, -- Gust of Wind
      --{128116, 108281}, -- Ancestral Guidance
      {127911, 108270}, -- Stone Bulwark Totem
    }
    if specID == 262 then -- Elemental
      specTalentsToCheck = {

      }
    elseif specID == 263 then -- Enhancement
      tinsert(t, 196884) -- Feral Lunge
      specTalentsToCheck = {
      }
    else -- Restoration (264)
      specTalentsToCheck = {
        {101913, 98008}, -- Spirit Link Totem
        {101929, 16191}, -- Mana Tide Totem
        {101912, 108280}, -- Healing Tide Totem
        {101930, 207399}, -- Ancestral Protection Totem
        {101942, 114052}, -- Ascendance
      }
    end    
  elseif playerClass == "WARLOCK" then
    t = {
      104773, -- Unending Resolve
    }
    classTalentsToCheck = {
      {124694, 48020}, -- Demonic Circle: Teleport
      {91457, 6789}, -- Mortal Coil
      {91444, 108416}, -- Dark Pactnn
    }
    --[[
    if specID == 265 then -- Affliction
      specTalentsToCheck = {

      }
    elseif specID == 266 then -- Demonology
      specTalentsToCheck = {
        
      }
    else -- Desctruction (267)
      specTalentsToCheck = {
        
      }
    end
    --]]
  elseif playerClass == "WARRIOR" then
    t = {
      {100, 112249}, -- Charge, Double Time increases charges by 1
    }
    classTalentsToCheck = {
      {112183, 202168}, -- Impending Victory
      {112186, 3411}, -- Intervene
      {112188, 97462}, -- Rallying Cry
      {112208, 6544}, -- Heroic Leap
      {112220, 383762}, -- Bitter Immunity
      {112253, 23920}, -- Spell Reflection
    }
    if specID == 71 then -- Arms
      specTalentsToCheck = {
        {112128, 118038}, -- Die by the Sword
      }
    elseif specID == 72 then -- Fury
      specTalentsToCheck = {
        {112264, 184364}, -- Enraged Regeneration
      }
    else -- Protection (73)
      specTalentsToCheck = {
        {112159, 1160}, -- Demoralizing Shout
        {112151, 12975}, -- Last Stand
        {112167, 871, 112165}, -- Shield Wall, Defender's Aegis increases charges by 1
        {112173, 385952}, -- Shield Charge
      }
    end

  end
  if raidHasWarlock then
    tinsert(t, -5512) -- Healthstone
  end
  -- Items
  tinsert(t, -13446) -- Health Potion
  do
    local _, race = UnitRace('player')
    if race == "NightElf" then
      tinsert(t, 58984) -- Shadowmeld
    elseif race == "VoidElf" then
      tinsert(t, 256948) -- Spatial Rift
    elseif race == "Worgen" then
      tinsert(t, 68992) -- Darkflight
    elseif race == "Goblin" then
      tinsert(t, 69070) -- Rocket Jump
    elseif race == "ZandalariTroll" then
      tinsert(t, 291944) -- Regeneratin'
    elseif race == "Draenei" then
      tinsert(t, 59542) -- Gift of the Naaru
    elseif race == "Dwarf" then
      tinsert(t, 20594) -- Stoneform
    elseif race == "DarkIronDwarf" then
      tinsert(t, 265221) -- Fireblood
    end
  end
  local dataToReturn = {}
  for k,v in pairs(t) do
    if type(v) == "table" then -- Check for extra charge
      local maxCharges = spellData[v[1]].charges or 1
      if cachedTalents[v[2]] then
        maxCharges = maxCharges + 1
      end
      dataToReturn[v[1] > 0 and FindSpellOverrideByID(v[1]) or v[1]] = {
        syncID = v[1],
        maxCharges = maxCharges
      }
    else
      dataToReturn[v > 0 and FindSpellOverrideByID(v) or v] = {
        syncID = v,
        maxCharges = spellData[v].charges or 1
      }
    end
  end
  for k,v in pairs(classTalentsToCheck) do
    if cachedTalents[v[1]] or (v[1] < 0 and not cachedTalents[-v[1]]) then
      local maxCharges = spellData[v[2]].charges or 1
      if v[3] then
        if type(v[3]) == "table" then -- each entry increases charges by 1
---@diagnostic disable-next-line: param-type-mismatch
          for _, talentID in pairs(v[3]) do
            if cachedTalents[talentID] then
              maxCharges = maxCharges + 1
            end
          end
        elseif cachedTalents[v[3]] then
            maxCharges = maxCharges + 1
        end
      end
      dataToReturn[v[2] > 0 and FindSpellOverrideByID(v[2]) or v[2]] = {
        syncID = v[2],
        maxCharges = maxCharges
      }
    end
  end
  for k,v in pairs(specTalentsToCheck) do
    if cachedTalents[v[1]] or (v[1] < 0 and not cachedTalents[-v[1]]) then
      local maxCharges = spellData[v[2]].charges or 1
      if v[3] then
        if type(v[3]) == "table" then -- each entry increases charges by 1
---@diagnostic disable-next-line: param-type-mismatch
          for _, talentID in pairs(v[3]) do
            if cachedTalents[talentID] then
              maxCharges = maxCharges + 1
            end
          end
        elseif cachedTalents[v[3]] then
            maxCharges = maxCharges + 1
        end
      end
      dataToReturn[v[2] > 0 and FindSpellOverrideByID(v[2]) or v[2]] = {
        syncID = v[2],
        maxCharges = maxCharges
      }
    end
  end
  return specID, dataToReturn
end
function private:getSyncStringForSpell(spellID, duration, charges, maxCharges)
  spellID = morphedSpells[spellID] or spellID
  local str
  if maxCharges and maxCharges > 1 then
    str = sformat("%d:%.1f:%d:%d", spellID, duration, charges or 0, maxCharges)
  elseif charges then -- support for old
    str = sformat("%d:%.1f:%d:%d", spellID, duration, charges)
  else
    str = sformat("%d:%.1f", spellID, duration)
  end
  return str, str:len()
end
function private:getSpellCooldown(id)
  if id > 0 then -- spells
    if debuffsOnly[id] then
      local d = GetPlayerAuraBySpellID(debuffsOnly[id])
      if not d then
        return 0,0
      end
      return d.expirationTime-GetTime(), d.expirationTime
    end
    local chargeData = C_Spell.GetSpellCharges(id)
    if chargeData then
      local cd = 0
      local endTime = 0
      if chargeData.currentCharges < chargeData.maxCharges then
        endTime = chargeData.cooldownStartTime+chargeData.cooldownDuration
        cd = endTime-GetTime()
      end
      return cd, endTime, chargeData.currentCharges
    else
      local _spellData = C_Spell.GetSpellCooldown(id)
      if not _spellData then return 0,0 end
      local endTime = 0
      if _spellData.duration > 2 then
        endTime = _spellData.startTime + _spellData.duration
      end
      return _spellData.duration <= 2 and 0 or endTime-GetTime(), endTime
    end
  else -- items
    local start, cooldown = C_Item.GetItemCooldown(-id)
    local endTime = 0
    if cooldown == .001 then -- item cooldown when it can't be used in combat anymore
      return 0,0
    end
    if start > 0 then
      endTime = start + cooldown
    end
    return start == 0 and 0 or endTime-GetTime(), endTime
  end
end
function private:sendFullSync()
  local specID, t = private:getCooldowns()
  currentSpecID = specID
  for id, d in pairs(t) do
    local duration, endTime, charges = private:getSpellCooldown(id)
    ownCds[id] = {
      endTime = duration > 2 and endTime or 0,
      charges = charges,
      duration = duration > 2 and duration or 0,
      maxCharges = d.maxCharges,
      syncID = d.syncID
    }
  end
  local temp = {}
  local strLen = 0
  local function addToTemp(str, currentStrLen)
    if currentStrLen + strLen <= 200 then
      strLen = strLen + currentStrLen
      if not temp[1] then
        temp[1] = {}
      end
      tinsert(temp[#temp], str)
    else
      temp[#temp+1] = {}
      strLen = currentStrLen
      tinsert(temp[#temp], str)
    end
  end
  for id,d in pairs(ownCds) do
    addToTemp(private:getSyncStringForSpell(d.syncID, d.duration, d.charges, d.maxCharges))
  end
  currentGroupType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party"
  --print(currentGroupType)
  local stime = _GetServerTime()
  for k,v in pairs(temp) do
    SendAddonMessage(prefixToUse, sformat("fullv3%04d%s>%s<%s",specID, stime, playerGUID, tconcat(v, ";")), currentGroupType)
  end
  temp = nil
end
function private:checkOwnCds()
  local _time = GetTime()
  local stime = _GetServerTime()
  local temp = {}
  local strLen = 0
  local function addToTemp(str, currentStrLen)
    if currentStrLen + strLen <= 200 then
      strLen = strLen + currentStrLen
      if not temp[1] then
        temp[1] = {}
      end
      tinsert(temp[#temp], str)
    else
      temp[#temp+1] = {}
      strLen = currentStrLen
      tinsert(temp[#temp], str)
    end
  end
  for k,v in pairs(ownCds) do
    local duration, endTime, charges = private:getSpellCooldown(k)
    if (duration == 0 and v.endTime ~= 0) or (duration > 0 and v.endTime ~= endTime) or (charges ~= v.charges) then
      v.endTime = endTime
      v.charges = charges
      v.duration = duration
      addToTemp(private:getSyncStringForSpell(v.syncID, v.duration, v.charges, v.maxCharges))
    end
  end
  for k,v in pairs(temp) do
    SendAddonMessage(prefixToUse, sformat("update%s>%s<%s", stime, playerGUID, tconcat(v, ";")), currentGroupType)
  end
  temp = nil
end
function private:getRange(unit)
  return rangeFuncsPerSpec[currentSpecID] and rangeFuncsPerSpec[currentSpecID](unit)
end

--[[ Note syntax, 0 prio to fully disable spell/item, items = negative numbers
>>external:encounterID>
longgrip -- optional, increases grip check by 10yd
>Ironi:123456:10 -- nickname
>Ironidk:123456:10 -- character
>6:123456:10 -- class
>250:123456:10 -- spec
>0:-123456:10 -- all (items only)
Ironi:123456 0-60;120-160;180-240
Ironidk:123456 0-60;120-160;180-240
6:123456 0-60;120-160;180-240
250:123456 0-60;120-160;180-240
0:-123456 0-60;120-160;180-240
<<external<
]]
function private:readNoteForExternalData(encounterID)
  if not (VMRT and VMRT.Note and VMRT.Note.Text1) then return end
  local note = VMRT.Note.Text1:lower()
  --Clean note
  note = note:gsub("||r", "")
  note = note:gsub("||cff%x%x%x%x%x%x", "")
  local noteData =  {
    blacklist = {
      all = {}
    },
    prio = CopyTable(whitelistedExternals),
    longGrip = false,
  }
  local shouldCare = false
  local startLine = sformat("^>>external:%s>", encounterID)
  for _,line in ipairs({strsplit("\n", note)}) do
    if line:match(startLine) then
      shouldCare = true
    elseif line:match("^<<external<") then
      return shouldCare and noteData or nil -- is not just some weird stand alone leftover line
    elseif shouldCare then
      if line == "longgrip" then
        noteData.longGrip = true
      elseif line:sub(0,1) == ">" then -- prio
        local target,spellID,newPrio = line:match("^>(.-):(-?%d+):(%d+)")
        spellID = tonumber(spellID)
        if not target then
          print("Liquid Note reading, incorrect syntax:", line)
        elseif not (spellData[spellID] and spellData[spellID].externalType) then
          print("Liquid Note reading, spell not found or not assigned as external in database:", spellID, line)
        else
          newPrio = tonumber(newPrio)
          if newPrio >= 100 then
            print("Liquid Note reading, prio is assigned >= 100, which might cause problems when syncing:", line)
          end
          if tonumber(target) then -- specID or classID or 0 (all)
            local targetValue = tonumber(target)
            if targetValue == 0 then -- all, accept only items
              if spellID < 0 then -- accept only items
                for _,specData in pairs(noteData.prio) do
                  if specData[spellData[spellID].externalType][spellID] then
                    specData[spellData[spellID].externalType][spellID] = newPrio
                  end
                end
              else
                print("Liquid Note reading, trying to assign spell for everyone, we only accept items:", spellID, line)
              end
            elseif classIDsToSpecID[targetValue] then -- is valid class
              for specID in pairs(classIDsToSpecID[targetValue]) do
                if noteData.prio[specID][spellData[spellID].externalType][spellID] then
                  noteData.prio[specID][spellData[spellID].externalType][spellID] = newPrio
                end
              end
            elseif noteData.prio[targetValue] then -- specid
              if noteData.prio[targetValue][spellData[spellID].externalType][spellID] then
                noteData.prio[targetValue][spellData[spellID].externalType][spellID] = newPrio
              end
            else
              print("Liquid Note reading, target is not valid:", line)
            end
          else
            -- don't print any errors for unknown chars, maybe change it?
            local guid
            if UnitExists(target) then
              guid = UnitGUID(target)
            else
              guid = select(3,LiquidAPI:GetCharacterInGroup(target))
            end
            if guid then
              if not noteData.prio[guid] then
                noteData.prio[guid] = {}
              end
              noteData.prio[guid][spellID] = newPrio
            end
          end
        end
      else -- time based blacklist
        local target, spellID, timeData = line:match("^(.-):(-?%d+) (.*)")
        spellID = tonumber(spellID)
        if not target then
          print("Liquid Note reading, incorrect syntax:", line)
        elseif not (spellData[spellID] and spellData[spellID].externalType) then
          print("Liquid Note reading, spell not found or not assigned as external in database:", spellID, line)
        else
          -- assume everything is fine and fetch time data before doing anything else, just so we don't have to copy paste it inside multiple ifs
          local times = {}
          for _, v in pairs({strsplit(";",timeData)}) do
            local from, to = strsplit("-", v)
            from = tonumber(from)
            to = tonumber(to)
            if not (from and to) then
              print("Liquid note reading, incorrect syntax:", v, line)
            else
              times[from] = to
            end
          end
          if tonumber(target) then -- all, class, spec wide blacklisting
            local targetValue = tonumber(target)
            if targetValue == 0 then -- all, accept only items
              if spellID < 0 then -- accept only items
                if not noteData.blacklist.all[spellID] then
                  noteData.blacklist.all[spellID] = times
                else -- append
                  for from,to in pairs(times) do
                    noteData.blacklist.all[spellID][from] = to
                  end
                end
              else
                print("Liquid Note reading, trying to assign spell for everyone, we only accept items:", spellID, line)
              end
            elseif classIDsToSpecID[targetValue] then -- is valid class
              for specID in pairs(classIDsToSpecID[targetValue]) do -- convert to specids
                if not noteData.blacklist[specID] then
                  noteData.blacklist[specID] = {}
                end
                if not noteData.blacklist[specID][spellID] then
                  noteData.blacklist[specID][spellID] = times
                else -- append
                  for from, to in pairs(times) do
                    noteData.blacklist[specID][spellID][from] = to
                  end
                end
              end
            elseif specIDsToRole[targetValue] then -- valid specid
              if not noteData.blacklist[targetValue] then
                noteData.blacklist[targetValue] = {}
              end
              if not noteData.blacklist[targetValue][spellID] then
                noteData.blacklist[targetValue][spellID] = times
              else -- append
                for from, to in pairs(times) do
                  noteData.blacklist[targetValue][spellID][from] = to
                end
              end
            else
              print("Liquid Note reading, blacklist target is not valid:", line)
            end
          else
            local guid
            if UnitExists(target) then
              guid = UnitGUID(target)
            else
              guid = select(3,LiquidAPI:GetCharacterInGroup(target))
            end
            if guid then
              if not noteData.blacklist[guid] then
                noteData.blacklist[guid] = {}
              end
              if not noteData.blacklist[guid][spellID] then
                noteData.blacklist[guid][spellID] = times
              else -- append
                for from,to in pairs(times) do
                  noteData.blacklist[guid][spellID][from] = to
                end
              end
            end
          end
        end
      end
    end
  end
end
function ns.cooldowns:CheckGroup()
  groupData = {}
  currentGroupType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party"
  local prefix = IsInRaid() and "raid" or "party"
  if prefix == "party" then
    groupData[playerGUID] = {
      unitID = "player",
      guid = playerGUID,
      playerPrio = 5, -- just to make life easier inside WeakAuras
      spells = {},
      range = {},
    }
  end
  raidHasWarlock = false
  for i = 1, GetNumGroupMembers() - (prefix == "party" and 1 or 0) do
    local unitID = prefix .. i
    local guid = UnitGUID(unitID)
    local _, class = UnitClass(unitID)
    if class == "WARLOCK" then
      raidHasWarlock = true
    end
    groupData[guid] = {
      unitID = unitID,
      guid = guid,
      playerPrio = i,
      spells = {},
      range = {},
    }
  end
end
function private:checkGroupChanges()
  if not IsInGroup() or GetNumGroupMembers() <= 1 then
    ns.PrintDebug("private:checkGroupChanges() - IsInGroup: %s - GetNumGroupMembers: %s", IsInGroup(), GetNumGroupMembers())
    return
  end
  if not currentlySyncing then
    private:startSyncing()
  end
  currentGroupType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party"
  for guid,v in pairs(groupData) do -- cache data
    v.unitID = false
  end
  local prefix = IsInRaid() and "raid" or "party"
  if prefix == "party" then
    if not groupData[playerGUID] then
      groupData[playerGUID] = {
        spells = {},
        range = {},
        guid = playerGUID,
      }
    end
    groupData[playerGUID].playerPrio = 5
    groupData[playerGUID].unitID = "player"
  end
  raidHasWarlock = false
  for i = 1, GetNumGroupMembers() - (prefix == "raid" and 0 or 1) do
    local unitID = prefix .. i
    local guid = UnitGUID(unitID)
    local _, class = UnitClass(unitID)
    if class == "WARLOCK" then
      raidHasWarlock = true
    end
    if not groupData[guid] then
      groupData[guid] = {
        spells = {},
        range = {},
        guid = guid
      }
    end
    groupData[guid].playerPrio = i
    groupData[guid].unitID = unitID
  end
  local removedGuids = {}
  for guid,playerData in pairs(groupData) do -- delete unused
    if not playerData.unitID then
      removedGuids[guid] = true
    end
  end
  for guid in pairs(removedGuids) do
    local data = {}
    if groupData[guid] then
      for spellID in pairs(groupData[guid].spells) do
        data[guid..spellID] = spellID
      end
    end
    sendWeakAuraEvent(guid, "PlayerRemoved", data)
    groupData[guid] = nil
  end
  -- send data for wa to easy adapting on WA side
  for guid,data in pairs(groupData) do
    local waUpdateData = {
      currentSpells = {},
      removedSpells = {},
      player = {
        guid = guid,
        specID = data.specID,
        classID = data.classID,
        realName = data.realName,
        name = data.name,
        colorFormat = data.colorFormat,
        classColors = data.classColors,
        playerPrio = data.playerPrio,
        unitID = data.unitID,
      },
    }
    for spellID, cooldownData in pairs(data.spells) do
      waUpdateData.currentSpells[spellID] = convertSpellToWAFormat(spellID, cooldownData, data.unitID)
    end
    sendWeakAuraEvent(guid, "fullPlayerUpdate", waUpdateData)
  end
end
function private:stopSyncing()
  local minDif = initialServerTimeDif
  _GetServerTime = function()
    return minDif+GetTime()
  end
  syncedServerTimeInformation = {
    set = false,
    order = 100,
    source = "",
    lastEncounterStart = 0,
    offSet = 0,
  }
  ns.PrintDebug("private:stopSyncing - currentlySyncing: %s", currentlySyncing)
  if not currentlySyncing then return end
  rosterTalents = {}
  for guid, playerData in pairs(groupData) do
    local data = {}
    for spellID in pairs(playerData.spells) do
      data[guid..spellID] = spellID
    end
    sendWeakAuraEvent(guid, "PlayerRemoved", data)
  end
  ownCds = nil
  ownCds = {}
  groupData = {}
  if ticker then
    ticker:Cancel()
  end
  currentlySyncing = false
  if serverTimeAccuracyReached then
    _eventHandler:SetScript("OnUpdate", nil)
  end
end
function private:startSyncing()
  ns.PrintDebug("private:startSyncing, currentlySyncing: %s", currentlySyncing)
  if currentlySyncing then return end
  private:checkTalents()
  isInGuild = IsInGuild()
  ownCds = nil
  ownCds = {}
  ns.cooldowns:CheckGroup()
  currentlySyncing = true
  if serverTimeAccuracyReached then
    _eventHandler:SetScript("OnUpdate", handleQueue)
  end
  ticker = C_Timer.NewTicker(3, function()
    private:checkOwnCds()
  end)
  SendAddonMessage(prefixToUse, "requestSync", currentGroupType)
end
function ns.cooldowns:ENCOUNTER_START(encounterID)
  syncedServerTimeInformation = {
    set = false,
    order = 100,
    source = "",
    lastEncounterStart = GetTime(),
    offSet = 0,
  }
  if IsInRaid() then
    local order = UnitInRaid('player')
    SendAddonMessage(prefixToUse, sformat("servertimeSync%s>%s>%s", playerGUID, _GetServerTime(), order), IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
  elseif IsInGroup() then
    local t = {}
    tinsert(t, playerGUID)
    for i = 1, GetNumGroupMembers()-1 do
      tinsert(t, UnitGUID("party"..i))
    end
    table.sort(t)
    local order = 0
    for i = 1, #t do
      if t[i] == playerGUID then
        order = i
        break
      end
    end
    SendAddonMessage(prefixToUse, sformat("servertimeSync%s>%s>%s", playerGUID, _GetServerTime(), order), IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
  end
  if not currentlySyncing then
    --private:startSyncing() -- currently seeing some weird bug that sometimes procs, force cooldown syncing here to make sure everything is working
    --ns.cooldowns:ENCOUNTER_START(encounterID)
    return
  end
  private.encounterStart = GetTime()
  private:sendFullSync() -- just force full syncs on encounter start, probably not *actually* needed but it doesn't cost too much
  local t = private:readNoteForExternalData(encounterID)
  if t then
    externalPrioData = t
  end
end
function ns.cooldowns:ENCOUNTER_END(...)
  private.encounterStart = 0
  externalPrioData = {
    blacklist = {
      all = {},
    },
    longGrip = false,
    prio = CopyTable(whitelistedExternals)
  }
end
function ns.cooldowns:GROUP_ROSTER_UPDATE()
  private:checkGroupChanges()
end
function ns.cooldowns:CHAT_MSG_ADDON(prefix, str, channel, sender)
  if (prefix == prefixForSync) or (prefix == prefixForSyncAlt) then
    if str:match("^range") then -- own if block so we safe some resources
      local sourceGUID, rangestr = str:match("^range>(.-)<(.*)")
      if not (sourceGUID or rangestr) then return end
      if not groupData[sourceGUID] then return end
      local rdata = {strsplit(";", rangestr)}
      -- could be desynced roster because of msg delay, but we get updated so often that i don't really care
      local i = 0
      for guid,data in ns:spairs(groupData) do
        i = i + 1
        groupData[sourceGUID].range[guid] = rdata[i] == "1"
      end
      return
    end
    return
  elseif prefix == prefixToUse then
    if cachedAddOnMessages[str] then
      cachedAddOnMessages[str] = nil
    end
    if str:match("^fullv") then
      local version = str:match("^fullv(%d)") -- 2/3 only has 1 minor difference, no point in making fully new code block for it
      version = tonumber(version)
      if version ~= 2 and version ~= 3 then return end
      local specID,serverTime, guid, datastr = str:match(version == 2 and "^fullv2(%d%d%d)(.-)>(.*)<(.*)" or "^fullv3(%d%d%d%d)(.-)>(.*)<(.*)")
      if not guid then return end
      local stime = _GetServerTime()
      local _time = GetTime()
      specID = tonumber(specID)
      serverTime = tonumber(serverTime)
      local data = {strsplit(";", datastr)}
      local realName = strsplit("-", sender)
      local name, colorFormat, roleAtlas, classColors = LiquidAPI:GetName(realName, true)
      if not thingsToDo.syncs[guid] then
        thingsToDo.syncs[guid] = {
          player = {
            guid = guid,
            specID = specID,
            classID = specIDsToClass[specID],
            realName = realName,
            name = name,
            colorFormat = colorFormat,
            classColors = classColors
          },
          spells = {},
        }
      end
      for _,v in pairs(data) do
        local spellID, cooldownLeft, currentCharges, maxCharges = strsplit(":", v)
        spellID = tonumber(spellID)
        if spellData[spellID] then
          maxCharges = tonumber(maxCharges)
          cooldownLeft = tonumber(cooldownLeft)
          currentCharges = tonumber(currentCharges)
          thingsToDo.syncs[guid].spells[spellID] = {
            endTime = cooldownLeft > 0 and (serverTime + cooldownLeft - stime + _time) or 0, -- convert to client time
            charges = maxCharges and maxCharges > 1 and currentCharges or 0,
            maxCharges = maxCharges or 1,
---@diagnostic disable-next-line: undefined-field
            duration = type(spellData[spellID].cd) == "table" and (spellData[spellID].cd[specID] or spellData[spellID].cd.default) or spellData[spellID].cd,
            defType = spellData[spellID].t and CopyTable(spellData[spellID].t) or {},
            sentServerTime = serverTime,
            preventAuraID = spellData[spellID].preventUsage,
            auraID = tonumber(spellData[spellID].activation.b) and spellData[spellID].activation.b or spellID,
          }
        end
      end
      --end
    elseif str:match("^update") then -- else would be enough for right now, but add this for safety later on
      local stime = _GetServerTime()
      local _time = GetTime()
      local serverTime, guid, datastr = str:match("^update(.-)>(.*)<(.*)")
      if not guid then return end
      if not thingsToDo.updates[guid] then
        thingsToDo.updates[guid] = {}
      end
      -- convert everything here to safe time on OnUpdate
      serverTime = tonumber(serverTime)
      for _,v in pairs({strsplit(";", datastr)}) do
        local spellID, cooldownLeft, currentCharges = strsplit(":", v)
        spellID = tonumber(spellID)
        --if spellData[spellID] and groupCDs[guid][spellID] then
        if spellData[spellID] then
          if not (thingsToDo.updates[guid][spellID] and thingsToDo.updates[guid][spellID].sentServerTime > serverTime) then
            cooldownLeft = tonumber(cooldownLeft)
            currentCharges = tonumber(currentCharges)
            thingsToDo.updates[guid][spellID] = {
              sentServerTime = serverTime,
              endTime = cooldownLeft > 0 and (serverTime + cooldownLeft - stime + _time) or 0, -- convert to client time
              currentCharges = currentCharges
            }
          end
        end
      end
    elseif str:match("^external") then
      local sourceGUID, eType, sentTime, spellstr, datastr = str:match("^external(.-)>(.-)<(.-)>(.-)<(.*)")
      if not (sourceGUID and groupData[sourceGUID]) then return end
      local externalType = eType == "D" and "DR" or eType == "G" and "GRIP"
      if not externalType then
        error("Liquid External request: incorrect externalType used")
        return
      end
      local externalSpells = {
        blacklistedSpells = {}
      }
      for k,v in ipairs({strsplit(";", spellstr)}) do
        if k == 1 then
          externalSpells.types = private:ParseExternalTypeString(v)
        else
          v = tonumber(v)
          if v then
            externalSpells.blacklistedSpells[v] = true
          elseif v == "default" then -- TODO support others, this should be the only one we get right now
            externalSpells.blacklistedSpells = "default"
          elseif v == "note" then
            externalSpells.blacklistedSpells = "note"
          end
        end
      end
      if not externalSpells.types then
        error("incorrect spellstr")
        return
      end
      local spellPrio = {}
      local sortedGUIDs = {}
      -- sort guids so we can match spell prios
      for k,_ in ns:spairs(groupData) do
        tinsert(sortedGUIDs, k)
      end
  
      for k,v in ipairs({strsplit(";", datastr)}) do -- we are fucked if group changes during message delays, hope that won't happen
        v = tonumber(v)
        local targetGUID = sortedGUIDs[k]
        if targetGUID and v and v > 0 then -- using 0 as not eligible target, just filter those out
          tinsert(spellPrio, {guid = sortedGUIDs[k], prio = v})
        end
      end
      thingsToDo.requests[sourceGUID] = {
        sentTime = tonumber(sentTime),
        externalType = externalType,
        prio = spellPrio,
        spells = externalSpells
      }
    elseif str:match("^edecline") then
      local declinerGUID, guids = str:match("^edecline(.-)>(.*)")
      if not (declinerGUID and guids) then return end
      local toDelete = {}
      local _time = _GetServerTime()
      for k,v in pairs(cachedAssignments) do
        if _time-v.request.sentTime < 10 then
          toDelete[k] = true
        end
      end
      for k,v in pairs(toDelete) do
        cachedAssignments[k] = nil
      end
      for _,g in pairs({strsplit(";", guids)}) do
        if not cachedAssignments[g] then return end
        sendWeakAuraEventForExternal({
            isForPlayer = declinerGUID == playerGUID or g == playerGUID,
            spellID = cachedAssignments[g].target.spellID
          },
          "decline"
        )
        if cachedAssignments[g] and _GetServerTime()-cachedAssignments[g].request.sentTime < 8 then
          thingsToDo.requests[g] = cachedAssignments[g].request
        end
      end
    elseif str == "requestSync" then
      private:sendFullSync()
    elseif str:match("^servertimeSync") then
      if not currentlySyncing then return end
      local senderGUID, proposedServerTime, order = str:match("^servertimeSync(.-)>(.-)>(.*)")
      proposedServerTime = tonumber(proposedServerTime)
      order = tonumber(order)
      if not (proposedServerTime and order) then return end -- shouldn't happen
      if syncedServerTimeInformation.set and syncedServerTimeInformation.order < order then return end -- we already higher prio data
      syncedServerTimeInformation.set = true
      syncedServerTimeInformation.order = order
      syncedServerTimeInformation.source = senderGUID
      syncedServerTimeInformation.offSet = proposedServerTime-syncedServerTimeInformation.lastEncounterStart
      local minDif = syncedServerTimeInformation.offSet
      _GetServerTime = function()
        return minDif+GetTime()
      end
    end
  end
end
function ns.cooldowns:COMBAT_LOG_EVENT_UNFILTERED()
  if not currentlySyncing then return end
  local _,event,_,sourceGUID,_,_,_,destGUID,_,_,_,spellID = CombatLogGetCurrentEventInfo()
  if not spellID then return end
  local auraToFind
  if morphedSpells[spellID] then
    auraToFind = spellID
    spellID = morphedSpells[spellID]
  end
  if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") and destGUID and preventsUsageOfOtherSpells[spellID] and groupData[destGUID] and groupData[destGUID].spells then
    local _add = event == "SPELL_AURA_APPLIED"
    local expTime
    if _add and spellID == 25771 then -- Forberance
      if groupData[destGUID] and groupData[destGUID].unitID then
        local auraData = C_UnitAuras.GetAuraDataBySpellName(groupData[destGUID].unitID, "Forbearance", "HARMFUL")
        if auraData then
          expTime = auraData.expirationTime
        end
      end
    end
    for k in pairs(preventsUsageOfOtherSpells[spellID]) do
      if groupData[destGUID].spells[k] then
        groupData[destGUID].spells[k].preventUsage = _add and (expTime or GetTime()+30) or nil
          sendDebugiEET(sformat("PreventUsage: %s,%s,%s", event, destGUID, spellID))
          sendWeakAuraEvent(destGUID..k, "preventUsage", {preventUsage = groupData[destGUID].spells[k].preventUsage, guid = destGUID})
      end
    end
  elseif sourceGUID and cleuEventsToUse[event] and groupData[sourceGUID] and groupData[sourceGUID].spells and cleuEventsToUse[event][spellID] then
    local d = groupData[sourceGUID].spells[cleuEventsToUse[event][spellID]]
    if not d then return end
    if event == "SPELL_AURA_APPLIED" and sourceGUID == destGUID then
      local auraDuration,auraExpirationTime = private:fetchAuraData(sourceGUID, spellID, sourceGUID, true)
      if auraDuration and auraExpirationTime then
        d.auraEndTime = auraExpirationTime
        d.auraDuration = auraDuration
        sendDebugiEET(sformat("AuraApplied: %s,%s", sourceGUID, spellID))
        sendWeakAuraEvent(sourceGUID..cleuEventsToUse[event][spellID], "aura", {auraEndTime = auraExpirationTime, auraDuration = auraDuration, auraActive = true})
      end
    elseif event == "SPELL_AURA_REMOVED" and sourceGUID == destGUID then
      d.auraEndTime = 0
      d.auraDuration = 0
      sendDebugiEET(sformat("AuraRemoved: %s,%s", sourceGUID, spellID))
      sendWeakAuraEvent(sourceGUID..cleuEventsToUse[event][spellID], "aura", {auraEndTime = 0, auraDuration = 0, auraActive = false, guid = sourceGUID})
    elseif event == "SPELL_CAST_SUCCESS" then -- should only be SPELL_CAST_SUCCESS, at least for now, start cd while waiting for sync
      d.endTime = GetTime() + d.duration
      if spellID == 323436 or spellID == 6262 then -- Phial of Serenity, Healthstone
        d.preventUsage = GetTime()+1200 -- Just use stupidly long cd
        sendDebugiEET(sformat("OnlyOnce: %s,%s", sourceGUID, spellID))
        sendWeakAuraEvent(sourceGUID..cleuEventsToUse[event][spellID], "preventUsage", {preventUsage = d.preventUsage, spellID = cleuEventsToUse[event][spellID], guid = sourceGUID})
      end
      if d.maxCharges > 1 then
        d.charges = d.charges - 1
      end
      sendWeakAuraEvent(sourceGUID..cleuEventsToUse[event][spellID], "updateCD", {endTime = d.endTime, currentCharges = d.maxCharges > 1 and d.charges or nil, available = d.charges and d.charges > 0, guid = sourceGUID, spellID = cleuEventsToUse[event][spellID]})
      if spellData[spellID] and spellData[spellID].reset then
        for k in pairs(spellData[spellID].reset) do
          if groupData[sourceGUID] and groupData[sourceGUID].spells and groupData[sourceGUID].spells[k] then
            groupData[sourceGUID].spells[k].endTime = 0
            sendWeakAuraEvent(sourceGUID..k, "updateCD", {endTime = 1, available = true, guid = sourceGUID, spellID = k})
          end
        end
      end
    end
  elseif event == "SPELL_AURA_APPLIED" and destGUID and checkDestOnly[auraToFind] and cleuEventsToUse[event][spellID] and groupData[destGUID] and groupData[destGUID].spells then
    local d = groupData[destGUID].spells[cleuEventsToUse[event][spellID]]
    if not d then return end
    local auraDuration,auraExpirationTime = private:fetchAuraData(destGUID, spellID, nil, true)
    if auraDuration and auraExpirationTime then
      d.auraEndTime = auraExpirationTime
      d.auraDuration = auraDuration
      sendDebugiEET(sformat("AuraApplied(dest): %s,%s", destGUID, spellID))
      sendWeakAuraEvent(destGUID..cleuEventsToUse[event][spellID], "aura", {auraEndTime = auraExpirationTime, auraDuration = auraDuration, auraActive = true, guid = destGUID})
    end
  elseif event == "SPELL_AURA_REMOVED" and destGUID and checkDestOnly[auraToFind] and cleuEventsToUse[event][spellID] and groupData[destGUID] and groupData[destGUID].spells then
    local d = groupData[destGUID].spells[cleuEventsToUse[event][spellID]]
    if not d then return end
    d.auraEndTime = 0
    d.auraDuration = 0
    sendDebugiEET(sformat("AuraRemoved(dest): %s,%s", destGUID, spellID))
    sendWeakAuraEvent(destGUID..cleuEventsToUse[event][spellID], "aura", {auraEndTime = 0, auraDuration = 0, auraActive = false, guid = destGUID})
  end
end
function ns.cooldowns:TRAIT_CONFIG_UPDATED(configID)
  private:checkTalents(configID)
  if not currentlySyncing then return end
  ownCds = {}
  private:sendFullSync()
end
function ns.cooldowns:ACTIVE_COMBAT_CONFIG_CHANGED(configID)
  private:checkTalents(configID)
  if not currentlySyncing then return end
  ownCds = {}
  private:sendFullSync()
end
function ns.cooldowns:TRAIT_CONFIG_LIST_UPDATED()
  private:checkTalents()
  if not currentlySyncing then return end
  ownCds = {}
  private:sendFullSync()
end
function ns.cooldowns:GROUP_JOINED()
  if not IsInGroup() or GetNumGroupMembers() <= 1 then return end
  private:startSyncing()
end
function ns.cooldowns:GROUP_LEFT()
  if IsInGroup() and GetNumGroupMembers() > 1 then return end
  private:stopSyncing()
end
function ns.cooldowns:LoggedIn()
  private:checkTalents()
  isInGuild = IsInGuild()
  if not IsInGroup() then return end
  private:startSyncing()
end
do
  local extValues = {
    allExt =              1,
    absorbExt =           10,
    cheatDeathExt =       100,
    healExt =             1000,
    physicalExt =         10000,
    magicExt =            100000,
    physicalImmunityExt = 1000000,
    magicImmunityExt =    10000000,
    gripExt =             100000000,
  }
  function private:GenerateStringForExternals(externalTypes)
    if not type(externalTypes) == "table" then return "" end
    local ext = 0
    for k, v in pairs(externalTypes) do
      if v then
        ext = ext + (extValues[k] or 0)
      end
    end
    return ext
  end
end
do
  local extIndexToType = {
    [1] = "allExt",
    [2] = "absorbExt",
    [3] = "cheatDeathExt",
    [4] = "healExt",
    [5] = "physicalExt",
    [6] = "magicExt",
    [7] = "physicalImmunityExt",
    [8] = "magicImmunityExt",
    [9] = "gripExt",
  }
  function private:ParseExternalTypeString(str)
    if not str then return {} end
    local types = {}
    local t = {string.byte(str, 1, #str)}
    local j = 0
    for i = #t, 1, -1 do
      j = j + 1
      if t[i] == 49 then -- 49 == 1
        if extIndexToType[j] then
          types[extIndexToType[j]] = true
        end
      end
    end
    return types
  end
end

do
  local lastRequests = {
    GRIP = 0,
    DR = 0,
  }
  function private:RequestExternal(types, playerPrioStr, externalType)
    if not type or not playerPrioStr then return end
    if GetTime() - lastRequests[externalType] < 5 then return end
    lastRequests[externalType] = GetTime()
    SendAddonMessage(prefixToUse, sformat("external%s>%s<%s>%s;%s<%s",
      playerGUID,
      (externalType == "GRIP" and "G" or "D"),
      _GetServerTime(),
      private:GenerateStringForExternals(types),
      "default", -- TODO fix when adding support for all spells
      playerPrioStr
    ),
    currentGroupType)
  end
end
do -- server time accuracy functions
  local serverTime
  local counter = 0
  local firstTime
  local dif
  local tries = 1
  local flames = {
    "Gateways are for *slow* players anyway.",
    "Why use gateways when you can use click-to-move?",
    "You can educate a fool, but you cannot make him think.",
    "A lot of good arguments are spoiled by some fool who knows what he is talking about.",
    "Never tell a fool that he is a fool. All you'll have is an angry fool.",
    "The fool knows after he's suffered",
  }
  _eventHandler:RegisterEvent("LOADING_SCREEN_DISABLED")
  function _eventHandler:LOADING_SCREEN_DISABLED()
    _eventHandler:UnregisterEvent("LOADING_SCREEN_DISABLED")
    _eventHandler:SetScript("OnUpdate", function(...)
      local stime = GetServerTime()
      if not firstTime then
        firstTime = stime
      elseif firstTime + 2 < stime then
        if not serverTime then
          serverTime = stime
        elseif stime > serverTime then
          serverTime = stime
          dif = serverTime-GetTime()
          if dif < initialServerTimeDif then
            initialServerTimeDif = dif
          end
          counter = counter + 1
          if counter == 15 then
            if ns.isLegitChar then
              if ns.configs.cacheCharacters then
                local showPopup = LiquidCharDB and LiquidCharDB.charData and LiquidCharDB.charData.maxilvl == 0
                ns.characterCaching:ScanAllEquippedItems() -- check items after log in (Liquid.lua)
                --ns:CheckCurrency()
                C_Timer.After(5, function()
                  ns.characterCaching:BAG_UPDATE_DELAYED()
                  if LiquidCharDB and LiquidCharDB.charData and LiquidCharDB.charData.currency then
                    for currencyId, func in pairs(ns.cacheConfigs.currency) do
                      func(LiquidCharDB.charData.currency)
                    end
                  end
                  if showPopup then
                    StaticPopup_Show("LIQUID_WARNING_2", "Liquid: Gear is now cached.")
                  end
                end) -- delay by 5seconds in order for CheckSlot() to run through
                --ns:FindTradeableItems()
                
                ns.utility.randomNotifications()
                ns.characterCaching:CacheSimc("Current Set", "current")
                ns.characterCaching:CacheProfessions()
              end
            end
            if ns.configs.lootTracking then
              ns.items:InitItems()
            end
          elseif counter == 20 then
            if C_Item.GetItemCount(188152) == 0 and not LiquidCharDB.gatewayWarning then
              local randomNumber = math.random(1000)
              StaticPopup_Show("LIQUID_WARNING_3", "Liquid tip #"..randomNumber.."\nYou should probably head to nearest <General Goods> vendor and buy Gateway Control Shard.")
              LiquidCharDB.gatewayWarning = true
            end
          elseif counter == 60 then
            do
              local minDif = initialServerTimeDif
              if not syncedServerTimeInformation.set then
                _GetServerTime = function()
                  return minDif+GetTime()
                end
              end
            end
            if currentlySyncing then
              _eventHandler:SetScript("OnUpdate", handleQueue)
            else
              _eventHandler:SetScript("OnUpdate", nil)
            end
            serverTimeAccuracyReached = true
            print("Liquid: Accuracy reached.")
          end
        end
      end
      if currentlySyncing then
        handleQueue(...)
      end
  end)
  end
end
-- create buttons for bindings
do
  local t = {
    {[[/ping [@player] warning
/script LIQUID_MANUAL_ACTION()]], "Manual data sending for WA (Liquid)"}, -- WA Macro
  {[[/ping [@player] assist
/script LiquidAPI:RequestExternal("DR")]], "Request External (Liquid)"}, -- Request External
  {[[/ping [@player] assist
/script LiquidAPI:RequestExternal("GRIP")]],"Request Grip (Liquid)"}, -- Request Grip
     {[[/script LiquidAPI:DeclineExternalCalls()]], "Decline external requests (Liquid)"}, -- Decline all requests
  }
  for k,v in ipairs(t) do
    local btn = CreateFrame("Button", "LIQUID_KEYBINDING"..k, nil, "SecureActionButtonTemplate");
    btn:SetAttribute("type","macro");-- Set type to "macro"
    _G["BINDING_NAME_CLICK LIQUID_KEYBINDING"..k..":Keybind"] = v[2]
    btn:SetAttribute("macrotext",v[1]);-- Set our macro text
    btn:RegisterForClicks("AnyUp", "AnyDown")
  end
  function ns.cooldowns:CreateMacros() -- create actual macros for TWW beta
    if true then return end -- keep this here, TODO add toggle option to create macros, incase someone prefers those
    if ns.isDragonflight then return end
    -- TO DO remove at some point, this just cleans up old mistake
    for i = 1, 4 do
      local mn = "LiquidMacro"..i
      while GetMacroInfo(mn) do
        DeleteMacro(mn)
      end
    end
    for k,v in ipairs(t) do
      local macroName = "LiquidMacro_"..k
      if not GetMacroInfo(macroName) then
          CreateMacro(macroName, 237554, v[1])
      end
      local btn = CreateFrame("Button", "LIQUID_KEYBINDING"..k, nil, "SecureActionButtonTemplate");
      btn:SetAttribute("type","macro");-- Set type to "macro"
      _G["BINDING_NAME_CLICK LIQUID_KEYBINDING"..k..":Keybind"] = v[2]
      --btn:SetAttribute("macrotext",v[1]);-- Set our macro text
      btn:SetAttribute("macro",macroName);-- Set our macro text
      btn:RegisterForClicks("AnyUp", "AnyDown")
    end
  end
end
function LiquidAPI:RequestExternal(externalType, prioData) -- TODO add decent support to call different externals from WA
  if not currentlySyncing then
    ns.PrintDebug("LiquidAPI:RequestExternal - not currently syncing")
    return
  end
  if not (externalType == "DR" or externalType == "GRIP") then
    error("incorrect external type.")
    return
  end
  local sorted = {}
  local legitPrioData = type(prioData) == "table"
  if prioData and not legitPrioData then
    error("prioData is provided but its not a table")
  end
  for guid,data in ns:spairs(groupData) do
    local added = false
    if legitPrioData then
      tinsert(sorted, prioData[guid] or 0)
    else
      if guid == playerGUID then
        added = true
        tinsert(sorted, 0)
      elseif not (data.specID and externalPrioData.prio[data.specID][externalType]) then
        added = true
        tinsert(sorted, 0)
      elseif not (data.classID) then
        added = true
        tinsert(sorted, 0)
      end
      -- range checks
      if not added then
        --if not (data.unitID and UnitInRange(data.unitID)) then
        if not (data.range and data.range[playerGUID]) then
          added = true
          tinsert(sorted, 0)
        end
      end
      --[[
      if not added and externalType == "DR" then
        if not (data.unitID and ((data.classID == 13 and IsItemInRange(18904, data.unitID)) or (data.classID ~= 13 and IsItemInRange(32698, data.unitID)))) then -- 35yd check for evoker, 45yd for the rest
          added = true
          tinsert(sorted, 0)
        end
      elseif not added and externalType == "GRIP" then
        if externalPrioData.longGrip then -- use +20 yard ranges
          if not (data.unitID and ((data.classID == 13 and IsItemInRange(116139, data.unitID)) or (data.classID ~= 13 and IsItemInRange(32825, data.unitID)))) then -- 50yd check for evoker, 60yd for the rest
            added = true
            tinsert(sorted, 0)
          end
        elseif not (data.unitID and ((data.classID == 13 and IsItemInRange(34191, data.unitID)) or (data.classID ~= 13 and IsItemInRange(34471, data.unitID)))) then -- 30yd check for evoker, 40yd for the rest
          added = true
          tinsert(sorted, 0)
        end
      end
      --]]
      if not added then
        local highestSpellFound = 0
        for spellID, spellValue in pairs(externalPrioData.prio[data.specID][externalType]) do -- TODO loop player spells instead of whitelist when supporting all spells
          if data.spells[spellID] then
            if externalPrioData.prio[guid] and externalPrioData.prio[guid][spellID] then
              if externalPrioData.prio[guid][spellID] > highestSpellFound then
                highestSpellFound = externalPrioData.prio[guid][spellID]
              end
            else
              if spellValue > highestSpellFound then
                highestSpellFound = spellValue
              end
            end
          end
        end
        if highestSpellFound > 0 then
          tinsert(sorted, highestSpellFound+#sorted/100)
        else
          tinsert(sorted, 0)
        end
      end
    end
  end
  -- TODO this is "temporary" solution
  local types = externalType == "DR" and {
    allExt = true,
    absorbExt = true,
    cheatDeathExt = true,
    healExt = true,
    physicalExt = true,
    magicExt = true,
    physicalImmunityExt = true,
    magicImmunityExt = true,
  } or {
    gripExt = true,
  }
  private:RequestExternal(types, tconcat(sorted, ";"), externalType)
end
function LiquidAPI:GetSortedGroupData(externalType)
  if not externalType then
    error("externalType is nil")
  end
  local t = {}
  for guid,data in ns:spairs(groupData) do
    local added = false
    if guid == playerGUID then
      added = true
      tinsert(t, {Guid = guid, Prio = 0})
    elseif not (data.specID and externalPrioData.prio[data.specID][externalType]) then
      added = true
      tinsert(t, {Guid = guid, Prio = 0})
    elseif not (data.classID) then
      added = true
      tinsert(t, {Guid = guid, Prio = 0})
    end
    -- range checks
    if not added then
      --if not (data.unitID and UnitInRange(data.unitID)) then
      if not (data.range and data.range[playerGUID]) then
        added = true
        tinsert(t, {Guid = guid, Prio = 0})
      end
    end
    if not added then
      local highestSpellFound = 0
      for spellID, spellValue in pairs(externalPrioData.prio[data.specID][externalType]) do -- TODO loop player spells instead of whitelist when supporting all spells
        if data.spells[spellID] then
          if externalPrioData.prio[guid] and externalPrioData.prio[guid][spellID] then
            if externalPrioData.prio[guid][spellID] > highestSpellFound then
              highestSpellFound = externalPrioData.prio[guid][spellID]
            end
          else
            if spellValue > highestSpellFound then
              highestSpellFound = spellValue
            end
          end
        end
      end
      if highestSpellFound > 0 then
        tinsert(t, {Guid = guid, Prio = highestSpellFound+#t/100})
      else
        tinsert(t, {Guid = guid, Prio = 0})
      end
    end
  end
  return t
end
function LiquidAPI:GetCooldowns(guid, types)
  if not (groupData[guid] and groupData[guid].spells) or not types then return {} end
  local t = {}
  for spellID,d in pairs(groupData[guid].spells) do
    for k in pairs(d.defType) do
      if types[k] then
        t[spellID] = convertSpellToWAFormat(spellID, d, groupData[guid].unitID)
        break
      end
    end
  end
  return t
end
function LiquidAPI:GetCooldownBySpellID(guid, spellID)
  if not (guid and spellID) then return end
  if not (groupData[guid] and groupData[guid].spells and groupData[guid].spells[spellID]) then return end
  return convertSpellToWAFormat(spellID, groupData[guid].spells[spellID], groupData[guid].unitID)
end
function LiquidAPI:GetSpecInformation(guid)
  if not guid then return end
  if not (groupData[guid] and groupData[guid].specID) then return end
  return groupData[guid].specID, groupData[guid].position
end
function LiquidAPI:GetSpotForSpecID(specID)
  if not specID then return end
  return specIDsToRole[specID]
end
function LiquidAPI:GetServerTime()
  return _GetServerTime()
end

---Returns if player has immunity ready in required time, and spellID that is ready if available
---@param guid string
---@param requiredImmunityType number 0 == All, 1 == Magic only, 2 == Physical, 3 == Any
---@param eta number Seconds in when immunity is needed
---@return boolean?, number?
function LiquidAPI:HasImmunityReady(guid, requiredImmunityType, eta)
    if not (guid and type(requiredImmunityType) == "number" and type(eta) == "number") then
      error("LiquidAPI:HasImmunityReady usage: LiquidAPI:HasImmunityReady(guid, requiredImmunityType, eta)")
      return false
    end
    local spells = LiquidAPI:GetCooldowns(guid, {
      immunity = true,
      magicImmunityExt = requiredImmunityType == 1 or requiredImmunityType == 3,
      magicImmunity = requiredImmunityType == 1 or requiredImmunityType == 3,
      physicalImmunity = requiredImmunityType == 2 or requiredImmunityType == 3,
      physicalImmunityExt = requiredImmunityType == 2 or requiredImmunityType == 3,
    })
    if spells then
        for spellID,d in pairs(spells) do
          if spellID == 642 then -- Divine Shield
            if rosterTalents[guid] and rosterTalents[guid].talents then
              if rosterTalents[guid].talents[128259] then -- Light's Revocation, can use Divine Shield during Forberance
                if d.available or (d.endTime-(GetTime()+eta) < 0) then
                  return true, spellID
                end
              elseif (d.available or (d.endTime-(GetTime()+eta) < 0)) and (not d.preventUsage or (d.preventUsage and d.preventUsage-(GetTime()+eta) < 0)) then
                return true, spellID
              end
            elseif (d.available or (d.endTime-(GetTime()+eta) < 0)) and (not d.preventUsage or (d.preventUsage and d.preventUsage-(GetTime()+eta) < 0)) then
              return true, spellID
            end
          elseif (d.available or (d.endTime-(GetTime()+eta) < 0)) and (not d.preventUsage or (d.preventUsage and d.preventUsage-(GetTime()+eta) < 0)) then
              if spellID == 235219 then -- cold snap
                  if spells[45438] and (not spells[45438].preventUsage or (spells[45438].preventUsage and spells[45438].preventUsage-(GetTime()+eta) < 0)) then
                      return true, spellID
                  end
              else
                  return true, spellID
              end
          end
        end
    end
    return false
end
function LiquidAPI:DeclineExternalCalls()
  local requests = {}
  for requesterGUID,d in pairs(cachedAssignments) do
    if d.target.guid == playerGUID then
      tinsert(requests, requesterGUID)
    end
  end
  if #requests == 0 then return end
  SendAddonMessage(prefixToUse, sformat("edecline%s>%s",playerGUID, tconcat(requests, ";")), currentGroupType)
end
---Check if player A is in relevant range of player B
---@param sourceGUID string
---@param destGUID string? Optional, uses playerGUID if not provided
---@return boolean?
function LiquidAPI:CheckRange(sourceGUID, destGUID)
  if not sourceGUID then return end
  if not (groupData[sourceGUID] and groupData[sourceGUID].range) then return end
  if destGUID then
    return groupData[sourceGUID].range[destGUID]
  end
  return groupData[sourceGUID].range[playerGUID]
end
-- Make different globals for macros, so slackers don't have to change their macros at any point, even if we end up changing something internally
function LIQUID_MACRO_EXTERNAL_DR()
  LiquidAPI:RequestExternal("DR")
end
function LIQUID_MACRO_EXTERNAL_GRIP()
  LiquidAPI:RequestExternal("GRIP")
end
function LIQUID_MACRO_EXTERNAL_DECLINE()
  LiquidAPI:DeclineExternalCalls()
end
do -- custom options for WA
  local beeeeeeeeee = {
    ["type"] = "toggle",
    ["key"] = "subOptionasd",
    ["useDesc"] = false,
    ["name"] = "asd",
    ["default"] = false,
    ["width"] = 1,
  } -- [2]
  local baseeeee = {
    ["subOptions"] = {
      {
        ["subOptions"] = {
          {
            ["type"] = "header",
            ["useName"] = true,
            ["noMerge"] = false,
            ["text"] = "Class wide",
            ["width"] = 1,
          }, -- [1]

        },
        ["type"] = "group",
        ["useDesc"] = false,
        ["nameSource"] = 0,
        ["name"] = "Death Knight",
        ["width"] = 1,
        ["useCollapse"] = true,
        ["noMerge"] = true,
        ["key"] = "dk",
        ["collapse"] = false,
        ["limitType"] = "none",
        ["groupType"] = "simple",
        ["hideReorder"] = true,
        ["size"] = 10,
      }, -- [1]
    },
    ["type"] = "group",
    ["useDesc"] = false,
    ["nameSource"] = 0,
    ["name"] = "LiquidFrontEndCooldownsConfig",
    ["width"] = 1,
    ["useCollapse"] = false,
    ["noMerge"] = true,
    ["key"] = "LiquidFrontEndCooldownsConfig",
    ["collapse"] = false,
    ["limitType"] = "none",
    ["groupType"] = "simple",
    ["hideReorder"] = true,
    ["size"] = 10,
  }
  local classData = {
  }
  function ns.cooldowns:GetCustomOptions()
    local classToColoredString = {}
    for classID, specs in pairs(classIDsToSpecID) do
      local className, englishClass = GetClassInfo(classID)
      local colorstr = select(4,GetClassColor(englishClass))
      classToColoredString[className] = sformat("|c%s%s|r", colorstr, className)
    end
    local cached = {}
    local groupedData = {}
    local stuffAtTheEnd = {}
    for spellID, data in pairs(spellData) do
      --[114556] = {p = 15, cd = 240,  debuffOnly = 123981, t = {cheatDeath = true}, activation = {e = "SPELL_AURA_APPLIED", b = 123981}, class = 6, specID = 250, displayName = "Purgatory"}, -- Purgatory
      local classToUse = cached[data.class]
      if not classToUse then
        if data.class == 0 then
          cached[data.class] = "All"
          classToUse = "All"
        else
          local className = GetClassInfo(data.class)
          cached[data.class] = className
          classToUse = className
        end
      end
      local tableToUse = data.class == 0 and stuffAtTheEnd or groupedData
      local spec = type(data.specID) == "table" and 0 or data.specID
      local specToUse
      if data.class == 0 then
        if data.specID == 1 then
          specToUse = "Racials"
        elseif data.specID == 2 then
          specToUse = "Items"
        else
          specToUse = UNKNOWN
        end
      else
        if spec == 0 then
          specToUse = "Class wide"
        end
      end
      if not specToUse then
        specToUse = cached[spec]
        if not specToUse then
          local _,specName,_,icon = GetSpecializationInfoForSpecID(spec)
          cached[spec] = specName
          --specToUse = sformat("%s%s",CreateSimpleTextureMarkup(icon),specName)

          specToUse = specName
        end
      end
      if not tableToUse[classToUse] then
        tableToUse[classToUse] = {}
      end
      if not tableToUse[classToUse][specToUse] then
        tableToUse[classToUse][specToUse] = {}
      end
      tableToUse[classToUse][specToUse][data.displayName] = tostring(spellID)
    end
    local base = {
      ["type"] = "group",
      ["useDesc"] = false,
      ["nameSource"] = 0,
      ["name"] = "LiquidFrontEndCooldownsConfig",
      ["width"] = 1,
      ["useCollapse"] = false,
      ["noMerge"] = true,
      ["key"] = "LiquidFrontEndCooldownsConfig",
      ["collapse"] = false,
      ["limitType"] = "none",
      ["groupType"] = "simple",
      ["hideReorder"] = true,
      ["size"] = 10,
      ["subOptions"] = {}
    }
    for className, _classData in ns:spairs(groupedData) do
      local _coloredClassName = classToColoredString[className]
      local t = {
          ["subOptions"] = {},
          ["type"] = "group",
          ["useDesc"] = false,
          ["nameSource"] = 0,
          ["name"] = _coloredClassName,
          ["width"] = 1,
          ["useCollapse"] = true,
          ["noMerge"] = true,
          ["key"] = className,
          ["collapse"] = false,
          ["limitType"] = "none",
          ["groupType"] = "simple",
          ["hideReorder"] = true,
          ["size"] = 10,
      }
      for specName, d in ns:spairs(_classData, function(_,a,b) return (a=="Class wide" and "" or a)<(b=="Class wide" and "" or b) end) do
        tinsert(t.subOptions,
          {
            ["type"] = "header",
            ["useName"] = true,
            ["noMerge"] = false,
            ["text"] = specName,
            ["width"] = 1,
          }
        )
        for spellName, spellKey in ns:spairs(d) do
          local icon
          if tonumber(spellKey) > 0 then
            icon =  C_Spell.GetSpellTexture(spellKey)
          else
            icon = select(5, C_Item.GetItemInfoInstant(-tonumber(spellKey)))
          end
          tinsert(t.subOptions, {
            ["type"] = "toggle",
            ["key"] = spellKey,
            ["useDesc"] = false,
            ["name"] = sformat("%s %s", icon and CreateSimpleTextureMarkup(icon) or "",spellName),
            ["default"] = false,
            ["width"] = 1,
          })
        end
      end
      tinsert(base.subOptions, t)
    end
    for catName, catData in ns:spairs(stuffAtTheEnd) do
      local t = {
          ["subOptions"] = {},
          ["type"] = "group",
          ["useDesc"] = false,
          ["nameSource"] = 0,
          ["name"] = catName,
          ["width"] = 1,
          ["useCollapse"] = true,
          ["noMerge"] = true,
          ["key"] = catName,
          ["collapse"] = false,
          ["limitType"] = "none",
          ["groupType"] = "simple",
          ["hideReorder"] = true,
          ["size"] = 10,
      }
      for subCatName, d in ns:spairs(catData) do
        tinsert(t.subOptions,
          {
            ["type"] = "header",
            ["useName"] = true,
            ["noMerge"] = false,
            ["text"] = subCatName,
            ["width"] = 1,
          })
        for spellName, spellKey in ns:spairs(d) do
          tinsert(t.subOptions, {
            ["type"] = "toggle",
            ["key"] = spellKey,
            ["useDesc"] = false,
            ["name"] = spellName,
            ["default"] = false,
            ["width"] = 1,
          })
        end
      end
      tinsert(base.subOptions, t)
    end
    return base
  end
end

do -- export stuff
  local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
  end
  --[=[
  function ICD_EXPORTCUSTOMOPTIONS()
    IroniDB.icdData = {}
    local classes = {
      [6]	= 1, -- Death Knight
      [12] = 2, -- Demon Hunter
      [11] = 3, -- Druid
      [13] = 4, -- Evoker
      [3] = 5, -- Hunter
      [8] = 6, -- Mage
      [10] = 7, -- Monk
      [2] = 8, -- Paladin
      [5]	= 9, -- Priest
      [4]	= 10, -- Rogue
      [7]	= 11, -- Shaman
      [9]	= 12, -- Warlock
      [1]	= 13, -- Warrior
      [0] = 20, -- Items, racials, whatever
    }
    local sorted = {}
    for k,v in pairs(spellData) do
      if not sorted[v.class] then
        sorted[v.class] = {}
      end
      if not sorted[v.class][v.specID] then
        sorted[v.class][v.specID] = {}
      end
      sorted[v.class][v.specID][k] = v
    end
    for classID,classData in spairs(sorted, function(t,a,b) return classes[a] < classes[b] end) do
      local classLocalized, className = GetClassInfo(classID)
      local coloredClass = className and RAID_CLASS_COLORS[className]:WrapTextInColorCode(classLocalized) or "General"
      local temp = {
        ["type"] = "group",
        ["useDesc"] = false,
        ["nameSource"] = 0,
        ["name"] = coloredClass,
        ["width"] = 1,
        ["useCollapse"] = true,
        ["noMerge"] = false,
        ["key"] = tostring(classID),
        ["collapse"] = false,
        ["limitType"] = "none",
        ["groupType"] = "simple",
        ["hideReorder"] = true,
        ["size"] = 10,
        ["subOptions"] = {}
      }
      for specID, specData in spairs(classData, function(t,a,b) return ((type(a) == "table" and " ") or (a == 0 and " ") or (select(2,GetSpecializationInfoByID(a > 10 and a or 0))) or "z") < ((type(b) == "table" and " ") or ((b == 0 and " ") or select(2,GetSpecializationInfoByID(b > 10 and b or 0))) or "z") end) do
        local specName
        if type(specID) == "table" then
          local t = {}
          for k,v in pairs(specID) do
            local n = select(2, GetSpecializationInfoByID(v))
            tinsert(t, n)
          end
          specName = table.concat(t, " & ")
        elseif specID == 0 then specName = "All"
        elseif specID == 1 then specName = "Racials"
        elseif specID == 2 then specName = "Items"
        else
          specName = select(2, GetSpecializationInfoByID(specID))
        end
        if specName == nil then
          print("nil specName:",specID)
        end
        tinsert(temp.subOptions, {
          ["type"] = "header",
          ["useName"] = true,
          ["text"] = specName or "",
          ["noMerge"] = false,
          ["width"] = 1
        })
        for spellID, spellData in spairs(specData, function(t,a,b) return (a > 0 and GetSpellInfo(a) or GetItemInfo(-a)) < (b > 0 and GetSpellInfo(b) or GetItemInfo(-b)) end) do
          local n = spellID > 0 and GetSpellInfo(spellID) or GetItemInfo(-spellID)
          if not n then print("NAME NOT FOUND FOR:", spellID) end
          tinsert(temp.subOptions, {
            ["type"] = "toggle",
            ["useDesc"] = false,
            ["key"] = tostring(spellID),
            ["default"] = false,
            ["name"] = n,
            ["width"] = 0.65
          })
        end
      end
      tinsert(IroniDB.icdData, temp)
    end
  end
  --]=]
  local editbox
  local function showExport(text)
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
      editbox:SetScript("OnEditFocusGained", function()
        editbox:HighlightText()
      end)
      editbox:SetScript('OnEnterPressed', function()
        editbox:ClearFocus()
        editbox:Hide()
      end)
      editbox:SetWidth(400)
      editbox:SetHeight(30)
      editbox:SetTextInsets(2, 2, 1, 0)
      editbox:SetPoint('center', UIParent, 'center', 0,0)
      editbox:SetAutoFocus(true)
---@diagnostic disable-next-line: undefined-field
      editbox:SetFont(STANDARD_TEXT_FONT, 10, "")
    end
    editbox:SetText(text)
    editbox:Show()
  end
  --[==[
  function LIQUIDEXPORTSHIT()
    if not IroniDB then return end
    local cats = {
      -- Externals
      --[[
      allExt = 800000,
      absorbExt = 790000,
      cheatDeathExt = 780000,
      healExt = 770000,
      physicalExt = 760000,
      magicExt = 750000,
      physicalImmunityExt = 740000,
      magicImmunityExt = 730000,
      --]]
      -- Immunity
      immunity = 700000,
      magicImmunity = 690000,
      physicalImmunity = 680000,
      -- Cheat deaths
      --cheatDeath = 600000,
      -- Personals
      all = 500000,
      magic = 490000,
      physical = 480000,
      absorb = 470000,
      heal = 460000,
    }
    local t = {}
    tinsert(t, 191427) -- Metamorphosis
    tinsert(t, 198589) -- Blur
    tinsert(t, 187827) -- Metamorphosis
    tinsert(t, 203720) -- Demon Spikes
    tinsert(t, 22812) -- Barkskin
    tinsert(t, {115877, 110959}) -- Greater Invisibility
    tinsert(t, {80177, 66}) -- Invisibility
    tinsert(t, {80141, 414659}) -- Ice Cold
    tinsert(t, {80181, 45438}) -- Ice Block
    tinsert(t, 235450) -- Prismatic Barrier
    tinsert(t, 235313) -- Blazing Barrier
    tinsert(t, 86949) --Cauterize
    tinsert(t, 11426) -- Ice Barrier
    tinsert(t, 235219) -- Cold Snap
    tinsert(t, 109304) -- Exhilaration
    tinsert(t, 5384) -- Feign Death
    tinsert(t, 781) -- Disengage
    tinsert(t, 186257) -- Aspect of the Cheetah
    tinsert(t, 186265) -- Aspect of the Turtle
    tinsert(t, 272679) -- Fortitude of the Bear
    tinsert(t, 642) -- Divine Shield
    tinsert(t, 115203) -- Fortifying Brew
    tinsert(t, 185311) -- Crimson Vial
    tinsert(t, 2983) -- Sprint
    tinsert(t, 1966) -- Feint
    tinsert(t, 104773) -- Unending Resolve  
    tinsert(t, {96199, 48707}) -- Anti Magic Shell
    tinsert(t, {96192, 49039}) -- Lichborne DR 
    tinsert(t, {96213, 48792}) -- Icebound Fortitude
    tinsert(t, {96194, 51052}) -- Anti-Magic Zone
    tinsert(t, {96206, 48743}) -- Death Pact 
    tinsert(t, {96207, 212552}) -- Wraith Walk
    tinsert(t, {96177, 383269}) -- Abomination Limb
    tinsert(t, {96308, 55233}) -- Vampiric Blood
    tinsert(t, {96278, 194679}) -- Rune Tap
    tinsert(t, {96269, 49028}) -- Dancing Rune Weapon
    tinsert(t, {96270, 219809}) -- Tombstone
    tinsert(t, {96267, 108199}) -- Gorefiend's Grasp
    tinsert(t, {96264, 114556}) -- Purgatory
    tinsert(t, {112853, 198793}) -- Vengeful Retreat
    tinsert(t, {112921, 196718}) -- Darkness
    tinsert(t, {112821, 196555}) -- Netherwalk
    tinsert(t, {112864, 204021, 112876}) -- Fiery Brand (Down in Flames increases charges to 2)
    tinsert(t, {112904, 202137}) -- Sigil of Silence
    tinsert(t, {112867, 202138}) -- Sigil of Chains
    tinsert(t, {112895, 209258}) -- Last Resort
    tinsert(t, {103298, 22842}) -- Frenzied Regeneration
    tinsert(t, {103276, 102401}) -- Wild Charge
    tinsert(t, {-103275, 1850}) -- Dash
    tinsert(t, {103275, 252216}) -- Tiger Dash
    tinsert(t, {103287, 132469}) -- Typhoon
    tinsert(t, {103312, 106898}) -- Stampeding Roar
    tinsert(t, {103321, 102793}) -- Ursol's Vortex
    tinsert(t, {103310, 108238}) -- Renewal
    tinsert(t, {103324, 124974}) -- Nature's Vigil
    tinsert(t, {103323, 29166}) -- Innervate
    tinsert(t, {103180, 61336}) -- Survival Instincts
    tinsert(t, {103193, 61336, 103192}) -- Survival Instincts (Improved Survival Instincts increases charges to 2)
    tinsert(t, {103222, 80313}) -- Pulverize
    tinsert(t, {103207, 200851}) -- Rage of the Sleeper
    tinsert(t, {103141, 102342}) -- Ironbark
    tinsert(t, {103108, 740}) -- Tranquility
    tinsert(t, {103120, 33891}) -- Incarnation: Tree of Life
    tinsert(t, {103119, 391528}) -- Convoke the Spirits
    tinsert(t, {103136, 197721}) -- Flourish
    tinsert(t, {115613, 363916, 115597}) -- Obsidian Scales, Obsidian Bulwark increases charges by 1
    tinsert(t, {115658, 374348}) -- Renewing Blaze
    tinsert(t, {115596, 370665}) -- Rescue
    tinsert(t, {115666, 374968}) -- Time Spiral
    tinsert(t, {115661, 374227}) -- Zephyr
    tinsert(t, {115655, 360995}) -- Verdant Embrace
    tinsert(t, {115651, 363534, 115570}) -- Rewind, Erasure increases charges by 1
    tinsert(t, {115650, 357170}) -- Time Dilation
    tinsert(t, {115549, 370960}) -- Emerald Communion
    tinsert(t, {115573, 359816}) -- Dream Flight
    tinsert(t, {100523, 264735}) -- Survival of the Fittest
    tinsert(t, {100652, 392060}) -- Wailing Arrow
    tinsert(t, {100590, 392060}) -- Wailing Arrow
    tinsert(t, {-80163, 1953}) -- Blink
    tinsert(t, {80163, 212653}) -- Shimmer
    tinsert(t, {80174, 342245}) -- Alter Time
    tinsert(t, {80183, 55342}) -- Mirror Image
    tinsert(t, {80152, 389713}) -- Displacement
    tinsert(t, {80148, 414660}) -- Mass Barrier
    tinsert(t, {101507, 116841}) -- Tiger's Lust
    tinsert(t, {101502, 115008, 101531}) -- Chi Torpedo (Improved Roll increases charges by 1)
    tinsert(t, {101512, 119996}) -- Transcendence: Transfer
    tinsert(t, {101516, 116844}) -- Ring of Peace
    tinsert(t, {101515, 122783}) -- Diffuse Magic
    tinsert(t, {101522, 122278}) -- Dampen Harm
    tinsert(t, {101458, 122281}) -- Healing Elixir
    tinsert(t, {101463, 322507}) -- Celestial Brew
    tinsert(t, {101547, 115176}) -- Zen Meditation
    tinsert(t, {101420, 122470}) -- Touch of Karma
    tinsert(t, {101432, 101545}) -- Flying Serpent Kick
    tinsert(t, {101390, 116849}) -- Life Cocoon
    tinsert(t, {101378, 115310}) -- Revival
    tinsert(t, {101377, 388615}) -- Restoral
    tinsert(t, {101374, 122281}) -- Healing Elixir
    tinsert(t, {101397, 322118}) -- Invoke Yu'lon, the Jade Serpent
    tinsert(t, {101396, 325197}) -- Invoke Chi-ji, the Red Crane
    tinsert(t, {102587, 1044}) -- Blessing of Freedom
    tinsert(t, {102602, 6940}) -- Blessing of Sacrifice
    tinsert(t, {102604, 1022}) -- Blessing of Protection
    tinsert(t, {102583, 633}) -- Lay on Hands
    tinsert(t, {102549, 498}) -- Divine Protection
    tinsert(t, {102607, 105809}) -- Holy Avenger
    tinsert(t, {102548, 31821}) -- Aura Mastery
    tinsert(t, {102573, 200652}) -- Tyr's Deliverance
    tinsert(t, {102445, 31850}) -- Ardent Defender
    tinsert(t, {111886, 204018}) -- Blessing of Spellwarding
    tinsert(t, {102456, 86659}) -- Guardian of the Ancient Kings
    tinsert(t, {102466, 387174}) -- Eye of Tyr
    tinsert(t, {102521, 184662}) -- Shield of Vengeance
    tinsert(t, {102520, 498}) -- Divine Protection
    tinsert(t, {102486, 205191}) -- Eye for an Eye
    tinsert(t, 19236) -- Desperate Prayer
    tinsert(t, {103835, 586}) -- Fade
    tinsert(t, {103853, 121536}) -- Angelic Feather
    tinsert(t, {103820, 108968}) -- Void Shift
    tinsert(t, {103868, 73325}) -- Leap of Faith
    tinsert(t, {103844, 10060}) -- Power Infusion
    tinsert(t, {103713, 33206, 103714}) -- Pain Suppression
    tinsert(t, {103687, 62618}) -- Power Word: Barrier
    tinsert(t, {103727, 47536}) -- Rapture
    tinsert(t, {103691, 246287}) -- Evangelism
    tinsert(t, {103844, 10060}) -- Power Infusion
    tinsert(t, {103774, 47788}) -- Guardian Spirit
    tinsert(t, {103755, 64843}) -- Divine Hymn
    tinsert(t, {103751, 64901}) -- Symbol of Hope
    tinsert(t, {103743, 200183}) -- Apotheosis
    tinsert(t, {103742, 265202}) -- Holy Word: Salvation
    tinsert(t, {103733, 372835}) -- Lightwell
    tinsert(t, {103676, 391124}) -- Restitution
    tinsert(t, {103841, 15286}) -- Vampiric Embrace
    tinsert(t, {103832, 10060}) -- Power Infusion, track only with Twins of the Sun Priestess
    tinsert(t, {103806, 47585}) -- Dispersion
    tinsert(t, {112657, 5277}) -- Evasion
    tinsert(t, {112585, 31224}) -- Cloak of Shadows
    tinsert(t, {114737, 31230}) -- Cheat Death
    tinsert(t, {101945, 108271}) -- Astral Shift
    tinsert(t, {101952, 198103}) -- Earth Elemental
    tinsert(t, {101976, 192077}) -- Wind Rush Totem
    tinsert(t, {101983, 58875}) -- Spirit Walk
    tinsert(t, {101982, 192063}) -- Gust of Wind
    tinsert(t, {102000, 108281}) -- Ancestral Guidance
    tinsert(t, {101913, 98008}) -- Spirit Link Totem
    tinsert(t, {101929, 16191}) -- Mana Tide Totem
    tinsert(t, {101912, 108280}) -- Healing Tide Totem
    tinsert(t, {101930, 207399}) -- Ancestral Protection Totem
    tinsert(t, {101942, 114052}) -- Ascendance  
    tinsert(t, {91441, 48020}) -- Demonic Circle: Teleport
    tinsert(t, {91457, 6789}) -- Mortal Coil
    tinsert(t, {91444, 108416}) -- Dark Pact
    tinsert(t, {112183, 202168}) -- Impending Victory
    tinsert(t, {112186, 3411}) -- Intervene
    tinsert(t, {112188, 97462}) -- Rallying Cry
    tinsert(t, {112208, 6544}) -- Heroic Leap
    tinsert(t, {112220, 383762}) -- Bitter Immunity
    tinsert(t, {112128, 118038}) -- Die by the Sword
    tinsert(t, {112264, 184364}) -- Enraged Regeneration
    tinsert(t, {112159, 1160}) -- Demoralizing Shout
    tinsert(t, {112151, 12975}) -- Last Stand
    tinsert(t, {112167, 871, 112165}) -- Shield Wall, Unbreakable Will increases charges by 1
    tinsert(t, {112173, 385952}) -- Shield Charge
    local _t = {}
    for _,v in pairs(t) do
      local spellID = type(v) == "number" and v or v[2]
      local talentID = type(v) == "number" and 0 or v[1]
      local talentForExtraCharges = type(v) == "number" and 0 or (v[3] and v[3] or 0)
      local d = spellData[spellID]
      if not d then print("incorrect spellID:", spellID) end
      local care = false
      --/script LIQUIDEXPORTSHIT()
      if spellID > 0 then
        for cat in pairs(cats) do
          if d.t[cat] then
            care = true
            break
          end
        end
      end
      if care then
          local s = {
            specID = type(d.specID) == "table" and CopyTable(d.specID) or d.specID,
            classID = d.class,
            spellName = GetSpellInfo(spellID),
            possibleSpellIDs = d.possibleSpellIDs and CopyTable(d.possibleSpellIDs) or {},
            talentID = talentID,
            talentForExtraCharges = talentForExtraCharges,
            spellID = spellID,
            activationStuffInTheAddOn = {e = d.activation.e, sameSpellID = d.activation.b}
          }
          tinsert(_t, s)
      end
    end
    IroniDB.LiquidWCLShit = _t
  end
  --]==]
  function ICDEXPORTSPELLS(full)
    local exportData = {}
    local classes = {
      [6]	= 1, -- Death Knight
      [12] = 2, -- Demon Hunter
      [11] = 3, -- Druid
      [13] = 4, -- Evoker
      [3] = 5, -- Hunter
      [8] = 6, -- Mage
      [10] = 7, -- Monk
      [2] = 8, -- Paladin
      [5]	= 9, -- Priest
      [4]	= 10, -- Rogue
      [7]	= 11, -- Shaman
      [9]	= 12, -- Warlock
      [1]	= 13, -- Warrior
      [0] = 20, -- Items, racials, whatever      
    }
    local split = {}
    for k,v in pairs(spellData) do
      if not split[v.class] then
        split[v.class] = {}
      end
      if not split[v.class][v.specID] then
        split[v.class][v.specID] = {}
      end
      if full then
        local t = {
          k > 0 and C_Spell.GetSpellInfo(k).name or C_Item.GetItemInfo(k*-1),
          v.cd,
        }
        for cat in pairs(v.t) do
          tinsert(t,cat)
        end
        split[v.class][v.specID][k] = table.concat(t, "\t")
      else
        split[v.class][v.specID][k] = k > 0 and C_Spell.GetSpellInfo(k).name
      end
    end
    for classID,classData in spairs(split, function(t,a,b) return classes[a] < classes[b] end) do
      local className = classID == 0 and "General" or GetClassInfo(classID)
      tinsert(exportData, className)
      local specs = {}
      for specID, specData in spairs(classData, function(t,a,b) if type(a) == "table" then a = 20 end if type(b) == "table" then b = 20 end return a < b end) do
        if not specs[specID] then
          specs[specID] = true
          local specName
          if type(specID) == "table" then
            local specs = {}
            for k,v in pairs(specID) do
              tinsert(specs, (select(2, GetSpecializationInfoForSpecID(v))))
            end
            specName = table.concat(specs, " & ")
          elseif specID < 10 then
            if specID == 0 then
              specName = "All"
            elseif specID == 1 then
              specName = "Racials"
            elseif specID == 2 then
              specName = "Items"
            else
              specName = "UNKNOWN"
            end
          else
            specName = select(2, GetSpecializationInfoForSpecID(specID))
          end
          tinsert(exportData, "\t"..specName)
        end
        for id, name in pairs(specData) do
          tinsert(exportData, sformat("\t\t%s\t%s", id, name))
        end
      end
    end
    showExport(table.concat(exportData, "\r"))
  end
end