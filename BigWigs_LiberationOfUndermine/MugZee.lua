
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Mug'Zee, Heads of Security", 2769, 2645)
if not mod then return end
mod:RegisterEnableMob(229953)
mod:SetEncounterID(3015)
mod:SetPrivateAuraSounds({
	472354, -- Fixate (Unstable Crawler Mines)
})
mod:SetRespawnTime(30)
mod:SetStage(1)

--[[

Phases                        (ability.id IN (468728, 468794) and type="cast") or (ability.id=463967 and type="begincast") or (ability.id=1216142 and type="begincast")
Mug/Zee Taking Charge         ability.id IN (468728, 468794) and type="cast"
Bloodlust                     ability.id=463967 and type="begincast"
DoubleMindedFury              ability.id=1216142 and type="begincast"

EarthshakerGaol               ability.id=472631 and type="applydebuff"
FrostshatterBoots             ability.id=466476 and type="applydebuff"
StormfuryFingerGun            ability.id=466509 and type="begincast"
MoltenGoldKunckles            ability.id=466518 and type="begincast"

UnstableCrawlerMines          ability.id=472458 and type="cast"
    ExperimentalPlating           ability.id IN (1219283,1225928) and type="applybuff"
GoblinGuidedRocket            ability.id=467380 and type="applydebuff"
SprayAndPray                  ability.id=466545 and type="begincast"
DoubleWhammyShot              ability.id=1223085 and type="begincast"
ElectroShockerSpawn           ability.id=1215591 and type="applybuff"
    ElectroChargedShield           ability.id=1222948 and type="removebuff"

ElectrocutionMatrix           ability.id=1217791 and type="begincast"
StaticCharge                  ability.id=1215953 and type="begincast"

--]]

--------------------------------------------------------------------------------
-- Locals
--

local earthershakerGaolCount = 1
local frostshatterBootsCount = 1
local fingerGunCount = 1
local moltenGoldKnucklesCount = 1

local unstableCrawlerMinesCount = 1
local mineEnrageWarned = false
local goblinGuidedRocketsCount = 1
local sprayAndPrayCount = 1
local doubleWhammyShotCount = 1

local numMines = 0
local numElectroShockers = 0

local staticChargeCount = 1

local mobCollector, mobMarks = {}, {}
local mineFixates = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.earthshaker_gaol = "Gaols"
	L.frostshatter_boots = "Frost Boots"
	L.frostshatter_spear = "Frost Spears"
	L.stormfury_finger_gun = "Finger Gun"
	L.molten_gold_knuckles = "Tank Knockback"
	L.unstable_crawler_mines = "Crawler Mines"
	L.goblin_guided_rocket = "Group Soak"
	L.double_whammy_shot = "Tank Soak"
	L.experimental_plating = "Mines Enrage"

	L.experimental_plating_message = "Mines are Enraging!"
	L.earthshaker_gaol_say = "Gaol"
	L.goblin_guided_rocket_say = "Soak"
	L.double_whammy_shot_say = "Tank Soak"

	L.electro_shocker = "Shocker"
	L.electro_shocker_bar = "Shocker Add"

	L.fixate_nameplate = ">" .. CL.fixate .. "<"
end

--------------------------------------------------------------------------------
-- Initialization
--

