
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sprocketmonger Lockenstock", 2769, 2653)
if not mod then return end
mod:RegisterEnableMob(230583)
mod:SetEncounterID(3013)
mod:SetRespawnTime(30)
mod:SetStage(1)

--[[

Phases                      (ability.id IN (466765,468791) and type="begincast") or (ability.id=1218318 and type="removebuff")

ActivateInventions          ability.id=473276 and type="begincast"
    Inventions                  (ability.id=473276 and type="begincast") or (ability.id IN (1216414,1216525) and type="cast")
FootBlasters                ability.id=1217231 and type="begincast"
WireTransfer                ability.id=1218418 and type="begincast"
ScrewUp                     ability.id=1216508 and type="cast"
SonicBaBoom                 ability.id=465232 and type="begincast"
PyroPartyPack               ability.id=1214878 and type="applydebuff"
PolarizationGenerator       ability.id=1217355 and type="cast"

BetaLaunch                  ability.id IN (466765,468791) and type="begincast"
BleedingEdge                ability.id=466860 and type="cast"
Voidsplosion                ability.id=1218319 and type="applydebuff"
BiotechUpgrade              ability.id=1218344 and type IN ("applybuff","applybuffstack")


--]]

--------------------------------------------------------------------------------
-- Locals
--

local activateInventionsCount = 1
local footBlasterCount = 1
local pyroPartyPackCount = 1
local screwUpCount = 1
local sonicBaBoomCount = 1
local wireTransferCount = 1
local betaLaunchCount = 1
local voidsplosionCount = 1
local polarizationGeneratorCount = 1

local numMinesExploded = 0
local myCharge = nil

local timersLFR = {
	[1218418] = { 2.0, 46.0, 53.0, 0 }, -- Wire Transfer
	[465232] = { 8.0, 33.0, 35.0, 35.0, 0 }, -- Sonic Ba-Boom
	[1214878] = { 23.1, 34.0, 30.1, 0 }, -- Pyro Party Pack
}
local timersNormal = {
	[1218418] = { 2.0, 39.0, 60.0, 0 }, -- Wire Transfer
	[1216509] = { 49.0, 31.0, 31.0, 0 }, -- Screw Up
	[465232] = { 8.0, 28.0, 27.0, 32.0, 0 }, -- Sonic Ba-Boom
	[1214878] = { 23.1, 34.0, 30.1, 0 }, -- Pyro Party Pack
}
local timersHeroic = {
	[1217231] = { 12.0, 62.0, 0 }, -- Foot-Blasters
	[1218418] = { 0.0, 41.0, 56.0, 0 }, -- Wire Transfer
	[1216509] = { 49.0, 33.0, 32.0, 0 }, -- Screw Up
	[465232]  = { 6.0, 28.0, 29.0, 30.0, 0 }, -- Sonic Ba-Boom
	[1214878] = { 23.0, 34.0, 30.0, 0 }, -- Pyro Party Pack
}
local timersMythic = {
	[1217231] = { 12.0, 34.0, 30.0, 0 }, -- Foot-Blasters
	[1218418] = { 0.1, 41.9, 59.0, 0 }, -- Wire Transfer
	[1216509] = { 20.0, 34.0, 33.0, 0 }, -- Screw Up
	[465232]  = { 9.0, 25.0, 27.0, 27.0, 21.0, 0 }, -- Sonic Ba-Boom
	[1214878] = { 22.6, 46.0, 46.0, 0 }, -- Pyro Party Pack
	[1216802] = { 4.0, 67.0, 46.0, 0 }, -- Polarization Generator
}
local timers = mod:Mythic() and timersMythic or mod:Normal() and timersNormal or mod:LFR() and timersLFR or timersHeroic

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.foot_blasters = "Mines"
	L.screw_up = "Drills"
	L.sonic_ba_boom = "Raid Damage"
	L.pyro_party_pack = "Tank Bomb"
	L.polarization_generator = "Polarization"
	L.posi_polarization = "Blue"
	L.nega_polarization = "Red"

	L.beta_launch_cast = CL.knockback
	L.polarization_soon = "Polarization Soon: %s"
	L.polarization_soon_change = "Polarization SWITCH Soon: %s"
	L.unstable_shrapnel = "Mine Soaked"

	L.activate_inventions = "Activating: %s"
	L.blazing_beam = "Lasers"
	L.rocket_barrage = "Rockets"
	L.mega_magnetize = "Magnets"
	L.jumbo_void_beam = "Big Lasers"
	L.void_barrage = "Balls"
	L.everything = "Everything"
	L.empowered_everything = "Everything"
