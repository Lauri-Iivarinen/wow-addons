local _, ns = ...

ns.cacheConfigs = {
  minLevel = 70,
  raidDataPreserveTime = 3*24*60*60, -- (3d), Older raids are removed from DB to keep it clean
  sparkItemID = 230906, -- Spark of Fortunes
	sparkFragmentItemID = 230905, -- Fractured Spark of Fortunes
	dbVersion = 3,
	crestHeroic = 3109,
	crestMythic = 3110,
	tierConversion = 3116, -- Essence of Kaja'mite
	minMythicPlus = 10,
}

--[[ currency slots in the addon:
1: sparks
2: mythic crest
3: heroic crest
4: max mythic crests
5: Restored Coffer Key
6: Coffer Key Shard
7: Highest boss kill
8: Professions
9: convert
10: version
]]
ns.cacheConfigs.currency = {
  [ns.cacheConfigs.crestMythic] = function(currencyDB) -- Gilded (Mythic)
    local ci = C_CurrencyInfo.GetCurrencyInfo(ns.cacheConfigs.crestMythic)
    currencyDB[2] = ci and ci.quantity or 0
		currencyDB[4] = ci and ci.totalEarned or 0
  end,
  [ns.cacheConfigs.crestHeroic] = function(currencyDB) -- Runed (Heroic)
    local ci = C_CurrencyInfo.GetCurrencyInfo(ns.cacheConfigs.crestHeroic)
    currencyDB[3] = ci and ci.quantity or 0
  end,
	[ns.cacheConfigs.tierConversion] = function(currencyDB) -- Tier Conversion
    local ci = C_CurrencyInfo.GetCurrencyInfo(ns.cacheConfigs.tierConversion)
    currencyDB[9] = ci and ci.quantity or 0
  end,
	[3028] = function(currencyDB) -- Restored Coffer Key
    local ci = C_CurrencyInfo.GetCurrencyInfo(3028)
    currencyDB[5] = ci and ci.quantity or 0
		--currencyDB[4] = ci.maxQuantity or 0
  end,
	-- tier converts = 9
	-- max mythic crests = 4
}
ns.cacheConfigs.reputations = { -- these are called on UPDATE_FACTION
  --[[function(currencyDB) -- Dream Wardens
    local faction = C_MajorFactions.GetMajorFactionData(2574)
    if faction then
      local currentLevel = faction.renownLevel or 0
      local repEarned = faction.renownReputationEarned or 0
      local renownLevelThreshold = faction.renownLevelThreshold or 2500
      local renownToShow = string.format("%.1f", currentLevel+repEarned/renownLevelThreshold)
      currencyDB[8] = renownToShow
    else
      currencyDB[8] = 0
    end
  end,
	--]]
}
ns.cacheConfigs.items = { -- these are called on BAG_UPDATE_DELAYED
  function(currencyDB) -- Sparks
		local fullSparks = C_Item.GetItemCount(ns.cacheConfigs.sparkItemID, true, nil, true) or 0
		local fragments = C_Item.GetItemCount(ns.cacheConfigs.sparkFragmentItemID, true, nil, true) or 0
		currencyDB[1] = fullSparks+(fragments/2)
  end,
	function(currencyDB) -- Coffer Key Shard
		currencyDB[6] = C_Item.GetItemCount(229899, true, nil, true) or 0
  end,
}
ns.cacheConfigs.specialWeeklyRewards = function(currencyDB, str)
	currencyDB[9] = str or ""
end
ns.cacheConfigs.professions = function(currencyDB, str) -- set it here so i dont miss it later that its actually caching something
	currencyDB[8] = str
end
ns.cacheConfigs.gear = {
	itemLevelRequirementForCaching = 620,
  tierSets = { -- Tier sets we want to track
		--[[ TWW S1
		[1696] = true, --  Death Knight
		[1695] = true, --  Demon Hunter
		[1694] = true, --  Druid
		[1693] = true, --  Evoker
		[1692] = true, --  Hunter
		[1691] = true, --  Mage
		[1690] = true, --  Monk
		[1689] = true, --  Paladin
		[1688] = true, --  Priest
		[1687] = true, --  Rogue
		[1686] = true, --  Shaman
		[1685] = true, --  Warlock
		[1684] = true, --  Warrior
		--]]
		-- TWW S2
		[1867] = true, --  Death Knight
		[1868] = true, --  Demon Hunter
		[1869] = true, --  Druid
		[1870] = true, --  Evoker
		[1871] = true, --  Hunter
		[1872] = true, --  Mage
		[1873] = true, --  Monk
		[1874] = true, --  Paladin
		[1875] = true, --  Priest
		[1876] = true, --  Rogue
		[1877] = true, --  Shaman
		[1878] = true, --  Warlock
		[1879] = true, --  Warrior
  },
  tierSlots = { -- Current tier slots, these matter for speadsheet too, so DO NOT CHANGE unless you know what you are doing
    [INVSLOT_HEAD] = 1,
    [INVSLOT_SHOULDER] = 2,
    [INVSLOT_CHEST] = 3,
    [INVSLOT_HAND] = 4,
    [INVSLOT_LEGS] = 5,
    ["Head"] = 1,
    ["Shoulders"] = 2,
    ["Chest"] = 3,
    ["Hands"] = 4,
    ["Legs"] = 5,
  },
	showStatsForItems = { -- These are for splits, normally we only show tertiaries, for these we also show secondary stats
		[228843] = true, -- Miniature Roulette Wheel (TWW S2)
	}
}
ns.cacheConfigs.tierTokens = { -- TODO figure out does this actually serve purpose anymore, dont wanna change it right before S2 though

	--[[	-- TWW S1 (Nerub-ar Palace)
	-- Dreadful
	225614, 225622, 225630, 225626, 225618,
	-- Mystic
	225615, 225623, 225631, 225627, 225619,
	-- Venerated
	225616, 225624, 225632, 225628, 225620,
	-- Zenith
	225617, 225625, 225633, 225629, 225621,
	-- Curio
	225634,
	--]]
	-- TWW S2 (Undermine)
	-- Dreadful
	228803,228807,228799,228815,228811,
	-- Mystic
	228804,228808,228800,228816,228812,
	-- Venerated
	228805,228809,228801,228817,228813,
	-- Zenith
	228806,228810,228802,228818,228814,
	-- Curio
	228819,

}

