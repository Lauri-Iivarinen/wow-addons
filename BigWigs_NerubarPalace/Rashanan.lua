--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Rasha'nan", 2657, 2609)
if not mod then return end
mod:RegisterEnableMob(214504)
mod:SetEncounterID(2918)
mod:SetRespawnTime(30)
mod:SetStage(1)
mod:SetPrivateAuraSounds({
	439790, -- Rolling Acid
	439815, -- Infested Spawn
	439783, -- Spinneret's Strands
})

-- SavageAssault         ability.id=444687 and type="begincast"

-- RollingAcid           ability.id=439789 and type="begincast"
-- InfestedSpawn         ability.id=455373 and type="begincast"
-- SpinneretsStrands     ability.id=439784 and type="begincast"
-- EnvelopingWebs        ability.id=454989 and type="begincast"

-- ErosiveSpray          ability.id=439811 and type="begincast"
-- CausticHail           ability.id=456853 and type="begincast" or type="interrupt"  //  ability.id=456762 and type="cast"
-- AcidicEruption        ability.id=452806 and type="begincast" and (ability.id=457877 and type IN ("applybuff", "removebuff"))
-- WebReave              ability.id=439795 and type="begincast"

--------------------------------------------------------------------------------
-- Locals
--

-- Counts are {totalCount, stageCount}
local rollingAcidCount = {1, 1}
local infestedSpawnCount = {1, 1}
local spinneretsStrandsCount = {1, 1}
local erosiveSprayCount = {1, 1}
local envelopingWebsCount = {1, 1}
local savageAssaultCount = 1
local causticHailCount = 1
local webReaveCount = 1
local canStartPhase = false

-- the stages are just segments of the fight with different cast sequences
-- grouping by spell id instead of stage to make copy pasta easier
local timersNormal = { -- 12:43
	[439789] = { -- Rolling Acid
		{43.4, 0},
		{18.4, 53.0, 0},
		{65.5, 0},
		{65.5, 0},
		{18.4, 53.0, 0},
		{44.0, 0},
	},
	[455373] = { -- Infested Spawn
		{62.5, 0},
		{41.5, 0},
		{15.9, 53.0, 0},
		{41.5, 0},
		{63.5, 0},
		{15.9, 53.0, 0},
	},
	[439784] = { -- Spinneret's Strands
		{14.8, 53.0, 0},
		{62.5, 0},
		{41.0, 0},
		{15.4, 53.0, 0},
		{41.0, 0},
		{62.5, 0},
		{15.4, 0},
	},
}
local timersHeroic = { -- 10:26
	[439789] = { -- Rolling Acid
		{41.4, 0},
		{16.7, 30.3, 19.7, 0},
		{61.2, 0},
		{61.2, 0},
		{16.8, 29.7, 20.3, 0},
		{42.0, 0},
	},
	[455373] = { -- Infested Spawn
		{59.2, 0},
		{40.5, 0},
		{15.3, 29.7, 20.3, 0},
		{40.5, 0},
		{59.7, 0},
		{15.3, 29.8, 20.2, 0},
	},
	[439784] = { -- Spinneret's Strands
		{14.2, 29.7, 20.2, 0},
		{59.2, 0},
		{40.0, 0},
		{14.7, 30.3, 19.7, 0},
		{40.0, 0},
		{59.3, 0},
	},
}
local timersMythic = { -- 6:36 (enrage)
	[439789] = { -- Rolling Acid
		{35.1, 0},
		{40.7, 0},
		{15.9, 0},
		{0},
		{20.7, 0},
		{0},
	},
	[455373] = { -- Infested Spawn
		{18.7, 0},
		{14.4, 0},
		{0},
		{14.3, 20.0, 0},
		{14.3, 24.8, 0},
		{19.1, 0},
	},
	[439784] = { -- Spinneret's Strands
		{14.2, 0},
		{33.8, 0},
		{18.7, 15.2, 0},
		{18.7, 0},
		{0},
		{13.9, 20.0, 0},
	},
	[454989] = { -- Enveloping Webs
		{38.1, 0},
		{18.6, 0},
		{38.6, 0},
		{38.6, 0},
		{33.9, 0},
		{38.6, 0},
	},
}
local timers = mod:Mythic() and timersMythic or mod:Easy() and timersNormal or timersHeroic

local function cd(spellId, count)
	-- not knowing the full fight sequence makes normal table lookups sketchy without metatables
	local stage = mod:GetStage()
	if type(count) == "table" then count = count[2] end
	return timers[spellId] and timers[spellId][stage] and timers[spellId][stage][count] or nil
end

local function inc(count)
	count[1] = count[1] + 1 -- total
	count[2] = count[2] + 1 -- stage
