--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Nexus-Princess Ky'veza", 2657, 2601)
if not mod then return end
mod:RegisterEnableMob(217748)
mod:SetEncounterID(2920)
mod:SetRespawnTime(30)
mod:SetStage(1)
mod:SetPrivateAuraSounds({
	436870, -- Assassination
	438141, -- Twilight Massacre
	{ 435534, 436663, 436664, 436665, 436666, 436671 }, -- Regicide
})

-- Assassination:        ability.id IN (436867,442573,440650) and type="cast"
-- TwilightMassacre:     ability.id=438245 and type="begincast"
-- NetherRift:           ability.id=437620 and type="begincast" and source.id=217748
-- NexusDaggers:         ability.id=439576 and type="begincast" and source.id=217748
-- VoidShredders:        ability.id=440377 and type="begincast"

-- StarlessNight:        ability.id IN (435405,442277) and type="begincast"

--------------------------------------------------------------------------------
-- Locals
--

local assassinationCount = 1
local twilightMassacreCount = 1
local netherRiftCount = 1
local nexusDaggersCount = 1
local voidShreddersCount = 1
local starlessNightCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.stacks_onboss = "%dx %s on BOSS"

	L.assasination = "Phantoms"
	L.twiligt_massacre = "Massacre"
	L.nexus_daggers = "Lines"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Stage One: The Phantom Blade
		{436867, "PRIVATE"}, -- Assassination
		437343, -- Queensbane
		439409, -- Dark Viscera
		{438245, "PRIVATE"}, -- Twilight Massacre
		437620, -- Nether Rift
		439576, -- Nexus Daggers
		{440377, "TANK_HEALER"}, -- Void Shredders
		{440576, "TANK"}, -- Chasmal Gash

		-- Stage Two: Starless Night
		{435405, "CASTBAR"}, -- Starless Night
		{442277, "CASTBAR"}, -- Eternal Night

		-- Mythic
		447174, -- Death Cloak
	},{
		[436867] = -28741, -- Stage One: The Phantom Blade
		[435405] = -28742, -- Stage Two: Starless Night
		[447174] = "mythic",
	},{
		[436867] = L.assasination, -- Assassination (Phantoms)
		[439409] = CL.orbs, -- Dark Visera (Orbs)
		[438245] = L.twiligt_massacre, -- Twilight Massacre (Massacre)
		[437620] = CL.rifts, -- Nether Rift (Rifts)
		[439576] = L.nexus_daggers, -- Nexus Daggers (Daggers)
	}
end

function mod:OnRegister()
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function(_, _, id)
		if mod:GetEncounterID() == id then
			if not mod:IsEnabled() then
				mod:Enable()
			end
			mod:Engage()
		end
	end)
	f:RegisterEvent("ENCOUNTER_START")
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Assassination", 436867, 442573, 440650) -- 3, 4, 5 targets
	self:Log("SPELL_AURA_APPLIED", "QueensbaneApplied", 437343)
	self:Log("SPELL_CAST_START", "TwilightMassacre", 438245)
	self:Log("SPELL_CAST_START", "NetherRift", 437620)
	self:Log("SPELL_CAST_START", "NexusDaggers", 439576)
	self:Log("SPELL_CAST_START", "VoidShredders", 440377)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ChasmalGashApplied", 440576)

	self:Log("SPELL_AURA_APPLIED", "DeathCloakApplied", 447174)
	self:Log("SPELL_AURA_APPLIED_DOSE", "DeathCloakApplied", 447174)

	self:Log("SPELL_CAST_START", "StarlessNight", 435405)
	self:Log("SPELL_AURA_REMOVED", "StarlessNightOver", 435405)
	self:Log("SPELL_CAST_START", "EternalNight", 442277)
end

function mod:OnEngage()
	self:SetStage(1)
	assassinationCount = 1
	twilightMassacreCount = 1
	netherRiftCount = 1
	nexusDaggersCount = 1
	voidShreddersCount = 1
	starlessNightCount = 1

	self:Bar(436867, 8.5, CL.count:format(self:SpellName(436867), assassinationCount)) -- Assassination
	self:Bar(440377, 10.0, CL.count:format(self:SpellName(440377), voidShreddersCount)) -- Void Shredders
	self:Bar(437620, 22.0, CL.count:format(self:SpellName(437620), netherRiftCount)) -- Nether Rift
	self:Bar(438245, 34.0, CL.count:format(self:SpellName(438245), twilightMassacreCount)) -- Twilight Massacre
	self:Bar(439576, 45.0, CL.count:format(self:SpellName(439576), nexusDaggersCount)) -- Nexus Daggers
	self:Bar(435405, 96.1, CL.count:format(self:SpellName(435405), starlessNightCount)) -- Starless Night
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Assassination(args)
	local spellName = self:SpellName(436867)
	self:StopBar(CL.count:format(spellName, assassinationCount))
	self:Message(436867, "cyan", CL.count:format(spellName, assassinationCount))
	assassinationCount = assassinationCount + 1
	if assassinationCount < 4 then
		self:Bar(436867, 130.0, CL.count:format(spellName, assassinationCount))
	end