ns.cacheConfigs.itemsForTrading = {
	--[[
	-- TWW S1 (Nerub-ar Palace)
	225614,225622,225630,225626,225618,225615,225623,225631,225627,225619,225616,225624,225632,
	225628,225620,225634,225617,225625,225633,225629,225621,212407,212413,212389,212397,212388,
	212401,212395,212398,212392,212405,212391,225636,212404,212394,212409,219877,212400,212399,
	225579,212386,212387,212417,212440,212428,212427,212448,225575,225577,212439,212444,212424,
	212429,212446,225574,212419,212421,212433,212420,212426,225587,225581,212438,212437,225588,
	225584,212415,212441,212418,212436,212432,225580,225585,225583,212425,212442,212414,225589,
	212430,212422,212435,212423,212434,225582,225590,212445,212416,225591,225586,212443,212431,
	212447,225578,225576,212451,219917,219915,212452,212454,220305,212449,212453,220202,212450,
	221023,212456,
	--]]
	-- TWW S2 (Undermine)
	228799,228802,228800,228801,228807,228810,228808,228809,228817,228818,228813,228812,228811,
	228814,228819,228816,228803,228805,228806,228804,228815,228898,228905,232526,228903,228891,
	228892,228894,231266,231268,228896,228901,228902,232804,228899,228897,228895,228904,228893,
	228900,231311,228889,228906,228890,228871,228859,228848,228858,228841,228842,228870,228860,
	228855,228875,228844,228839,228851,228850,228864,228852,228884,228885,228857,228869,228878,
	228881,228868,228846,228867,228863,228849,228872,228882,228886,228880,228877,228861,228873,
	228856,228845,228853,228854,228866,228865,228888,228883,228876,228874,228879,228887,228862,
	228847,228843,231265,228840,230019,230186,230193,230188,230027,230194,230026,230189,230199,
	230192,230198,230029,230197,230191,230190,
	-- TWW S2 Trash
	232656,232655,232657,232658,232659,232660,232661,232662,232663,
}
ns.cacheConfigs.itemsForTradingBoE = { -- for scuffed trading shit in case of trash splits :puke
	232656,232655,232657,232658,232659,232660,232661,232662,232663,
}

