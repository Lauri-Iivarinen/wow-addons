
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The One-Armed Bandit", 2769, 2644)
if not mod then return end
mod:RegisterEnableMob(228458)
mod:SetEncounterID(3014)
mod:SetPrivateAuraSounds({
	465325, -- Hot Hot Heat
})
mod:SetRespawnTime(30)
mod:SetStage(1)

--[[

PayLine              ability.id=460181 and type="cast"
FoulExhaust          ability.id=469993 and type="begincast"
TheBigHit            ability.id=460472 and type="cast"
SpinToWin            ability.id=461060 and type="begincast"

WitheringFlames      ability.id=471930 and type="cast"

Rewards              ability.id IN (464772, 464801, 464804, 464806, 464809, 464810, 464776) and type="begincast"

MaintenanceCycle     ability.id=465765 and type="cast"
CheatToWin           ability.id IN (465432, 465322, 465580, 465587) and type="begincast"

HotHotHeat           ability.id=465325 and type="applydebuff"

--]]

--------------------------------------------------------------------------------
-- Locals
--

local spinToWinCount = 1
local payLineCount = 1
local foulExhaustCount = 1
local theBigHitCount = 1
local hyperCoilCount = 1
local hotHotHeatCount = 1

local fullPayLineCount = 1
local fullFoulExhaustCount = 1
local fullTheBigHitCount = 1

local payLineCD = 10
local lastReward = nil
local tokenCount = 0
local timerHandles = {}
local mobCollector = {}
local mobMark = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.the_big_hit = "Big Hit"
	L.withering_flames_say = "Flames"

	L.tokens= "Insert Token"
	L.tokens_desc = "Show a message when depositing the first token during Spin to Win!"
	L.tokens_icon = "achievement_battleground_templeofkotmogu_02"

	L.rewards = "Fabulous Prizes"
	L.rewards_desc = "Messages and sounds to let you know which Fabulous Prizes have been won!"
	L.rewards_icon = "inv_111_vendingmachine_blackwater"

	L.hyper_coil_timer = "Hyper Coil Spawn Timer"
	L.hyper_coil_timer_icon = "inv_misc_stormlordsfavor"
	L.hyper_coil_spawn = "New Coil"

	L.hot_hot_heat_timer = "Hot Hot Heat Beam Timer"
	L.hot_hot_heat_timer_icon = "ability_mage_firestarter"
	L.hot_hot_head_beams = CL.beams

	L.fixate_nameplate = ">" .. CL.fixate .. "<"
end

--------------------------------------------------------------------------------
-- Initialization
--

local reelAssistantMarkerMapTable = {8, 7, 6, 5}
local reelAssistantMarker = mod:AddMarkerOption(false, "npc", reelAssistantMarkerMapTable[1], -30085, unpack(reelAssistantMarkerMapTable))
function mod:GetOptions()
	return {
		reelAssistantMarker,
		"stages",
		460181, -- Pay-Line
			460444, -- High Roller!
		469993, -- Foul Exhaust
		460472, -- The Big Hit

		-- Stage One: That's RNG, Baby!
		461060, -- Spin To Win!
			464776, -- Fraud Detected!
			"tokens", -- Insert Tokens
			"rewards", -- Fabulous Prizes
				-- Reward: Shock and Flame
				-- Reward: Shock and Bomb
				-- Reward: Coin and Bomb
				-- Reward: Flame and Bomb
				{465009, "NAMEPLATE"}, -- Explosive Gaze
				-- Reward: Flame and Coin
				-- Reward: Coin and Shock
				474665, -- Coin Magnet
			-- Reel Assistant
			{460582, "NAMEPLATE"}, -- Overload! (interrupt)
			{471927, "NAMEPLATE"}, -- Withering Flames (dispel)
			-- 460847, -- Electric Blast

		-- Stage Two: This Game Is Rigged
		465765, -- Maintenance Cycle
		465761, -- Rig the Game!
		465432, -- Linked Machines
		"hyper_coil_timer",
		{465322, "PRIVATE"}, -- Hot Hot Hot
		"hot_hot_heat_timer",
		465580, -- Scattered Payout
		{465587, "CASTBAR"}, -- Explosive Jackpot
	},{
		[461060] = -30083, -- Stage 1
		[465765] = -30086, -- Stage 2
	},{
		[460472] = L.the_big_hit,
		[461060] = CL.adds,
		[465009] = {CL.fixate, "fixate_nameplate"}, -- Explosive Gaze (Fixate)
		[469993] = CL.heal_absorbs, -- Foul Exhaust (Heal Absorbs)
		["hyper_coil_timer"] = {nil, "hyper_coil_spawn"},
		["hot_hot_heat_timer"] = {nil, "hot_hot_head_beams"},
	}