end

local inventions

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		{468791, "CASTBAR"}, -- Gigadeath

		-- Mythic
		1216802, -- Polarization Generator
		1216911, -- Posi-Polarization
		1216934, -- Nega-Polarization
		1219047, -- Polarized Catastro-Blast
		1216706, -- Void Barrage

		-- Stage One: Assembly Required
		473276, -- Activate Inventions!
		1217231, -- Foot-Blasters
			1216406, -- Unstable Explosion
			1218342, -- Unstable Shrapnel
		1218418, -- Wire Transfer
		1216509, -- Screw Up
		465232, -- Sonic Ba-Boom
		1214878, -- Pyro Party Pack
		{465917, "TANK"}, -- Gravi-Gunk

		-- Stage Two: Research and Destruction
		{466765, "CASTBAR"}, -- Beta Launch
		1218319, -- Voidsplosion
	},{
		[1216802] = "mythic", -- Mythic
		[473276] = -30425, -- Stage 1
		[466765] = -30427, -- Stage 2
	},{
		[473276] = {nil, "activate_inventions", "blazing_beam", "rocket_barrage", "mega_magnetize", "jumbo_void_beam", "void_barrage", "everything", "empowered_everything"},
		[1217231] = L.foot_blasters,
		[1218342] = L.unstable_shrapnel,
		[1216509] = L.screw_up,
		[465232] = L.sonic_ba_boom,
		[1214878] = L.pyro_party_pack,
		[466765] = {nil, "beta_launch_cast"}, -- Beta Launch
		[1216802] = {L.polarization_generator, "polarization_soon"},
		[1216911] = L.posi_polarization,
		[1216934] = L.nega_polarization,
	}
end

