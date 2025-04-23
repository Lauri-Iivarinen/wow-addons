--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Bloodbound Horror", 2657, 2611)
if not mod then return end
mod:RegisterEnableMob(214502)
mod:SetEncounterID(2917)
mod:SetRespawnTime(30)
mod:SetStage(1)

-- Phase Buffs           ability IN (443612, 445570) and type IN ("applydebuff", "removedebuff")
-- InvokeTerrors         ability.id=444497 and type="cast"
-- GruesomeDisgorge      ability.id=444363 and type="begincast"
-- SpewingHemorrhage     ability.id=445936 and type="begincast"
-- Goresplatter          ability.id=442530 and type="begincast"
-- CrimsonRain           ability.id=443305 and type="applydebuff"
-- GraspFromBeyond       ability.id=443042 and type="applydebuff"
-- BlackSepsis           ability.id=438696 and type="cast"

-- BlackBulwark          ability.id=451288 and type="begincast"
-- SpectralSlam          ability.id=445016 and type="begincast"
-- ManifestHorror        ability.id=445174 and type="begincast"

-- Bloodcurdle           ability.id=452237 and type="begincast" or (ability.id=452245 and type IN ("applydebuff","removedebuff"))

--------------------------------------------------------------------------------
-- Locals
--

local invokeTerrorsCount = 1
local gruesomeDisgorgeCount = 1
local spewingHemorrhageCount = 1
local goresplatterCount = 1
local crimsonRainCount = 1
local graspFromBeyondCount = 1
local bloodcurdleCount = 1

local isBanefulShiftOnMe = false
local watcherCount = 0
local harbingerCount = 0
local markCollector = {}
local addMarks = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.stacks_onboss = "%dx %s on BOSS"

	L[443612 .. "_desc"] = "Inside The Unseeming."

	L.invoke_terrors = "New Adds"
	L.gruesome_disgorge_debuff = "Phase Shift"
	L.grasp_from_beyond = "Tentacles"
	L.bloodcurdle = "Spread"
	L.bloodcurdle_singular = "Spread"
	L.goresplatter = "Run Away"
end

--------------------------------------------------------------------------------
-- Initialization
--

local watcherMarker = mod:AddMarkerOption(false, "npc", 1, -29072, 8, 7) -- Lost Watcher
local harbingerMarker = mod:AddMarkerOption(false, "npc", 8, -29075, 1, 2, 3, 4, 5, 6) -- Forgotten Harbinger
function mod:GetOptions()
	return {
		444497, -- Invoke Terrors
		444363, -- Gruesome Disgorge
		443612, -- Gruesome Disgorge (Debuff)
		445570, -- Unseeming Blight
		{445936, "CASTBAR"}, -- Spewing Hemorrhage
		442530, -- Goresplatter
		443203, -- Crimson Rain
		{443042, "SAY", "ME_ONLY_EMPHASIZE"}, -- Grasp From Beyond
		445518, -- Black Blood
		438696, -- Black Sepsis

		-- The Unseeming
		-29072, -- Lost Watcher
		watcherMarker,
		{451288, "NAMEPLATE"}, -- Black Bulwark
		{445016, "TANK", "NAMEPLATE"}, -- Spectral Slam
		-29075, -- Forgotten Harbinger
		harbingerMarker,
		445272, -- Blood Pact

		-- Mythic
		452237, -- Bloodcurdle
	},{
		[-29072] = 462306, -- The Unseeming
		[452237] = "mythic",
	},{
		[444497] = L.invoke_terrors, -- (New Adds)
		[444363] = CL.frontal_cone, -- Gruesome Disgorge (Frontal Cone)
		[443612] = L.gruesome_disgorge_debuff, -- Gruesome Disgorge (Phase Shift)
		[445936] = CL.beams, -- Spewing Hemorrhage (Beams)
		[442530] = L.goresplatter, -- Goresplatter (Run Away)
		[443042] = L.grasp_from_beyond, -- Grasp From Beyond (Tentacles)
		[452237] = {L.bloodcurdle, "bloodcurdle_singular"}, -- Bloodcurdle (Spread)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "InvokeTerrors", 444497)
	-- Phase One: The Black Blood
	self:Log("SPELL_CAST_START", "GruesomeDisgorge", 444363)
	self:Log("SPELL_AURA_APPLIED", "BanefulShiftApplied", 443612)
	self:Log("SPELL_AURA_REMOVED", "BanefulShiftRemoved", 443612)
	self:Log("SPELL_AURA_APPLIED", "UnseemingBlightApplied", 445570)
	self:Log("SPELL_AURA_REMOVED", "UnseemingBlightRemoved", 445570)
	self:Log("SPELL_CAST_START", "SpewingHemorrhage", 445936)
	self:Log("SPELL_CAST_START", "Goresplatter", 442530)
	self:Log("SPELL_AURA_APPLIED", "CrimsonRainApplied", 443305)
	self:Log("SPELL_AURA_REMOVED", "CrimsonRainRemoved", 443305)
	self:Log("SPELL_AURA_APPLIED", "GraspFromBeyondApplied", 443042)
	self:Log("SPELL_AURA_APPLIED", "BlackBloodDamage", 445518)
	self:Log("SPELL_PERIODIC_DAMAGE", "BlackBloodDamage", 445518)
	self:Log("SPELL_PERIODIC_MISSED", "BlackBloodDamage", 445518)
	self:Log("SPELL_CAST_SUCCESS", "BlackSepsis", 438696)

	-- Phase Two: The Unseeming
	self:Log("SPELL_SUMMON", "LostWatcherSummon", 444830)
	self:Death("LostWatcherDeath", 221667)
	self:Log("SPELL_CAST_START", "BlackBulwark", 451288)
	self:Log("SPELL_CAST_START", "SpectralSlam", 445016)

	self:Log("SPELL_SUMMON", "ForgettenHarbingerSummon", 444835)
	self:Death("ForgottenHarbingerDeath", 221945)
	-- self:Log("SPELL_CAST_START", "ManifestHorror", 445174)
	self:Log("SPELL_AURA_APPLIED", "BloodPactApplied", 445272)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BloodPactApplied", 445272)

	-- Mythic
	self:Log("SPELL_CAST_START", "Bloodcurdle", 452237)
	self:Log("SPELL_AURA_APPLIED", "BloodcurdleApplied", 452245)
	self:Log("SPELL_AURA_REMOVED", "BloodcurdleRemoved", 452245)
