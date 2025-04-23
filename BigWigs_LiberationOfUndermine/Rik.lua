
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Rik Reverb", 2769, 2641)
if not mod then return end
mod:RegisterEnableMob(228648)
mod:SetEncounterID(3011)
mod:SetRespawnTime(30)
mod:SetStage(1)

--[[

Amplification             ability.id=473748 and type="begincast"
EchoingChant              ability.id=466866 and type="cast"
SoundCannon               ability.id=469380 and type="applydebuff"
FaultyZap                 ability.id=466979 and type="begincast" // ability.id=467108 and type="applydebuff"
SparkblastIgnition        ability.id=1214688 and type="summon"

Haywire                   ability.id=466093 and type="applybuff"

SoundCloud                ability.id=1213817 and type IN ("applybuff", "removebuff") or (ability.id=473655 and type="begincast")
BlaringDrop               ability.id=473260 and type="cast"

--]]

--------------------------------------------------------------------------------
-- Locals
--

local amplificationCount = 1
local echoingChantCount = 1
local soundCannonCount = 1
local faultyZapCount = 1
local sparkblastIgnitionCount = 1
local soundCloudCount = 1
local blaringDropCount = 1

local fullAmplificationCount = 1
local fullEchoingChantCount = 1
local fullSoundCannonCount = 1
local fullFaultyZapCount = 1
local fullSparkblastIgnitionCount = 1

local mobCollector = {}
local mobMarks = {}

local timersNormal = {
	[473748] = { 9.7, 40.3, 38.9, 0 }, -- Amplification!
	[466866] = { 24.5, 58.5, 28.5, 0 }, -- Echoing Chant
	[467606] = { 32.0, 35.0, 0 }, -- Sound Cannon
	[466979] = { 43.5, 31.5, 26.5, 0 }, -- Faulty Zap
}
local timersHeroic = {
	[473748] = { 10.9, 39.6, 39.2, 0 }, -- Amplification!
	[466866] = { 24.6, 58.5, 0 }, -- Echoing Chant
	[467606] = { 32.1, 35.0, 0 }, -- Sound Cannon
	[466979] = { 43.5, 31.5, 26.0, 0 }, -- Faulty Zap
	-- [472306] = { 20.5, 39.5, 43.2, 0 }, -- Sparkblast Ignition (USCS)
	[472306] = { 25.0, 39.5, 43.2, 0 }, -- Sparkblast Ignition (Summon)
}
local timersMythic = {
	[473748] = { 11.0, 40.0, 39.0, 0 }, -- Amplification!
	[466866] = { 24.5, 39.0, 0 }, -- Echoing Chant
	[467606] = { 32.0, 35.0, 0 }, -- Sound Cannon
	[466979] = { 43.5, 31.5, 26.0, 0 }, -- Faulty Zap
	-- [472306] = { 20.5, 59.0, 21.5, 0 }, -- Sparkblast Ignition (USCS)
	[472306] = { 25.0, 59.0, 21.5, 0 }, -- Sparkblast Ignition (Summon)
}
local timers = mod:Easy() and timersNormal or mod:Mythic() and timersMythic or timersHeroic

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.amp_spawn = "Amps Spawn"
	L.amp_spawn_desc = "Show an additional message and bar for when the Amplifiers appear."
	L.amp_spawn_icon = "inv_111_statsoundwaveemitter_blackwater"
	L.amp_spawn_bar = L.amp_spawn
	L.amp_spawn_message = "Amps spawning"

	L.echoing_chant = "Dodges"
	L.sparkblast_ignition = CL.adds -- "Pyrotechnics"
end

--------------------------------------------------------------------------------
-- Initialization
--