local electroShockerMarker = mod:AddMarkerOption(false, "npc", 8, -31766, 8, 7)
local unstableCrawlerMinesMarker = mod:AddMarkerOption(false, "npc", 1, 466539, 1, 2, 3, 4)
function mod:GetOptions()
	return {
		electroShockerMarker,
		unstableCrawlerMinesMarker,

		"stages",
		466385, -- Moxie
		1216142, -- Double-Minded Fury

		-- Mug
		{472631, "SAY", "SAY_COUNTDOWN", "CASTBAR"}, -- Earthshaker Gaol
			1214623, -- Enraged
			472782, -- Pay Respects
			470910, -- Gaol Break
		466476, -- Frostshatter Boots
			466480, -- Frostshatter Spear
		466509, -- Stormfury Finger Gun
		466518, -- Molten Gold Knuckles
			467202, -- Golden Drip

		-- Zee
		{466539, "NAMEPLATE"}, -- Unstable Crawler Mines
			-- 472354, Fixate
			469043, -- Searing Shrapnel
			1225928, -- Experimental Plating
		{467380, "SAY", "SAY_COUNTDOWN"}, -- Goblin-guided Rocket
		466545, -- Spray and Pray
		-31766, -- Mk II Electro Shocker
			{1215591, "OFF"}, -- Faulty Wiring
			1222948, -- Electro-Charged Shield (Mythic)
		{469491, "CASTBAR"}, -- Double Whammy Shot
			469391, -- Perforating Wound

		-- Intermission (40%)
		{1215953, "CASTBAR"}, -- Static Charge
		{471574, "CASTBAR"}, -- Bulletstorm
		-- 1216495, -- Electrocution Matrix (Mythic)

		-- Mug'Zee
		463967, -- Bloodlust
	},{
		[472631] = -31677, -- Mug
		[466539] = -31693, -- Zee
		[1215953] = -30517, -- Intermission
		[463967] = -30510, -- Stage 2
	},{
		[1216142] = CL.full_energy, -- Double-Minded Fury
		-- [472631] = L.earthshaker_gaol,
		[466476] = L.frostshatter_boots,
		[466480] = L.frostshatter_spear,
		[466509] = L.stormfury_finger_gun,
		[466518] = L.molten_gold_knuckles,
		[466539] = {L.unstable_crawler_mines, "fixate_nameplate"},
		[1225928] = {L.experimental_plating, "experimental_plating_message"},
		[467380] = L.goblin_guided_rocket,
		[1215591] = CL.weakened, -- Faulty Wiring
		[1222948] = CL.shield, -- Electro-Charged Shield
		[469491] = L.double_whammy_shot,
		[-31766] = {nil, "electro_shocker_bar"}, -- Mk II Electro Shocker
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1") -- Double Whammy Shot
	-- self:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")

	self:Log("SPELL_AURA_APPLIED_DOSE", "MoxieApplied", 466385)
	self:Log("SPELL_CAST_START", "DoubleMindedFury", 1216142)
	-- Mug
	self:Log("SPELL_CAST_SUCCESS", "MugTakingCharge", 468728)
	self:Log("SPELL_AURA_APPLIED", "EarthshakerGaolApplied", 472631)
	self:Log("SPELL_AURA_APPLIED", "EnragedApplied", 1214623)
	self:Log("SPELL_CAST_START", "PayRespects", 472782)
	self:Log("SPELL_CAST_START", "GaolBreak", 470910)
	self:Log("SPELL_AURA_APPLIED", "FrostshatterBootsApplied", 466476)
	self:Log("SPELL_CAST_START", "StormfuryFingerGun", 466509)
	self:Log("SPELL_CAST_START", "MoltenGoldKunckles", 466518)
	self:Log("SPELL_AURA_APPLIED", "GoldenDripApplied", 467202)
	self:Log("SPELL_AURA_REMOVED", "GoldenDripRemoved", 467202)
	-- Zee
	self:Log("SPELL_CAST_SUCCESS", "ZeeTakingCharge", 468794)
	self:Log("SPELL_AURA_APPLIED", "ElectroShockerSpawn", 1215591) -- Faulty Wiring (initial buff)
	self:Log("SPELL_CAST_SUCCESS", "FaultyWiringApplied", 1215595)
	self:Log("SPELL_AURA_REMOVED", "ElectroChargedShieldRemoved", 1222948)
	self:Log("SPELL_CAST_SUCCESS", "UnstableCrawlerMines", 472458)
	self:Log("SPELL_AURA_APPLIED", "SearingShrapnelApplied", 469043)
	self:Log("SPELL_AURA_APPLIED", "GoblinGuidedRocketApplied", 467380)
	self:Log("SPELL_AURA_REMOVED", "GoblinGuidedRocketRemoved", 467380)
	self:Log("SPELL_CAST_START", "SprayAndPray", 466545)
	-- self:Log("SPELL_CAST_START", "DoubleWhammyShot", 469490) -- USCS
	self:Log("SPELL_AURA_APPLIED", "PerforatingWoundApplied", 469391)
	self:Log("SPELL_AURA_REMOVED", "PerforatingWoundRemoved", 469391)
	self:Death("ElectroShockerDeath", 230316)
	self:Log("SPELL_CAST_SUCCESS", "UnstableCrawlerMinesSpawn", 1219283) -- Experimental Plating
	self:Log("SPELL_CAST_SUCCESS", "ExperimentalPlatingImmune", 1225928)
	self:Death("UnstableCrawlerMineDeath", 231788)
	-- Intermission
	self:Log("SPELL_CAST_START", "ElectrocutionMatrix", 1217791)
	self:Log("SPELL_CAST_START", "StaticCharge", 1215953)
	self:Log("SPELL_CAST_SUCCESS", "Bulletstorm", 471574)
	-- Stage 2
	self:Log("SPELL_CAST_START", "Bloodlust", 463967)
	self:Log("SPELL_CAST_SUCCESS", "BloodlustSuccess", 463967)
end

function mod:OnEngage()
	self:SetStage(1)

	earthershakerGaolCount = 1
	frostshatterBootsCount = 1
	fingerGunCount = 1
	moltenGoldKnucklesCount = 1

	unstableCrawlerMinesCount = 1
	goblinGuidedRocketsCount = 1
	doubleWhammyShotCount = 1
	sprayAndPrayCount = 1

	numMines = 0

	staticChargeCount = 1

	mobCollector = {}
	mobMarks = {}
	mineFixates = {}

	-- MugTakingCharge/ZeeTakingCharge start the phase

	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	if not self:Mythic() then -- Mythic uses Electrocution Matrix
		self:RegisterUnitEvent("UNIT_POWER_UPDATE", nil, "boss1")
	end
	if self:GetOption(electroShockerMarker) then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end
	if self:GetOption(unstableCrawlerMinesMarker) or self:CheckOption(466539, "NAMEPLATE") then
		self:RegisterTargetEvents("AddMarking")
	end
end

function mod:OnBossDisable()
	numElectroShockers = 0 -- Electro Shockers spawn before engage fires if you start on Zee
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 8 do
		local unit = ("boss%d"):format(i)
		local guid = self:UnitGUID(unit)
		if guid then
			local mobId = self:MobId(guid)
			if mobId == 230316 and not mobCollector[guid] then -- Mk II Electro Shocker
				mobCollector[guid] = true
				local icon = mobMarks[mobId] or 8
				self:CustomIcon(electroShockerMarker, unit, icon)
				mobMarks[mobId] = icon - 1
			end
		end
	end
end

function mod:AddMarking(_, unit, guid)
	if self:MobId(guid) == 231788 then -- Unstable Crawler Mine
		if mobCollector[guid] and self:GetOption(unstableCrawlerMinesMarker) then
			self:CustomIcon(unstableCrawlerMinesMarker, unit, mobCollector[guid])
		end
		if not mineFixates[guid] and self:Me(self:UnitGUID(unit .. "target")) then
			-- XXX handle refixate?
			self:Nameplate(466539, 0, guid, L.fixate_nameplate)
			mineFixates[guid] = true
		end
	end
end

function mod:UnstableCrawlerMinesSpawn(args)
	numMines = numMines + 1
	self:Debug("Mines", numMines)
	if numMines == 1 then
		self:Bar(1225928, 63, L.experimental_plating)
	end

	local icon = mobMarks[231788] or 1
	mobCollector[args.sourceGUID] = icon
	mobMarks[231788] = icon + 1
end

function mod:ExperimentalPlatingImmune(args)
	if not mineEnrageWarned then
		self:Message(1225928, "red", L.experimental_plating_message)
		self:PlaySound(1225928, "alarm")
		mineEnrageWarned = true
		self:StopBar(L.experimental_plating)
	end
end

function mod:UnstableCrawlerMineDeath(args)
	if mineFixates[args.destGUID] then
		self:StopNameplate(466539, args.destGUID, L.fixate_nameplate)
		mineFixates[args.destGUID] = nil
	end

	numMines = math.max(numMines - 1, 0)
	self:Debug("Mines", numMines)
	if numMines == 0 then
		self:StopBar(L.experimental_plating)
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:GetHealth(unit) < 43 then -- Intermission at 40%
		self:UnregisterUnitEvent(event, unit)
		self:Message("stages", "cyan", CL.soon:format(CL.intermission), false)
		self:PlaySound("stages", "info")
	end
end

function mod:UNIT_POWER_UPDATE(event, unit)
	-- XXX no other events for this?
	-- another option is use Head Honcho:Mug/Zug buffs and transition if there is no new gain
	local power = UnitPower(unit)
	if power == 0 and self:GetHealth(unit) < 40 then
		self:UnregisterUnitEvent(event, unit)
		self:IntermissionStart()
	end
end

function mod:MoxieApplied(args)
	-- XXX probably not terribly useful info to show since you'll probably be going off of double-minded fury
	if args.amount >= 15 and args.amount % 5 == 0 then
		self:Message(args.spellId, "red", CL.count:format(args.spellName, args.amount))
	end
end

function mod:DoubleMindedFury(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- fail
end

-- Mug

function mod:MugTakingCharge(args)
	self:StopBar(1216142) -- Double-Minded Fury
	self:StopBar(CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount)) -- Unstable Crawler Mines
	self:StopBar(CL.count:format(self:SpellName(467380), goblinGuidedRocketsCount)) -- Goblin-guided Rockets
	self:StopBar(CL.count:format(self:SpellName(466545), sprayAndPrayCount)) -- Spray and Pray
	self:StopBar(CL.count:format(self:SpellName(469491), doubleWhammyShotCount)) -- Double Whammy Shot

	self:SetStage(1)
	self:Message("stages", "cyan", self:SpellName(468728), false) -- 468728 = Mug Taking Charge
	self:PlaySound("stages", "long")

	self:Bar(472631, 13.9, CL.count:format(self:SpellName(472631), earthershakerGaolCount)) -- Earthshaker Gaol
	self:Bar(466518, self:Easy() and 33.4 or self:Heroic() and 30.6 or 27.8, CL.count:format(self:SpellName(466518), moltenGoldKnucklesCount)) -- Molten Gold Knuckles
	self:Bar(466476, self:Easy() and 48.7 or self:Heroic() and 44.8 or 36.7, CL.count:format(self:SpellName(466476), frostshatterBootsCount)) -- Frostshatter Boots
	self:Bar(466509, self:Easy() and 60.0 or self:Heroic() and 55.0 or 50.0, CL.count:format(self:SpellName(466509), fingerGunCount)) -- Stormfury Finger Gun
	self:Bar(1216142, self:Easy() and 76.4 or self:Heroic() and 69.4 or 61.7) -- Double-Minded Fury
end

do
	local playerList = {}
	local prev = 0
	local gaolOnMe = false

	function mod:EarthshakerGaolApplied(args)
		if args.time - prev > 3 then
			prev = args.time
			playerList = {}
			gaolOnMe = false

			self:StopBar(CL.count:format(args.spellName, earthershakerGaolCount))
			self:CastBar(args.spellId, 6, CL.count:format(L.earthshaker_gaol, earthershakerGaolCount))
			earthershakerGaolCount = earthershakerGaolCount + 1
		end
		playerList[#playerList + 1] = args.destName
		if self:Me(args.destGUID) then
			gaolOnMe = true
			-- self:Say(args.spellId, L.earthshaker_gaol_say, nil, "Gaol")
			-- self:SayCountdown(args.spellId, 6)
		end
		local count = 2
		if self:Mythic() then
			count = self:GetStage() == 3 and 4 or math.min(earthershakerGaolCount, 4) -- surely it caps, right?
		end
		self:TargetsMessage(args.spellId, "orange", playerList, count, CL.count:format(args.spellName, earthershakerGaolCount - 1))
		if #playerList == count then
			if gaolOnMe then
				self:PlaySound(args.spellId, "warning") -- stack
			elseif not self:CheckOption(args.spellId, "ME_ONLY") then
				self:PlaySound(args.spellId, "alert") -- stack
			end
		end
	end

	function mod:EarthshakerGaolRemoved(args)
		if self:Me(args.destGUID) then
			gaolOnMe = false
		end
	end
end

function mod:EnragedApplied(args)
	-- no throttle, multiple messages is probably fine
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- fail
end

function mod:PayRespects(args)
	-- only show for your goon
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 10) then
		local canDo, ready = self:Interrupter(args.sourceGUID)
		if canDo and ready then
			self:Message(args.spellId, "yellow")
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:GaolBreak(args)
	-- only show for your goon
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 10) then
		self:Message(args.spellId, "orange")
		self:PlaySound(args.spellId, "alarm")
	end