function mod:OnBossEnable()
	-- Stage 1
	self:Log("SPELL_CAST_START", "ActivateInventions", 473276)
	self:Log("SPELL_CAST_START", "FootBlasters", 1217231)
	self:Log("SPELL_AURA_APPLIED", "UnstableExplosionApplied", 1216406)
	self:Log("SPELL_AURA_APPLIED_DOSE", "UnstableExplosionApplied", 1216406)
	self:Log("SPELL_AURA_APPLIED", "UnstableShrapnelApplied", 1218342)
	self:Log("SPELL_AURA_APPLIED", "GraviGunkApplied", 465917)
	self:Log("SPELL_CAST_START", "PyroPartyPack", 1214872)
	self:Log("SPELL_AURA_APPLIED", "PyroPartyPackApplied", 1214878)
	self:Log("SPELL_AURA_REMOVED", "PyroPartyPackRemoved", 1214878)
	self:Log("SPELL_CAST_SUCCESS", "ScrewUp", 1216508)
	self:Log("SPELL_AURA_APPLIED", "ScrewUpApplied", 1216509)
	self:Log("SPELL_CAST_START", "SonicBaBoom", 465232)
	self:Log("SPELL_CAST_START", "WireTransfer", 1218418)
	-- Stage 2
	self:Log("SPELL_CAST_START", "BetaLaunch", 466765)
	self:Log("SPELL_CAST_SUCCESS", "BleedingEdge", 466860)
	self:Log("SPELL_AURA_APPLIED", "VoidsplosionApplied", 1218319)
	self:Log("SPELL_AURA_APPLIED_DOSE", "VoidsplosionApplied", 1218319)
	self:Log("SPELL_AURA_REMOVED", "BleedingRemoved", 1218318)
	self:Log("SPELL_CAST_START", "Gigadeath", 468791)

	-- self:Log("SPELL_AURA_APPLIED", "GroundDamage", 466235) -- Wire Transfer
	-- Mythic
	self:Log("SPELL_CAST_SUCCESS", "PolarizationGenerator", 1217355)
	self:Log("SPELL_AURA_APPLIED", "PolarizationGeneratorPosiApplied", 1217357)
	self:Log("SPELL_AURA_APPLIED", "PolarizationGeneratorNegaApplied", 1217358)
	self:Log("SPELL_AURA_APPLIED", "PosiPolarizationApplied", 1216911)
	self:Log("SPELL_AURA_APPLIED", "NegaPolarizationApplied", 1216934)
	self:Log("SPELL_DAMAGE", "PolarizedCatastroBlast", 1219047)
	self:Log("SPELL_DAMAGE", "VoidBarrageHit", 1216706)
	self:Log("SPELL_MISSED", "VoidBarrageHit", 1216706)

	timers = self:Mythic() and timersMythic or self:Normal() and timersNormal or self:LFR() and timersLFR or timersHeroic
	if self:Mythic() then
		inventions = {
			{ L.blazing_beam,  CL.plus:format(L.blazing_beam, L.rocket_barrage), L.everything },
			{ L.jumbo_void_beam, CL.plus:format(L.jumbo_void_beam, L.rocket_barrage), L.everything },
			{ L.void_barrage, CL.plus:format(L.void_barrage, L.mega_magnetize), L.empowered_everything },
		}
	else
		inventions = {
			{ L.blazing_beam, L.rocket_barrage, L.mega_magnetize },
			{ L.jumbo_void_beam, CL.plus:format(L.jumbo_void_beam, L.rocket_barrage), CL.plus:format(L.jumbo_void_beam, L.mega_magnetize) },
			{ L.void_barrage, CL.plus:format(L.void_barrage, L.mega_magnetize), L.empowered_everything },
		}
	end
end

function mod:OnEngage()
	self:SetStage(1)
	activateInventionsCount = 1
	footBlasterCount = 1
	pyroPartyPackCount = 1
	screwUpCount = 1
	sonicBaBoomCount = 1
	wireTransferCount = 1
	betaLaunchCount = 1
	polarizationGeneratorCount = 1

	numMinesExploded = 0
	myCharge = nil

	-- self:Bar(1218418, timers[1218418][1], CL.count:format(self:SpellName(1218418), wireTransferCount)) -- Wire Transfer (casted immediately)
	if self:Mythic() then
		self:Bar(1216802, timers[1216802][1], CL.count:format(self:SpellName(1216802), polarizationGeneratorCount)) -- Polarization Generator
	end
	self:Bar(465232, timers[465232][1], CL.count:format(self:SpellName(465232), sonicBaBoomCount)) -- Sonic Ba-Boom
	if not self:Easy() then
		self:Bar(1217231, timers[1217231][1], CL.count:format(self:SpellName(1217231), footBlasterCount)) -- Foot-Blasters
	end
	self:Bar(1214878, timers[1214878][1], CL.count:format(self:SpellName(1214878), pyroPartyPackCount)) -- Pyro Party Pack
	if not self:LFR() then
		self:Bar(1216509, timers[1216509][1], CL.count:format(self:SpellName(1216509), screwUpCount)) -- Screw Up
	end
	self:Bar(473276, 30.0 + 4.0, CL.count:format(inventions[1][1], activateInventionsCount)) -- Activate Inventions! (offset for the cast of the weapon)
	self:Bar(466765, 121.6, CL.count:format(self:SpellName(466765), betaLaunchCount)) -- Beta Launch
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Stage 1