end

function mod:OnBossEnable()
	-- Stage One: That's RNG, Baby!
	self:Log("SPELL_CAST_START", "PayLineStart", 460181)
	self:Log("SPELL_CAST_SUCCESS", "PayLine", 460181)
	self:Log("SPELL_AURA_APPLIED", "HighRollerApplied", 460444)
	self:Log("SPELL_AURA_REFRESH", "HighRollerApplied", 460444)
	self:Log("SPELL_CAST_START", "FoulExhaust", 469993)
	self:Log("SPELL_CAST_START", "TheBigHit", 460472)
	self:Log("SPELL_CAST_SUCCESS", "TheBigHitSuccess", 460472)
	self:Log("SPELL_AURA_APPLIED", "TheBigHitApplied", 460472)

	self:Log("SPELL_CAST_START", "SpinToWin", 461060)
	-- Insert Tokens
	self:Log("SPELL_CAST_SUCCESS", "Tokens",
		472882, -- Insert Shock Token
		472886, -- Insert Flame Token
		472868, -- Insert Bomb Token
		472889  -- Insert Coin Token
	)
	self:Log("SPELL_CAST_START", "FraudDetected", 464776)
	self:Log("SPELL_CAST_START", "Rewards",
		464772, -- Shock and Flame
		464801, -- Shock and Bomb
		464804, -- Flame and Bomb
		464806, -- Flame and Coin
		464809, -- Coin and Shock
		464810  -- Coin and Bomb
	)

	-- Fabulous Prizes followups
	self:Log("SPELL_AURA_APPLIED", "ExplosiveGazeApplied", 465009)
	self:Log("SPELL_AURA_REMOVED", "ExplosiveGazeRemoved", 465009)
	self:Log("SPELL_CAST_SUCCESS", "CoinMagnet", 474665)

	-- Reel Assistant
	self:Log("SPELL_AURA_APPLIED", "SpinToWinApplied", 471720) -- Add spawn
	self:Log("SPELL_CAST_START", "Overload", 460582)
	self:Log("SPELL_INTERRUPT", "OverloadInterrupt", 460582)
	self:Log("SPELL_CAST_SUCCESS", "OverloadSuccess", 460582)
	self:Log("SPELL_CAST_SUCCESS", "WitheringFlames", 471930)
	self:Log("SPELL_AURA_APPLIED", "WitheringFlamesApplied", 471927)
	self:Death("ReelAssistantDeath", 232599, 228463) -- Reel Assistants (on pull, spawned)

	-- Stage Two: This Game Is Rigged!
	self:Log("SPELL_CAST_SUCCESS", "MaintenanceCycle", 465765)
	self:Log("SPELL_CAST_START", "RigTheGame", 465761)
	self:Log("SPELL_CAST_START", "LinkedMachines", 465432)
	self:Log("SPELL_CAST_START", "HotHotHeat", 465322)
	self:Log("SPELL_CAST_START", "ScatteredPayout", 465580)
	self:Log("SPELL_CAST_START", "ExplosiveJackpot", 465587)
end

