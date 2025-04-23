--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Queen Ansurek", 2657, 2602)
if not mod then return end
mod:RegisterEnableMob(218370)
mod:SetEncounterID(2922)
mod:SetRespawnTime(30)
mod:SetStage(1)


-- Phases               (ability.id=447207 and type="removebuff") or (ability.id IN (449986,447076) and type="begincast")


-- ReactiveToxin         ability.id=437586 and type="applydebuff"
-- VenomNova             ability.id=437417 and type="begincast"
-- SilkenTomb            ability.id=439814 and type="begincast"
-- Liquefy               ability.id=440899 and type="begincast"
-- Feast                 ability.id=437093 and type="begincast"
-- WebBlades             ability.id=439299 and type="cast"


-- Predation             ability.id=447076 and type="begincast"
-- ParalyzingVenom       ability.id=447456 and type="cast"
-- Wrest                 ability.id=447411 and type="begincast"


-- WrestStageTwo         ability.id=450191 and type="begincast"
-- PredationThreads      ability.id=447170 and type="applydebuff"
-- AcidicApocalypse      ability.id=449940 and type IN ("begincast","cast")

-- Shadowblast           ability.id=447950 and type="begincast"
-- VoidspeakerDeath      (type="death" and target.id=223150) or (ability.id=448046)
-- Shadowgate            ability.id=460369 and type="begincast"

-- Oust                  ability.id=448147 and type="begincast"
-- ExpulsionBeam         ability.id=451600 and type="begincast"


-- AphoticCommunion      ability.id=449986 and type="begincast"
-- AbyssalInfusion       ability.id=443903 and type="applydebuff"
-- FrothingGluttony      ability.id=445422 and type="begincast"
-- QueensSummons         ability.id=444829 and type="begincast"
-- NullDetonation          ability.id=445021 and type="begincast"
-- RoyalCondemnation     MATCHED ability.id=438974 and type="applydebuff" IN (1,4,7,10,13,16,19) END
-- RoyalShacklesApplied    ability.id=441865 and type="applydebuff"
-- Infest                ability.id=443325 and type="begincast"
-- Gorge                 ability.id=443336 and type="begincast"
-- WebBlades             MATCHED ability.id=439299 and type="cast" IN (1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61,65,69,73,77) END

--------------------------------------------------------------------------------
-- Locals
--

local reactiveToxinCount = 1
local venomNovaCount = 1
local silkenTombCount = 1
local liquefyCount = 1
local feastCount = 1
local webBladesCount = 1

local paralyzingVenomCount = 1
local wrestCount = 1

local firstShadowGate = false
local gloomTouchCount = 1
local platformAddsKilled = 0
local worshippersKilled = 0
local acolytesKilled = 0
local lastAcolyteMarked = nil

local abyssalInfusionCount = 1
local frothingGluttonyCount = 1
local queensSummonsCount = 1
local royalCondemnationCount = 1
local infestCount = 1
local gorgeCount = 1

local mobCollector, mobMarks = {}, {}

local timersNormal = { -- 11:32
	[1] = {
		[437592] = { 19.3, 56.0, 56.0, 0 }, -- Reactive Toxin
		[439814] = { 57.5, 54.0, 0 }, -- Silken Tomb
		[440899] = { 8.5, 40.0, 55.0, 0 }, -- Liquefy
		[437093] = { 12.5, 40.0, 55.0, 0 }, -- Feast
		[439299] = { 76.4, 48.0, 0 }, -- Web Blades
	},
	[3] = {
		[444829] = { 113.7, 82.0, 0 }, -- Queen's Summons
		[438976] = { 43.2, 141.6, 0 }, -- Royal Condemnation
		[443325] = { 29.2, 66.0, 80.0, 0 }, -- Infest
		[443336] = { 35.2, 66.0, 80.0, 0 }, -- Gorge
		[439299] = { 201.2, 0 }, -- Web Blades
	},
}

local timersHeroic = { -- 10:09 (enrage)
	[1] = {
		[437592] = { 19.3, 56.0, 56.0, 0 }, -- Reactive Toxin
		[439814] = { 57.4, 64.0, 0 }, -- Silken Tomb
		[440899] = { 8.5, 40.0, 51.0, 0 }, -- Liquefy
		[437093] = { 11.4, 40.0, 51.0, 0 }, -- Feast
		[439299] = { 20.5, 47.0, 43.0, 29.0, 0 }, -- Web Blades
	},
	[3] = {
		[444829] = { 119.0, 75.0, 0 }, -- Queen's Summons
		[438976] = { 43.2, 58.5, 99.5, 0 }, -- Royal Condemnation
		[443325] = { 29.7, 66.0, 82.0, 0 }, -- Infest
		[443336] = { 32.7, 66.0, 82.0, 0 }, -- Gorge
		[439299] = { 85.0, 39.0, 41.0, 18.5, 49.5, 0 }, -- Web Blades
	},
}

local timersMythic = { -- 10:10 (enrage)
	[1] = {
		[437592] = { 21.1, 56.0, 56.0, 0 }, -- Reactive Toxin
		[439814] = { 12.3, 40.0, 57.0, 0 }, -- Silken Tomb
		[440899] = { 6.4, 40.0, 54.0, 0 }, -- Liquefy
		[437093] = { 8.4, 40.0, 54.0, 0 }, -- Feast
		[439299] = { 20.3, 40.0, 13.0, 25.0, 19.0, 23.0, 0 }, -- Web Blades
	},
	[3] = {
		[444829] = { 43.3, 64.0, 83.0, 0 }, -- Queen's Summons
		[438976] = { 111.4, 86.0, 0 }, -- Royal Condemnation
		[443325] = { 30.0, 66.0, 80.0, 0 }, -- Infest
		[443336] = { 32.0, 66.0, 80.0, 0 }, -- Gorge
		[439299] = { 48.3, 37.0, 21.0, 17.0, 42.0, 21.0, 19.0, 36.0, 0 }, -- Web Blades
		[445422] = { 45.0, 80.0, 88.0, 35.5 }, -- Frothing Gluttony
	},
}

local timers = mod:Mythic() and timersMythic or mod:Easy() and timersNormal or timersHeroic

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.stacks_onboss = "%dx %s on BOSS"
	L.stage_two_end_message_storymode = "Use portal"

	L.summoned_acolyte = "Summoned Acolyte"

	L.reactive_toxin_say = "Toxin"
	L.web_blades = "Lines"
	L.silken_tomb = "Roots"
	L.apocalypse = "Apocalypse"
	L.abyssal_infusion_singular = CL.portal
	L.frothing_gluttony = "Ring"
	L.royal_condemnation = "Shackles"
	L.royal_condemnation_no_shackles = "Explosions"