ns.cacheConfigs.simc = {
  encounters = {
		--[[
		-- TWW S1 (Nerub-ar Palace)
		[2902] = true, -- Ulgrax the Devourer
		[2917] = true, -- The Bloodhound Horror
		[2898] = true, -- Sikran, Captain of the Sureki
		[2918] = true, -- Rasha'nan
		[2919] = true, -- Broodtwister Ovi'nax
		[2920] = true, -- Nexus-Princess Ky'veza
		[2921] = true, -- The Silken Court
		[2922] = true, -- Queen Ansurek
		--]]
		-- TWW S2 (Undermine)
		[3009] = true, -- Vexie and the Geargrinders
		[3010] = true, -- Cauldron of Carnage
		[3011] = true, -- Rik Reverb
		[3012] = true, -- Stix Bunkjunker
		[3013] = true, -- Sprocketmonger Lockenstock
		[3014] = true, -- One-Armed Bandit
		[3015] = true, -- Mug'Zee, Heads of Security
		[3016] = true, -- Chrome King Gallywix
  }
}
ns.cacheConfigs.highestKill = {
	orders = {
		[3009] = 1, -- Vexie and the Geargrinders
		[3010] = 2, -- Cauldron of Carnage
		[3011] = 3, -- Rik Reverb
		[3012] = 4, -- Stix Bunkjunker
		[3013] = 5, -- Sprocketmonger Lockenstock
		[3014] = 6, -- One-Armed Bandit
		[3015] = 7, -- Mug'Zee, Heads of Security
		[3016] = 8, -- Chrome King Gallywix
	},
	statistics = {
		-- Mythic (16)
		{statisticID = 41330, dif = 16, encounterID = 3016}, -- Chrome King Gallywix (Mythic Liberation of Undermine)
		{statisticID = 41326, dif = 16, encounterID = 3015}, -- Mug'Zee, Heads of Security (Mythic Liberation of Undermine)
		{statisticID = 41322, dif = 16, encounterID = 3014}, -- The One-Armed Bandit (Mythic Liberation of Undermine)
		{statisticID = 41318, dif = 16, encounterID = 3013}, -- Sprocketmonger Lockenstock (Mythic Liberation of Undermine)
		{statisticID = 41314, dif = 16, encounterID = 3012}, -- Stix Bunkjunker (Mythic Liberation of Undermine)
		{statisticID = 41310, dif = 16, encounterID = 3011}, -- Rik Reverb (Mythic Liberation of Undermine)
		{statisticID = 41306, dif = 16, encounterID = 3010}, -- Cauldron of Carnage (Mythic Liberation of Undermine)
		{statisticID = 41302, dif = 16, encounterID = 3009}, -- Vexie and the Geargrinders Mythic Liberation of Undermine)
		-- Heroic (15)
		{statisticID = 41329, dif = 15, encounterID = 3016}, -- Chrome King Gallywix (Heroic Liberation of Undermine)
		{statisticID = 41325, dif = 15, encounterID = 3015}, -- Mug'Zee, Heads of Security (Heroic Liberation of Undermine)
		{statisticID = 41321, dif = 15, encounterID = 3014}, -- The One-Armed Bandit (Heroic Liberation of Undermine)
		{statisticID = 41317, dif = 15, encounterID = 3013}, -- Sprocketmonger Lockenstock (Heroic Liberation of Undermine)
		{statisticID = 41313, dif = 15, encounterID = 3012}, -- Stix Bunkjunker (Heroic Liberation of Undermine)
		{statisticID = 41309, dif = 15, encounterID = 3011}, -- Rik Reverb (Heroic Liberation of Undermine)
		{statisticID = 41305, dif = 15, encounterID = 3010}, -- Cauldron of Carnage (Heroic Liberation of Undermine)
		{statisticID = 41301, dif = 15, encounterID = 3009}, -- Vexie and the Geargrinders (Heroic Liberation of Undermine)
		-- Normal (14)
		{statisticID = 41328, dif = 14, encounterID = 3016}, -- Chrome King Gallywix (Normal Liberation of Undermine)
		{statisticID = 41324, dif = 14, encounterID = 3015}, -- Mug'Zee, Heads of Security (Normal Liberation of Undermine)
		{statisticID = 41320, dif = 14, encounterID = 3014}, -- The One-Armed Bandit (Normal Liberation of Undermine)
		{statisticID = 41316, dif = 14, encounterID = 3013}, -- Sprocketmonger Lockenstock (Normal Liberation of Undermine)
		{statisticID = 41312, dif = 14, encounterID = 3012}, -- Stix Bunkjunker (Normal Liberation of Undermine)
		{statisticID = 41308, dif = 14, encounterID = 3011}, -- Rik Reverb (Normal Liberation of Undermine)
		{statisticID = 41304, dif = 14, encounterID = 3010}, -- Cauldron of Carnage (Normal Liberation of Undermine)
		{statisticID = 41300, dif = 14, encounterID = 3009}, -- Vexie and the Geargrinders (Normal Liberation of Undermine)
		-- LFR (17)
		{statisticID = 41327, dif = 17, encounterID = 3016}, -- Chrome King Gallywix (Raid Finder Liberation of Undermine)
		{statisticID = 41323, dif = 17, encounterID = 3015}, -- Mug'Zee, Heads of Security (Raid Finder Liberation of Undermine)
		{statisticID = 41319, dif = 17, encounterID = 3014}, -- The One-Armed Bandit (Raid Finder Liberation of Undermine)
		{statisticID = 41315, dif = 17, encounterID = 3013}, -- Sprocketmonger Lockenstock (Raid Finder Liberation of Undermine)
		{statisticID = 41311, dif = 17, encounterID = 3012}, -- Stix Bunkjunker (Raid Finder Liberation of Undermine)
		{statisticID = 41307, dif = 17, encounterID = 3011}, -- Rik Reverb (Raid Finder Liberation of Undermine)
		{statisticID = 41303, dif = 17, encounterID = 3010}, -- Cauldron of Carnage (Raid Finder Liberation of Undermine)
		{statisticID = 41299, dif = 17, encounterID = 3009}, -- Vexie and the Geargrinders (NRaid Finder Liberation of Undermine)
	},
	setFunc = function(currencyDB, str) -- set it here so i dont miss it later that its actually caching something
		currencyDB[7] = str or ""
		ns.PrintDebug("Setting highest kill to: %s", str or "")
	end,
	getCurrent = function(currencyDB)
		return currencyDB[7]
	end,
}