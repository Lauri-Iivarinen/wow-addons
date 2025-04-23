
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Vexie and the Geargrinders", 2769, 2639)
if not mod then return end
mod:RegisterEnableMob(225821, 225822) -- The Geargrinder, Vexie Fullthrottle
mod:SetEncounterID(3009)
mod:SetPrivateAuraSounds({
	459669, -- Spew Oil
	468486, -- Incendiary Fire
})
mod:SetRespawnTime(30)
mod:SetStage(1)

--[[

CallBikers               ability.id=459943 and type="begincast"
SpewOil                  ability.id=459671 and type="begincast"
IncendiaryFire           ability.id=468487 and type="begincast"
TankBuster               ability.id=459627 and type="begincast"
ExhaustFumes             ability.id=468149 and type IN ("applybuff", "applybuffstack")

ProtectPlating           ability.id=466615 and type IN ("applybuff","removebuff")
MechanicalBreakdown      ability.id=460603 and type="begincast"
TuneUpApplied            ability.id=460116 and type IN ("applybuff","removebuff")
UnrelentingCARnage       ability.id=471403 and type="begincast"

--]]

--------------------------------------------------------------------------------
-- Locals
--

local tankBusterCount = 1
local exhaustFumesCount = 1
local spewOilCount = 1
local callBikersCount = 1
local incendiaryFireCount = 1
local phaseCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.plating_removed = "%d Plating remaining"
	L.exhaust_fumes = "Raid Damage"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		-- Stage One: Fury Road
		466615, -- Protective Plating
		471403, -- Unrelenting CAR-nage
		459943, -- Call Bikers
			473507, -- Soaked In Oil (Mythic)
			-- 459453, -- Blaze of Glory
			-- 460625, -- Burning Shrapnel
			-- 459994, -- Hot Wheels (Damage)
		{459671, "PRIVATE"}, -- Spew Oil
			-- 459683, -- Oil Slick (Damage)
		{468487, "PRIVATE"}, -- Incendiary Fire
		459974, -- Bomb Voyage! (Damage)
		{465865, "TANK"}, -- Tank Buster
			468149,	-- Exhaust Fumes (DPS / Healers)

		-- Stage Two: Pit Stop
		460603, -- Mechanical Breakdown
		460116, -- Tune-Up
	},{
		[466615] = -30093, -- Stage 1
		[460603] = -30094, -- Stage 2
	},{
		[468149] = L.exhaust_fumes, -- Exhaust Fumes (Raid Damage)
		[471403] = CL.full_energy, -- Unrelenting CAR-nage (Full Energy)
	}
end

function mod:OnBossEnable()
	-- Stage 1
	self:Log("SPELL_AURA_APPLIED", "ProtectivePlatingApplied", 466615)
	self:Log("SPELL_AURA_REMOVED_DOSE", "ProtectivePlatingRemoved", 466615)
	self:Log("SPELL_CAST_START", "UnrelentingCARnage", 471403)
	self:Log("SPELL_CAST_START", "CallBikers", 459943)
	self:Log("SPELL_AURA_APPLIED", "SoakedInOilApplied", 473507)
	self:Log("SPELL_CAST_START", "SpewOil", 459671)
	self:Log("SPELL_AURA_APPLIED", "SpewOilApplied", 459678) -- DOT after getting hit
	self:Log("SPELL_CAST_START", "IncendiaryFire", 468487)
	self:Log("SPELL_AURA_APPLIED", "IncendiaryFireApplied", 468216) -- Targetting debuff (non-private)
	self:Log("SPELL_AURA_APPLIED", "BombVoyageApplied", 459978) -- DOT after getting hit
	self:Log("SPELL_CAST_START", "TankBuster", 459627)
	self:Log("SPELL_AURA_APPLIED", "TankBusterApplied", 465865)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TankBusterApplied", 465865)
	self:Log("SPELL_AURA_APPLIED", "ExhaustFumesApplied", 468149)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ExhaustFumesApplied", 468149)
	-- Stage 2
	self:Log("SPELL_CAST_START", "MechanicalBreakdown", 460603)
	self:Log("SPELL_AURA_APPLIED", "TuneUpApplied", 460116)
	self:Log("SPELL_AURA_REMOVED", "TuneUpRemoved", 460116)

	-- self:Log("SPELL_AURA_APPLIED", "GroundDamage", 459683) -- Oil Slick
	-- self:Log("SPELL_PERIODIC_DAMAGE", "GroundDamage", 459683)
	-- self:Log("SPELL_PERIODIC_MISSED", "GroundDamage", 459683)
end