end

do
	local prev = 0
	function mod:FrostshatterBootsApplied(args)
		if args.time - prev > 3 then
			prev = args.time
			self:StopBar(CL.count:format(args.spellName, frostshatterBootsCount))
			self:Message(args.spellId, "red", CL.count:format(args.spellName, frostshatterBootsCount))
			if not self:Easy() then
				self:Bar(466480, 8) -- Frostshatter Spear
			end
			frostshatterBootsCount = frostshatterBootsCount + 1
			if self:GetStage() == 3 and frostshatterBootsCount < 3 then
				self:Bar(args.spellId, self:Mythic() and 85.8 or 86.2, CL.count:format(args.spellName, frostshatterBootsCount))
			end
		end
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId)
			self:PlaySound(args.spellId, "warning")
		end
	end
end

do
	local function printTarget(self, player, guid)
		self:TargetMessage(466509, "orange", player, CL.count:format(self:SpellName(466509), fingerGunCount - 1))
		if self:Me(guid) then
			self:PlaySound(466509, "warning")
		else
			self:PlaySound(466509, "alert", nil, player) -- frontal
		end
	end
	function mod:StormfuryFingerGun(args)
		self:StopBar(CL.count:format(args.spellName, fingerGunCount))
		fingerGunCount = fingerGunCount + 1
		self:GetBossTarget(printTarget, 1, args.sourceGUID)
	end