end

--------------------------------------------------------------------------------
-- Initialization
--

local chamberAcolyteMarker = mod:AddMarkerOption(false, "npc", 1, -29945, 1, 4)
local summonedAcolyteMarker = mod:AddMarkerOption(true, "npc", 8, "summoned_acolyte", 8, 7, 6, 5)
function mod:GetOptions()
	return {
		{"stages", "CASTBAR"},
		chamberAcolyteMarker,
		summonedAcolyteMarker,
		-- Stage One: A Queen's Venom
		{437592, "ME_ONLY_EMPHASIZE"}, -- Reactive Toxin
			451278, -- Concentrated Toxin
			464638, -- Frothy Toxin (Fail)
			438481, -- Toxic Waves (Damage)
		{437417, "CASTBAR"}, -- Venom Nova
			441556, -- Reactive Vapor (Fail)
		439814, -- Silken Tomb
		440899, -- Liquefy
		{437093, "TANK_HEALER"}, -- Feast
		439299, -- Web Blades

		-- Intermission: The Spider's Web
		447076, -- Predation
		447456, -- Paralyzing Venom
		{447411, "CASTBAR"}, -- Wrest

		-- Stage Two: Royal Ascension
		{460369, "CASTBAR"}, -- Shadowgate
		-- Queen Ansurek
		{449940, "CASTBAR"}, -- Acidic Apocalypse (Fail)
		-- Ascended Voidspeaker
		447950, -- Shadowblast
		-- 448176, -- Gloom Orbs
		448046, -- Gloom Eruption
		-- Devoted Worshipper
		{447967, "ME_ONLY_EMPHASIZE"}, -- Gloom Touch
		{448458, "CASTBAR"}, -- Cosmic Apocalypse (Fail)
		-- Chamber Guardian
		{448147, "TANK"}, -- Oust
		-- Chamber Expeller
		451600, -- Expulsion Beam
		-- Chamber Acolyte
		{455374, "NAMEPLATE"}, -- Dark Detonation
		-- Caustic Skitterer
		449236, -- Caustic Fangs

		-- Stage Three: Paranoia's Feast
		{443888, "ME_ONLY_EMPHASIZE"}, -- Abyssal Infusion
			455387, -- Abyssal Reverberation
		445422, -- Frothing Gluttony
			445880, -- Froth Vapor (Fail)
		444829, -- Queen's Summons
			445152, -- Acolyte's Essence
			445021, -- Null Detonation
		{438976, "ME_ONLY_EMPHASIZE"}, -- Royal Condemnation
			441865, -- Royal Shackles
		443325, -- Infest
			443726, -- Gloom Hatchling
		443336, -- Gorge
		451832, -- Cataclysmic Evolution
	}, {
		[437592] = -28754, -- Stage 1
		[447076] = -28755, -- Intermission
		[460369] = -28756, -- Stage 2
		[443888] = -28757, -- Stage 3
	}, {
		[451278] = CL.bomb, -- Concentrated Toxin
		[439814] = L.silken_tomb, -- (Roots)
		[439299] = L.web_blades, -- (Lines)
		[447456] = CL.waves, -- Paralyzing Venom
		[448458] = L.apocalypse, -- Acidic Apocalypse
		[448046] = CL.knockback, -- Gloom Eruption
		[449940] = L.apocalypse, -- Cosmic Apocalypse
		[443888] = {CL.portals, "abyssal_infusion_singular"}, -- Abyssal Infusion
		[455387] = CL.bomb, -- Abyssal Reverberation
		[445422] = L.frothing_gluttony, -- (Ring)
		[438976] = {L.royal_condemnation, "royal_condemnation_no_shackles"},
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", nil, "boss1")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")

	-- Stage One: A Queen's Venom
	self:Log("SPELL_CAST_START", "ReactiveToxin", 437592)
	self:Log("SPELL_CAST_SUCCESS", "ReactiveToxinSuccess", 437592) -- LFR
	self:Log("SPELL_AURA_APPLIED", "ReactiveToxinApplied", 437586)
	self:Log("SPELL_AURA_APPLIED", "ConcentratedToxinApplied", 451278)
	-- self:Log("SPELL_AURA_APPLIED", "FrothyToxinApplied", 464638)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FrothyToxinApplied", 464638)
	self:Log("SPELL_DAMAGE", "ToxicWavesDamage", 438481)
	self:Log("SPELL_CAST_START", "VenomNova", 437417)
	self:Log("SPELL_AURA_APPLIED", "ReactiveVaporApplied", 441556)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ReactiveVaporApplied", 441556)
	self:Log("SPELL_CAST_START", "SilkenTomb", 439814)
	self:Log("SPELL_CAST_START", "Liquefy", 440899)
	self:Log("SPELL_AURA_APPLIED", "LiquefyApplied", 436800)
	self:Log("SPELL_CAST_START", "Feast", 437093)
	self:Log("SPELL_AURA_APPLIED", "FeastApplied", 455404)
	self:Log("SPELL_CAST_SUCCESS", "WebBlades", 439299)

	-- Intermission: The Spider's Web
	self:Log("SPELL_CAST_START", "Predation", 447076)
	self:Log("SPELL_AURA_APPLIED", "PredationApplied", 447207)
	self:Log("SPELL_AURA_REMOVED", "PredationRemoved", 447207)
	self:Log("SPELL_CAST_SUCCESS", "ParalyzingVenom", 447456)
	self:Log("SPELL_CAST_START", "Wrest", 447411)

	-- Stage Two: Royal Ascension
	self:Log("SPELL_CAST_START", "Shadowgate", 460369)
	self:Log("SPELL_AURA_APPLIED", "ShadowyDistortionApplied", 460218)
	self:Log("SPELL_AURA_APPLIED", "ShadowgateGloomTouchApplied", 464056)
	-- Queen Ansurek
	self:Log("SPELL_AURA_APPLIED", "CosmicProtection", 458247) -- Story Mode Stage 2
	self:Log("SPELL_AURA_APPLIED", "PredationThreadsApplied", 447170)
	self:Log("SPELL_CAST_START", "AcidicApocalypse", 449940)
	self:Log("SPELL_CAST_SUCCESS", "AcidicApocalypseSuccess", 449940)
	-- Ascended Voidspeaker
	self:Log("SPELL_CAST_START", "Shadowblast", 447950)
	self:Death("VoidspeakerDeath", 223150)
	-- Devoted Worshipper
	self:Log("SPELL_AURA_APPLIED", "GloomTouchApplied", 447967)
	self:Log("SPELL_CAST_START", "CosmicApocalypse", 448458)
	self:Log("SPELL_CAST_SUCCESS", "CosmicApocalypseSuccess", 448458)
	self:Death("WorshipperDeath", 223318)
	-- Chamber Guardian
	self:Log("SPELL_CAST_START", "Oust", 448147)
	self:Death("GuardianDeath", 223204)
	-- Chamber Expeller
	self:Log("SPELL_CAST_START", "ExpulsionBeam", 451600)
	self:Death("ExpellerDeath", 224368)
	-- Chamber Acolyte
	self:Log("SPELL_CAST_START", "DarkDetonation", 455374)
	self:Death("ChamberAcolyteDeath", 226200)
	-- Caustic Skitterer
	-- self:Log("SPELL_AURA_APPLIED", "CausticFangsApplied", 449236)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CausticFangsApplied", 449236)

	-- Stage Three: Paranoia's Feast
	self:Log("SPELL_CAST_START", "AphoticCommunion", 449986)
	self:Log("SPELL_CAST_SUCCESS", "AphoticCommunionSuccess", 449986)
	self:Log("SPELL_CAST_START", "AbyssalInfusion", 443888)
	self:Log("SPELL_CAST_SUCCESS", "AbyssalInfusionSuccess", 443888) -- LFR
	self:Log("SPELL_AURA_APPLIED", "AbyssalInfusionApplied", 443903)
	self:Log("SPELL_AURA_APPLIED", "AbyssalReverberationApplied", 455387)
	self:Log("SPELL_CAST_START", "FrothingGluttony", 445422)
	self:Log("SPELL_AURA_APPLIED", "FrothVaporAppliedOnBoss", 445880)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FrothVaporAppliedOnBoss", 445880)
	self:Log("SPELL_CAST_START", "QueensSummons", 444829)
	self:Log("SPELL_AURA_APPLIED", "AcolytesEssenceApplied", 445152)
	self:Log("SPELL_CAST_START", "NullDetonation", 445021)
	self:Log("SPELL_AURA_APPLIED", "RoyalCondemnationApplied", 438974)
	self:Log("SPELL_AURA_APPLIED", "RoyalShacklesApplied", 441865)
	self:Log("SPELL_CAST_START", "Infest", 443325)
	self:Log("SPELL_AURA_APPLIED", "InfestApplied", 443656)
	self:Log("SPELL_AURA_REMOVED", "InfestRemoved", 443656)
	self:Log("SPELL_AURA_APPLIED", "GloomHatchlingAppliedOnBoss", 443726)
	self:Log("SPELL_AURA_APPLIED_DOSE", "GloomHatchlingAppliedOnBoss", 443726)
	self:Log("SPELL_CAST_START", "Gorge", 443336)
	self:Log("SPELL_AURA_APPLIED", "GorgeApplied", 443342)
	self:Log("SPELL_AURA_APPLIED_DOSE", "GorgeApplied", 443342)
	self:Log("SPELL_CAST_SUCCESS", "CataclysmicEvolution", 451832)