function mod:OnEngage()
	self:SetStage(1)

	spinToWinCount = 1
	payLineCount = 1
	foulExhaustCount = 1
	theBigHitCount = 1

	fullPayLineCount = 1
	fullFoulExhaustCount = 1
	fullTheBigHitCount = 1

	lastReward = nil
	tokenCount = 0
	mobCollector = {}
	mobMark = 1

	if not self:Easy() then
		payLineCD = self:Mythic() and 4.5 or 5.9
		self:CDBar(460181, payLineCD, CL.count:format(self:SpellName(460181), fullPayLineCount)) -- Pay-Line
	end
	self:CDBar(469993, self:Mythic() and 8.1 or self:Easy() and 8.4 or 9.9, CL.count:format(self:SpellName(469993), fullFoulExhaustCount)) -- Foul Exhaust
	self:CDBar(461060, self:Mythic() and 14.2 or 18.9, CL.count:format(self:SpellName(461060), spinToWinCount)) -- Spin To Win!
	self:CDBar(460472, self:Mythic() and 20.8 or self:Easy() and 17.1 or 22.3, CL.count:format(("%s [Left]"):format(self:SpellName(460472)), fullTheBigHitCount)) -- The Big Hit

	if self:GetOption(reelAssistantMarker) then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	for i = 1, 8 do
		local unit = ("boss%d"):format(i)
		local guid = self:UnitGUID(unit)
		if mobCollector[guid] then -- Reel Assistant
			local icon = reelAssistantMarkerMapTable[mobCollector[guid]]
			self:CustomIcon(reelAssistantMarker, unit, icon)
			mobCollector[guid] = false
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:GetHealth(unit) < 33 then -- Forced Stage 2 at 30%
		self:UnregisterUnitEvent(event, unit)
		self:Message("stages", "cyan", CL.soon:format(CL.stage:format(2)), false)
		self:PlaySound("stages", "info")
	end
end

-- Stage 1

function mod:PayLineStart(args)
	self:Bar(args.spellId, { 1, payLineCD }, CL.count:format(args.spellName, fullPayLineCount))
end

function mod:PayLine(args)
	self:StopBar(CL.count:format(args.spellName, fullPayLineCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, fullPayLineCount))
	self:PlaySound(args.spellId, "alert") -- Dodge coin path and get close
	payLineCount = payLineCount + 1
	fullPayLineCount = fullPayLineCount + 1

	if self:Easy() and self:GetStage() == 1 then
		payLineCD = 0 -- 1 per reward
	elseif self:GetStage() == 2 then
		if self:Easy() then
			payLineCD = 36.2
		else
			local timer = { 24.6, 36.7 }
			payLineCD = timer[payLineCount]
		end
	elseif payLineCount < 3 then
		payLineCD = self:Mythic() and 26.8 or 31.8
	end
	self:CDBar(args.spellId, payLineCD, CL.count:format(args.spellName, fullPayLineCount))
end