end

function mod:MoltenGoldKunckles(args)
	self:StopBar(CL.count:format(args.spellName, moltenGoldKnucklesCount))
	self:Message(args.spellId, "purple", CL.count:format(args.spellName, moltenGoldKnucklesCount))
	self:PlaySound(args.spellId, "alert") -- frontal
	moltenGoldKnucklesCount = moltenGoldKnucklesCount + 1
end

function mod:GoldenDripApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	elseif self:Tank() and self:Tank(args.destName) then
		self:TargetMessage(args.spellId, "purple", args.destName)
		self:PlaySound(args.spellId, "warning") -- tauntswap
	end
end

function mod:GoldenDripRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "green", CL.removed:format(args.spellName))
		self:PlaySound(args.spellId, "info")
	end
end

-- Zee

function mod:ZeeTakingCharge(args)
	self:StopBar(1216142) -- Double-Minded Fury
	self:StopBar(CL.count:format(self:SpellName(472631), earthershakerGaolCount)) -- Earthshaker Gaol
	self:StopBar(CL.count:format(self:SpellName(466518), moltenGoldKnucklesCount)) -- Molten Gold Knuckles
	self:StopBar(CL.count:format(self:SpellName(466476), frostshatterBootsCount)) -- Frostshatter Boots
	self:StopBar(CL.count:format(self:SpellName(466509), fingerGunCount)) -- Stormfury Finger Gun

	self:SetStage(2)
	self:Message("stages", "cyan", self:SpellName(468794), false) -- 468728 = Zee Taking Charge
	self:PlaySound("stages", "long")

	mobMarks = {}

	self:Bar(466539, 15.3, CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount)) -- Unstable Crawler Mines
	self:Bar(467380, self:Easy() and 35.4 or self:Heroic() and 32.6 or 29.8, CL.count:format(self:SpellName(467380), goblinGuidedRocketsCount)) -- Goblin-guided Rockets
	self:Bar(469491, self:Easy() and 46.7 or self:Heroic() and 42.8 or 38.9, CL.count:format(self:SpellName(469491), doubleWhammyShotCount)) -- Double Whammy Shot (-3.5s from SCS)
	self:Bar(466545, self:Easy() and 60.0 or self:Heroic() and 55.0 or 50.0, CL.count:format(self:SpellName(466545), sprayAndPrayCount)) -- Spray and Pray
	self:Bar(1216142, self:Easy() and 76.4 or self:Heroic() and 69.4 or 61.7) -- Double-Minded Fury