end

function mod:OnEngage()
	timers = self:Mythic() and timersMythic or self:Easy() and timersNormal or timersHeroic

	self:SetStage(1)
	reactiveToxinCount = 1
	venomNovaCount = 1
	silkenTombCount = 1
	liquefyCount = 1
	feastCount = 1
	webBladesCount = 1

	mobCollector = {}
	mobMarks = {}

	if not self:Story() then
		self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
		self:Bar(440899, timers[1][440899][1], CL.count:format(self:SpellName(440899), liquefyCount)) -- Liquefy
		self:Bar(437093, timers[1][437093][1], CL.count:format(self:SpellName(437093), feastCount)) -- Feast
		self:Bar(437592, timers[1][437592][1], CL.count:format(self:SpellName(437592), reactiveToxinCount)) -- Reactive Toxin
		self:Bar("stages", 153.9, CL.intermission, 447207) -- Predation
	else
		self:Bar("stages", 100, CL.stage:format(2), 458247) -- Cosmic Protection
	end
	self:Bar(439299, self:Story() and 7.5 or timers[1][439299][1], CL.count:format(self:SpellName(439299), webBladesCount)) -- Web Blades
	self:Bar(437417, self:Story() and 34.5 or 29.5, CL.count:format(self:SpellName(437417), venomNovaCount)) -- Venom Nova
	self:Bar(439814, self:Story() and 20.5 or timers[1][439814][1], CL.count:format(self:SpellName(439814), silkenTombCount)) -- Silken Tomb
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
			if mobId == 221863 and not mobCollector[guid] then -- Summoned Acolyte
				mobCollector[guid] = true
				local icon = mobMarks[mobId] or 8
				self:CustomIcon(summonedAcolyteMarker, unit, icon)
				mobMarks[mobId] = icon - 1
			end
		end
	end
end

function mod:AddMarking(_, unit, guid)
	if self:MobId(guid) == 226200 and not mobCollector[guid] then -- Chamber Acolyte
		mobCollector[guid] = true
		if self:GetIcon(unit) and not lastAcolyteMarked then return end

		local marks = { 1, 4 } -- star, triangle
		local index = self:MobSpawnIndex(guid)
		if index == 1 and lastAcolyteMarked then -- staggered spawn
			local spawnA, spawnB = self:MobSpawnTime(lastAcolyteMarked), self:MobSpawnTime(guid)
			if spawnA < spawnB then
				-- this is the second spawn
				index = 2
			else
				-- remark other add
				local otherUnit = self:UnitTokenFromGUID(lastAcolyteMarked)
				self:CustomIcon(chamberAcolyteMarker, otherUnit, marks[2])
			end
		end
		self:CustomIcon(chamberAcolyteMarker, unit, marks[index])
		lastAcolyteMarked = guid
	end
end

function mod:UNIT_SPELLCAST_INTERRUPTED(_, _, _, spellId)
	if spellId == 450191 then -- Wrest
		self:WrestInterrupted()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
	if spellId == 450040 then -- Land
		self:Land()
	elseif spellId == 449962 then -- Acidic Apocalypse
		self:AcidicApocalypsePrecast()
	elseif self:Story() and spellId == 438667 then -- Royal Condemnation
		-- No RoyalCondemnationApplied in story mode
		self:StopBar(CL.count:format(L.royal_condemnation, royalCondemnationCount))
		self:Message(438976, "yellow", CL.count:format(L.royal_condemnation, royalCondemnationCount))
		self:Bar(441865, 6.2, CL.explosion)
		royalCondemnationCount = royalCondemnationCount + 1
		self:Bar(438976, 53.0, CL.count:format(L.royal_condemnation, royalCondemnationCount))
	end
end

-- Stage One: A Queen's Venom