function mod:ActivateInventions(args)
	-- self:StopBar(CL.count:format(inventions[betaLaunchCount][activateInventionsCount], activateInventionsCount))
	self:Message(args.spellId, "cyan", CL.count:format(L.activate_inventions:format(inventions[betaLaunchCount][activateInventionsCount]), activateInventionsCount))
	self:PlaySound(args.spellId, "long")
	activateInventionsCount = activateInventionsCount + 1
	if activateInventionsCount < 4 then -- 3 per
		-- self:Bar(args.spellId, 30, CL.count:format(inventions[betaLaunchCount][activateInventionsCount], activateInventionsCount))
		self:ScheduleTimer("Bar", 4.0, args.spellId, 30, CL.count:format(inventions[betaLaunchCount][activateInventionsCount], activateInventionsCount))
	end
end

function mod:FootBlasters(args)
	self:StopBar(CL.count:format(args.spellName, footBlasterCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, footBlasterCount))
	self:PlaySound(args.spellId, "alert")
	footBlasterCount = footBlasterCount + 1
	self:Bar(args.spellId, timers[args.spellId][footBlasterCount], CL.count:format(args.spellName, footBlasterCount))

	numMinesExploded = 0
end

do
	local soaker = nil
	local soakTime = 0
	local prev = 0

	function mod:UnstableExplosionApplied(args)
		local t = args.time
		if t - soakTime > 1 and t - prev > 1 then
			prev = t
			self:Message(args.spellId, "red") -- , CL.count:format(args.spellName, 4 - numMinesExploded))
			self:PlaySound(args.spellId, "alarm")
		end
	end

	function mod:UnstableShrapnelApplied(args)
		numMinesExploded = numMinesExploded + 1
		soaker = args.destName
		soakTime = args.time
		if self:Me(args.destGUID) then
			self:Message(args.spellId, "blue", CL.count_amount:format(args.spellName, numMinesExploded, 4))
			self:PlaySound(args.spellId, "warning")
		-- else
		-- 	local targetMsg = CL.other:format(args.spellName, self:ColorName(soaker))
		-- 	self:Message(args.spellId, "orange", CL.count_amount:format(targetMsg, numMinesExploded, 4))
		end
	end
end

function mod:GraviGunkApplied(args)
	local amount = args.amount or 1
	if amount % 3 == 1 then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 10)
		if self:Me(args.destGUID) then
			self:PlaySound(args.spellId, "alarm")
		elseif self:Tank() and amount > 9 then
			self:PlaySound(args.spellId, "warning") -- taunt?
		end
	end
end

function mod:PyroPartyPack()
	if self:Tank() then
		self:Message(1214878, "purple", CL.casting:format(self:SpellName(1214878)))
		self:PlaySound(1214878, "info")
	end
end

function mod:PyroPartyPackApplied(args)
	self:StopBar(CL.count:format(args.spellName, pyroPartyPackCount))
	self:TargetMessage(args.spellId, "purple", args.destName, CL.count:format(args.spellName, pyroPartyPackCount))
	self:TargetBar(args.spellId, 6, args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "warning") -- not great being the same as taunt?
	end
	pyroPartyPackCount = pyroPartyPackCount + 1
	self:Bar(args.spellId, timers[args.spellId][pyroPartyPackCount], CL.count:format(args.spellName, pyroPartyPackCount))
end

function mod:PyroPartyPackRemoved(args)
	self:StopBar(args.spellId, args.destName)
end

do
	local playerList = {}
	function mod:ScrewUp()
		self:StopBar(CL.count:format(self:SpellName(1216509), screwUpCount))
		-- self:Message(1216509, "yellow", CL.count:format(self:SpellName(1216509), screwUpCount))
		screwUpCount = screwUpCount + 1
		self:Bar(1216509, timers[1216509][screwUpCount], CL.count:format(self:SpellName(1216509), screwUpCount))
		playerList = {}
	end

	function mod:ScrewUpApplied(args)
		playerList[#playerList + 1] = args.destName
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId)
			self:PlaySound(args.spellId, "warning")
		end
		self:TargetsMessage(args.spellId, "yellow", playerList, 3, CL.count:format(args.spellName, screwUpCount-1))
	end