end

function mod:OnEngage()
	invokeTerrorsCount = 1
	gruesomeDisgorgeCount = 1
	spewingHemorrhageCount = 1
	goresplatterCount = 1
	crimsonRainCount = 1
	graspFromBeyondCount = 1
	bloodcurdleCount = 1

	isBanefulShiftOnMe = false
	watcherCount = 0
	harbingerCount = 0
	markCollector = {}
	addMarks = {}

	self:Bar(444497, self:Mythic() and 3 or 5, CL.count:format(self:SpellName(444497), invokeTerrorsCount)) -- Invoke Terrors
	self:Bar(443203, 11.6, CL.count:format(self:SpellName(443203), crimsonRainCount)) -- Crimson Rain
	self:Bar(444363, self:Mythic() and 14 or 16, CL.count:format(self:SpellName(444363), gruesomeDisgorgeCount)) -- Gruesome Disgorge
	self:Bar(443042, self:Mythic() and 19 or 22, CL.count:format(self:SpellName(443042), graspFromBeyondCount)) -- Grasp From Beyond
	if not self:Easy() then
		self:Bar(445936, 32, CL.count:format(self:SpellName(445936), spewingHemorrhageCount)) -- Spewing Hemorrhage
	end
	self:Bar(442530, 120, CL.count:format(self:SpellName(442530), goresplatterCount)) -- Goresplatter
	if self:Mythic() then
		self:Bar(452237, 9, CL.count:format(self:SpellName(452237), bloodcurdleCount)) -- Bloodcurdle
	end

	if self:GetOption(watcherMarker) or self:GetOption(harbingerMarker) then
		self:RegisterTargetEvents("AddMarking")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:InvokeTerrors(args)
	self:StopBar(CL.count:format(args.spellName, invokeTerrorsCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, invokeTerrorsCount))
	self:PlaySound(args.spellId, "info") -- adds
	invokeTerrorsCount = invokeTerrorsCount + 1

	local cd
	if self:Mythic() then
		cd = invokeTerrorsCount % 2 == 0 and 59 or 69
	else
		cd = invokeTerrorsCount % 2 == 0 and 51 or 77
	end
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, invokeTerrorsCount))
end