end

function mod:ElectroShockerSpawn(args)
	numElectroShockers = numElectroShockers + 1
	if self:GetStage() == 3 then
		self:StopBar(L.electro_shocker_bar)
		self:Message(-31766, "cyan", CL.spawned:format(L.electro_shocker), false)
		self:PlaySound(-31766, "info")
	end
end

function mod:FaultyWiringApplied(args)
	local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags)) or ""
	self:Message(1215591, "green", self:SpellName(1215591) .. icon)
	self:PlaySound(1215591, "info")
end

do
	local removed = 0
	local prev = 0
	local scheduled = nil

	function mod:ElectroChargedShieldRemovedMessage()
		self:Message(1222948, "green", CL.count_amount:format(CL.removed:format(self:SpellName(1222948)), removed, numElectroShockers))
		self:PlaySound(1222948, "info")
	end

	function mod:ElectroChargedShieldRemoved(args)
		if args.time - prev > 4 then
			prev = args.time
			removed = 0
		end
		removed = removed + 1
		if not scheduled then
			scheduled = self:ScheduleTimer("ElectroChargedShieldRemovedMessage", 0.3)
		end
	end
end

function mod:ElectroShockerDeath(args)
	numElectroShockers = math.max(numElectroShockers - 1, 0)
	self:Message(-31766, "green", CL.mob_remaining:format(L.electro_shocker, numElectroShockers), false)
	self:PlaySound(-31766, "info")