function mod:UNIT_HEALTH(event, unit)
	if self:GetHealth(unit) < 37 then -- Intermission forced at 35%
		self:UnregisterUnitEvent(event, unit)
		self:Message("stages", "cyan", CL.soon:format(CL.intermission), false)
		self:PlaySound("stages", "info")
	end
end

do
	local playerList = {}
	function mod:ReactiveToxin(args)
		playerList = {}
	end

	function mod:ReactiveToxinSuccess()
		if self:LFR() then -- No ReactiveToxinApplied in LFR
			local spellName = self:SpellName(437592)
			self:StopBar(CL.count:format(spellName, reactiveToxinCount))
			self:Message(437592, "orange", CL.count:format(spellName, reactiveToxinCount))
			reactiveToxinCount = reactiveToxinCount + 1
			self:Bar(437592, timers[1][437592][reactiveToxinCount], CL.count:format(spellName, reactiveToxinCount))
		end
	end

	function mod:ReactiveToxinApplied(args)
		local spellName = self:SpellName(437592)
		if #playerList == 0 then
			self:StopBar(CL.count:format(spellName, reactiveToxinCount))
			reactiveToxinCount = reactiveToxinCount + 1
			self:Bar(437592, timers[1][437592][reactiveToxinCount], CL.count:format(spellName, reactiveToxinCount))
		end
		playerList[#playerList + 1] = args.destName
		if self:Me(args.destGUID) then
			self:PlaySound(437592, "warning") -- position?
			-- self:Say(437592, L.reactive_toxin_say, nil, "Toxin")
			-- self:SayCountdown(437592, self:Mythic() and 5 or 6)
		end
		local count = self:Mythic() and math.min(reactiveToxinCount, 3) or self:Easy() and 1 or 2
		self:TargetsMessage(437592, "orange", playerList, count, {CL.count:format(spellName, reactiveToxinCount - 1), spellName})
	end
end

function mod:ConcentratedToxinApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm") -- avoid others
		-- self:Say(args.spellId, CL.bomb, nil, "Bomb")
		-- self:SayCountdown(args.spellId, 6)
	end
end

function mod:FrothyToxinApplied(args)
	if self:Me(args.destGUID) and args.amount > 3 then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 3)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:ToxicWavesDamage(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "underyou")
		self:PlaySound(args.spellId, "underyou")
	end
end

function mod:VenomNova(args)
	local msg = CL.count:format(args.spellName, venomNovaCount)
	self:StopBar(msg)
	self:Message(args.spellId, "red", CL.casting:format(msg))
	self:CastBar(args.spellId, self:Mythic() and 5 or self:Story() and 4 or 6, msg)
	self:PlaySound(args.spellId, "alert")
	venomNovaCount = venomNovaCount + 1
	if venomNovaCount < (self:Story() and 3 or 4) then
		self:Bar(args.spellId, self:Story() and 38 or 56.0, CL.count:format(args.spellName, venomNovaCount))
	end
end

function mod:ReactiveVaporApplied(args)
	if self:Me(args.destGUID) then
		-- self:PersonalMessage(args.spellId)
		self:StackMessage(args.spellId, "red", args.destName, args.amount, 1)
		self:PlaySound(args.spellId, "alarm") -- failed
	end
end

function mod:SilkenTomb(args)
	self:StopBar(CL.count:format(args.spellName, silkenTombCount))
	self:Message(args.spellId, "yellow", CL.casting:format(CL.count:format(args.spellName, silkenTombCount)))
	self:PlaySound(args.spellId, "alarm") -- spread
	silkenTombCount = silkenTombCount + 1
	self:Bar(args.spellId, self:Story() and 38.0 or timers[1][args.spellId][silkenTombCount], CL.count:format(args.spellName, silkenTombCount))
end

function mod:Liquefy(args)
	self:StopBar(CL.count:format(args.spellName, liquefyCount))
	self:Message(args.spellId, "purple", CL.casting:format(CL.count:format(args.spellName, liquefyCount)))
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:Tanking(unit) then
		self:PlaySound(args.spellId, "alarm") -- defensive
	else -- rest of the raid
		self:PlaySound(args.spellId, "alert")
	end
	liquefyCount = liquefyCount + 1
	self:Bar(args.spellId, timers[1][args.spellId][liquefyCount], CL.count:format(args.spellName, liquefyCount))
end

function mod:LiquefyApplied(args)
	if self:Tank() then
		self:TargetMessage(440899, "purple", args.destName)
		local unit = self:UnitTokenFromGUID(args.sourceGUID)
		if unit and not self:Tanking(unit) then
			self:PlaySound(440899, "warning") -- tauntswap
		end
	end
end

function mod:Feast(args)
	self:StopBar(CL.count:format(args.spellName, feastCount))
	self:Message(args.spellId, "purple", CL.casting:format(CL.count:format(args.spellName, feastCount)))
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:Tanking(unit) then
		self:PlaySound(args.spellId, "alarm") -- defensive
	end
	feastCount = feastCount + 1
	self:Bar(args.spellId, timers[1][args.spellId][feastCount], CL.count:format(args.spellName, feastCount))
end

function mod:FeastApplied(args)
	self:TargetMessage(437093, "purple", args.destName)
end

do
	local prev = 0
	function mod:WebBlades(args)
		if args.time - prev > 5 then
			prev = args.time
			self:StopBar(CL.count:format(args.spellName, webBladesCount))
			self:Message(args.spellId, "cyan", CL.incoming:format(CL.count:format(args.spellName, webBladesCount)))
			self:PlaySound(args.spellId, "long")
			webBladesCount = webBladesCount + 1
			self:Bar(args.spellId, self:Story() and 38.0 or timers[self:GetStage()][args.spellId][webBladesCount], CL.count:format(args.spellName, webBladesCount))
		end
	end
end

-- Intermission: The Spider's Web