function mod:OnEngage()
	self:SetStage(1)
	tankBusterCount = 1
	exhaustFumesCount = 1
	spewOilCount = 1
	callBikersCount = 1
	incendiaryFireCount = 1
	phaseCount = 1

	self:CDBar(465865, self:Mythic() and 6.3 or 7.6, CL.count:format(self:SpellName(465865), tankBusterCount)) -- Tank Buster
	if not self:Tank() then
		self:CDBar(468149, self:Mythic() and 7.8 or 9.1, CL.count:format(self:SpellName(468149), exhaustFumesCount)) -- Exhaust Fumes
	end
	self:CDBar(459671, self:Mythic() and 12.0 or 13.0, CL.count:format(self:SpellName(459671), spewOilCount)) -- Spew Oil
	self:CDBar(459943, self:Mythic() and 21.0 or 20.3, CL.count:format(self:SpellName(459943), callBikersCount)) -- Call Bikers
	self:CDBar(468487, self:Mythic() and 26.0 or self:Easy() and 30.6 or 25.5, CL.count:format(self:SpellName(468487), incendiaryFireCount)) -- Incendiary Fire
	self:Bar(471403, 121, CL.count:format(self:SpellName(471403), phaseCount)) -- Unrelenting CAR-nage
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Stage 1

function mod:ProtectivePlatingApplied(args)
	if not self:IsEngaged() then return end

	self:Message(466615, "cyan", CL.count:format(args.spellName, phaseCount))
	self:PlaySound(466615, "info")
end

do
	local stacks = 0
	local scheduled = nil
	function mod:ProtectivePlatingRemovedMessage()
		self:Message(466615, "green", L.plating_removed:format(stacks))
		if stacks < 4 then
			self:PlaySound(466615, "info") -- breaking soon
		end
		scheduled = nil
	end

	function mod:ProtectivePlatingRemoved(args)
		stacks = args.amount
		if not scheduled then
			scheduled = self:ScheduleTimer("ProtectivePlatingRemovedMessage", 1)
		end
	end
end

function mod:UnrelentingCARnage(args)
	self:StopBar(CL.count:format(self:SpellName(471403), phaseCount)) -- Unrelenting CAR-nage
	self:StopBar(CL.count:format(self:SpellName(465865), tankBusterCount)) -- Tank Buster
	self:StopBar(CL.count:format(self:SpellName(459671), spewOilCount)) -- Spew Oil
	self:StopBar(CL.count:format(self:SpellName(459943), callBikersCount)) -- Call Bikers
	self:StopBar(CL.count:format(self:SpellName(468487), incendiaryFireCount)) -- Incendiary Fire

	self:Message(args.spellId, "red", CL.count:format(args.spellName, phaseCount))
	self:PlaySound(args.spellId, "alarm") -- fail
end

function mod:CallBikers(args)
	self:StopBar(CL.count:format(args.spellName, callBikersCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, callBikersCount))
	self:PlaySound(args.spellId, "info") -- adds
	callBikersCount = callBikersCount + 1
	local timer = { 24.3, 29.2, 31.7, 28.0, 0 }
	self:CDBar(args.spellId, timer[callBikersCount], CL.count:format(args.spellName, callBikersCount))
end

function mod:SoakedInOilApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:SpewOil(args)
	self:StopBar(CL.count:format(args.spellName, spewOilCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, spewOilCount))
	spewOilCount = spewOilCount + 1
	if (phaseCount == 1 and spewOilCount < 4) then
		self:CDBar(args.spellId, 37.7, CL.count:format(args.spellName, spewOilCount))
	elseif (phaseCount > 1 and spewOilCount < 7) then
		self:CDBar(args.spellId, spewOilCount == 2 and 22.0 or 20.7, CL.count:format(args.spellName, spewOilCount))
	end
end

function mod:SpewOilApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(459671)
		self:PlaySound(459671, "alarm")
	end
end

function mod:IncendiaryFire(args)
	self:StopBar(CL.count:format(args.spellName, incendiaryFireCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, incendiaryFireCount))
	incendiaryFireCount = incendiaryFireCount + 1
	if (phaseCount == 1 and incendiaryFireCount < 5) then
		self:CDBar(args.spellId, 25.5, CL.count:format(args.spellName, incendiaryFireCount))
	elseif (phaseCount > 1 and incendiaryFireCount < 4) then
		local timer = { 34.2, 35.3, 36.5 }
		self:CDBar(args.spellId, timer[incendiaryFireCount], CL.count:format(args.spellName, incendiaryFireCount))
	end
end

function mod:IncendiaryFireApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(468487)
		-- self:Say(468487, nil, nil, "Incendiary Fire")
		-- self:SayCountdown(468487, 6)
	end
end