end

function mod:SonicBaBoom(args)
	self:StopBar(CL.count:format(args.spellName, sonicBaBoomCount))
	self:Message(args.spellId, "yellow", CL.casting:format(CL.count:format(args.spellName, sonicBaBoomCount)))
	self:PlaySound(args.spellId, "alert") -- healer
	sonicBaBoomCount = sonicBaBoomCount + 1
	self:Bar(args.spellId, timers[args.spellId][sonicBaBoomCount], CL.count:format(args.spellName, sonicBaBoomCount))
end

function mod:WireTransfer(args)
	self:StopBar(CL.count:format(args.spellName, wireTransferCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, wireTransferCount))
	self:PlaySound(args.spellId, "alarm")
	wireTransferCount = wireTransferCount + 1
	self:Bar(args.spellId, timers[args.spellId][wireTransferCount], CL.count:format(args.spellName, wireTransferCount))
end

-- Stage 2

function mod:BetaLaunch(args)
	self:StopBar(CL.count:format(args.spellName, betaLaunchCount)) -- Beta Launch
	self:StopBar(CL.count:format(self:SpellName(1218418), wireTransferCount)) -- Wire Transfer
	self:StopBar(CL.count:format(self:SpellName(465232), sonicBaBoomCount)) -- Sonic Ba-Boom
	self:StopBar(CL.count:format(self:SpellName(1217231), footBlasterCount)) -- Foot-Blasters
	self:StopBar(CL.count:format(self:SpellName(1214878), pyroPartyPackCount)) -- Pyro Party Pack
	-- self:StopBar(CL.count:format(inventions[betaLaunchCount][activateInventionsCount], activateInventionsCount)) -- Activate Inventions!
	self:StopBar(CL.count:format(self:SpellName(1216509), screwUpCount)) -- Screw Up
	self:StopBar(CL.count:format(self:SpellName(1216802), polarizationGeneratorCount)) -- Polarization Generator

	self:SetStage(2)
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, betaLaunchCount))
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 4, L.beta_launch_cast)
	betaLaunchCount = betaLaunchCount + 1

	voidsplosionCount = 1

	self:Bar(1218319, 6.3, CL.count:format(self:SpellName(1218319), voidsplosionCount)) -- Voidsplosion
end

function mod:BleedingEdge(args)
	self:Bar("stages", self:Easy() and 10 or 20, CL.stage:format(1), args.spellId)
	if self:Mythic() then
		self:Bar(1216802, 24.0, CL.count:format(self:SpellName(1216802), 1)) -- Polarization Generator
	end
end

do
	local prev = 0
	function mod:VoidsplosionApplied(args)
		if args.time - prev > 3 then
			prev = args.time
			self:StopBar(CL.count:format(args.spellName, voidsplosionCount))
			self:Message(args.spellId, "orange", CL.count:format(args.spellName, voidsplosionCount))
			self:PlaySound(args.spellId, "alert") -- healer
			voidsplosionCount = voidsplosionCount + 1
			if voidsplosionCount < (self:Easy() and 3 or 5) then
				self:Bar(args.spellId, 5, CL.count:format(args.spellName, voidsplosionCount)) -- Voidsplosion
			end
		end
	end
end