do
	local prev = 0
	function mod:HighRollerApplied(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:Message(args.spellId, "green", CL.you:format(args.spellName))
			self:PlaySound(args.spellId, "info") --	buffed
		end
	end
end

function mod:FoulExhaust(args)
	self:StopBar(CL.count:format(args.spellName, fullFoulExhaustCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, fullFoulExhaustCount))
	self:PlaySound(args.spellId, "alert") -- debuffs inc
	foulExhaustCount = foulExhaustCount + 1
	fullFoulExhaustCount = fullFoulExhaustCount + 1

	local cd
	if self:GetStage() == 2 then
		if self:Easy() then
			cd = 25.6
		else
			local timer = { 17.5, 25.7, 30.5 }
			cd = timer[foulExhaustCount]
		end
	elseif foulExhaustCount < 3 then
		if not self:Mythic() then
			cd = (lastReward == nil and self:Easy() and 0) or 31 -- 31.2~33.3
		else
			cd = lastReward == nil and 34.2 or 32.8
		end
	end
	self:CDBar(args.spellId, cd, CL.count:format(args.spellName, fullFoulExhaustCount))
end

function mod:TheBigHit(args)
	local text = ("%s [%s]"):format(args.spellName, fullTheBigHitCount % 2 == 1 and "Left" or "Right")
	self:Bar(args.spellId, {2.5, 20.6}, CL.count:format(text, fullTheBigHitCount))
end

function mod:TheBigHitSuccess(args)
	local text = ("%s [%s]"):format(args.spellName, fullTheBigHitCount % 2 == 1 and "Left" or "Right")
	self:StopBar(CL.count:format(text, fullTheBigHitCount))
	self:Message(args.spellId, "purple", CL.count:format(text, fullTheBigHitCount))
	local unit = self:UnitTokenFromGUID(args.sourceGUID)
	if unit and self:Tanking(unit) then
		self:PlaySound(args.spellId, "alarm") -- defensive
	end
	theBigHitCount = theBigHitCount + 1
	fullTheBigHitCount = fullTheBigHitCount + 1

	local cd
	if self:GetStage() == 2 then
		if self:Easy() then
			cd = 25.6
		else
			local timer = { 28.5, 20.9, 18.3, 17.9 }
			cd = timer[theBigHitCount]
		end
	elseif theBigHitCount < 4 then -- 3 per normal
		if self:Heroic() and lastReward == 464804 then -- Flame and Bomb
			cd = 32.0
		elseif not self:Mythic() then
			cd = lastReward == nil and (self:Easy() and 0 or 18.9) or 19.6
		else -- mythic
			cd = lastReward == nil and 18.2 or 20.6
		end
	end
	self:CDBar(args.spellId, cd, CL.count:format(("%s [%s]"):format(args.spellName, fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount))
end

function mod:TheBigHitApplied(args)
	if self:Tank() then
		self:TargetMessage(args.spellId, "purple", args.destName)
		local unit = self:UnitTokenFromGUID(args.sourceGUID)
		if unit and not self:Tanking(unit) then -- XXX Confirm swap on 1
			self:PlaySound(args.spellId, "warning") -- tauntswap
		end
	end
end

function mod:SpinToWin(args)
	self:StopBar(CL.count:format(args.spellName, spinToWinCount))
	self:Message(args.spellId, "cyan", CL.count:format(args.spellName, spinToWinCount))
	self:PlaySound(args.spellId, "long") -- adds inc
	spinToWinCount = spinToWinCount + 1
	tokenCount = 0
	mobMark = 1

	self:Bar(471927, self:Easy() and 20.6 or 17) -- Withering Flames
	self:Bar(464776, 32) -- Fraud Detected

	local cd = self:Mythic() and 52.3 or self:Easy() and 87 or 61.2
	if spinToWinCount < 8 then
		self:CDBar(args.spellId, cd, CL.count:format(args.spellName, spinToWinCount))
	-- elseif spinToWinCount == 7 then
	-- 	self:CDBar(args.spellId, cd, CL.stage:format(2))
	end
end

function mod:Tokens(args)
	tokenCount = tokenCount + 1
	if tokenCount == 1 then
		local message = { --> Locked In: <Token>
			[472882] = self:SpellName(472075), -- Insert Shock Token
			[472886] = self:SpellName(472078), -- Insert Flame Token
			[472868] = self:SpellName(472080), -- Insert Bomb Token
			[472889] = self:SpellName(472079), -- Insert Coin Token
		}
		self:Message("tokens", "green", message[args.spellId] or args.spellName, args.spellId)
		-- self:PlaySound("tokens", "info")
	end
end

function mod:FraudDetected(args)
	self:StopBar(args.spellId)
	self:StopBar(471927) -- Withering Flames
	self:StopBar(CL.count:format(self:SpellName(460181), fullPayLineCount)) -- Pay-Line
	self:StopBar(CL.count:format(self:SpellName(469993), fullFoulExhaustCount)) -- Foul Exhaust
	self:StopBar(CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount)) -- The Big Hit

	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- TILT TILT TILT!

	lastReward = args.spellId
	payLineCount = 1
	foulExhaustCount = 1
	theBigHitCount = 1

	payLineCD = 6.7
	self:CDBar(460181, payLineCD, CL.count:format(self:SpellName(460181), fullPayLineCount))
	self:CDBar(469993, 10.6, CL.count:format(self:SpellName(469993), fullFoulExhaustCount))
	self:CDBar(460472, 19.3, CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount))
end