do
	local predationApplied = 0
	function mod:Predation()
		self:UnregisterUnitEvent("UNIT_HEALTH", "boss1")
		self:StopBar(CL.intermission)
		self:StopBar(CL.count:format(self:SpellName(440899), liquefyCount)) -- Liquefy
		self:StopBar(CL.count:format(self:SpellName(437093), feastCount)) -- Feast
		self:StopBar(CL.count:format(self:SpellName(437592), reactiveToxinCount)) -- Reactive Toxin
		self:StopBar(CL.count:format(self:SpellName(437417), venomNovaCount)) -- Venom Nova
		self:StopCastBar(CL.count:format(self:SpellName(437417), venomNovaCount)) -- Venom Nova
		self:StopBar(CL.count:format(self:SpellName(439814), silkenTombCount)) -- Silken Tomb
		self:StopBar(CL.count:format(self:SpellName(439299), webBladesCount)) -- Web Blades

		self:SetStage(1.5)
		self:Message("stages", "cyan", CL.intermission, false)
		self:PlaySound("stages", "long")

		paralyzingVenomCount = 1
		wrestCount = 1

		self:Bar(447411, 6.0, CL.count:format(self:SpellName(447411), wrestCount)) -- Wrest
		self:Bar(447456, 15.5, CL.count:format(self:SpellName(447456), paralyzingVenomCount)) -- Paralyzing Venom
	end

	function mod:PredationApplied(args)
		predationApplied = args.time
	end

	function mod:PredationRemoved(args)
		self:StopBar(CL.count:format(self:SpellName(447456), paralyzingVenomCount)) -- Paralyzing Venom
		self:StopBar(CL.count:format(self:SpellName(447411), wrestCount)) -- Wrest
		self:StopCastBar(CL.count:format(self:SpellName(447411), wrestCount-1))

		self:Message(447076, "green", CL.removed_after:format(args.spellName, args.time - predationApplied))

		self:SetStage(2)
		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:PlaySound("stages", "long")

		wrestCount = 1
		gloomTouchCount = 1
		platformAddsKilled = 0
		worshippersKilled = 0
		acolytesKilled = 0
		lastAcolyteMarked = nil
		firstShadowGate = true

		if self:Mythic() then
			if self:GetOption(chamberAcolyteMarker) then
				self:RegisterTargetEvents("AddMarking")
			end
			self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "ShadowgateNameplateCheck")
			self:RegisterEvent("UNIT_SPELLCAST_START")
			self:RegisterEvent("UNIT_SPELLCAST_STOP")
		end
	end
end

function mod:ParalyzingVenom(args)
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, paralyzingVenomCount))
	paralyzingVenomCount = paralyzingVenomCount + 1
	self:Bar(args.spellId, paralyzingVenomCount % 3 == 1 and 11.0 or 4.0, CL.count:format(args.spellName, paralyzingVenomCount))
end

function mod:Wrest(args)
	self:Message(args.spellId, "red", CL.count:format(args.spellName, wrestCount))
	self:CastBar(args.spellId, 6, CL.count:format(args.spellName, wrestCount))
	self:PlaySound(args.spellId, "alert")
	wrestCount = wrestCount + 1
	self:Bar(args.spellId, 19.0, CL.count:format(args.spellName, wrestCount))
end

-- Stage Two: Royal Ascension

function mod:CosmicProtection() -- Story Mode
	self:UnregisterUnitEvent("UNIT_HEALTH", "boss1")
	self:StopBar(CL.stage:format(2))
	self:StopBar(CL.count:format(self:SpellName(437417), venomNovaCount)) -- Venom Nova
	self:StopCastBar(CL.count:format(self:SpellName(437417), venomNovaCount)) -- Venom Nova
	self:StopBar(CL.count:format(self:SpellName(439814), silkenTombCount)) -- Silken Tomb
	self:StopBar(CL.count:format(self:SpellName(439299), webBladesCount)) -- Web Blades

	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "long")
end

do
	-- Shadowgate
	local prev = nil
	local casterGUID = nil
	-- cast events from nameplates, requires looking at the gate D;
	function mod:ShadowgateNameplateCheck(event, unit)
		local guid = self:UnitGUID(unit)
		if self:MobId(guid) == 228617 then -- Shadowgate
			casterGUID = guid
			local name, _, _, _, endTime = UnitCastingInfo(unit)
			if name then
				local duration = endTime / 1000 - GetTime()
				self:CastBar(460369, {duration, 12})
			end
		end
		if self.targetEventFunc then -- for RegisterTargetEvents
			self:NAME_PLATE_UNIT_ADDED(event, unit)
		end
	end

	function mod:UNIT_SPELLCAST_START(_, unit, castGUID, spellId)
		if spellId == 460369 and prev ~= castGUID then -- Shadowgate
			firstShadowGate = false
			prev = castGUID
			casterGUID = self:UnitGUID(unit)
			self:CastBar(460369, 12)
		end
	end
	function mod:UNIT_SPELLCAST_STOP(_, unit, _, spellId)
		if spellId == 460369 then -- Shadowgate
			casterGUID = self:UnitGUID(unit)
			self:StopCastBar(460369)
		end
	end

	function mod:Shadowgate(args)
		if firstShadowGate then -- get the next cast
			firstShadowGate = false
			self:CastBar(args.spellId, 12)
		elseif casterGUID == args.sourceGUID then
			-- show the cast for the last gate you saw a nameplate for
			self:CastBar(args.spellId, 12)
		end
	end

	function mod:ShadowyDistortionApplied(args)
		if self:Me(args.destGUID) then
			casterGUID = nil
			self:StopCastBar(460369) -- Shadowgate
			-- Wrest swap
			local currentCount = wrestCount - 1
			local nextCount = wrestCount + 1
			self:StopCastBar(CL.count:format(self:SpellName(447411), currentCount)) -- Wrest
			local remaining = self:BarTimeLeft(CL.count:format(self:SpellName(447411), nextCount)) - 8
			self:StopBar(CL.count:format(self:SpellName(447411), nextCount))
			if remaining > 1 then
				self:CDBar(447411, remaining, CL.count:format(self:SpellName(447411), wrestCount))
			end
		elseif args.sourceGUID ~= casterGUID then -- dest portal isn't mine
			self:StopCastBar(460369) -- Shadowgate
		end
	end
end

function mod:ShadowgateGloomTouchApplied(args)
	local touchOnMe = false
	if self:Me(args.destGUID) then
		touchOnMe = true -- make sure there's a message
		self:PlaySound(447967, "alarm") -- spread
		-- self:Say(args.spellId)
	end
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if touchOnMe or (unit and self:UnitWithinRange(unit, 45)) then
		self:TargetMessage(447967, "yellow", args.destName)
	end
end

-- Queen Ansurek