local amplifierMarker = mod:AddMarkerOption(false, "npc", 1, -31087, 1, 2, 3, 4, 5, 6, 7, 8)
function mod:GetOptions()
	return {
		amplifierMarker,

		-- Stage One: Party Starter
		{473748, "COUNTDOWN"}, -- Amplification!
		"amp_spawn",
			1217122, -- Lingering Voltage
			468119, -- Resonant Echoes (Damage)
				1214598, -- Entranced!
			-- 465795, -- Noise Pollution
			466093, -- Haywire
		466866, -- Echoing Chant
		467606, -- Sound Cannon "SAY", "SAY_COUNTDOWN"
		466979, -- Faulty Zap
		472306, -- Sparkblast Ignition
			-- 472294, -- Grand Finale
			1214164, -- Excitement
		-- 466128, -- Resonance XXX should add a tank warning
		464518, -- Tinnitus

		-- Stage Two: Hype Hustle
		{1213817, "CASTBAR"}, -- Sound Cloud
		473260, -- Blaring Drop
		{473655, "CASTBAR"}, -- Hype Fever!
	},{
		[473748] = -31656, -- Stage 1
		[1213817] = -31655, -- Stage 2
	},{
		["amp_spawn"] = {nil, "amp_spawn_message", "amp_spawn_bar"},
		[466866] = L.echoing_chant,
		[472306] = L.sparkblast_ignition,
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")

	self:Log("SPELL_CAST_START", "Amplification", 473748)
	self:Log("SPELL_AURA_APPLIED", "LingeringVoltageApplied", 1217122)
	self:Log("SPELL_AURA_APPLIED_DOSE", "LingeringVoltageApplied", 1217122)
	self:Log("SPELL_AURA_APPLIED", "ResonantEchoesApplied", 468119)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ResonantEchoesApplied", 468119)
	self:Log("SPELL_AURA_APPLIED", "EntrancedApplied", 1214598)
	self:Log("SPELL_AURA_APPLIED", "HaywireApplied", 466093)
	self:Log("SPELL_CAST_SUCCESS", "EchoingChant", 466866)
	self:Log("SPELL_CAST_START", "SoundCannon", 467606)
	self:Log("SPELL_AURA_APPLIED", "SoundCannonApplied", 469380)
	self:Log("SPELL_AURA_REMOVED", "SoundCannonRemoved", 469380)
	self:Log("SPELL_CAST_SUCCESS", "SoundCannonSuccess", 467606)
	self:Log("SPELL_CAST_START", "FaultyZap", 466979)
	self:Log("SPELL_AURA_APPLIED", "FaultyZapApplied", 467108) -- pre debuffs
	self:Log("SPELL_SUMMON", "PyrotechnicsSpawn", 1214688) -- Sparkblast Ignition
	self:Log("SPELL_AURA_APPLIED", "ExcitementApplied", 1214164)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ExcitementApplied", 1214164)
	self:Log("SPELL_AURA_APPLIED", "TinnitusApplied", 464518)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TinnitusApplied", 464518)

	-- Stage Two: Hype Hustle
	self:Log("SPELL_AURA_APPLIED", "SoundCloudApplied", 1213817)
	self:Log("SPELL_AURA_REMOVED", "SoundCloudRemoved", 1213817)
	self:Log("SPELL_CAST_SUCCESS", "BlaringDrop", 473260)
	self:Log("SPELL_CAST_START", "HypeFever", 473655)
	self:Log("SPELL_CAST_SUCCESS", "HypeFeverSuccess", 473655)

	timers = self:Easy() and timersNormal or self:Mythic() and timersMythic or timersHeroic
end

function mod:OnEngage()
	self:SetStage(1)

	amplificationCount = 1
	echoingChantCount = 1
	soundCannonCount = 1
	faultyZapCount = 1
	sparkblastIgnitionCount = 1
	soundCloudCount = 1

	-- these are on the bars
	fullAmplificationCount = 1
	fullEchoingChantCount = 1
	fullSoundCannonCount = 1
	fullFaultyZapCount = 1
	fullSparkblastIgnitionCount = 1

	mobCollector = {}
	mobMarks = {}

	self:CDBar(473748, timers[473748][amplificationCount], CL.count:format(self:SpellName(473748), fullAmplificationCount)) -- Amplification!
	if not self:Easy() then
		self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	end
	self:Bar(466866, timers[466866][echoingChantCount], CL.count:format(self:SpellName(466866), fullEchoingChantCount)) -- Echoing Chant
	self:Bar(467606, timers[467606][soundCannonCount], CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:Bar(466979, timers[466979][faultyZapCount], CL.count:format(self:SpellName(466979), fullFaultyZapCount)) -- Faulty Zap
	self:Bar(1213817, 121, CL.count:format(self:SpellName(1213817), soundCloudCount)) -- Sound Cloud

	if self:GetOption(amplifierMarker) and not self:Mythic() then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	-- remove marks for removed amps
	for icon = 1, 8 do
		local guid = mobMarks[icon]
		if guid and not self:UnitTokenFromGUID(guid) then
			mobMarks[icon] = nil
		end
	end

	for i = 2, 9 do
		local unit = ("boss%d"):format(i)
		local guid = self:UnitGUID(unit)
		if guid then
			local mobId = self:MobId(guid)
			if mobId == 230197 and not mobCollector[guid] then -- Amplifier
				mobCollector[guid] = true
				for icon = 1, 8 do
					if not mobMarks[icon] then
						mobMarks[icon] = guid
						self:CustomIcon(amplifierMarker, unit, icon)
						break
					end
				end
			end
		end
	end
end

-- Stage One: Party Starter

function mod:UNIT_SPELLCAST_SUCCEEDED(_, unit, _, spellId)
	if spellId == 1216111 then -- Amplification!
		self:StopBar(CL.count:format(L.amp_spawn_bar, fullAmplificationCount))
		self:Message("amp_spawn", "yellow", CL.count:format(L.amp_spawn_message, fullAmplificationCount), L.amp_spawn_icon)
		self:PlaySound("amp_spawn", "info") -- spawning amplifiers
	-- elseif spellId == 472306 then  -- Sparkblast Ignition
	-- 	self:StopBar(CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount))
	-- 	self:Message(472306, "cyan", CL.incoming:format(CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount)))
	-- 	self:PlaySound(472306, "info") -- adds
	-- 	sparkblastIgnitionCount = sparkblastIgnitionCount + 1
	-- 	fullSparkblastIgnitionCount = fullSparkblastIgnitionCount + 1
	-- 	self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount))
	end
