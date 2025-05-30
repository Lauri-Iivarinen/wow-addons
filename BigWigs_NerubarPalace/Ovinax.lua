--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Broodtwister Ovi'nax", 2657, 2612)
if not mod then return end
mod:RegisterEnableMob(214506)
mod:SetEncounterID(2919)
mod:SetRespawnTime(30)
mod:SetStage(1)

-- IngestBlackBlood      ability.id=442432 and type="begincast"

-- StickyWeb             ability.id=446344 and type="cast" // (ability.id=446349 and type="applydebuff")
-- ExperimentalDosage    ability.id=442526 and type="begincast"  //  ability.id=440421 and type IN ("applydebuff", "removedebuff")
-- VolatileConcoction    ability.id=443003 and type="begincast"

-- CausticReaction       ability.id=450661 and type="cast"
-- PoisonBurst           ability.id=446700 and type="begincast"
-- Infest                ability.id=442257 and type="begincast"

--------------------------------------------------------------------------------
-- Locals
--

local experimentalDosageCount = 1
local ingestBlackBloodCount = 1
local unstableInfusionCount = 1
local stickyWebCount = 1
local volatileConcoctionCount = 1
local fixateOnMeList = {}
local mobCollector = {}
local startTime = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.sticky_web = "Webs"
	L.sticky_web_singular = "Sticky Web" -- since the callout is pural
	L.sticky_web_say = "Web"
	L.infest_cast = "Casting Infest on YOU!"
	L.infest_say = "Parasites"
	L.experimental_dosage = "Egg Breaks"
	L.experimental_dosage_say = "Egg Break"
	L.ingest_black_blood = "Next Container"
	L.unstable_infusion = "Swirls" -- is also the heal absorb on the boss
end

--------------------------------------------------------------------------------
-- Initialization
--