function mod:BombVoyageApplied(args) -- cast every 8s
	if self:Me(args.destGUID) then
		self:PersonalMessage(459974)
		self:PlaySound(459974, "alarm")
	end
end

function mod:TankBuster()
	self:StopBar(CL.count:format(self:SpellName(465865), tankBusterCount))
	self:Message(465865, "purple", CL.count:format(self:SpellName(465865), tankBusterCount))
	self:PlaySound(465865, "info")
	tankBusterCount = tankBusterCount + 1
	if phaseCount == 1 then
		local timer = { 7.1, 22.0, 32.8, 21.9, 23.1 }
		self:CDBar(465865, timer[tankBusterCount] or 0, CL.count:format(self:SpellName(465865), tankBusterCount))
	else
		local timer = { 9.7, 17.0, 17.1, 20.7, 21.9, 19.4 }
		self:CDBar(465865, timer[tankBusterCount] or 0, CL.count:format(self:SpellName(465865), tankBusterCount))
	end
	if not self:Tank() then
		self:Bar(468149, {1.5, 17}, CL.count:format(self:SpellName(468149), exhaustFumesCount)) -- Exhaust Fumes
	end
end

function mod:TankBusterApplied(args)
	self:StackMessage(args.spellId, "purple", args.destName, args.amount, 1)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "alarm") -- On you
	end
end

function mod:ExhaustFumesApplied(args)
	if not self:Tank() then
		self:StopBar(CL.count:format(args.spellName, exhaustFumesCount))
		self:Message(args.spellId, "orange", CL.count:format(args.spellName, exhaustFumesCount))
		exhaustFumesCount = exhaustFumesCount + 1
		if phaseCount == 1 then
			local timer = { 8.6, 22.0, 32.8, 21.9, 23.1 }
			self:CDBar(args.spellId, timer[exhaustFumesCount] or 0, CL.count:format(args.spellName, exhaustFumesCount))
		else
			local timer = { 11.4, 17.0, 17.0, 20.7, 21.9, 23.1 }
			self:CDBar(args.spellId, timer[exhaustFumesCount] or 0, CL.count:format(args.spellName, exhaustFumesCount))
		end
	end
end

-- Stage 2

function mod:MechanicalBreakdown(args)
	self:StopBar(CL.count:format(self:SpellName(471403), phaseCount)) -- Unrelenting CAR-nage
	self:StopBar(CL.count:format(self:SpellName(465865), tankBusterCount)) -- Tank Buster
	self:StopBar(CL.count:format(self:SpellName(468149), exhaustFumesCount)) -- Exhaust Fumes
	self:StopBar(CL.count:format(self:SpellName(459671), spewOilCount)) -- Spew Oil
	self:StopBar(CL.count:format(self:SpellName(459943), callBikersCount)) -- Call Bikers
	self:StopBar(CL.count:format(self:SpellName(468487), incendiaryFireCount)) -- Incendiary Fire

	self:SetStage(2)
	self:Message(args.spellId, "green", CL.count:format(args.spellName, phaseCount))
	self:PlaySound(args.spellId, "long")
end

function mod:TuneUpApplied(args)
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, phaseCount))
	self:PlaySound(args.spellId, "info")
	self:Bar(args.spellId, 45, CL.count:format(args.spellName, phaseCount))
end

function mod:TuneUpRemoved(args)
	self:StopBar(CL.count:format(args.spellName, phaseCount))

	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:PlaySound("stages", "long")
	phaseCount = phaseCount + 1

	tankBusterCount = 1
	exhaustFumesCount = 1
	spewOilCount = 1
	callBikersCount = 1
	incendiaryFireCount = 1

	self:CDBar(465865, self:Mythic() and 6.3 or 10.2, CL.count:format(self:SpellName(465865), tankBusterCount)) -- Tank Buster
	if not self:Tank() then
		self:CDBar(468149, self:Mythic() and 7.8 or 11.7, CL.count:format(self:SpellName(468149), exhaustFumesCount)) -- Exhaust Fumes
	end
	self:CDBar(459671, self:Mythic() and 15.8 or self:Easy() and 12.3 or 16.7, CL.count:format(self:SpellName(459671), spewOilCount)) -- Spew Oil
	self:CDBar(459943, self:Mythic() and 24.3 or self:Easy() and 21.0 or 23.7, CL.count:format(self:SpellName(459943), callBikersCount)) -- Call Bikers
	self:CDBar(468487, self:Mythic() and 34.3 or self:Easy() and 30.6 or 33.8, CL.count:format(self:SpellName(468487), incendiaryFireCount)) -- Incendiary Fire
	self:Bar(471403, 126, CL.count:format(self:SpellName(471403), phaseCount)) -- Unrelenting CAR-nage
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