end

do
	local prev = 0
	function mod:QueensbaneApplied(args)
		if not self:Easy() and args.time - prev > 2 then
			prev = args.time
			self:Bar(439409, 10) -- Dark Viscera
		end
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId)
			self:PlaySound(args.spellId, "alarm")
			-- if not self:Easy() then
			-- 	self:SayCountdown(args.spellId, 10)
			-- end
		end
	end
end

function mod:TwilightMassacre(args)
	self:StopBar(CL.count:format(args.spellName, twilightMassacreCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, twilightMassacreCount))
	self:PlaySound(args.spellId, "alert")
	twilightMassacreCount = twilightMassacreCount + 1
	if twilightMassacreCount < 7 then
		self:Bar(args.spellId, twilightMassacreCount % 2 == 0 and 30.0 or 100.0, CL.count:format(args.spellName, twilightMassacreCount))
	end
end

function mod:NetherRift(args)
	if self:MobId(args.sourceGUID) == 217748 then -- boss, not phantoms
		self:StopBar(CL.count:format(args.spellName, netherRiftCount))
		self:Message(args.spellId, "orange", CL.count:format(args.spellName, netherRiftCount))
		self:PlaySound(args.spellId, "alert")
		netherRiftCount = netherRiftCount + 1
		if netherRiftCount < 10 then
			self:Bar(args.spellId, netherRiftCount % 3 == 1 and 70.0 or 30.0, CL.count:format(args.spellName, netherRiftCount))
		end
	end
end

do
	local daggerCastedCount = 0
	function mod:NexusDaggers(args)
		if self:MobId(args.sourceGUID) == 217748 then -- boss, not phantoms
			self:StopBar(CL.count:format(args.spellName, nexusDaggersCount))
			self:Message(args.spellId, "yellow", CL.count:format(args.spellName, nexusDaggersCount))
			self:PlaySound(args.spellId, "alarm")
			nexusDaggersCount = nexusDaggersCount + 1
			if nexusDaggersCount < 7 then
				self:Bar(args.spellId, nexusDaggersCount % 2 == 0 and 30.0 or 100.0, CL.count:format(args.spellName, nexusDaggersCount))
			end
			daggerCastedCount = 0
		else -- phantoms
			daggerCastedCount = daggerCastedCount + 1
			if daggerCastedCount == 5 then
				self:Message(args.spellId, "green", CL.over:format(args.spellName))
				self:PlaySound(args.spellId, "info")
			end
		end
	end
end

function mod:VoidShredders(args)
	self:StopBar(CL.count:format(args.spellName, voidShreddersCount))
	self:Message(args.spellId, "purple", CL.count:format(args.spellName, voidShreddersCount))
	self:PlaySound(args.spellId, "alert")
	voidShreddersCount = voidShreddersCount + 1
	if voidShreddersCount < 10 then
		-- 10.0, 30.0, 30.0, 70.0, 30.0, 30.0, 70.0, 30.0, 30.0
		local cd = voidShreddersCount % 3 == 1 and 70 or 30
		self:Bar(args.spellId, cd, CL.count:format(args.spellName, voidShreddersCount))
	end
end

function mod:ChasmalGashApplied(args)
	-- 4 stacks in 1.5s
	if args.amount % 4 == 0 then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 4)
		if self:Tank() and not self:Me(args.destGUID) then
			self:PlaySound(args.spellId, "warning") -- tankswap?
		end
	end
end

do
	local stacks = 0
	local scheduled = nil
	function mod:DeathCloakStacksMessage()
		self:Message(447174, "red", L.stacks_onboss:format(stacks, self:SpellName(447174)))
		if stacks > 2 then
			self:PlaySound(447174, "alarm") -- fail
		end
		scheduled = nil
	end

	function mod:DeathCloakApplied(args)
		stacks = args.amount or 1
		if not scheduled then
			scheduled = self:ScheduleTimer("DeathCloakStacksMessage", 0.4)
		end
	end
end

function mod:StarlessNight(args)
	self:SetStage(2)
	self:StopBar(CL.count:format(args.spellName, starlessNightCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, starlessNightCount))
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 29, CL.count:format(args.spellName, starlessNightCount))
	starlessNightCount = starlessNightCount + 1
	if starlessNightCount == 3 then
		self:Bar(442277, 130.0) -- Eternal Night
	elseif starlessNightCount < 3 then
		self:Bar(args.spellId, 130.0, CL.count:format(args.spellName, starlessNightCount))
	end
end

function mod:StarlessNightOver()
	self:SetStage(1)
end

function mod:EternalNight(args)
	self:SetStage(2)
	self:StopBar(args.spellName)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 38)
end