end

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.rolling_acid = "Waves"
	L.spinnerets_strands = "Strands"
	L.spinnerets_strands_say = "Strands"
	L.enveloping_webs = "Webs"
	L.enveloping_web_say = "Web" -- Singular of Webs
	L.erosive_spray = "Spray"
	L.caustic_hail = "Next Position"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- "stages",
		{439789, "PRIVATE"}, -- Rolling Acid
			439785, -- Corrosion
			439787, -- Acidic Stupor
			439776, -- Acid Pool (Damage)
		{455373, "PRIVATE"}, -- Infested Spawn
			455287, -- Infested Bite
		{439784, "PRIVATE"}, -- Spinneret's Strands
		{444687, "TANK_HEALER"}, -- Savage Assault
			{458067, "TANK"}, -- Savage Wound
		439811, -- Erosive Spray
		452806, -- Acidic Eruption
			457877, -- Acidic Carapace
		{439795, "CASTBAR"}, -- Web Reave
		456853, -- Caustic Hail
		439792, -- Tacky Burst

		-- Mythic
		454989, -- Enveloping Webs
	},{
		[454989] = "mythic",
	},{
		[439789] = L.rolling_acid, -- Rolling Acid (Waves)
		[455373] = CL.adds, -- Infested Spawn (Adds)
		[439784] = L.spinnerets_strands, -- Spinneret's Strands (Strands)
		[439795] = CL.soak, -- Web Reave (Soak)
		[439811] = L.erosive_spray, -- Erosive Spray (Spray)
		[454989] = L.enveloping_webs, -- Enveloping Webs (Webs)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "SavageAssault", 444687)
	self:Log("SPELL_AURA_APPLIED", "SavageWoundApplied", 458067)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SavageWoundApplied", 458067)
	self:Log("SPELL_CAST_START", "RollingAcid", 439789)
	self:Log("SPELL_AURA_APPLIED", "AcidicStuporApplied", 439787)
	self:Log("SPELL_AURA_APPLIED", "CorrosionApplied", 439785)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CorrosionApplied", 439785)
	self:Log("SPELL_CAST_START", "InfestedSpawn", 455373)
	self:Log("SPELL_AURA_APPLIED", "InfestedBiteApplied", 455287)
	self:Log("SPELL_AURA_APPLIED_DOSE", "InfestedBiteApplied", 455287)
	self:Log("SPELL_CAST_START", "SpinneretsStrands", 439784)
	self:Log("SPELL_CAST_START", "ErosiveSpray", 439811)
	self:Log("SPELL_CAST_SUCCESS", "TackyBurst", 439792)
	-- Mythic
	self:Log("SPELL_CAST_START", "EnvelopingWebs", 454989)
	self:Log("SPELL_AURA_APPLIED", "EnvelopingWebsApplied", 454991)

	-- Phase
	self:Log("SPELL_CAST_START", "CausticHail", 456853)
	self:Log("SPELL_CAST_SUCCESS", "CausticHailDone", 456762)
	self:Log("SPELL_CAST_START", "AcidicEruption", 452806)
	self:Log("SPELL_AURA_APPLIED", "AcidicCarapace", 457877)
	self:Log("SPELL_INTERRUPT", "AcidicEruptionInterrupted", 452806)
	self:Log("SPELL_CAST_START", "WebReave", 439795)
	-- Damage
	self:Log("SPELL_AURA_APPLIED", "AcidPoolDamage", 439776)
	self:Log("SPELL_PERIODIC_DAMAGE", "AcidPoolDamage", 439776)
	self:Log("SPELL_PERIODIC_MISSED", "AcidPoolDamage", 439776)
end