function mod:AddMarking(_, unit, guid)
	local icon = markCollector[guid] -- icon order from SPELL_SUMMON
	if icon then
		if self:MobId(guid) == 221667 then -- Lost Watcher
			self:CustomIcon(harbingerMarker, unit, icon)
		elseif self:MobId(guid) == 221945 then -- Forgotten Harbinger
			self:CustomIcon(watcherMarker, unit, icon)
		end
		markCollector[guid] = nil
	end
end

function mod:LostWatcherSummon(args)
	watcherCount = watcherCount + 1
	for i = 8, 7, -1 do
		if not markCollector[args.destGUID] and not addMarks[i] then
			addMarks[i] = args.destGUID
			markCollector[args.destGUID] = i
			return
		end
	end
end

function mod:ForgettenHarbingerSummon(args)
	harbingerCount = harbingerCount + 1
	for i = 1, 6, 1 do
		if not markCollector[args.destGUID] and not addMarks[i] then
			addMarks[i] = args.destGUID
			markCollector[args.destGUID] = i
			return
		end
	end
end

function mod:LostWatcherDeath(args)
	self:StopNameplate(451288, args.destGUID) -- Black Bulwark
	self:StopNameplate(445016, args.destGUID) -- Spectral Slam

	watcherCount = math.max(watcherCount - 1, 0)
	if watcherCount > 0 then
		self:Message(-29072, "green", CL.mob_remaining:format(self:SpellName(-29072), watcherCount), false)
	else
		self:Message(-29072, "green", CL.killed:format(self:SpellName(-29072)), false)
	end
	self:PlaySound(-29072, "info")
	local icon = markCollector[args.destGUID]
	if icon then
		addMarks[icon] = nil
	end
end

function mod:ForgottenHarbingerDeath(args)
	harbingerCount = math.max(harbingerCount - 1, 0)
	self:Message(-29075, "green", CL.mob_remaining:format(self:SpellName(-29075), harbingerCount), false)
	self:PlaySound(-29075, "info")
	local icon = markCollector[args.destGUID]
	if icon then
		addMarks[icon] = nil
	end
end

-- Phase One: The Black Blood
function mod:GruesomeDisgorge(args)
	self:StopBar(CL.count:format(args.spellName, gruesomeDisgorgeCount))
	self:Message(args.spellId, "purple", CL.count:format(args.spellName, gruesomeDisgorgeCount))
	self:PlaySound(args.spellId, "alert") -- frontal cone
	gruesomeDisgorgeCount = gruesomeDisgorgeCount + 1

	local cd
	if self:Mythic() then
		cd = gruesomeDisgorgeCount % 2 == 0 and 59 or 69
	else
		cd = gruesomeDisgorgeCount % 2 == 0 and 51 or 77
	end
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, gruesomeDisgorgeCount))
end

function mod:BanefulShiftApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
		self:TargetBar(args.spellId, 40, args.destName)
		isBanefulShiftOnMe = true
	end
end

function mod:BanefulShiftRemoved(args)
	if self:Me(args.destGUID) then
		isBanefulShiftOnMe = false
	end
end

function mod:UnseemingBlightApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:UnseemingBlightRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "green", CL.removed:format(args.spellName))
		-- self:PlaySound(args.spellId, "info")
	end
end

function mod:SpewingHemorrhage(args)
	self:StopBar(CL.count:format(args.spellName, spewingHemorrhageCount))
	self:Message(args.spellId, "red", CL.count:format(args.spellName, spewingHemorrhageCount))
	self:PlaySound(args.spellId, "alarm")  -- run out
	self:CastBar(args.spellId, 26)
	spewingHemorrhageCount = spewingHemorrhageCount + 1

	local cd
	if self:Mythic() then
		cd = spewingHemorrhageCount % 2 == 0 and 59 or 69
	else
		cd = spewingHemorrhageCount % 2 == 0 and 49 or 79
	end
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, spewingHemorrhageCount))
end

function mod:Goresplatter(args)
	self:StopBar(CL.count:format(args.spellName, goresplatterCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, goresplatterCount))
	self:PlaySound(args.spellId, "warning") -- spread
	goresplatterCount = goresplatterCount + 1
	self:Bar(args.spellId, 128, CL.count:format(args.spellName, goresplatterCount))
end