end

function mod:Amplification(args)
	self:StopBar(CL.count:format(args.spellName, fullAmplificationCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, fullAmplificationCount))
	self:PlaySound(args.spellId, "alert") -- dropping amplifiers
	amplificationCount = amplificationCount + 1
	fullAmplificationCount = fullAmplificationCount + 1

	local cd = timers[args.spellId][amplificationCount]
	self:CDBar(args.spellId, cd, CL.count:format(args.spellName, fullAmplificationCount))
	if cd and cd > 0 then
		self:Bar("amp_spawn", cd - 5, CL.count:format(L.amp_spawn_bar, fullAmplificationCount), L.amp_spawn_icon)
	end
end

function mod:LingeringVoltageApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		local tooHigh = 100 -- XXX Check what is high enough
		if amount % 2 == 1 or amount > tooHigh then
			self:StackMessage(args.spellId, "blue", args.destName, amount, tooHigh)
			if amount > tooHigh then
				self:PlaySound(args.spellId, "alarm") -- watch stacks
			end
		end
	end
end

function mod:ResonantEchoesApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 1)
		if self:Easy() then -- Warning sound in heroic+ from Entranced!
			self:PlaySound(args.spellId, "alarm") -- watch stacks
		end
	end
end

function mod:EntrancedApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "warning") -- lured in
	end
end