function mod:OnEngage()
	self:SetStage(1)
	timers = self:Mythic() and timersMythic or self:Easy() and timersNormal or timersHeroic

	rollingAcidCount = {1, 1}
	infestedSpawnCount = {1, 1}
	spinneretsStrandsCount = {1, 1}
	erosiveSprayCount = {1, 1}
	envelopingWebsCount = {1, 1}
	savageAssaultCount = 1
	causticHailCount = 1
	webReaveCount = 1
	canStartPhase = false

	self:Bar(444687, self:Mythic() and 5.6 or 10.5, CL.count:format(self:SpellName(444687), savageAssaultCount)) -- Savage Assault
	self:Bar(439811, self:Mythic() and 8.1 or 3.0, CL.count:format(self:SpellName(439811), erosiveSprayCount[1])) -- Erosive Spray
	self:Bar(439784, cd(439784, spinneretsStrandsCount), CL.count:format(self:SpellName(439784), spinneretsStrandsCount[1])) -- Spinneret's Strands
	self:Bar(439789, cd(439789, rollingAcidCount), CL.count:format(self:SpellName(439789), rollingAcidCount[1])) -- Rolling Acid
	self:Bar(455373, cd(455373, infestedSpawnCount), CL.count:format(self:SpellName(455373), infestedSpawnCount[1])) -- Infested Spawn
	self:Bar(456853, self:Mythic() and 56.7 or self:Easy() and 90.0 or 87, CL.count:format(self:SpellName(456853), causticHailCount)) -- Caustic Hail
	if self:Mythic() then
		self:Bar(454989, cd(454989, envelopingWebsCount), CL.count:format(self:SpellName(454989), envelopingWebsCount[1])) -- Enveloping Webs
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SavageAssault(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "info")
	savageAssaultCount = savageAssaultCount + 1

	local cd
	if self:Mythic() then
		if self:GetStage() == 1 then
			local timer = { 5.6, 22.6, 2.0, 12.9, 2.5 }
			cd = timer[savageAssaultCount]
		else
			local timer = { 9.8, 2.0, 18.0, 2.0, 11.8, 2.5 }
			cd = timer[savageAssaultCount]
		end
	elseif self:Heroic() then
		if self:GetStage() == 1 then
			local timer = { 10.5, 14.8, 23.1, 6.5, 14.8 }
			cd = timer[savageAssaultCount]
		else
			local timer = { 11.1, 14.8, 23.7, 5.9, 14.8, 3.7 }
			cd = timer[savageAssaultCount]
		end
	else -- Easy
		if self:GetStage() == 1 then
			local timer = { 10.9, 15.7, 23.6, 7.8, 15.7 }
			cd = timer[savageAssaultCount]
		else
			local timer = { 3.6, 7.8, 15.7, 23.5, 7.8, 15.7 }
			cd = timer[savageAssaultCount]
		end
	end
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, savageAssaultCount))
end

function mod:SavageWoundApplied(args)
	self:StackMessage(args.spellId, "purple", args.destName, args.amount, 1)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "alarm") -- On you
	end
end

function mod:RollingAcid(args)
	self:StopBar(CL.count:format(args.spellName, rollingAcidCount[1]))
	self:Message(args.spellId, "yellow", CL.casting:format(CL.count:format(args.spellName, rollingAcidCount[1])))
	-- self:PlaySound(args.spellId, "alert")
	inc(rollingAcidCount)
	if not self:LFR() then -- 1 per in lfr
		self:Bar(args.spellId, cd(args.spellId, rollingAcidCount), CL.count:format(args.spellName, rollingAcidCount[1]))
	end
end

function mod:AcidicStuporApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:CorrosionApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 3 == 0 then
			self:StackMessage(args.spellId, "blue", args.destName, amount, 3)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

function mod:InfestedSpawn(args)
	self:StopBar(CL.count:format(args.spellName, infestedSpawnCount[1]))
	self:Message(args.spellId, "cyan", CL.incoming:format(CL.count:format(args.spellName, infestedSpawnCount[1])))
	self:PlaySound(args.spellId, "info") -- adds
	inc(infestedSpawnCount)
	if not self:LFR() then -- 1 per in lfr
		self:Bar(args.spellId, cd(args.spellId, infestedSpawnCount), CL.count:format(args.spellName, infestedSpawnCount[1]))
	end
end

function mod:InfestedBiteApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 3 == 1 then
			self:StackMessage(args.spellId, "blue", args.destName, amount, 5)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

function mod:SpinneretsStrands(args)
	self:StopBar(CL.count:format(args.spellName, spinneretsStrandsCount[1]))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, spinneretsStrandsCount[1]))
	self:PlaySound(args.spellId, "alert")
	inc(spinneretsStrandsCount)
	if not self:LFR() then -- 1 per in lfr
		self:Bar(args.spellId, cd(args.spellId, spinneretsStrandsCount), CL.count:format(args.spellName, spinneretsStrandsCount[1]))
	end
end

