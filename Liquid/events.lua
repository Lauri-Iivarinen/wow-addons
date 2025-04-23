---@diagnostic disable: inject-field
local addonName, ns = ...
ns.events = CreateFrame('Frame')
ns.events:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)
local f = ns.events
ns.InLoadingScreen = true
local weeklyEventFuncs = {}
local weeklyResetSeen = false
local function HandleWeeklyReset(resetTime)
  weeklyResetSeen = true
  ns.PrintDebug("Weekly reset triggered")
  for id, func in pairs(weeklyEventFuncs) do
    ns.PrintDebug("Weekly reset func running - Func id: %s", id)
    func(resetTime)
  end
end
local checkForWeeklyReset = true
local previousWeeklyResetTime
local function CheckForWeeklyReset()
  if not checkForWeeklyReset then return end
  local currentResetTime = C_DateAndTime.GetWeeklyResetStartTime()
  if not previousWeeklyResetTime then
    if not LiquidCharDB.lastWeeklyReset then
      HandleWeeklyReset(currentResetTime)
      LiquidCharDB.lastWeeklyReset = currentResetTime
    elseif LiquidCharDB.lastWeeklyReset < currentResetTime then
      HandleWeeklyReset(currentResetTime)
      LiquidCharDB.lastWeeklyReset = currentResetTime
    end
    previousWeeklyResetTime = currentResetTime
    local timeSinceReset = GetServerTime()-currentResetTime
    if timeSinceReset < 561600 then -- 6.5 days, only care about reset if its gonna be in the next 12 hours
      ns.PrintDebug("Weekly reset is too far away to care about: %s", timeSinceReset)
      checkForWeeklyReset = false
    end
    return
  end
  if previousWeeklyResetTime >= currentResetTime then return end
  -- weekly reset
  HandleWeeklyReset(currentResetTime)
  LiquidCharDB.lastWeeklyReset = currentResetTime
  previousWeeklyResetTime = currentResetTime
  checkForWeeklyReset = false
end
function ns.addToWeeklyReset(id, func)
  if weeklyResetSeen then -- we are addung function after we already seen the reset during this session, run it right away
    ns.PrintDebug("Running weekly reset function that was added after reset was already seen - func id: %s", id)
    func(previousWeeklyResetTime)
  end
  if not weeklyEventFuncs[id] then
    weeklyEventFuncs[id] = func
  end
end

local handleAfterLoadingScreen = {}
function ns.dealAfterLoadingScreen(func, args)
  table.insert(handleAfterLoadingScreen, {func = func, args = args})
end
local function dealAfterLoadingScreen()
  for _,v in pairs(handleAfterLoadingScreen) do
    if v.args then
      v.func(unpack(v.args))
    else
      v.func()
    end
  end
  wipe(handleAfterLoadingScreen)
end
f:RegisterEvent("CHAT_MSG_ADDON")
function f:CHAT_MSG_ADDON(...)
  ns.main:CHAT_MSG_ADDON(...)
  ns.cooldowns:CHAT_MSG_ADDON(...)
end

f:RegisterEvent("ADDON_LOADED")
function f:ADDON_LOADED(...)
  ns.main:ADDON_LOADED(...)
end

f:RegisterEvent("PLAYER_LOGIN")
function f:PLAYER_LOGIN(...)
  ns.main:PLAYER_LOGIN(...)
  ns.cooldowns:CreateMacros()
  CheckForWeeklyReset()
end

f:RegisterEvent("LOADING_SCREEN_ENABLED")
function f:LOADING_SCREEN_ENABLED()
  ns.InLoadingScreen = true
end

f:RegisterEvent("LOADING_SCREEN_DISABLED")
function f:LOADING_SCREEN_DISABLED()
  ns.InLoadingScreen = false
  dealAfterLoadingScreen()
end

f:RegisterEvent("GROUP_FORMED")
function f:GROUP_FORMED(...)
  ns.main:GROUP_FORMED(...)
end