local voraciousWormMarker = mod:AddMarkerOption(false, "npc", 1, -28999, 1, 2, 3, 4) -- Voracious Worm
function mod:GetOptions()
	return {
		456690, -- Berserk
		{442526, "ME_ONLY_EMPHASIZE"}, -- Experimental Dosage
		442660, -- Experimental Dosage (was rupture/healing absorb)
		442432, -- Ingest Black Blood
			443274, -- Unstable Infusion
		442799, -- Sanguine Overflow (Damage)
			450661, -- Caustic Reaction
		{446349, "SAY", "ME_ONLY_EMPHASIZE"}, -- Sticky Web
			446351, -- Web Eruption
		{441362, "TANK_HEALER"}, -- Volatile Concoction
		-- Adds
		458212, -- Necrotic Wound
		446700, -- Poison Burst
		voraciousWormMarker,
		442250, -- Fixate
			{442257, "SAY"}, -- Infest
	},{
		[458212] = "adds",
	},{
		[442526] = L.experimental_dosage, -- Experimental Dosage (Egg Breaks)
		[442660] = CL.heal_absorb, -- Experimental Dosage (Heal Absorb)
		[442432] = L.ingest_black_blood, -- Ingest Black Blood (Next Container)
		[443274] = L.unstable_infusion, -- Unstable Infusion (Swirls)
		[446349] = {L.sticky_web, "sticky_web_singular"}, -- Sticky Web (Webs)
		[442257] = {nil, "infest_cast"}, -- Infest
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1") -- Ingest Black Blood adjustments
	self:Log("SPELL_AURA_APPLIED", "BerserkApplied", 456690)
	startTime = 0

	self:Log("SPELL_CAST_START", "ExperimentalDosage", 442526)
	self:Log("SPELL_AURA_APPLIED", "ExperimentalDosageApplied", 440421)
	self:Log("SPELL_AURA_REMOVED", "ExperimentalDosageRemoved", 440421)
	self:Log("SPELL_AURA_APPLIED", "RuptureApplied", 442660)
	self:Log("SPELL_CAST_SUCCESS", "IngestBlackBlood", 442432)
	self:Log("SPELL_AURA_APPLIED", "SanguineOverflowApplied", 442799)
	self:Log("SPELL_CAST_SUCCESS", "CausticReaction", 450661)
	self:Log("SPELL_AURA_APPLIED", "UnstableInfusionApplied", 443274)
	self:Log("SPELL_CAST_SUCCESS", "StickyWeb", 446344)
	self:Log("SPELL_AURA_APPLIED", "StickyWebApplied", 446349)
	self:Log("SPELL_AURA_APPLIED", "WebEruptionApplied", 446351)
	self:Log("SPELL_CAST_START", "VolatileConcoction", 443003)
	self:Log("SPELL_AURA_APPLIED", "VolatileConcoctionApplied", 441362)

	-- Adds
	self:Log("SPELL_AURA_APPLIED", "NecroticWoundApplied", 458212)
	self:Log("SPELL_AURA_APPLIED_DOSE", "NecroticWoundApplied", 458212)
	self:Log("SPELL_CAST_START", "PoisonBurst", 446700)
	self:Log("SPELL_AURA_APPLIED", "FixateApplied", 442250)
	self:Log("SPELL_AURA_REMOVED", "FixateRemoved", 442250)
	self:Log("SPELL_CAST_START", "Infest", 442257)
	self:Log("SPELL_AURA_APPLIED", "InfestApplied", 442257)
	self:Log("SPELL_AURA_REMOVED", "InfestRemoved", 442257)
end

function mod:OnEngage()
	self:SetStage(1)
	experimentalDosageCount = 1
	ingestBlackBloodCount = 1
	unstableInfusionCount = 1
	stickyWebCount = 1
	volatileConcoctionCount = 1
	fixateOnMeList = {}
	mobCollector = {}
	startTime = GetTime()

	self:Bar(441362, 2.1, CL.count:format(self:SpellName(441362), volatileConcoctionCount)) -- Volatile Concoction
	if not self:Easy() then
		self:Bar(446349, 14.9, CL.count:format(self:SpellName(446349), stickyWebCount)) -- Sticky Web
	end
	self:CDBar(442432, 15.7, CL.count:format(self:SpellName(442432), ingestBlackBloodCount)) -- Ingest Black Blood
	self:Bar(442526, 31.7, CL.count:format(self:SpellName(442526), experimentalDosageCount)) -- Experimental Dosage

	if self:GetOption(voraciousWormMarker) then
		self:RegisterTargetEvents("AddMarking")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:AddMarking(_, unit, guid)
	if self:MobId(guid) == 219046 and not mobCollector[guid] and self:GetOption(voraciousWormMarker) then
		mobCollector[guid] = true
		local index = self:MobSpawnIndex(guid)
		local icon = index
		self:CustomIcon(voraciousWormMarker, unit, icon)
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
	if spellId == 442430 then -- Ingest Black Blood (100 energy)
		local stage = self:GetStage()
		self:SetStage(stage + 1)

		-- re-adjusts the bar time to the cast cd after ingest and pauses the bar while the boss moves
		-- Experimental Dosage
		self:Bar(442526, {16.0, experimentalDosageCount == 1 and 31.7 or 66.7}, CL.count:format(self:SpellName(442526), experimentalDosageCount))
		self:PauseBar(442526, CL.count:format(self:SpellName(442526), experimentalDosageCount))
		-- Volatile Concoction
		self:Bar(441362, {18.0, volatileConcoctionCount == 2 and 31.6 or 26.6}, CL.count:format(self:SpellName(441362), volatileConcoctionCount))
		self:PauseBar(441362, CL.count:format(self:SpellName(441362), volatileConcoctionCount))
		-- Sticky Web
		if not self:Easy() then
			self:Bar(446349, {31.0, stickyWebCount == 2 and 31.8 or 46.7}, CL.count:format(self:SpellName(446349), stickyWebCount))
			self:PauseBar(446349, CL.count:format(self:SpellName(446349), stickyWebCount))
		end
	end
end

function mod:BerserkApplied(args)
	self:StopBar(args.spellName)
	self:Message(456690, "red", CL.custom_end:format(self.displayName, args.spellName))
	self:PlaySound(456690, "alarm")
end

function mod:ExperimentalDosage(args)
	self:StopBar(CL.count:format(args.spellName, experimentalDosageCount))
	self:Message(args.spellId, "orange", CL.casting:format(CL.count:format(args.spellName, experimentalDosageCount)))
	self:PlaySound(args.spellId, "alert")
	local debuffDuration = self:Easy() and 10 or 8
	self:Bar(args.spellId, 1.5 + debuffDuration, CL.count:format(CL.adds, experimentalDosageCount))
	experimentalDosageCount = experimentalDosageCount + 1

	if experimentalDosageCount < 10 then
		-- 16, 50, 50 // 16, 50, 50 // 16, 50, 50
		local cd = (experimentalDosageCount - 1) % 3 == 0 and 66.7 or 50.0
		self:Bar(args.spellId, cd, CL.count:format(args.spellName, experimentalDosageCount))
	end
end

function mod:ExperimentalDosageApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(442526)
		self:PlaySound(442526, "warning")
		-- self:Say(442526)
		-- self:SayCountdown(442526, self:Easy() and 10 or 8)
	end
end

function mod:ExperimentalDosageRemoved(args)
	-- if self:Me(args.destGUID) then
	-- 	self:CancelSayCountdown(442526)
	-- end
end

function mod:RuptureApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:IngestBlackBlood(args)
	self:StopBar(CL.count:format(args.spellName, ingestBlackBloodCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, ingestBlackBloodCount))
	self:PlaySound(args.spellId, "long")
	ingestBlackBloodCount = ingestBlackBloodCount + 1
	if ingestBlackBloodCount < 4 then
		self:CDBar(args.spellId, 165, CL.count:format(args.spellName, ingestBlackBloodCount)) -- ~time to USCS 442430
	elseif ingestBlackBloodCount == 5 then
		if startTime > 0 then
			local remaining = 600.5 - (GetTime() - startTime)
			self:Bar(456690, remaining) -- Berserk
		end
	end

	self:ResumeBar(442526, CL.count:format(self:SpellName(442526), experimentalDosageCount)) -- Experimental Dosage
	self:ResumeBar(441362, CL.count:format(self:SpellName(441362), volatileConcoctionCount)) -- Volatile Concoction
	if not self:Easy() then
		self:ResumeBar(446349, CL.count:format(self:SpellName(446349), stickyWebCount)) -- Sticky Web
	end
end

function mod:SanguineOverflowApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:CausticReaction(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- fail
end

do
	local prev = 0
	function mod:UnstableInfusionApplied(args)
		if args.time - prev > 2 then
			prev = args.time
			self:StopBar(CL.count:format(L.unstable_infusion, unstableInfusionCount))
			unstableInfusionCount = unstableInfusionCount + 1
			self:Bar(args.spellId, 7.5, CL.count:format(L.unstable_infusion, unstableInfusionCount))
		end
	end
end

function mod:StickyWeb(args)
	local spellName = self:SpellName(446349)
	self:StopBar(CL.count:format(spellName, stickyWebCount))
	self:Message(446349, "yellow", CL.count:format(spellName, stickyWebCount))
	stickyWebCount = stickyWebCount + 1
	-- 14.9 // 31, 30, 30, 30, 30 // 31, 30, 30, 30, 30 // 31, 30, 30, 30, 30, 30, 30, ...
	local cd = stickyWebCount > 13 and 30.0 or stickyWebCount == 2 and 31.8 or (stickyWebCount - 2) % 5 == 0 and 46.7 or 30.0
	self:Bar(446349, cd, CL.count:format(spellName, stickyWebCount))
end

do
	local prevOnMe = 0
	function mod:StickyWebApplied(args)
		if self:Me(args.destGUID)  then
			prevOnMe = args.time
			self:PersonalMessage(args.spellId, nil, L.sticky_web_singular)
			self:PlaySound(args.spellId, "warning")
			self:Say(args.spellId, L.sticky_web_say, nil, "Web")
		end
	end

	function mod:WebEruptionApplied(args)
		if self:Me(args.destGUID) and args.time - prevOnMe > 10 then -- You didn't have Sticky Web
			self:PersonalMessage(args.spellId)
			self:PlaySound(args.spellId, "alarm") -- fail
		end
	end
end

function mod:VolatileConcoction(args)
	local spellName = self:SpellName(441362)
	self:StopBar(CL.count:format(spellName, volatileConcoctionCount))
	volatileConcoctionCount = volatileConcoctionCount + 1
	-- 2.1 // 18, 20, 20, 20, 20, 20, 20, 20 // 18, 20, 20, 20, 20, 20, 20, 20 // 18, 20, 20, 20, 20, 20, ...
	local cd = volatileConcoctionCount > 19 and 20.0 or volatileConcoctionCount == 2 and 31.6 or (volatileConcoctionCount - 2) % 8 == 0 and 26.6 or 20.0
	self:Bar(441362, cd, CL.count:format(spellName, volatileConcoctionCount))
end

function mod:VolatileConcoctionApplied(args)
	self:TargetMessage(args.spellId, "purple", args.destName, CL.count:format(args.spellName, volatileConcoctionCount - 1))
	self:TargetBar(args.spellId, 8, args.destName)
	local bossUnit = self:UnitTokenFromGUID(args.sourceGUID)
	if bossUnit and self:Tank() and not self:Me(args.destGUID) and not self:Tanking(bossUnit) then
		self:PlaySound(args.spellId, "warning") -- Taunt
	elseif self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "alarm") -- On you
	end
end

function mod:VolatileConcoctionRemoved(args)
	self:StopBar(args.spellId, args.destName)
end

function mod:NecroticWoundApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 2 == 1 then
			self:StackMessage(args.spellId, "blue", args.destName, amount, 3)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

function mod:PoisonBurst(args)
	local canDo, ready = self:Interrupter(args.sourceGUID)
	if canDo and ready then
		self:Message(args.spellId, "yellow")
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:FixateApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, CL.fixate)
		self:PlaySound(args.spellId, "alarm")
		fixateOnMeList[args.sourceGUID] = true
	end
end

function mod:FixateRemoved(args)
	if self:Me(args.destGUID) then
		fixateOnMeList[args.sourceGUID] = nil
	end
end

function mod:Infest(args)
	if fixateOnMeList[args.sourceGUID] then
		self:Message(args.spellId, "red", L.infest_cast)
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:InfestApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
		-- self:TargetBar(args.spellId, 10, args.destName)
	end
end

function mod:InfestRemoved(args)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, L.infest_say, true, "Parasites")
		-- self:StopBar(args.spellId, args.destName)
	end
end