function mod:Rewards(args)
	self:StopBar(471927) -- Withering Flames
	self:StopBar(CL.count:format(self:SpellName(460181), fullPayLineCount)) -- Pay-Line
	self:StopBar(CL.count:format(self:SpellName(469993), fullFoulExhaustCount)) -- Foul Exhaust
	self:StopBar(CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount)) -- The Big Hit
	self:StopBar(464776) -- Fraud Detected

	self:Message("rewards", "cyan", args.spellName, args.spellId)
	self:PlaySound("rewards", "long") -- Rewards incoming

	lastReward = args.spellId
	payLineCount = 1
	foulExhaustCount = 1
	theBigHitCount = 1

	-- move left over add to backup kick mark
	local guid = self:UnitGUID("boss2")
	if guid and mobCollector[guid] == false then -- Reel Assistant
		self:CustomIcon(reelAssistantMarker, "boss2", reelAssistantMarkerMapTable[4])
	end

	local isFlameAndCoin = lastReward == 464806 -- Flame and Coin extra channel delay
	local foulExhaustCD, theBigHitCD
	if self:Easy() then
		payLineCD = isFlameAndCoin and 25.6 or 23.7
		foulExhaustCD = isFlameAndCoin and 11.3 or 9.7
		theBigHitCD = isFlameAndCoin and 14.9 or 19.1
	elseif self:Heroic() then
		payLineCD = isFlameAndCoin and 12.8 or 6.9
		foulExhaustCD = isFlameAndCoin and 16.4 or 10.8
		theBigHitCD = isFlameAndCoin and 24.7 or 19.6
	else -- if self:Mythic() then
		payLineCD = isFlameAndCoin and 12.7 or 5.8
		foulExhaustCD = isFlameAndCoin and 16.6 or 9.7
		theBigHitCD = isFlameAndCoin and 27.4 or 18.3
	end
	self:CDBar(460181, payLineCD, CL.count:format(self:SpellName(460181), fullPayLineCount))
	self:CDBar(469993, foulExhaustCD, CL.count:format(self:SpellName(469993), fullFoulExhaustCount))
	self:CDBar(460472, theBigHitCD, CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount))
end

function mod:ExplosiveGazeApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "warning") -- fixated
		self:Nameplate(args.spellId, 0, args.sourceGUID, L.fixate_nameplate)
	end
end

function mod:ExplosiveGazeRemoved(args)
	if self:Me(args.destGUID) then
		self:StopNameplate(args.spellId, args.sourceGUID, L.fixate_nameplate)
	end
end

function mod:CoinMagnet(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alert") -- getting pulled in
end

function mod:SpinToWinApplied(args) -- Add spawn
	if mobCollector[args.destGUID] == nil then
		mobCollector[args.destGUID] = mobMark
		mobMark = mobMark + 1
		self:Nameplate(460582, 16.2, args.destGUID) -- Overload!
	end
end

function mod:Overload(args)
	local canDo, ready = self:Interrupter(args.sourceGUID)
	if canDo and ready then
		self:Message(args.spellId, "yellow")
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:OverloadInterrupt(args)
	self:Nameplate(460582, 21.9, args.destGUID)
end

function mod:OverloadSuccess(args)
	self:Nameplate(args.spellId, 21.9, args.sourceGUID)
end

do
	local prev = 0
	function mod:WitheringFlames(args)
		self:StopBar(471927) -- Initial bar for all casts
		if args.time - prev > 2 then
			prev = args.time
			self:Message(471927, "orange")
			self:PlaySound(471927, "alert") -- debuffs inc
		end
		self:Nameplate(471927, 16.4, args.sourceGUID)
	end
end

function mod:WitheringFlamesApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "warning") -- debuff
		-- self:Say(args.spellId, L.withering_flames_say, nil, "Flames")
	end
end

function mod:ReelAssistantDeath(args)
	self:ClearNameplate(args.destGUID)
end

-- Stage Two: This Game Is Rigged!

function mod:MaintenanceCycle(args)
	self:StopBar(471927) -- Withering Flames
	self:StopBar(464776) -- Fraud Detected
	self:StopBar(CL.stage:format(2))
	self:StopBar(CL.count:format(self:SpellName(461060), spinToWinCount)) -- Spin To Win!
	self:StopBar(CL.count:format(self:SpellName(460181), fullPayLineCount)) -- Pay-Line
	self:StopBar(CL.count:format(self:SpellName(469993), fullFoulExhaustCount)) -- Foul Exhaust
	self:StopBar(CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount)) -- The Big Hit
	self:UnregisterUnitEvent("UNIT_HEALTH", "boss1")

	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "long")

	payLineCount = 1
	foulExhaustCount = 1
	theBigHitCount = 1

	fullPayLineCount = 1
	fullFoulExhaustCount = 1
	fullTheBigHitCount = 1

	self:Bar(args.spellId, 6, CL.stunned) -- Stunned
	self:CDBar(465432, 13.1) -- Cheat to Win - Linked Machines
	self:CDBar(469993, self:Mythic() and 18.3 or 17.5, CL.count:format(self:SpellName(469993), fullFoulExhaustCount)) -- Foul Exhaust
	payLineCD = self:Mythic() and 24.9 or 24.2
	self:CDBar(460181, payLineCD, CL.count:format(self:SpellName(460181), fullPayLineCount)) -- Pay-Line
	self:CDBar(460472, self:Mythic() and 31.8 or 31.8, CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount)) -- The Big Hit

	self:CDBar(465587, self:Easy() and 104 or 90) -- Cheat to Win -> Explosive Jackpot