do
	local prev = 0
	local scheduled = nil
	local threadsOnMe = false
	local currentCount, nextCount = nil, nil

	function mod:WrestReset()
		if platformAddsKilled == 2 then -- platform 2->3
			self:StopCastBar(460369) -- Shadowgate

			-- resets when you spawn the bridge? so may vary a bit
			local text = CL.count:format(self:SpellName(447411), wrestCount)
			local remaining = self:BarTimeLeft(text)
			if remaining > 1 then
				self:CDBar(447411, 12.0, text)
			end
			text = CL.count:format(self:SpellName(447411), wrestCount + 1)
			remaining = self:BarTimeLeft(text)
			if remaining > 1 then
				self:CDBar(447411, 12.0, text)
			end
		end
	end

	function mod:WrestInterrupted()
		if threadsOnMe then -- last cast was on me
			self:StopCastBar(CL.count:format(self:SpellName(447411), currentCount))
			self:StopBar(CL.count:format(self:SpellName(447411), nextCount))
			-- skips the side when the bridge is created, so first to click will most likely get the next cast
			-- XXX acolyte side was usually first is and interrupts the cast, so assume
			self:CDBar(447411, 10.7, CL.count:format(self:SpellName(447411), currentCount + 1))
		else
			-- XXX (see above) other side, swap order
			self:StopBar(CL.count:format(self:SpellName(447411), wrestCount))
			self:CDBar(447411, 18.7, CL.count:format(self:SpellName(447411), nextCount))
		end
	end

	function mod:WrestCast()
		self:StopBar(CL.count:format(self:SpellName(447411), wrestCount))
		wrestCount = wrestCount + 1
		if threadsOnMe then
			currentCount = wrestCount - 1
			self:Message(447411, "red", CL.count:format(self:SpellName(447411), currentCount))
			self:CastBar(447411, 5, CL.count:format(self:SpellName(447411), currentCount))
			self:PlaySound(447411, "alert")
			nextCount = wrestCount + 1
			self:CDBar(447411, 16.0, CL.count:format(self:SpellName(447411), nextCount))
		else
			self:CDBar(447411, {8.0, 16.0}, CL.count:format(self:SpellName(447411), wrestCount))
		end
	end

	function mod:PredationThreadsApplied(args)
		if self:GetStage() == 2 then
			if args.time - prev > 2 then
				prev = args.time
				threadsOnMe = false
				scheduled = self:ScheduleTimer("WrestCast", 0.1)
			end
			if self:Me(args.destGUID) then
				threadsOnMe = true
			end
		end
	end

	function mod:AcidicApocalypsePrecast()
		-- platform 3->4
		self:CancelTimer(scheduled)
		for i = 1, wrestCount + 1 do
			self:StopBar(CL.count:format(self:SpellName(447411), i)) -- nuclear cleanup
		end
		self:StopCastBar(460369) -- Shadowgate
		-- firstShadowGate = true -- XXX can still catch desync'd casts here z.z
	end

	function mod:AcidicApocalypse(args)
		self:Message(args.spellId, "yellow", CL.casting:format(args.spellName))
		self:CastBar(args.spellId, self:Easy() and 50 or 35)
	end
end

function mod:AcidicApocalypseSuccess(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- fail
end

-- Ascended Voidspeaker
function mod:Shadowblast(args)
	local isPossible, isReady = self:Interrupter(args.sourceGUID)
	if isPossible then
		self:Message(args.spellId, "orange")
		if isReady then
			self:PlaySound(args.spellId, "alert")
		end
	end
end

do
	local prev = 0
	function mod:VoidspeakerDeath(args)
		if args.time - prev > 2 then
			prev = args.time
			if self:Story() then
				self:Message("stages", "cyan", L.stage_two_end_message_storymode, false, nil, 5) -- Stay onscreen for 5s
			else
				self:StopCastBar(460369) -- Shadowgate

				self:Message("stages", "cyan", CL.killed:format(args.destName), false)
				self:Bar(448046, self:Mythic() and 5.2 or self:Easy() and 7.1 or 5.9) -- Gloom Eruption

				if wrestCount == 1 then -- first Voidspeaker set
					firstShadowGate = true
					self:CDBar(447411, self:Easy() and 13.5 or 11.8, CL.count:format(self:SpellName(447411), wrestCount)) -- Wrest
					self:Bar(451600, 12.5) -- Expulsion Beam
					self:Bar(448147, 14.2) -- Oust
				end
			end
		end
	end
end

-- Devoted Worshipper
do
	local prev, prevSource = 0, nil
	local touchOnMe = false
	local playerList = {}
	function mod:GloomTouchApplied(args)
		if args.sourceGUID ~= prevSource or args.time - prev > 5 then
			prev = args.time
			prevSource = args.sourceGUID
			playerList = {}
			touchOnMe = false
			gloomTouchCount = gloomTouchCount + 1
		end
		if self:Me(args.destGUID) then
			touchOnMe = true -- make sure there's a message
			self:PlaySound(args.spellId, "alarm") -- spread
			-- self:Say(args.spellId, nil, nil, "Gloom Touch")
		end

		local unit = self:UnitTokenFromGUID(args.sourceGUID)
		if touchOnMe or (unit and self:UnitWithinRange(unit, 60)) then
			playerList[#playerList + 1] = args.destName
			self:TargetsMessage(args.spellId, "yellow", playerList, self:Mythic() and 1 or 2, {CL.count:format(args.spellName, gloomTouchCount-1), args.spellName})
		end
	end
end

do
	local prev = 0
	function mod:CosmicApocalypse(args)
		if args.time - prev > 2 then
			prev = args.time
			self:CastBar(args.spellId, self:Mythic() and 80 or self:Easy() and 95 or 85)
		end
	end
end

do
	local prev = 0
	function mod:CosmicApocalypseSuccess(args)
		if args.time - prev > 2 then
			prev = args.time
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "alarm") -- fail
		end
	end
end

function mod:WorshipperDeath(args)
	worshippersKilled = worshippersKilled + 1
	self:Message("stages", "cyan", CL.mob_killed:format(args.destName, worshippersKilled, 2), false)
	if worshippersKilled == 2 then
		self:StopCastBar(448458) -- Cosmic Apocalypse
	end
end

-- Chamber Guardian
function mod:Oust(args)
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 60) then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "warning")
		self:Bar(args.spellId, 10)
	end
end

do
	local prev = 0
	function mod:GuardianDeath(args)
		if args.time - prev > 2 then
			prev = args.time
			self:StopBar(448147) -- Oust
			self:Message("stages", "cyan", CL.killed:format(args.destName), false)
			platformAddsKilled = platformAddsKilled + 1
			self:WrestReset()
		end
	end
end

-- Chamber Expeller
function mod:ExpulsionBeam(args)
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 60) then
		self:Message(args.spellId, "orange")
		self:PlaySound(args.spellId, "alert")
		self:Bar(args.spellId, 10)
	end
end

do
	local prev = 0
	function mod:ExpellerDeath(args)
		if args.time - prev > 2 then
			prev = args.time
			self:StopBar(451600) -- Expulsion Beam
			self:Message("stages", "cyan", CL.killed:format(args.destName), false)
			platformAddsKilled = platformAddsKilled + 1
			self:WrestReset()
		end
	end
end

-- Chamber Acolyte
function mod:DarkDetonation(args)
	local isPossible, isReady = self:Interrupter(args.sourceGUID)
	if isPossible then
		self:Message(args.spellId, "yellow")
		if isReady then
			self:PlaySound(args.spellId, "alert")
		end
	end
	self:Nameplate(args.spellId, 13, args.sourceGUID)