function mod:ErosiveSpray(args)
	self:StopBar(CL.count:format(args.spellName, erosiveSprayCount[1]))
	if erosiveSprayCount[1] >= (self:Mythic() and 12 or self:Heroic() and 13 or 15) then -- soft enrage
		self:Message(args.spellId, "red", CL.count:format(args.spellName, erosiveSprayCount[1]))
		self:PlaySound(args.spellId, "long")
	else
		self:Message(args.spellId, "yellow", CL.count:format(args.spellName, erosiveSprayCount[1]))
		self:PlaySound(args.spellId, "alert")
	end
	inc(erosiveSprayCount)

	local cd = 0
	if self:GetStage() == 1 then -- 3 casts before the first move
		if self:Easy() then
			local timer = { 3.0, 31.4, 47.1 }
			cd = timer[erosiveSprayCount[2]]
		elseif self:Mythic() then
			if erosiveSprayCount[2] == 2 then -- only 2
				cd = 40.0
			end
		else
			local timer = { 3.0, 29.6, 44.4 }
			cd = timer[erosiveSprayCount[2]]
		end
	elseif erosiveSprayCount[2] == 2 then -- then 2 per
		cd = self:Mythic() and 25.0 or self:Easy() and 47.0 or 44.4
	end
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, erosiveSprayCount[1]))
end

function mod:TackyBurst(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- tank fail
end

function mod:EnvelopingWebs(args)
	self:StopBar(CL.count:format(args.spellName, envelopingWebsCount[1]))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, envelopingWebsCount[1]))
	self:PlaySound(args.spellId, "alarm") -- dodge
	inc(envelopingWebsCount)
	self:Bar(args.spellId, cd(args.spellId, envelopingWebsCount), CL.count:format(args.spellName, envelopingWebsCount[1]))
end

function mod:EnvelopingWebsApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(454989)
		self:PlaySound(454989, "alarm") -- fail
		-- self:Yell(454989, L.enveloping_web_say, nil, "Web") -- look at my shame
	end
end

-- Phase

function mod:CausticHail(args)

	self:StopBar(CL.count:format(args.spellName, causticHailCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, causticHailCount))
	self:PlaySound(args.spellId, "long")
	causticHailCount = causticHailCount + 1
	canStartPhase = false
end

function mod:CausticHailDone(args)
	-- done moving
	canStartPhase = true
end

function mod:AcidicEruption(args)
	local _, ready = self:Interrupter(args.sourceGUID)
	self:Message(args.spellId, "yellow")
	if ready then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:AcidicCarapace(args)
	self:Message(args.spellId, "cyan", CL.onboss:format(args.spellName))
	self:PlaySound(args.spellId, "info")
end

function mod:AcidicEruptionInterrupted(args)
	if args.extraSpellId == 452806 and canStartPhase then -- Acidic Eruption
		self:Message(452806, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
		self:PlaySound(452806, "info")
		local stage = self:GetStage() + 1
		self:SetStage(stage)

		-- reset stage counts
		rollingAcidCount[2] = 1
		infestedSpawnCount[2] = 1
		spinneretsStrandsCount[2] = 1
		erosiveSprayCount[2] = 1
		envelopingWebsCount[2] = 1
		savageAssaultCount = 1

		self:Bar(444687, self:Mythic() and 9.8 or 11.1, CL.count:format(self:SpellName(444687), savageAssaultCount)) -- Savage Assault
		self:Bar(439789, cd(439789, rollingAcidCount), CL.count:format(self:SpellName(439789), rollingAcidCount[1])) -- Rolling Acid
		self:Bar(455373, cd(455373, infestedSpawnCount), CL.count:format(self:SpellName(455373), infestedSpawnCount[1])) -- Infested Spawn
		self:Bar(439784, cd(439784, spinneretsStrandsCount), CL.count:format(self:SpellName(439784), spinneretsStrandsCount[1])) -- Spinneret's Strands
		if self:Mythic() then
			self:Bar(454989, cd(454989, envelopingWebsCount), CL.count:format(self:SpellName(454989), envelopingWebsCount[1])) -- Enveloping Webs
		end
		-- self:Bar(439795, 3.6, CL.count:format(self:SpellName(439795), webReaveCount)) -- Web Reave
		self:Bar(439811, self:Mythic() and 23.7 or self:Easy() and 35.0 or 33.3, CL.count:format(self:SpellName(439811), erosiveSprayCount[1])) -- Erosive Spray
		if not self:Mythic() or stage < 6 then -- XXX need to recheck other difficulties for enrage
			self:Bar(456853, self:Mythic() and 57.3 or self:Easy() and 90.5 or 87.0, CL.count:format(self:SpellName(456853), causticHailCount)) -- Caustic Hail
		end
	end
end

function mod:WebReave(args)
	self:StopBar(CL.count:format(args.spellName, webReaveCount))
	self:Message(args.spellId, "red", CL.casting:format(CL.count:format(args.spellName, webReaveCount)))
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 4, CL.count:format(args.spellName, webReaveCount))
	webReaveCount = webReaveCount + 1
end

-- Damage

do
	local prev = 0
	function mod:AcidPoolDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PlaySound(args.spellId, "underyou")
			self:PersonalMessage(args.spellId, "underyou")
		end
	end
end