end

function mod:UnstableCrawlerMines(args)
	self:StopBar(CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount))
	self:Message(466539, "yellow", CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount))
	unstableCrawlerMinesCount = unstableCrawlerMinesCount + 1
	if self:GetStage() == 3 and unstableCrawlerMinesCount < 3 then
		self:Bar(466539, 88.7, CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount))
	end
	mobMarks[231788] = nil

	mineEnrageWarned = false
	numMines = 0
	self:Debug("Mines", numMines)
end

function mod:SearingShrapnelApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:GoblinGuidedRocketApplied(args)
	self:StopBar(CL.count:format(args.spellName, goblinGuidedRocketsCount))
	self:TargetMessage(args.spellId, "orange", args.destName, CL.count:format(args.spellName, goblinGuidedRocketsCount))
	self:TargetBar(args.spellId, 8, args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "warning")
		-- self:Yell(args.spellId, L.goblin_guided_rocket_say, nil, "Soak")
		-- self:YellCountdown(args.spellId, 8, L.goblin_guided_rocket_say, nil, "Soak")
	else
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
	goblinGuidedRocketsCount = goblinGuidedRocketsCount + 1
end

function mod:GoblinGuidedRocketRemoved(args)
	self:StopBar(args.spellId, args.destName)
end