end

function mod:RigTheGame(args)
	self:Message(args.spellId, "red")
	if spinToWinCount < 7 then
		self:PlaySound(args.spellId, "warning") -- all coils activating soon
	end
end

function mod:LinkedMachines(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "cyan", CL.count_amount:format(args.spellName, 1, 4))
	self:PlaySound(args.spellId, "long") -- electric links inc

	hyperCoilCount = 1
	self:Bar("hyper_coil_timer", 5, CL.count:format(L.hyper_coil_spawn, hyperCoilCount), L.hyper_coil_timer_icon)
	timerHandles["LinkedMachinesRepeater"] = self:ScheduleTimer("LinkedMachinesRepeater", 5)

	self:CDBar(465322, self:Easy() and 30.5 or 25.5) -- Cheat to Win -> Hot Hot Heat
end

function mod:LinkedMachinesRepeater()
	self:Message("hyper_coil_timer", "orange", CL.incoming:format(CL.count:format(L.hyper_coil_spawn, hyperCoilCount)), L.hyper_coil_timer_icon)
	self:PlaySound("hyper_coil_timer", "info")

	hyperCoilCount = hyperCoilCount + 1
	local cd = self:Easy() and 21 or 18
	self:Bar("hyper_coil_timer", cd, CL.count:format(L.hyper_coil_spawn, hyperCoilCount), L.hyper_coil_timer_icon)
	timerHandles["LinkedMachinesRepeater"] = self:ScheduleTimer("LinkedMachinesRepeater", cd)
end

function mod:HotHotHeat(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "cyan", CL.count_amount:format(args.spellName, 2, 4))
	self:PlaySound(args.spellId, "long") -- fire lines inc

	hotHotHeatCount = 1
	local cd = 8 -- applied at 3s + 5s debuff
	self:Bar("hot_hot_heat_timer", cd, CL.count:format(L.hot_hot_head_beams, hotHotHeatCount), L.hot_hot_heat_timer_icon)
	timerHandles["HotHotHeatRepeater"] = self:ScheduleTimer("HotHotHeatRepeater", cd)

	self:CDBar(465580, self:Easy() and 30.5 or 24.6) -- Cheat to Win -> Scattered Payout
end

function mod:HotHotHeatRepeater()
	hotHotHeatCount = hotHotHeatCount + 1
	local cd = 12
	self:Bar("hot_hot_heat_timer", cd, CL.count:format(L.hot_hot_head_beams, hotHotHeatCount), L.hot_hot_heat_timer_icon)
	timerHandles["HotHotHeatRepeater"] = self:ScheduleTimer("HotHotHeatRepeater", cd)
end

function mod:ScatteredPayout(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "cyan", CL.count_amount:format(args.spellName, 3, 4))
	self:PlaySound(args.spellId, "long") -- ticking damage inc
	-- damage is every 2s, don't need a timer
	-- self:CDBar(465587, self:Easy() and 30.5 or 25.9) -- Cheat to Win -> Explosive Jackpot
end

function mod:ExplosiveJackpot(args)
	self:StopBar(args.spellId)
	self:StopBar(CL.count:format(self:SpellName(460181), fullPayLineCount)) -- Pay-Line
	self:StopBar(CL.count:format(self:SpellName(469993), fullFoulExhaustCount)) -- Foul Exhaust
	self:StopBar(CL.count:format(("%s [%s]"):format(self:SpellName(460472), fullTheBigHitCount % 2 == 1 and "Left" or "Right"), fullTheBigHitCount)) -- The Big Hit

	self:Message(args.spellId, "red", CL.count_amount:format(args.spellName, 4, 4))
	self:PlaySound(args.spellId, "alarm") -- enrage
	self:CastBar(args.spellId, 10)
end
