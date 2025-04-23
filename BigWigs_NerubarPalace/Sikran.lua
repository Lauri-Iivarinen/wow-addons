--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sikran, Captain of the Sureki", 2657, 2599)
if not mod then return end
mod:RegisterEnableMob(214503)
mod:SetEncounterID(2898)
mod:SetRespawnTime(30)
mod:SetStage(1)
mod:SetPrivateAuraSounds({
	433517, -- Phase Blades
	439191, -- Decimate
})

-- Expose                ability.id=432965 and type="begincast" or (ability.id IN (438845, 435410) and type IN ("applydebuff", "applydebuffstack"))
-- PhaseBlades           ability.id=433519 and type="begincast"
-- Decimate              ability.id=442428 and type="begincast"
-- RainOfArrows          ability.id=439559 and type="begincast"
-- ShatteringSweep       ability.id=456420 and type="begincast"

--------------------------------------------------------------------------------
-- Locals
--

local phaseBladesCount = 1
local decimateCount = 1
local shatteringSweepCount = 1
local captainsFlourishCount = 1
local rainOfArrowsCount = 1

local timersNormal = { -- 8:26
	[439511] = {6.4, 22.5, 23.1, 23.1, 25.8, 23.1, 23.0, 23.1, 29.1, 23.1, 23.0, 23.1, 28.1, 23.1, 23.0, 23.1, 29.2, 23.0, 23.0, 23.1, 29.1}, -- Captain's Flourish
	[433517] = {19.4, 46.2, 48.8, 42.5, 55.9, 42.5, 55.8, 42.5, 55.9, 42.4}, -- Phase Blades
	[442428] = {42.7, 39.1, 55.9, 38.0, 58.2, 40.1, 58.2, 40.0, 58.3, 40.0}, -- Decimate
	[439559] = {35.6, 52.3, 42.5, 53.4, 44.9, 53.4, 44.0, 53.4, 44.9, 53.4}, -- Rain of Arrows
}
local timersHeroic = { -- 5:22
	[439511] = {6.2, 23.2, 23.1, 22.7, 27.2, 23.1, 22.8, 23.1, 30.4, 23.1, 23.1, 23.1, 27.9, 22.7}, -- Captain's Flourish
	[433517] = {14.3, 45.5, 51.1, 42.3, 57.1, 42.5, 54.7}, -- Phase Blades
	[442428] = {42.5, 38.5, 59.7, 39.0, 58.3, 38.9}, -- Decimate
	[439559] = {35.4, 53.2, 43.0, 53.2, 44.9, 53.5}, -- Rain of Arrows
}
local timersMythic = { -- 8:08
	[439511] = {6.9, 25.8, 25.1, 25.7, 18.7, 28.1, 28.0, 27.1, 15.8, 28.1, 28.1, 27.3, 15.3, 28.2, 27.1, 28.0, 15.4, 28.1, 27.2, 28.0}, -- Captain's Flourish
	[433517] = {13.0, 27.3, 27.2, 42.1, 28.1, 28.2, 43.9, 28.2, 28.1, 41.6, 27.9, 28.0, 43.8, 28.0, 28.1}, -- Phase Blades
	[442428] = {51.2, 26.6, 75.6, 27.1, 72.0, 28.1, 70.8, 27.9, 70.7, 28.0}, -- Decimate
	[439559] = {22.8, 42.3, 55.5, 26.8, 27.1, 45.1, 27.0, 26.6, 45.5, 26.7, 26.7, 45.0, 26.9, 26.8}, -- Rain of Arrows
}
local timers = mod:Mythic() and timersMythic or mod:Easy() and timersNormal or timersHeroic

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L[434860 .. "_desc"] = "Players hit with Phase Blades have their healing received reduced by 50% and additional Shadow damage inflicted for 20 sec."
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{433517, "PRIVATE"}, -- Phase Blades
			434860, -- Phase Blades (Debuff)
		{442428, "PRIVATE"}, -- Decimate
			459273, -- Cosmic Shards
		456420, -- Shattering Sweep
		{439511, "TANK_HEALER"}, -- Captain's Flourish
			{438845, "TANK"}, -- Expose
			{432969, "TANK"}, -- Phase Lunge
		439559, -- Rain of Arrows
		-- Mythic
		461401, -- Collapsing Nova
	},{
		[461401] = "mythic",
	},{
		[439511] = CL.tank_combo,
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "PhaseBlades", 433475)
	self:Log("SPELL_AURA_APPLIED", "CosmicWoundApplied", 434860)
	self:Log("SPELL_CAST_START", "Decimate", 442428)
	self:Log("SPELL_AURA_APPLIED", "CosmicShardsApplied", 459273)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CosmicShardsApplied", 459273)
	self:Log("SPELL_CAST_START", "ShatteringSweep", 456420)
	self:Log("SPELL_CAST_START", "Expose", 432965)
	self:Log("SPELL_AURA_APPLIED", "ExposeApplied", 438845)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ExposeApplied", 438845)
	self:Log("SPELL_CAST_START", "PhaseLunge", 435403)
	self:Log("SPELL_CAST_SUCCESS", "PhaseLungeSuccess", 435403)
	self:Log("SPELL_AURA_APPLIED", "PhaseLungeApplied", 435410)
	self:Log("SPELL_AURA_APPLIED_DOSE", "PhaseLungeApplied", 435410)
	self:Log("SPELL_CAST_START", "RainOfArrows", 439559)

	self:Log("SPELL_DAMAGE", "CollapsingNova", 461401)
	self:Log("SPELL_MISSED", "CollapsingNova", 461401)