f:RegisterEvent("CURRENCY_TRANSFER_LOG_UPDATE")
function f:CURRENCY_TRANSFER_LOG_UPDATE()
  if not IsInGuild() then return end
  C_ChatInfo.SendAddonMessage('Liquid', "currencyTransfer", "guild")
end

if ns.configs.cacheCharacters then
  f:RegisterEvent("PLAYER_LEVEL_UP")
  function f:PLAYER_LEVEL_UP(...)
    ns.main:PLAYER_LEVEL_UP(...)
  end
end
function ns:LoadEvents(cooldownsOnly)
  do
    f:RegisterEvent("QUEST_LOG_UPDATE")
    function f:QUEST_LOG_UPDATE()
      CheckForWeeklyReset()
      if not checkForWeeklyReset then
        f:UnregisterEvent("QUEST_LOG_UPDATE")
      end
    end
  end
  if not cooldownsOnly and ns.configs.cacheCharacters then
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    function f:PLAYER_EQUIPMENT_CHANGED(...)
      ns.characterCaching:PLAYER_EQUIPMENT_CHANGED(...)
      ns.characterCaching:CacheSimc("Current Set", "current")
    end
    
    f:RegisterEvent("PLAYER_LEAVING_WORLD")
    function f:PLAYER_LEAVING_WORLD(...)
      ns.characterCaching:PLAYER_LEAVING_WORLD(...)
    end
    
    f:RegisterEvent("UPDATE_FACTION")
    function f:UPDATE_FACTION(...)
      ns.characterCaching:UPDATE_FACTION(...)
    end

    f:RegisterEvent("BAG_UPDATE_DELAYED")
    function f:BAG_UPDATE_DELAYED(...)
      if ns.configs.lootTracking then
        ns.items:BAG_UPDATE_DELAYED(...)
      end
      ns.characterCaching:BAG_UPDATE_DELAYED(...)
    end
    if ns.configs.lootTracking then
      f:RegisterEvent("START_LOOT_ROLL")
      function f:START_LOOT_ROLL(...)
        ns.items:START_LOOT_ROLL(...)
      end
    end
    f:RegisterEvent("BANKFRAME_OPENED")
    function f:BANKFRAME_OPENED()
      ns.characterCaching:BANKFRAME_OPENED()
    end
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    function f:PLAYER_REGEN_ENABLED()
      ns.characterCaching:PLAYER_REGEN_ENABLED()
    end
    f:RegisterEvent("PVP_RATED_STATS_UPDATE")
    function f:PVP_RATED_STATS_UPDATE(...)
      ns.characterCaching:PVP_RATED_STATS_UPDATE(...)
    end
    f:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    function f:WEEKLY_REWARDS_UPDATE(...)
      CheckForWeeklyReset()
      ns.characterCaching:WEEKLY_REWARDS_UPDATE(...)
    end
    f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    function f:CURRENCY_DISPLAY_UPDATE(...)
      ns.characterCaching:CURRENCY_DISPLAY_UPDATE(...)
    end

    f:RegisterEvent("SKILL_LINE_SPECS_RANKS_CHANGED")
    function f:SKILL_LINE_SPECS_RANKS_CHANGED()
      ns.characterCaching:CacheProfessions()
    end
    f:RegisterEvent("UPDATE_INSTANCE_INFO")
    function f:UPDATE_INSTANCE_INFO(...)
      CheckForWeeklyReset()
      ns.characterCaching:UPDATE_INSTANCE_INFO(...)
    end
    if ns.configs.lootTracking then
      function f:UNIT_SPELLCAST_SUCCEEDED(...)
        ns.items:UNIT_SPELLCAST_SUCCEEDED(...)
      end
      f:RegisterEvent("TRADE_SHOW")
      function f:TRADE_SHOW(...)
        ns.items:TRADE_SHOW(...)
      end
      f:RegisterEvent("LOOT_ITEM_ROLL_WON")
      function f:LOOT_ITEM_ROLL_WON(...)
        ns.items:LOOT_ITEM_ROLL_WON(...)
      end
      f:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
      function f:ENCOUNTER_LOOT_RECEIVED(...)
        ns.items:ENCOUNTER_LOOT_RECEIVED(...)
      end
    end
    f:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    function f:CHALLENGE_MODE_MAPS_UPDATE(...)
      CheckForWeeklyReset()
      ns.characterCaching:CHALLENGE_MODE_MAPS_UPDATE(...)
    end
  end
  ns.cooldowns:LoggedIn() -- init cooldowns
  f:RegisterEvent("GROUP_JOINED")
  function f:GROUP_JOINED(...)
    ns.cooldowns:GROUP_JOINED(...)
  end
  f:RegisterEvent("GROUP_LEFT")
  function f:GROUP_LEFT(...)
    ns.cooldowns:GROUP_LEFT(...)
  end
  f:RegisterEvent("GROUP_ROSTER_UPDATE")
  function f:GROUP_ROSTER_UPDATE(...)
    ns.cooldowns:GROUP_ROSTER_UPDATE(...)
  end
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  function f:COMBAT_LOG_EVENT_UNFILTERED(...)
    ns.cooldowns:COMBAT_LOG_EVENT_UNFILTERED(...)
  end
  f:RegisterEvent("TRAIT_CONFIG_UPDATED")
  function f:TRAIT_CONFIG_UPDATED(...)
    ns.cooldowns:TRAIT_CONFIG_UPDATED(...)
    if ns.configs.cacheCharacters then
      ns.characterCaching:TRAIT_CONFIG_UPDATED(...)
    end
    if not cooldownsOnly and ns.configs.cacheCharacters then
      ns.PrintDebug("Caching current set - reason: TRAIT_CONFIG_UPDATED")
      ns.characterCaching:CacheSimc("Current Set", "current")
    end
  end
  f:RegisterEvent("TRAIT_CONFIG_LIST_UPDATED")
  function f:TRAIT_CONFIG_LIST_UPDATED(...)
    ns.cooldowns:TRAIT_CONFIG_LIST_UPDATED(...)
    if not cooldownsOnly and ns.configs.cacheCharacters then
      ns.PrintDebug("Caching current set - reason: TRAIT_CONFIG_LIST_UPDATED")
      ns.characterCaching:CacheSimc("Current Set", "current")
    end
  end
  f:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")
  function f:ACTIVE_COMBAT_CONFIG_CHANGED(...)
    ns.cooldowns:ACTIVE_COMBAT_CONFIG_CHANGED(...)
    if not cooldownsOnly and ns.configs.cacheCharacters then
      ns.PrintDebug("Caching current set - reason: ACTIVE_COMBAT_CONFIG_CHANGED")
      ns.characterCaching:CacheSimc("Current Set", "current")
    end
  end
  f:RegisterEvent("ENCOUNTER_START")
  function f:ENCOUNTER_START(...)
    ns.cooldowns:ENCOUNTER_START(...)
    if not cooldownsOnly then
      if ns.configs.lootTracking and ns.configs.cacheCharacters then
        ns.items:ENCOUNTER_START(...)
        f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") -- TODO figure out cheaper event to use
      end
    end
  end
  f:RegisterEvent("ENCOUNTER_END")
  function f:ENCOUNTER_END(...)
    ns.cooldowns:ENCOUNTER_END(...)
    if not cooldownsOnly then
      ns.main:ENCOUNTER_END(...)
      if ns.configs.lootTracking and ns.configs.cacheCharacters then
        ns.items:ENCOUNTER_END(...)
        f:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED") -- TODO figure out cheaper event to use
      end
      if ns.configs.cacheCharacters then
        ns.characterCaching:ENCOUNTER_END(...)
      end
    end
  end
  f:RegisterEvent("CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE")
  function f:CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE(...)
    ns.utility:CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE(...)
  end
end

--[[
UNIT_MODEL_CHANGED ?
LFG_LOCK_INFO_RECEIVED
LFG_UPDATE_RANDOM_INFO
INSTANCE_LOCK_STOP
CALENDAR_UPDATE_EVENT_LIST
--]]