do
	local prev = 0
	local rainOnMe = false
	function mod:CrimsonRainApplied(args)
		if args.time - prev > 10 then
			prev = args.time
			self:StopBar(CL.count:format(args.spellName, crimsonRainCount))
			crimsonRainCount = crimsonRainCount + 1
			self:Bar(443203, crimsonRainCount % 4 == 1 and 38 or 30, CL.count:format(args.spellName, crimsonRainCount))
		end
		if self:Me(args.destGUID) and not rainOnMe then
			rainOnMe = true
			self:PersonalMessage(443203)
			self:PlaySound(443203, "alert")
		end
	end
	function mod:CrimsonRainRemoved(args)
		if self:Me(args.destGUID) then
			rainOnMe = false
		end
	end
end

do
	local prev = 0
	function mod:GraspFromBeyondApplied(args)
		if args.time - prev > 3 then
			prev = args.time
			self:StopBar(CL.count:format(args.spellName, graspFromBeyondCount))
			self:Message(args.spellId, "yellow", CL.count:format(args.spellName, graspFromBeyondCount))
			graspFromBeyondCount = graspFromBeyondCount + 1

			local cd
			if self:Mythic() then
				local timer = {28, 41, 28, 31} -- 41.2, 27.8, 31.1, 27.9
				cd = timer[graspFromBeyondCount % 4 + 1]
			elseif self:Easy() then
				-- 22.1, 15.0, 15.0, 21.0, 15.0, 15.0, 47.1, 15.0, 15.0, 21.0, 15.1, 15.0, 47.0, 15.0, 15.0, 21.0, 15.0, 15.0
				cd = (graspFromBeyondCount - 1) % 6 == 0 and 47 or graspFromBeyondCount % 3 == 1 and 21 or 15
			else
				cd = graspFromBeyondCount % 5 == 0 and 44 or 28
			end
			self:Bar(args.spellId, cd, CL.count:format(args.spellName, graspFromBeyondCount))
		end
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId)
			self:PlaySound(args.spellId, "warning")
			self:Say(args.spellId, L.grasp_from_beyond, nil, "Tentacles")
			-- self:SayCountdown(args.spellId, 12)
		end
	end
end

do
	local prev = 0
	function mod:BlackBloodDamage(args)
		if self:Me(args.destGUID) and args.time-prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:BlackSepsis(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning") -- tankcast
end

-- Phase Two: The Unseeming

function mod:BlackBulwark(args)
	if not isBanefulShiftOnMe then return end
	local canDo, ready = self:Interrupter(args.sourceGUID)
	if canDo then
		self:Message(args.spellId, "yellow")
		if ready then
			self:PlaySound(args.spellId, "alert") -- interrupt
		end
	end
	self:Nameplate(args.spellId, 17, args.destGUID) -- 17.1, 23.0 / 17.4, 16.1 / 17.9, 20.7 / 18.1, 18.2, 24.4, 18.2
end

function mod:SpectralSlam(args)
	if not isBanefulShiftOnMe then return end
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "alarm") -- tankcast
	self:Nameplate(args.spellId, 20, args.destGUID) -- 27.6, 19.9 / 22.3 / 27.6 / 24.1, 23.1
end

do
	local stacks = 0
	local scheduled = nil
	function mod:BloodPactMessage()
		self:Message(445272, "red", L.stacks_onboss:format(stacks, self:SpellName(445272)))
		self:PlaySound(445272, "alarm") -- fail
		scheduled = nil
	end

	function mod:BloodPactApplied(args)
		stacks = args.amount or 1
		if not scheduled then
			scheduled = self:ScheduleTimer("BloodPactMessage", 2)
		end
	end
end

-- Mythic

function mod:Bloodcurdle(args)
	self:StopBar(CL.count:format(args.spellName, bloodcurdleCount))
	self:Message(args.spellId, "orange", CL.casting:format(CL.count:format(args.spellName, bloodcurdleCount)))
	bloodcurdleCount = bloodcurdleCount + 1

	local timer = {32, 37, 32, 27} -- 37.1, 32.0, 27.0, 32.0
	self:Bar(args.spellId, timer[bloodcurdleCount % 4 + 1], CL.count:format(args.spellName, bloodcurdleCount))
end

function mod:BloodcurdleApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(452237, nil, L.bloodcurdle_singular)
		self:PlaySound(452237, "alarm") -- spread
		self:TargetBar(452237, 5, args.destName, L.bloodcurdle_singular)
	end
end

function mod:BloodcurdleRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(L.bloodcurdle_singular, args.destName)
	end
end