function mod:HaywireApplied(args)
	if self:GetStage() == 1 then
		local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags)) or ""
		self:Message(args.spellId, "red", args.spellName .. icon)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:EchoingChant(args)
	self:StopBar(CL.count:format(args.spellName, fullEchoingChantCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, fullEchoingChantCount))
	self:PlaySound(args.spellId, "alert") -- watch amplifiers
	echoingChantCount = echoingChantCount + 1
	fullEchoingChantCount = fullEchoingChantCount + 1

	local cd = timers[args.spellId][echoingChantCount]
	self:Bar(args.spellId, cd, CL.count:format(args.spellName, fullEchoingChantCount))
end

function mod:SoundCannon(args)
	self:StopBar(CL.count:format(args.spellName, fullSoundCannonCount))
	self:Bar(args.spellId, timers[args.spellId][soundCannonCount+1], CL.count:format(args.spellName, fullSoundCannonCount+1))
end

function mod:SoundCannonApplied(args)
	self:TargetMessage(467606, "red", args.destName, CL.count:format(self:SpellName(467606), fullSoundCannonCount))
	self:TargetBar(467606, 5, args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(467606, "warning")
		-- if self:Mythic() then -- soak
		-- 	self:Yell(467606, nil, nil, "Sound Cannon")
		-- 	self:YellCountdown(467606, 5)
		-- else -- avoid
		-- 	self:Say(467606, nil, nil, "Sound Cannon")
		-- 	self:SayCountdown(467606, 5)
		-- end
	else
		self:PlaySound(467606, "alert", nil, args.destName) -- avoid / soak
	end
end

function mod:SoundCannonRemoved(args)
	self:StopBar(467606, args.destName)
	-- if self:Me(args.destGUID) then
	-- 	if self:Mythic() then
	-- 		self:CancelYellCountdown(467606)
	-- 	else
	-- 		self:CancelSayCountdown(467606)
	-- 	end
	-- end
end

function mod:SoundCannonSuccess(args)
	-- increase count here incase of re-casting
	soundCannonCount = soundCannonCount + 1
	fullSoundCannonCount = fullSoundCannonCount + 1
end

function mod:FaultyZap(args)
	self:StopBar(CL.count:format(args.spellName, fullFaultyZapCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, fullFaultyZapCount))
	-- self:PlaySound(args.spellId, "alert")
	faultyZapCount = faultyZapCount + 1
	fullFaultyZapCount = fullFaultyZapCount + 1
	self:Bar(args.spellId, timers[args.spellId][faultyZapCount], CL.count:format(args.spellName, fullFaultyZapCount))
end

function mod:FaultyZapApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(466979)
		self:PlaySound(466979, "alarm")
	end
end

do
	local prev = 0
	function mod:PyrotechnicsSpawn(args)
		if args.time - prev > 3 then
			prev = args.time
			self:StopBar(CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount))
			self:Message(472306, "cyan", CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount))
			self:PlaySound(472306, "info") -- adds
			sparkblastIgnitionCount = sparkblastIgnitionCount + 1
			fullSparkblastIgnitionCount = fullSparkblastIgnitionCount + 1
			self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount))
		end
	end
end

function mod:ExcitementApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 2 == 1 then
			self:Message(args.spellId, "green", CL.stackyou:format(amount, args.spellName))
			self:PlaySound(args.spellId, "info") -- buffs!
		end
	end
end

function mod:TinnitusApplied(args)
	if self:Tank() and self:Tank(args.destName) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "purple", args.destName, amount, 0)
		if amount > 5 and amount % 2 == 0 then -- 6, 8...
			self:PlaySound(args.spellId, "warning") -- swap?
		end
	elseif self:Me(args.destGUID) then -- Not a tank
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 0)
		self:PlaySound(args.spellId, "warning")
	end
end

-- Stage Two: Hype Hustle