end

function mod:ChamberAcolyteDeath(args)
	acolytesKilled = acolytesKilled + 1
	self:Message("stages", "cyan", CL.mob_killed:format(args.destName, acolytesKilled, 2), false)
	self:ClearNameplate(args.destGUID)
end

-- Caustic Skitterer
function mod:CausticFangsApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 10 == 0 then
			self:StackMessage(args.spellId, "blue", args.destName, amount, 20)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

-- Stage Three: Paranoia's Feast

function mod:AphoticCommunion(args)
	self:StopCastBar(449940) -- Acidic Apocalypse
	if self:Mythic() then
		self:UnregisterTargetEvents()
		self:UnregisterEvent("UNIT_SPELLCAST_START")
		self:UnregisterEvent("UNIT_SPELLCAST_STOP")
	end

	self:SetStage(3)
	self:Message("stages", "cyan", CL.stage:format(3), false)
	self:PlaySound("stages", "long")
	self:CastBar("stages", 20, CL.stage:format(3), args.spellId)

	abyssalInfusionCount = 1
	frothingGluttonyCount = 1
	queensSummonsCount = 1
	royalCondemnationCount = 1
	infestCount = 1
	gorgeCount = 1
	webBladesCount = 1

	if self:GetOption(summonedAcolyteMarker) and not self:Mythic() then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end

	-- if not self:Story() then
	-- 	self:Bar(443325, timers[3][443325][1], CL.count:format(CL.small_adds, infestCount)) -- Infest
	-- 	self:Bar(443336, timers[3][443336][1], CL.count:format(CL.pools, gorgeCount)) -- Gorge
	-- 	self:Bar(443888, 59.1, CL.count:format(CL.portals, abyssalInfusionCount)) -- Abyssal Infusion
	-- 	self:Bar(439299, timers[3][439299][1], CL.count:format(L.web_blades, webBladesCount)) -- Web Blades
	-- end
	-- self:Bar(438976, self:Story() and 31.0 or timers[3][438976][1], CL.count:format(L.royal_condemnation, royalCondemnationCount)) -- Royal Condemnation
	-- self:Bar(445422, self:Story() and 62.0 or 68.8, CL.count:format(L.frothing_gluttony, frothingGluttonyCount)) -- Frothing Gluttony
	-- self:Bar(444829, self:Story() and 42.0 or timers[3][444829][1], CL.count:format(CL.big_adds, queensSummonsCount)) -- Queen's Summons
end

function mod:AphoticCommunionSuccess()
	-- timers from Land UNIT event, roughly 24s shorter than CLEU
	if not self:Story() then
		self:Bar(443325, 5.9, CL.count:format(self:SpellName(443325), infestCount)) -- Infest
		self:Bar(443336, self:Mythic() and 7.9 or self:Easy() and 11.9 or 8.9, CL.count:format(self:SpellName(443336), gorgeCount)) -- Gorge
		self:Bar(443888, 35.7, CL.count:format(self:SpellName(443888), abyssalInfusionCount)) -- Abyssal Infusion
		self:Bar(439299, self:Mythic() and 24.9 or self:Easy() and 177 or 62.0, CL.count:format(self:SpellName(439299), webBladesCount)) -- Web Blades

		self:PauseBar(443325, CL.count:format(self:SpellName(443325), infestCount)) -- Infest
		self:PauseBar(443336, CL.count:format(self:SpellName(443336), gorgeCount)) -- Gorge
		self:PauseBar(443888, CL.count:format(self:SpellName(443888), abyssalInfusionCount)) -- Abyssal Infusion
		self:PauseBar(439299, CL.count:format(self:SpellName(439299), webBladesCount)) -- Web Blades
	end

	self:Bar(444829, self:Mythic() and 19.9 or self:Easy() and 90 or self:Story() and 19.0 or 96.0, CL.count:format(self:SpellName(444829), queensSummonsCount)) -- Queen's Summons
	self:Bar(445422, self:Story() and 39.0 or 45.0, CL.count:format(self:SpellName(445422), frothingGluttonyCount)) -- Frothing Gluttony
	self:Bar(438976, self:Mythic() and 88.0 or self:Story() and 8.0 or 20.0, CL.count:format(self:SpellName(438976), royalCondemnationCount)) -- Royal Condemnation

	self:PauseBar(444829, CL.count:format(self:SpellName(444829), queensSummonsCount)) -- Queen's Summons
	self:PauseBar(445422, CL.count:format(self:SpellName(445422), frothingGluttonyCount)) -- Frothing Gluttony
	self:PauseBar(438976, CL.count:format(self:SpellName(438976), royalCondemnationCount)) -- Royal Condemnation
end

function mod:Land()
	if not self:Story() then
		self:ResumeBar(443325, CL.count:format(self:SpellName(443325), infestCount)) -- Infest
		self:ResumeBar(443336, CL.count:format(self:SpellName(443336), gorgeCount)) -- Gorge
		self:ResumeBar(443888, CL.count:format(self:SpellName(443888), abyssalInfusionCount)) -- Abyssal Infusion
		self:ResumeBar(439299, CL.count:format(self:SpellName(439299), webBladesCount)) -- Web Blades
	end
	self:ResumeBar(444829, CL.count:format(self:SpellName(444829), queensSummonsCount)) -- Queen's Summons
	self:ResumeBar(445422, CL.count:format(self:SpellName(445422), frothingGluttonyCount)) -- Frothing Gluttony
	self:ResumeBar(438976, CL.count:format(self:SpellName(438976), royalCondemnationCount)) -- Royal Condemnation
end