do
	local function printTarget(self, player, guid)
		self:TargetMessage(466545, "orange", player, CL.count:format(self:SpellName(466545), sprayAndPrayCount - 1))
		if self:Me(guid) then
			self:PlaySound(466545, "warning")
		else
			self:PlaySound(466545, "alert", nil, player) -- frontal
		end
	end
	function mod:SprayAndPray(args)
		self:StopBar(CL.count:format(args.spellName, sprayAndPrayCount))
		sprayAndPrayCount = sprayAndPrayCount + 1
		self:GetBossTarget(printTarget, 1, args.sourceGUID)
	end
end

do
	local woundOnMe = false

	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
		if spellId == 469490 then -- Double Whammy Shot (debuff applied)
			self:DoubleWhammyShot()
		end
	end

	-- function mod:CHAT_MSG_RAID_BOSS_WHISPER(_, msg)
	-- 	-- |TInterface\\\\ICONS\\\\Ability_Hunter_BurstingShot.blp:20|t Zee targets you with |cFFFF0000|Hspell:469490|h[Double Whammy Shot]
	-- 	if msg:find("spell:469490", nil, true) then
	-- 		self:Yell(469491, L.double_whammy_shot_say, nil, "Tank Soak")
	-- 		self:YellCountdown(469491, 6)
	-- 	end
	-- end

	function mod:DoubleWhammyShot()
		self:StopBar(CL.count:format(self:SpellName(469491), doubleWhammyShotCount))
		self:Message(469491, "purple", CL.count:format(self:SpellName(469491), doubleWhammyShotCount))
		self:CastBar(469491, 6)
		if self:Tank() and not woundOnMe then
			self:PlaySound(469491, "warning") -- soak
		end
		doubleWhammyShotCount = doubleWhammyShotCount + 1
	end

	function mod:PerforatingWoundApplied(args)
		if self:Me(args.destGUID) then
			woundOnMe = true
			self:PersonalMessage(args.spellId)
			self:PlaySound(args.spellId, "alarm")
		end
	end

	function mod:PerforatingWoundRemoved(args)
		if self:Me(args.destGUID) then
			woundOnMe = false
		end
	end
end

-- Intermission

function mod:ElectrocutionMatrix()
	self:IntermissionStart()
end

function mod:IntermissionStart(skipBars)
	self:UnregisterUnitEvent("UNIT_HEALTH", "boss1")
	self:UnregisterUnitEvent("UNIT_POWER_UPDATE", "boss1")
	self:StopBar(1216142) -- Double-Minded Fury
	self:StopBar(CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount)) -- Unstable Crawler Mines
	self:StopBar(CL.count:format(self:SpellName(467380), goblinGuidedRocketsCount)) -- Goblin-guided Rockets
	self:StopBar(CL.count:format(self:SpellName(466545), sprayAndPrayCount)) -- Spray and Pray
	self:StopBar(CL.count:format(self:SpellName(469491), doubleWhammyShotCount)) -- Double Whammy Shot
	self:StopBar(CL.count:format(self:SpellName(472631), earthershakerGaolCount)) -- Earthshaker Gaol
	self:StopBar(CL.count:format(self:SpellName(466518), moltenGoldKnucklesCount)) -- Molten Gold Knuckles
	self:StopBar(CL.count:format(self:SpellName(466476), frostshatterBootsCount)) -- Frostshatter Boots
	self:StopBar(CL.count:format(self:SpellName(466509), fingerGunCount)) -- Stormfury Finger Gun

	self:SetStage(2.5)
	self:Message("stages", "cyan", CL.intermission, false)

	if not skipBars then
		self:PlaySound("stages", "long")
		-- "<306.90 00:18:39> [UNIT_POWER_UPDATE] boss1#Mug'Zee#TYPE:ENERGY/3#MAIN:0/100#ALT:0/0",
		-- "<316.90 00:18:49> [CLEU] SPELL_CAST_START#Creature-0-5770-2769-13207-229953-00000D94EE#Mug'Zee(37.6%-0.0%)##nil#1215953#Static Charge#nil#nil#nil#nil#nil#nil",
		-- "<364.88 00:19:37> [CLEU] SPELL_CAST_START#Creature-0-5770-2769-13207-229953-00000D94EE#Mug'Zee(26.7%-0.0%)##nil#463967#Bloodlust#nil#nil#nil#nil#nil#nil",
		self:Bar(1215953, 10.0, CL.count:format(self:SpellName(1215953), staticChargeCount)) -- Static Charge
		self:Bar("stages", 52.3, CL.stage:format(2), "inv_111_raid_achievement_mugzeeheadsofsecurity")
		self:Bar(466539, (self:Mythic() and 5.3 or 4.9) + 52.3, CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount)) -- Unstable Crawler Mines
	end