function mod:SoundCloudApplied(args)
	if self:GetStage() == 3 then return end
	self:StopBar(CL.count:format(args.spellName, soundCloudCount))
	self:StopBar(CL.count:format(L.amp_spawn_bar, fullAmplificationCount))
	self:StopBar(CL.count:format(self:SpellName(473748), fullAmplificationCount)) -- Amplification!
	self:StopBar(CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	self:StopBar(CL.count:format(self:SpellName(466866), fullEchoingChantCount)) -- Echoing Chant
	self:StopBar(CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:StopBar(CL.count:format(self:SpellName(466979), fullFaultyZapCount)) -- Faulty Zap

	self:SetStage(2)
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, soundCloudCount))
	self:PlaySound(args.spellId, "long") -- stage 2
	soundCloudCount = soundCloudCount + 1
	if soundCloudCount < 3 then
		self:CastBar(args.spellId, self:Mythic() and 28 or 32)
	end

	blaringDropCount = 1

	self:Bar(473260, self:Mythic() and 5.3 or 6.3, CL.count:format(self:SpellName(473260), blaringDropCount))
end

function mod:SoundCloudRemoved(args)
	if self:GetStage() == 3 then return end
	self:StopCastBar(args.spellId)

	self:SetStage(1)
	self:Message(args.spellId, "cyan", CL.removed:format(args.spellName))
	self:PlaySound(args.spellId, "long") -- stage 1
	if soundCloudCount < 3 then
		self:Bar(args.spellId, 120.0, CL.count:format(args.spellName, soundCloudCount))
	else
		self:Bar(473655, 115.0) -- third cast -> Hype Fever
	end

	amplificationCount = 1
	echoingChantCount = 1
	soundCannonCount = 1
	faultyZapCount = 1
	sparkblastIgnitionCount = 1

	self:CDBar(473748, timers[473748][amplificationCount], CL.count:format(self:SpellName(473748), fullAmplificationCount)) -- Amplification!
	if not self:Easy() then
		self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	end
	self:Bar(466866, timers[466866][echoingChantCount], CL.count:format(self:SpellName(466866), fullEchoingChantCount)) -- Echoing Chant
	self:Bar(467606, timers[467606][soundCannonCount], CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:Bar(466979, timers[466979][faultyZapCount], CL.count:format(self:SpellName(466979), fullFaultyZapCount)) -- Faulty Zap
end

function mod:BlaringDrop(args)
	self:StopBar(CL.count:format(args.spellName, blaringDropCount))
	if soundCloudCount < 4 then
		self:Message(args.spellId, "red", CL.count_amount:format(args.spellName, blaringDropCount, 4))
	else
		self:Message(args.spellId, "red", CL.count:format(args.spellName, blaringDropCount))
	end
	self:PlaySound(args.spellId, "warning")
	blaringDropCount = blaringDropCount + 1
	if soundCloudCount < 4 and blaringDropCount < 5 then
		self:Bar(args.spellId, self:Mythic() and 7.0 or 8.0, CL.count:format(args.spellName, blaringDropCount))
	elseif soundCloudCount == 4 then
		self:Bar(args.spellId, 12.0, CL.count:format(args.spellName, blaringDropCount))
	end
end

function mod:HypeFever(args)
	self:StopBar(CL.count:format(args.spellName, soundCloudCount))
	self:StopBar(CL.count:format(L.amp_spawn_bar, fullAmplificationCount))
	self:StopBar(CL.count:format(self:SpellName(473748), fullAmplificationCount)) -- Amplification!
	self:StopBar(CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	self:StopBar(CL.count:format(self:SpellName(466866), fullEchoingChantCount)) -- Echoing Chant
	self:StopBar(CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:StopBar(CL.count:format(self:SpellName(466979), fullFaultyZapCount)) -- Faulty Zap

	self:SetStage(3)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 5)

	blaringDropCount = 1

	self:Bar(473260, 10.3, CL.count:format(self:SpellName(473260), blaringDropCount))
end

function mod:HypeFeverSuccess(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- enrage
end