do
	local playerList = {}
	function mod:AbyssalInfusion(args)
		playerList = {}
	end

	function mod:AbyssalInfusionSuccess()
		if self:LFR() then -- No AbyssalInfusionApplied in LFR
			local spellName = self:SpellName(443888)
			self:StopBar(CL.count:format(spellName, abyssalInfusionCount))
			self:Message(443888, "orange", CL.count:format(spellName, abyssalInfusionCount))
			abyssalInfusionCount = abyssalInfusionCount + 1
			if abyssalInfusionCount < 5 then
				self:Bar(443888, 80, CL.count:format(spellName, abyssalInfusionCount))
			end
		end
	end

	function mod:AbyssalInfusionApplied(args)
		local spellName = self:SpellName(443888)
		if #playerList == 0 then
			self:StopBar(CL.count:format(spellName, abyssalInfusionCount))
			abyssalInfusionCount = abyssalInfusionCount + 1
			if abyssalInfusionCount <  4 then
				self:Bar(443888, 80, CL.count:format(spellName, abyssalInfusionCount))
			end
		end
		playerList[#playerList + 1] = args.destName
		if self:Me(args.destGUID) then
			self:PlaySound(443888, "warning") -- position?
			-- self:Say(443888, CL.portal, nil, "Portal")
			-- self:SayCountdown(443888, 6)
		end
		self:TargetsMessage(443888, "orange", playerList, 2, {CL.count:format(spellName, abyssalInfusionCount-1), L.abyssal_infusion_singular})
	end
end

function mod:AbyssalReverberationApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:FrothingGluttony(args)
	self:StopBar(CL.count:format(args.spellName, frothingGluttonyCount))
	self:Message(args.spellId, "red", CL.casting:format(CL.count:format(args.spellName, frothingGluttonyCount)))
	self:PlaySound(args.spellId, "alert")
	frothingGluttonyCount = frothingGluttonyCount + 1
	local cd
	if self:Mythic() then
		cd = timers[3][args.spellId][frothingGluttonyCount]
	elseif self:Story() then
		cd = 53
	else
		-- 4th (5th in LFR) cast triggers Cataclysmic Evolution
		cd = frothingGluttonyCount < (self:LFR() and 5 or 4) and 80 or 25.5
	end
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, frothingGluttonyCount))
end

do
	local stacks = 0
	local scheduled = nil
	function mod:FrothVaporStacksMessage()
		self:Message(445880, "red", L.stacks_onboss:format(stacks, self:SpellName(445880)))
		self:PlaySound(445880, "alarm") -- fail
		scheduled = nil
	end

	function mod:FrothVaporAppliedOnBoss(args)
		stacks = args.amount or 1
		if not scheduled then
			scheduled = self:ScheduleTimer("FrothVaporStacksMessage", 1)
		end
	end
end

function mod:QueensSummons(args)
	self:StopBar(CL.count:format(args.spellName, queensSummonsCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, queensSummonsCount))
	self:PlaySound(args.spellId, "info")
	queensSummonsCount = queensSummonsCount + 1
	self:Bar(args.spellId, self:Story() and 53 or timers[3][args.spellId][queensSummonsCount], CL.count:format(args.spellName, queensSummonsCount))
	mobMarks[221863] = nil
end

function mod:AcolytesEssenceApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:NullDetonation(args)
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and not self:UnitBuff(unit, 445013) then -- Dark Barrier
		local isPossible, isReady = self:Interrupter(args.sourceGUID)
		if isPossible then
			self:Message(args.spellId, "yellow")
			if isReady then
				self:PlaySound(args.spellId, "alarm")
			end
		end
	end
end

do
	local prev = 0
	local playerList = {}
	function mod:RoyalCondemnationApplied(args)
		if args.time - prev > 3 then
			prev = args.time
			self:StopBar(CL.count:format(self:SpellName(438976), royalCondemnationCount))
			if self:Easy() then
				self:Bar(441865, 6.2, L.royal_condemnation_no_shackles) -- 6~6.5
			else
				self:Bar(441865, 8.3, CL.on_group:format(L.royal_condemnation))
			end
			royalCondemnationCount = royalCondemnationCount + 1
			self:Bar(438976, timers[3][438976][royalCondemnationCount], CL.count:format(self:SpellName(438976), royalCondemnationCount))
			playerList = {}
		end
		playerList[#playerList + 1] = args.destName
		if self:Me(args.destGUID) then
			self:PlaySound(438976, "warning")
			-- self:Say(438976, L.royal_condemnation, nil, "Shackles")
			-- self:SayCountdown(438976, 6.2) -- projectile based both ways? z.z
		end
		local count = self:Mythic() and 3 or self:LFR() and 1 or 2
		self:TargetsMessage(438976, "yellow", playerList, count, {CL.count:format(args.spellName, royalCondemnationCount-1), L.royal_condemnation})
	end
end

function mod:RoyalShacklesApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "link_with", L.royal_condemnation) -- Linked with Shackles
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:Infest(args)
	self:StopBar(CL.count:format(args.spellName, infestCount))
	self:Message(args.spellId, "purple", CL.casting:format(CL.count:format(args.spellName, infestCount)))
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:Tanking(unit) then
		self:PlaySound(args.spellId, "alarm") -- defensive
	end
	infestCount = infestCount + 1
	self:Bar(args.spellId, timers[3][args.spellId][infestCount], CL.count:format(args.spellName, infestCount))
end

function mod:InfestApplied(args)
	self:TargetMessage(443325, "purple", args.destName)
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and not self:Tanking(unit) then
		self:PlaySound(443325, "warning") -- tauntswap
	end
	self:TargetBar(443325, self:Mythic() and 4 or 5, args.destName)
	-- if self:Me(args.destGUID) then
	-- 	self:Say(443325, nil, nil, "Infest")
	-- 	self:SayCountdown(443325, self:Mythic() and 4 or 5)
	-- end
end

function mod:InfestRemoved(args)
	self:StopBar(443325, args.destName)
	-- if self:Me(args.destGUID) then
	-- 	self:CancelSayCountdown(443325)
	-- end
end

do
	local stacks = 0
	local scheduled = nil
	function mod:GloomHatchlingStacksMessage()
		self:Message(443726, "red", L.stacks_onboss:format(stacks, self:SpellName(443726)))
		self:PlaySound(443726, "alarm")
		scheduled = nil
	end

	function mod:GloomHatchlingAppliedOnBoss(args)
		stacks = args.amount or 1
		if not scheduled then
			scheduled = self:ScheduleTimer("GloomHatchlingStacksMessage", 2)
		end
	end
end

function mod:Gorge(args)
	self:StopBar(CL.count:format(args.spellName, gorgeCount))
	self:Message(args.spellId, "purple", CL.casting:format(CL.count:format(args.spellName, gorgeCount)))
	self:PlaySound(args.spellId, "alert")
	gorgeCount = gorgeCount + 1
	self:Bar(args.spellId, timers[3][args.spellId][gorgeCount], CL.count:format(args.spellName, gorgeCount))
end

do
	local minTauntAmount = 4
	function mod:GorgeApplied(args)
		if self:Tank() then
			local amount = args.amount or 1
			if amount % 2 == 1 or amount >= minTauntAmount then
				self:StackMessage(443336, "purple", args.destName, amount, 1)
				if self:Me(args.destGUID) and amount >= minTauntAmount then
					self:PlaySound(443336, "alarm")
				elseif amount >= minTauntAmount then
					self:PlaySound(443336, "warning") -- Taunt?
				end
			end
		end
	end
end

function mod:CataclysmicEvolution(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm")
end