end

function mod:StaticCharge(args)
	if self:GetStage() < 2.5 then -- just in case
		self:IntermissionStart(true)
		self:Bar("stages", 42.9, CL.stage:format(2), "inv_111_raid_achievement_mugzeeheadsofsecurity")
		self:Bar(466539, (self:Mythic() and 5.3 or 4.9) + 42.9, CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount)) -- Unstable Crawler Mines
	end
	self:StopBar(CL.count:format(args.spellName, staticChargeCount))
	self:Message(args.spellId, "orange", CL.count_amount:format(args.spellName, staticChargeCount, 3))
	self:CastBar(args.spellId, 3, CL.count:format(args.spellName, staticChargeCount))
	self:PlaySound(args.spellId, "alarm") -- avoid
	staticChargeCount = staticChargeCount + 1
	if staticChargeCount < 4 then
		self:Bar(args.spellId, 14.0, CL.count:format(args.spellName, staticChargeCount))
	end
end

function mod:Bulletstorm(args)
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "alert") -- cones
	self:CastBar(args.spellId, 8)
end

-- Stage 2

function mod:Bloodlust()
	self:StopCastBar(471574) -- Bulletstorm
	self:StopBar(CL.count:format(self:SpellName(1215953), staticChargeCount)) -- Static Charge
	self:StopBar(CL.stage:format(2))

	self:SetStage(3)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "long")

	earthershakerGaolCount = 1
	frostshatterBootsCount = 1
	fingerGunCount = 1
	moltenGoldKnucklesCount = 1

	unstableCrawlerMinesCount = 1
	goblinGuidedRocketsCount = 1
	doubleWhammyShotCount = 1
	sprayAndPrayCount = 1

	mobMarks = {}

	-- self:Bar(466539, self:Mythic() and 5.3 or 4.9, CL.count:format(self:SpellName(466539), unstableCrawlerMinesCount)) -- Unstable Crawler Mines
	self:Bar(466476, self:Mythic() and 18.3 or 17.8, CL.count:format(self:SpellName(466476), frostshatterBootsCount)) -- Frostshatter Boots
	self:Bar(472631, 28.7, CL.count:format(self:SpellName(472631), earthershakerGaolCount)) -- Earthshaker Gaol
	self:Bar(467380, self:Mythic() and 40.8 or 40.3, CL.count:format(self:SpellName(467380), goblinGuidedRocketsCount)) -- Goblin-guided Rockets
	self:Bar(-31766, 47.5, L.electro_shocker_bar, "inv_misc_enggizmos_02") -- Mk II Electro Shocker
	self:Bar(466518, 50.0, CL.count:format(self:SpellName(466518), moltenGoldKnucklesCount)) -- Molten Gold Knuckles
	self:Bar(466509, 62.5, CL.count:format(self:SpellName(466509), fingerGunCount)) -- Stormfury Finger Gun
	self:Bar(469491, self:Mythic() and 71.3 or 71.8, CL.count:format(self:SpellName(469491), doubleWhammyShotCount)) -- Double Whammy Shot (-3.5s from SCS)
	self:Bar(466545, 81.2, CL.count:format(self:SpellName(466545), sprayAndPrayCount)) -- Spray and Pray
	self:Bar(1216142, 118.1) -- Double-Minded Fury
end

function mod:BloodlustSuccess(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm")
end