end

function mod:OnEngage()
	timers = self:Mythic() and timersMythic or self:Easy() and timersNormal or timersHeroic

	phaseBladesCount = 1
	decimateCount = 1
	shatteringSweepCount = 1
	captainsFlourishCount = 1
	rainOfArrowsCount = 1

	self:CDBar(439511, timers[439511][1], CL.count:format(self:SpellName(439511), captainsFlourishCount)) -- Captain's Flourish
	self:CDBar(433517, timers[433517][1], CL.count:format(self:SpellName(433517), phaseBladesCount)) -- Phase Blades
	self:CDBar(439559, timers[439559][1], CL.count:format(self:SpellName(439559), rainOfArrowsCount)) -- Rain of Arrows
	self:CDBar(442428, timers[442428][1], CL.count:format(self:SpellName(442428), decimateCount)) -- Decimate
	self:CDBar(456420, 90, CL.count:format(self:SpellName(456420), shatteringSweepCount)) -- Shattering Sweep
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:PhaseBlades()
	self:StopBar(CL.count:format(self:SpellName(433517), phaseBladesCount))
	self:Message(433517, "orange", CL.count:format(self:SpellName(433517), phaseBladesCount))
	phaseBladesCount = phaseBladesCount + 1
	self:CDBar(433517, timers[433517][phaseBladesCount], CL.count:format(self:SpellName(433517), phaseBladesCount))
end

function mod:CosmicWoundApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:Decimate(args)
	self:StopBar(CL.count:format(args.spellName, decimateCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, decimateCount))
	decimateCount = decimateCount + 1
	self:CDBar(args.spellId, timers[args.spellId][decimateCount], CL.count:format(args.spellName, decimateCount))
end

do
	local stacks = 0
	function mod:CosmicShardsMessage()
		self:Message(459273, "blue", CL.stackyou:format(stacks, self:SpellName(459273)))
		self:PlaySound(459273, "alarm")
	end

	function mod:CosmicShardsApplied(args)
		if self:Me(args.destGUID) then
			stacks = args.amount or 1
			if stacks == 1 then
				self:ScheduleTimer("CosmicShardsMessage", 0.5)
			end
		end
	end
end

function mod:ShatteringSweep(args)
	self:StopBar(CL.count:format(args.spellName, shatteringSweepCount))
	self:Message(args.spellId, "red", CL.count:format(args.spellName, shatteringSweepCount))
	self:PlaySound(args.spellId, "long")
	shatteringSweepCount = shatteringSweepCount + 1
	self:CDBar(args.spellId, 98, CL.count:format(args.spellName, shatteringSweepCount))
end

-- Expose cast (message/current tank sound) -> Expose debuff (message) -> Expose debuff (message) -> Phased Lunge cast (other tank sound) -> Pierced Defence (message)
function mod:Expose(args)
	self:StopBar(CL.count:format(self:SpellName(439511), captainsFlourishCount))
	self:Message(439511, "cyan", CL.count:format(self:SpellName(439511), captainsFlourishCount))
	local bossUnit = self:UnitTokenFromGUID(args.sourceGUID)
	if bossUnit and self:Tanking(bossUnit) then -- boss1
		self:PlaySound(439511, "alarm") -- defensive
	end
	self:Bar(432969, 4) -- Phase Lunge
	captainsFlourishCount = captainsFlourishCount + 1
	-- local cd = captainsFlourishCount % 4 ~= 1 and 22 or 28
	self:CDBar(439511, timers[439511][captainsFlourishCount], CL.count:format(self:SpellName(439511), captainsFlourishCount))
end

function mod:ExposeApplied(args)
	local amount = args.amount or 1
	self:StackMessage(args.spellId, "purple", args.destName, amount, 2)
end

function mod:PhaseLunge(args)
	-- self:Message(432969, "purple", CL.casting:format(args.spellName))
	local bossUnit = self:UnitTokenFromGUID(args.sourceGUID)
	if bossUnit and self:Tank() and not self:Tanking(bossUnit) then
		self:PlaySound(432969, "warning") -- tauntswap
	end
end

function mod:PhaseLungeSuccess(args)
	self:StopBar(432969)
end

function mod:PhaseLungeApplied(args)
	self:TargetMessage(432969, "purple", args.destName)
	-- self:PlaySound(432969, "info")
end

function mod:RainOfArrows(args)
	self:StopBar(CL.count:format(args.spellName, rainOfArrowsCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, rainOfArrowsCount))
	self:PlaySound(args.spellId, "alarm")
	rainOfArrowsCount = rainOfArrowsCount + 1
	self:CDBar(args.spellId, timers[args.spellId][rainOfArrowsCount], CL.count:format(args.spellName, rainOfArrowsCount))
end

do
	local prev = 0
	function mod:CollapsingNova(args)
		if args.time - prev > 3 then
			prev = args.time
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "alarm")
		end
	end
end