function mod:BleedingRemoved()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:PlaySound("stages", "long")

	activateInventionsCount = 1
	footBlasterCount = 1
	pyroPartyPackCount = 1
	screwUpCount = 1
	sonicBaBoomCount = 1
	wireTransferCount = 1
	polarizationGeneratorCount = 1

	-- self:Bar(1218418, timers[1218418][1], CL.count:format(self:SpellName(1218418), wireTransferCount)) -- Wire Transfer (casted immediately)
	-- if self:Mythic() then
	-- 	self:Bar(1216802, timers[1216802][1], CL.count:format(self:SpellName(1216802), polarizationGeneratorCount)) -- Polarization Generator
	-- end
	self:Bar(465232, timers[465232][1], CL.count:format(self:SpellName(465232), sonicBaBoomCount)) -- Sonic Ba-Boom
	if not self:Easy() then
		self:Bar(1217231, timers[1217231][1], CL.count:format(self:SpellName(1217231), footBlasterCount)) -- Foot-Blasters
	end
	self:Bar(1214878, timers[1214878][1], CL.count:format(self:SpellName(1214878), pyroPartyPackCount)) -- Pyro Party Pack
	if not self:LFR() then
		self:Bar(1216509, timers[1216509][1], CL.count:format(self:SpellName(1216509), screwUpCount)) -- Screw Up
	end
	self:Bar(473276, 30.0, CL.count:format(inventions[betaLaunchCount][activateInventionsCount], activateInventionsCount)) -- Activate Inventions!
	if betaLaunchCount < 3 then
		self:Bar(466765, self:Mythic() and 121.7 or 120.3, CL.count:format(self:SpellName(466765), betaLaunchCount)) -- Beta Launch
	elseif betaLaunchCount == 3 then
		self:Bar(468791, self:Mythic() and 121.7 or 120.3) -- Gigadeath
	end
end

function mod:Gigadeath(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- enrage
	self:CastBar(args.spellId, 4)
end

-- do
-- 	local prev = 0
-- 	function mod:GroundDamage(args)
-- 		if self:Me(args.destGUID) and args.time - prev > 2 then
-- 			prev = args.time
-- 			self:PlaySound(args.spellId, "underyou")
-- 			self:PersonalMessage(args.spellId, "underyou")
-- 		end
-- 	end
-- end

-- Mythic

function mod:PolarizationGenerator(args)
	self:StopBar(CL.count:format(self:SpellName(1216802), polarizationGeneratorCount))
	polarizationGeneratorCount = polarizationGeneratorCount + 1
	self:Bar(1216802, timers[1216802][polarizationGeneratorCount], CL.count:format(self:SpellName(1216802), polarizationGeneratorCount))
end

function mod:PolarizationGeneratorPosiApplied(args)
	if self:Me(args.destGUID) then
		if myCharge == "blue" then
			self:Message(1216802, "cyan", L.polarization_soon:format(_G.LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(self:SpellName(1216911)))) -- Posi
		else
			self:Message(1216802, "cyan", L.polarization_soon_change:format(_G.LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(self:SpellName(1216911)))) -- Posi
			self:PlaySound(1216802, "warning")
		end
	end
end

function mod:PolarizationGeneratorNegaApplied(args)
	if self:Me(args.destGUID) then
		if myCharge == "red" then
			self:Message(1216802, "cyan", L.polarization_soon:format(_G.DULL_RED_FONT_COLOR:WrapTextInColorCode(self:SpellName(1216934)))) -- Nega
		else
			self:Message(1216802, "cyan", L.polarization_soon_change:format(_G.DULL_RED_FONT_COLOR:WrapTextInColorCode(self:SpellName(1216934)))) -- Nega
			self:PlaySound(1216802, "warning")
		end
	end
end

function mod:PosiPolarizationApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, _G.LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(args.spellName))
		self:PlaySound(args.spellId, "info")
		myCharge = "blue"
	end
end

function mod:NegaPolarizationApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, _G.DULL_RED_FONT_COLOR:WrapTextInColorCode(args.spellName))
		self:PlaySound(args.spellId, "info")
		myCharge = "red"
	end
end

do
	local prev = 0
	function mod:PolarizedCatastroBlast(args)
		if args.time - prev > 2 then
			prev = args.time
			self:Message(args.spellId, "red")
			self:PlaySound(args.spellId, "alarm") -- boom
		end
	end
end

function mod:VoidBarrageHit(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	self:PlaySound(args.spellId, "alarm")
end
