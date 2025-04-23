local _an, ns = ...
--TODO add votes under db.votes with [characterName] = positive (true/false)
LiquidDB = LiquidDB or {}
LiquidCharDB = LiquidCharDB or {}
ns.me = {
	currentCharName = UnitName('player'),
	guid = UnitGUID('player'),
}
ns.main = {}
do
	local _,btag = BNGetInfo()
	if ns.debugMode then
		if not IRONI_DEBUG_TABLE then
			IRONI_DEBUG_TABLE = {}
		end
		IRONI_DEBUG_TABLE["BattleTag from Liquid"] = btag or "nil"
	end
	-- in case something weird happens
	if btag then
		ns.btag = btag
		ns.me.btag = btag
	end
end
do
	local _v = C_AddOns.GetAddOnMetadata(_an, "version")
	local _major,_minor,_patch = _v:match("^(%d-)%.(%d-)%.(%d+)")
	ns.version = {
		str = _v,
		major = tonumber(_major),
		minor = tonumber(_minor),
		patch = tonumber(_patch),
	}
end

local currentCharName = UnitName('player'):lower()
C_ChatInfo.RegisterAddonMessagePrefix('Liquid')
C_ChatInfo.RegisterAddonMessagePrefix('LiquidWA')
C_ChatInfo.RegisterAddonMessagePrefix('LiquidSplits')

local listening = false
local listeningForSyncDebugs = false
local autoProfilingWA = false
ns.playerGUID = UnitGUID('player')
ns.playerClass = select(2, UnitClass('player'))
local sformat, SendAddonMessage, tconcat = string.format, C_ChatInfo.SendAddonMessage, table.concat

function ns:spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
-- otherwise just sort the keys
	if order then
			table.sort(keys, function(a,b) return order(t, a, b) end)
	else
			table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
			i = i + 1
			if keys[i] then
					return keys[i], t[keys[i]]
			end
	end
end
StaticPopupDialogs.LIQUID_WARNING_1 = {
	text = "%s",
	button1 = OKAY,
	hideOnEscape = true,
}
StaticPopupDialogs.LIQUID_WARNING_2 = {
	text = "%s",
	button1 = OKAY,
	hideOnEscape = true,
}
StaticPopupDialogs.LIQUID_WARNING_3 = {
	text = "%s",
	button1 = OKAY,
	hideOnEscape = true,
}
function ns:DisableDevMode()
	LiquidDB.dev = false
	for _,v in pairs({"overview", "dev", "production"}) do
		if LiquidDB.WeakAuraRoles[v] then
			LiquidDB.WeakAuraRoles[v] = false
			print("WeakAuras role disabled:", ns:GetFormatedRoleText(v))
		end
	end
	print("Liquid: Developer mode disabled.")
end

local checkedMembersForSplits = {}
local function checkSplitMembers()
	print("Liquid: Checking raid members for WA.")
	local fails = false
	for i = 1, GetNumGroupMembers() do
		local g = UnitGUID("raid"..i)
		if g and not checkedMembersForSplits[g] then
			if not fails then
				print("Players missing WA:")
				fails = true
			end
			local n = UnitFullName("raid"..i)
			print(n)
		end
	end
	if not fails then
		print("Liquid: all okay.")
	end
end
function ns.main:CHAT_MSG_ADDON(prefix,msg,chatType,sender)
	if prefix == "LiquidWA" then
		if WeakAuras then -- update displays
			local a,b = strsplit(";", msg, 2)
			WeakAuras.ScanEvents("LIQUID_CUSTOM_WA_SYNC", a,b, sender)
		end
	elseif prefix == "LiquidSplits" then
		if msg == "check" then
			--SendAddonMessage("LiquidSplits", UnitGUID('player'), "raid")
		else
			checkedMembersForSplits[msg] = true
		end
		return
	elseif prefix ~= 'Liquid' then return end
	if not msg then return end -- to filter out idiots
	if msg == 'userCheck' then
		local t = {}
		for k,v in ns:spairs(LiquidDB.WeakAuraRoles) do
			if v then
				tinsert(t,k)
			end
		end
		C_ChatInfo.SendAddonMessage('Liquid', string.format('userCheckReply3:%s:%s:%s:;%s', ns.version.str, LiquidWeakAurasAPI and LiquidWeakAurasAPI.Version.str or "0.0.0", BigWigsAPI and BigWigsAPI.GetVersion and select(2, BigWigsAPI:GetVersion()) or "0", tconcat(t, ";")), chatType)
	elseif msg == "auracheck" then
		--ns.handleHiddenAuras()
	elseif msg == "TradeSync" then
		--[[
		if not LiquidDB.identity then
			print("Liquid: setup your identity with >> /liquid identify YourIdentity <<")
			return
		end
		if LiquidDB.lastHistoryUpdate then -- fix error on accounts without any L60 chars
			sendInitSync()
		end
		--]]
	elseif msg == "TradeSyncFull" then
		--[[
		if not LiquidDB.identity then
			print("Liquid: setup your identity with >> /liquid identify YourIdentity <<")
			return
		end
		ns:AnnounceUpdate(nil, 0) --]]
	elseif msg == "requestbnet" then
		if ns.btag then
			SendAddonMessage("Liquid", sformat("bnet:%s", ns.btag), chatType)
		end
	elseif msg == "currencyTransfer" then
		ns.PrintDebug("Currency transfer by %s (%s)", LiquidAPI:GetName(sender), sender)
	elseif msg == "zonecheck" then
		local difID = select(3, GetInstanceInfo()) or 0
		SendAddonMessage("LiquidZone", difID, "guild")
	elseif msg:lower() == "syncdebug" then
		--print(LiquidAPI:GetServerTime(), GetServerTime())
		SendAddonMessage("Liquid", sformat("syncDebug:%s", LiquidAPI:GetServerTime()), "guild")
	elseif msg:match("^syncDebug") then
		if not listeningForSyncDebugs then return end
		local v = msg:gsub("syncDebug:", "")
		if not v then return end
		print(v, LiquidAPI:GetName(sender))
	elseif msg:match("^gimmeloot") then
		if not ns.configs.lootTracking then return end
		ns.items:AddToLootRoster(sender, msg)
	elseif msg:match("^lootCache") then
		if not ns.configs.lootTracking then return end
		ns.items:LootCaching(msg)
	elseif msg:match("^TradeSync;") then
		--[[
		local t = {strsplit(";", msg)}
		for k,v in pairs(t) do
			local id, _time = strsplit(":", v)
			if id == LiquidDB.identity then
				ns:AnnounceUpdate(nil, tonumber(_time))
			end
		end
		--]]
	elseif msg:match("^TradeSyncOK;") then
		if not LiquidDB.identity then return end
		if msg:find(";"..LiquidDB.identity..";") or msg:find(";"..LiquidDB.identity.."$") then
			--LiquidDB.lastOK = GetServerTime()
			--ns:updateOKSyncText()
		end
	elseif msg:match("^bnet:") then
		local btag = msg:sub(6)
		if btag == "" then return end
		local char = strsplit("-", sender)
		ns:AddNewNickname(btag:lower(), char)
	elseif msg:match("^MOTI;") then
		local _, name, source = strsplit(";", msg)
		if chatType ~= "GUILD" then
			print(string.format("%s tried to motivate %s.", source, name))
		else
			if not WeakAuras then return end
			WeakAuras.ScanEvents("LIQUID_MOTIVATION", name, source)
		end
	elseif msg:match("^GOODHELPER;") then
		local _, group, name, source = strsplit(";", msg)
		if chatType ~= "GUILD" then
			print(string.format("%s praised %s.", source, name))
		else
			if not WeakAuras then return end
			WeakAuras.ScanEvents("LIQUID_MOTIVATION", name, source, group)
		end
	elseif msg:match("bugsack ") then
		msg = msg:lower()
		local nickNameFound = ns.me.nickname and ns.me.nickname ~= "" and msg:find(ns.me.nickname:lower())
		if (msg == "bugsack all" and not UnitIsUnit("player", strsplit("-", sender))) or nickNameFound or msg:find(currentCharName) then
			local errors = BugSack:GetErrors(BugGrabber:GetSessionId())
			SendAddonMessage("Liquid", "bugsackreport:"..#errors, "whisper", sender)
			if #errors > 0 then
				BugSack:SendBugsToUser(sender,BugGrabber:GetSessionId())
			end
		end
	elseif msg:match("^bugsackreport") then
		local errorCount = tonumber(msg:match("^bugsackreport:(%d*)"))
		if errorCount and errorCount > 0 then
			print(sformat("%s has %s errors for this session, they are sending them over which may take some time, depending on error count and length", LiquidAPI:GetName(sender), errorCount))
		else
			print(sformat("%s has no errors for this session.", LiquidAPI:GetName(sender)))
		end
	elseif listening and msg:match("^userCheckReply3") then
		local v = msg:gsub("userCheckReply3:", "")
		if v then -- nil check to filter out idiots
			local liquidV,liquidWAV,BWV, roles = strsplit(":", v)
			local roles = {strsplit(";", roles)}
			local t = {}
			for _,role in ipairs(roles) do
				local atlas = ns:GetFormatedRoleText(role, true)
				tinsert(t, atlas and CreateAtlasMarkup(atlas.atlas, 20,20) or role)
			end
			local major,minor,patch = liquidV:match("^(%d-)%.(%d-)%.(%d+)")
			major = tonumber(major)
			minor = tonumber(minor)
			patch = tonumber(patch)
			local old = false
			if major < ns.version.major then
				old = true
			else
				if minor < ns.version.minor then
					old = true
				elseif patch < ns.version.patch then
					old = true
				end
			end
			local waMajor,waMinor,waPatch = liquidWAV:match("^(%d-)%.(%d-)%.(%d+)")
			waMajor = tonumber(waMajor)
			waMinor = tonumber(waMinor)
			waPatch = tonumber(waPatch)
			local waOld = false
			local liquidWAVersion = LiquidWeakAurasAPI and LiquidWeakAurasAPI.Version or {major = 0, minor = 0, patch = 0}
			if waMajor < liquidWAVersion.major then
				waOld = true
			else
				if waMinor < liquidWAVersion.minor then
					waOld = true
				elseif waPatch < liquidWAVersion.patch then
					waOld = true
				end
			end
			local currentBWGuildVersion = BigWigsAPI and BigWigsAPI.GetVersion and select(2, BigWigsAPI.GetVersion()) or 0
			local bwOld = false
			if tonumber(BWV) then
				if currentBWGuildVersion > tonumber(BWV) then
					bwOld = true
				end
			end
			print(string.format("|cff%s%s (%s) %s|r - |cff%sLiquidWA %s|r - |cff%sBigWigs %s|r - WARoles: %s",
				old and "ff0000" or "ffffff", LiquidAPI:GetName(sender), sender, liquidV,
				waOld and "ff0000" or "ffffff", liquidWAV,
				bwOld and "ff0000" or "ffffff", BWV,
				tconcat(t, " ")))
		end
	elseif listening and msg:find('userCheckReply') then -- unnecessary check for now, but use it so it will also work in future
		local v = msg:gsub("userCheckReply:", "")
		if v then -- nil check to filter out idiots
			local roles = {strsplit(";", v)}
			local t = {}
			for _,role in ipairs(roles) do
				local atlas = ns:GetFormatedRoleText(role, true)
				tinsert(t, atlas and CreateAtlasMarkup(atlas.atlas, 20,20) or role)
			end
			local major,minor,patch = v:match("^(%d-)%.(%d-)%.(%d+)")
			major = tonumber(major)
			minor = tonumber(minor)
			patch = tonumber(patch)
			local old = false
			if major < ns.version.major then
				old = true
			else
				if minor < ns.version.minor then
					old = true
				elseif patch < ns.version.patch then
					old = true
				end
			end
			print(string.format("|cff%s%s: %s|r", old and "ff0000" or "ffffff", sender, tconcat(t, " ")))
		end
	end
end
do -- ADDON_LOADED
	local isMRTSetuped = false
	local function setupMRT()
		if isMRTSetuped then return end
		isMRTSetuped = true
		local mrt = getglobal("MRTOptionsFrameMethod Raid Tools")
		--mrt.animLogo:SetTexture("Interface\\AddOns\\Liquid\\Media\\mrt_logo")
		--/script local i=getglobal("MRTOptionsFrameMethod Raid Tools")for k,v in pairs({i:GetRegions()}) do if v.GetTexture then print(v:GetTexture()) end end
		MRTOptionsFrame.modulesList.List[1].table = ""
		hooksecurefunc(MRTOptionsFrame.modulesList.List[1], 'SetText', function(self,txt)
			self:SetFormattedText("%s", "|cffffa800Weeb Raid Tools|r")
		end)
		GMRT.F:RegisterCallback("RaidCooldowns_Bar_TextName", function(_,_,d)
			if d and d.name then
				d.name = LiquidAPI:GetName(d.name)
			end
		end)
		--[===[
		for k,v in pairs({mrt:GetRegions()}) do
			if v.GetTexture then
				local a,b,c,d,e = v:GetPoint()
				if b == mrt.animLogo and a == "LEFT" and c == "RIGHT" then
					v:SetAlpha(0)
					break
				end
				--[=[ GetTexture() is returning fileIds in 10.0.0 for some reason?
				if v:GetTexture() == [[Interface\AddOns\MRT\media\logoname2]] then
					v:SetAlpha(0)
					break
				end
				--]=]
			end
		end
		--]===]
	end
	local waStuffSetuped = false
	function ns.main:ADDON_LOADED(addonName)
		if addonName == "Liquid" then
			--[[
			if LiquidDB.afk then
				ns.events:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', "player")
				--ns.events:UnregisterEvent("ADDON_LOADED")
			end
			--]]
			--[[
			if not LiquidDB.tradeableSlots then
				LiquidDB.tradeableSlots = {}
			end --]]
			--[[ if not LiquidDB.lootTrading then
				LiquidDB.lootTrading = {
					encounters = {},
					loot = {},
					cachedItems = {},
				}
			end --]]
			ns.debugMode = LiquidDB.debugMode
			if LiquidDB.version and LiquidDB.version.major then -- major version missing was Kultzipuppelit problem only
				if LiquidDB.version.major < 2 then
					for k,v in pairs(LiquidDB.tradeableSlots) do
						if v.domSockets then
							v.domSockets = nil
						end
						v.history = {
							Head = 0,
							Neck = 0,
							Shoulders = 0,
							Chest = 0,
							Belt = 0,
							Legs = 0,
							Boots = 0,
							Wrists = 0,
							Hands = 0,
							Ring = 0,
							Cloak = 0,
							Weapon = 0,
							Offhand = 0,
							Shield = 0,
						}
						if v.renowns then
							for renownID,renownData in pairs(v.renowns) do
									renownData.conduit = false
							end
						end
						v.currency = {0,0,0,0,0}
						v.tierSlots = {0,0,0,0,0} -- TODO remove with db3 clean up
						v.faction = "Horde" -- previously only tracked horde characters
						v.updated = 0
						if v.soulAsh then
							v.soulAsh = nil
						end
					end
					LiquidDB.lastOK = 0
					LiquidDB.lastHistoryUpdate = 0
					StaticPopup_Show("LIQUID_WARNING_1", "Liquid addon data has been reseted, please login your relevant characters and stay online for >30 seconds< on each character.")
				end
				if LiquidDB.version.major == 2 and LiquidDB.version.minor < 1 then
					LiquidDB.WeakAuraRoles = {}
					StaticPopup_Show("LIQUID_WARNING_2", "Liquid: Select your roles for weakauras **AFTER** cleaning old weakauras.\n/liquid.")
				elseif LiquidDB.version.major == 2 and LiquidDB.version.minor == 1 and LiquidDB.version.patch == 1 then
					for k,v in pairs(LiquidDB.WeakAuraRoles) do
						LiquidDB.WeakAuraRoles[k] = nil
					end
					StaticPopup_Show("LIQUID_WARNING_2", "Liquid addon ROLE data has been reseted, select roles **AFTER** cleaning old weakauras.")
				end
				if LiquidDB.version.major == 2 and LiquidDB.version.minor < 4 then
					LiquidDB.nicknames = {}
				end
				if LiquidDB.version.major == 2 and LiquidDB.version.minor < 6 then
					for k,v in pairs(LiquidDB.tradeableSlots) do
						v.history.Weapon = nil
						v.history.Offhand = nil
						v.history.Shield = nil
						if v.renowns then
							v.renowns = nil
						end
						v.currency = {0,0,0,0,0}
						v.level = 60
					end
				end
				if LiquidDB.version.major == 2 and LiquidDB.version.minor <= 7 and LiquidDB.version.patch < 7 then
					local timestamp = GetServerTime()-(14*24*60*60) -- 14 days in seconds
					local toDelete = {}
					for k,v in pairs(LiquidDB.tradeableSlots) do
						if not v.updated or v.updated < timestamp then
							toDelete[k] = true
						else
							v.history.tierSlots = {0,0,0,0,0,0,0,0} -- TODO remove with db3 clean up
							v.updated = GetServerTime()
						end
					end
					for k,v in pairs(toDelete) do
						LiquidDB.tradeableSlots[k] = nil
					end
					StaticPopup_Show("LIQUID_WARNING_2", "Liquid:\nCleaned up characters that havent been updated in the last 14 days.")
				end
				if LiquidDB.version.major == 2 and LiquidDB.version.minor < 8 then
					LiquidDB.lootTrading = {}
				end
				if LiquidDB.version.major == 2 and LiquidDB.version.minor < 12 then
					LiquidDB.tradeableSlots = {} -- reset
					StaticPopup_Show("LIQUID_WARNING_1", "New keybinding added for interactions with certain WA's, you can use this if you don't want to use macros (found in Keybinding -> Liquid)")
				end
			else -- first load
				LiquidDB.WeakAuraRoles = {}
				LiquidDB.lastOK = 0
				LiquidDB.auraChecks = {
						from = 0,
						to = 20,
				}
				LiquidDB.lastHistoryUpdate = 0
				LiquidDB.nicknames = {}
				StaticPopup_Show("LIQUID_WARNING_2", "Liquid: Select your roles for weakauras **AFTER** cleaning old weakauras.\n/liquid.")
				StaticPopup_Show("LIQUID_WARNING_1", "This seems to be your first login with Liquid addon, please login your relevant characters and stay online for >30 seconds< on each character.")
			end
			if not isMRTSetuped and C_AddOns.IsAddOnLoaded("MRT") then
				setupMRT()
			end
			if not waStuffSetuped and C_AddOns.IsAddOnLoaded("WeakAuras") then
				waStuffSetuped = true
				ns:SetupWAStuff()
			end
			if ns.configs.cacheCharacters then
				ns.characterCaching:SetupCharacter()
			else
				ns:LoadEvents(true)
			end
			if ns.me.btag then
				LiquidCharDB.btag = ns.me.btag
			else
				ns.me.btag = LiquidCharDB.btag
			end
			LiquidDB.version = ns.version
			ns:loadNames()
			-- delete twice to fix stupid stuff
			--if ns.handleWeakAuraDeleting then
				--ns:handleWeakAuraDeleting()
			--end
			if ns.handleSpecificWACleanups then -- remove old Liquid anchors
				ns:handleSpecificWACleanups()
			end
			if ns.configs.importWeakAuras then
				if ns.handleWeakAuraImports then
					ns:handleWeakAuraImports()
				end
				if ns.handleWeakAuraDeleting then
					ns:handleWeakAuraDeleting()
				end
			end
			if ns.handleWeakAuraFrontEndOptions then
				ns:handleWeakAuraFrontEndOptions()
			end
		elseif not isMRTSetuped and addonName == "MRT" then
			setupMRT()
		elseif not waStuffSetuped and addonName == "WeakAuras" then
			waStuffSetuped = true
			ns:SetupWAStuff()
		end
	end
end

function ns.main:PLAYER_LOGIN()
	--[[
	if C_CVar.GetCVar('advancedCombatLogging') ~= "1" then
		C_CVar.SetCVar('advancedCombatLogging', 1)
	end
	--]]
	--[[
	if not LiquidDB.identity then
		LiquidDB.identity = UnitName('player')
	end --]] 
	--[[
	C_Timer.After(20, function()
		if LiquidDB.lastHistoryUpdate and LiquidDB.identity then -- fix error on accounts without any L60 chars
			sendInitSync()
		end
	end) --]]
	if ns.version.major == 2 and ns.version.minor == 11 and ns.version.patch == 1 then -- TODO remove later, this is only a quick fix so LiquidClient has data and doesn't break
		if LiquidCharDB and LiquidCharDB.raids then
			local ownRealm = select(2, UnitFullName('player'))
			for encounterId,encounterData in pairs(LiquidCharDB.raids) do
				for killTime,killData in pairs(encounterData.kills) do
					for playerGuid,playerData in pairs(killData.players) do
						if not playerData.Server then
							playerData.Server = ownRealm
						end
					end
				end
			end
		end
	end
	if IsInGuild() and ns.btag then
		SendAddonMessage("Liquid", sformat("bnet:%s", ns.btag), "guild")
	end
	if IsInGroup() then -- request nicknames from group members on login
		SendAddonMessage("Liquid", "requestbnet", IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
	end
	ns.utility:InitializeCraftOrder()
	ns.characterCaching.fetchHighestKill()
end
function ns.main:ENCOUNTER_END(...)
	if autoProfilingWA and WeakAuras then
		autoProfilingWA = false
		C_Timer.After(3, function()
			WeakAuras.PrintProfile()
		end)
	end

end
function ns.main:GROUP_FORMED()
	if not IsInGroup() then return end -- should be useless nil check but cba to test it too much
	SendAddonMessage("Liquid", "requestbnet", IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
end

function ns.main:PLAYER_LEVEL_UP(level, ...)
	if level >= 70 and LiquidCharDB.charData then -- only create new chars on login, cba to reinit anything when someone dings 60
		LiquidCharDB.charData.level = level
		--LiquidDB.tradeableSlots[ns.playerGUID].updated = GetServerTime()
		--LiquidDB.lastHistoryUpdate = GetServerTime()
		--ns:AnnounceUpdate(ns.playerGUID)
	end
end

local mainFrame
local function showExportButtons()
	if not mainFrame then
		local backdrop = {
			bgFile = 'Interface\\Buttons\\WHITE8x8',
			edgeFile = 'Interface\\Buttons\\WHITE8x8',
			edgeSize = 1,
			insets = {
				left = 0,
				right = 0,
				top = 0,
				bottom = 0,
			}
		}
		local i = 0
		mainFrame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
		mainFrame:SetSize(600, 30)
		mainFrame:SetFrameStrata("HIGH")
		mainFrame:SetBackdrop(backdrop)
		mainFrame:SetBackdropColor(0.1,0.1,0.1,0.8)
		mainFrame:SetBackdropBorderColor(0,0,0,1)
		mainFrame:SetPoint("top", UIParent, "top", 0, -50)

		local closeButton = CreateFrame("button", nil, mainFrame, "UIPanelButtonTemplate")
		closeButton:SetSize(100, 20)
		closeButton:SetPoint("bottom", mainFrame, "bottom", 0, 5)
		closeButton:SetText("Close")
		closeButton:SetScript("OnClick", function() mainFrame:Hide() end)

		local lastFrame
		local lineCount = 0
		--function WeakAuras.Import(inData, target)
		for _,v	in ns:spairs(ns.WADB, function(t,a,b) return t[b].updated < t[a].updated end) do
			lineCount = lineCount + 1
			local f = CreateFrame("frame", nil, mainFrame, "BackdropTemplate")
			f:SetSize(594,30)
			f:SetBackdrop(backdrop)
			if v.required then
				f:SetBackdropBorderColor(1,0,0,1)
				f:SetBackdropColor(1,0,0,.1)
			else
				f:SetBackdropBorderColor(.7,.5,.2,1)
				f:SetBackdropColor(.7,.5,.2,.1)
			end
			
			if not lastFrame then
				f:SetPoint("topleft", mainFrame, "topleft", 3, -3)
			else
				f:SetPoint("topright", lastFrame, "bottomright", 0, -3)
			end
			local txt = f:CreateFontString()
			txt:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
			txt:SetPoint('TOPLEFT', f, 'TOPLEFT', 3,-3)
			txt:SetJustifyH("LEFT")
			txt:SetText(string.format("%s\n%s",v.name, date(LiquidDB.timeFormat and "%m/%d/%y %I:%M%p" or "%d/%m/%y %H:%M",  v.updated)))

			local editbox = CreateFrame("EditBox", nil, mainFrame, "BackdropTemplate")
			editbox:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				edgeSize = 1,
				insets = {
					left = -1,
					right = -1,
					top = -1,
					bottom = -1,
				},
			})
			editbox:SetBackdropColor(.1,.1,.1,.8)
			editbox:SetBackdropBorderColor(1,0,0,1)
			editbox:SetScript("OnEditFocusGained", function()
				editbox:HighlightText()
			end)
			editbox:SetScript("OnEditFocusLost", function()
				editbox:HighlightText(0,0)
			end)
			editbox:SetScript('OnEnterPressed', function()
				editbox:ClearFocus()
			end)
			editbox:SetWidth(100)
			editbox:SetHeight(21)
			editbox:SetTextInsets(2, 2, 1, 0)
			editbox:SetPoint('right', f, 'right', -3,0)
			editbox:SetText(v.main)
			editbox:SetAutoFocus(false)
			editbox:SetFont(STANDARD_TEXT_FONT, 10, "")
			local import = CreateFrame("button", nil, f, "UIPanelButtonTemplate")
			import:SetSize(100, 20)
			import:SetPoint("right", editbox, "left", -3, 0)
			import:SetText("Import")
			import:SetScript("OnClick", function() 
				if not WeakAuras then print("Liquid: ERROR >> enable WeakAuras <<") return end
				WeakAuras.Import(v.main)
			end)
			lastFrame = f
			if v.sub then
				for _,_v in ipairs(v.sub) do
					lineCount = lineCount + 1
					local sf = CreateFrame("frame", nil, mainFrame, "BackdropTemplate")
					sf:SetSize(544,30)
					sf:SetBackdrop(backdrop)
					sf:SetBackdropColor(1,1,1,0)
					sf:SetBackdropBorderColor(0,0,0,1)
					sf:SetPoint("topright", lastFrame, "bottomright", 0, -3)
					local stxt = sf:CreateFontString()
					stxt:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
					stxt:SetPoint('TOPLEFT', sf, 'TOPLEFT', 3,-3)
					stxt:SetJustifyH("LEFT")
					stxt:SetText(string.format("%s\n%s",_v.name, _v.updated))
					local seditbox = CreateFrame("EditBox", nil, mainFrame, "BackdropTemplate")
					seditbox:SetBackdrop({
						bgFile = "Interface\\Buttons\\WHITE8x8",
						edgeFile = "Interface\\Buttons\\WHITE8x8",
						edgeSize = 1,
						insets = {
							left = -1,
							right = -1,
							top = -1,
							bottom = -1,
						},
					})
					seditbox:SetFont(STANDARD_TEXT_FONT, 10, "")
					seditbox:SetBackdropColor(.1,.1,.1,.8)
					seditbox:SetBackdropBorderColor(1,0,0,1)
					seditbox:SetScript('OnEnterPressed', function()
						seditbox:ClearFocus()
					end)
					seditbox:SetScript("OnEditFocusGained", function()
						seditbox:HighlightText()
					end)
					seditbox:SetScript("OnEditFocusLost", function()
						seditbox:HighlightText(0,0)
					end)
					seditbox:SetWidth(100)
					seditbox:SetHeight(21)
					seditbox:SetTextInsets(2, 2, 1, 0)
					seditbox:SetPoint('RIGHT', sf, 'RIGHT', -3,0)
					seditbox:SetText(_v.main)
					lastFrame = sf
				end
			end
		end
		mainFrame:SetHeight(lineCount*32+40)
		local desc = mainFrame:CreateFontString()
		desc:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
		desc:SetPoint('BOTTOMLEFT', mainFrame, 'BOTTOMLEFT', 3,3)
		desc:SetJustifyH("LEFT")
		desc:SetText("|cffff0000Required|r |cffb38033Optional|r")
		mainFrame:Show()
	elseif mainFrame:IsShown() then
		mainFrame:Hide()
	else
		mainFrame:Show()
	end
end
--Options/Delete frame
do
	local _roleData = {
		tank = {
			atlas = "adventures-tank",
			text = "Tank"
		},
		healer = {
			atlas = "adventures-healer",
			text = "Healer"
		},
		mdps = {
			atlas = "adventures-dps",
			text = "Melee DPS"
		},
		rdps = {
			atlas = "adventures-dps-ranged",
			text = "Ranged DPS"
		},
		overview = {
			atlas = "worldquest-icon-nzoth",
			text = "Overview"
		},
		dev = {
			atlas = "Garr_BuildIcon",
			text = "Dev/Test"
		},
		production = {
			atlas = "movierecordingicon",
			text = "Production"
		},
		overlaymax = {
			atlas = "honorsystem-icon-prestige-11",
			text = "Overlay-Max"
		},
		overlayluml = {
			atlas = "honorsystem-icon-prestige-9",
			text = "Overlay-Luml"
		},
	}
	function ns:GetFormatedRoleText(role, returnData)
		if returnData and not _roleData[role] then return false end
		if not _roleData[role] then return role end
		if returnData then return _roleData[role] end
		return string.format("%s%s", CreateAtlasMarkup(_roleData[role].atlas, 24,24), _roleData[role].text)
	end
end
do
	local backdrop = {
		bgFile = 'Interface\\Buttons\\WHITE8x8',
		edgeFile = 'Interface\\Buttons\\WHITE8x8',
		edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0,
		}
	}

	local deleteFrame
	local createdLines = {}
	local function getLine(i, mf)
		if createdLines[i] then
			return createdLines[i]
		end
		local f = CreateFrame("frame", nil, mf, "BackdropTemplate")
		f:SetSize(594,20)
		f:SetBackdrop(backdrop)
		f:SetBackdropColor(1,1,1,0)
		f:SetBackdropBorderColor(0,0,0,1)
		if i == 1 then
			f:SetPoint("TOPLEFT", mf, "TOPLEFT", 3, -53)
		else
			f:SetPoint("TOPRIGHT", createdLines[i-1], "BOTTOMRIGHT", 0, -3)
		end
		f.txt = f:CreateFontString()
		f.txt:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
		f.txt:SetPoint('LEFT', f, 'LEFT', 3, 0)
		f.txt:SetJustifyH("LEFT")
		f.delete = CreateFrame("button", nil, f, "UIPanelButtonTemplate")
		f.delete:SetSize(80, 16)
		f.delete:SetPoint("RIGHT", f, "RIGHT", -3, 0)
		f.delete:SetText("Delete")
		f.delete.guidToDelete = ""
		createdLines[i] = f
		return createdLines[i]
	end
	local function refreshLines(mf)
		local lineCount = 1
		if LiquidDB.tradeableSlots then
			for guid,v in pairs(LiquidDB.tradeableSlots) do
				local f = getLine(lineCount, mf)
				f.delete.guidToDelete = guid
				f.txt:SetText(sformat("%s |c%s%s-%s|r |T4643980:0:0|t%s - Last updated %s", v.faction and CreateAtlasMarkup("nameplates-icon-bounty-"..v.faction:lower(), 20,20) or "", RAID_CLASS_COLORS[v.class].colorStr, v.name, v.server, v.currency[1] or 0, date(LiquidDB.timeFormat and "%m/%d/%y %I:%M%p" or "%d/%m/%y %H:%M", v.updated)))
				f:SetBackdropColor(RAID_CLASS_COLORS[v.class].r,RAID_CLASS_COLORS[v.class].g,RAID_CLASS_COLORS[v.class].b,.1)
				f.delete:SetScript("OnClick", function()
					LiquidDB.tradeableSlots[f.delete.guidToDelete] = nil
					refreshLines(mf)
				end)
				f:Show()
				lineCount = lineCount + 1
			end
		end
		if LiquidCharDB.notes then
			for encounterID, difs in pairs(LiquidCharDB.notes) do
				for difID,dataString in pairs(difs) do
					local f = getLine(lineCount, mf)
					f.txt:SetText(sformat("EncounterID: %s - Difficulty: %s", encounterID, difID == 16 and "Mythic" or difID == 15 and "Heroic" or difID == 14 and "Normal" or "????"))
					f.delete:SetScript("OnClick", function()
						if LiquidCharDB.notes[encounterID] and LiquidCharDB.notes[encounterID][difID] then
							LiquidCharDB.notes[encounterID][difID] = nil
							LIQUID_PRIVATE_NOTE_CHANGED(false, encounterID, difID)
							local left = 0
							for k,v in pairs(LiquidCharDB.notes[encounterID]) do
								left = left + 1
							end
							if left == 0 then
								LiquidCharDB.notes[encounterID] = nil
							end
							refreshLines(mf)
						end
					end)
					f:Show()
					lineCount = lineCount + 1
				end
			end
		end
		for j = lineCount, #createdLines do
			createdLines[j]:Hide()
		end
		mf:SetHeight((lineCount-1)*22+90)
	end
	function ns:showDeleteOptions()
		if not deleteFrame then
			local backdrop = {
				bgFile = 'Interface\\Buttons\\WHITE8x8',
				edgeFile = 'Interface\\Buttons\\WHITE8x8',
				edgeSize = 1,
				insets = {
					left = 0,
					right = 0,
					top = 0,
					bottom = 0,
				}
			}
			deleteFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
			deleteFrame:SetSize(600, 50)
			deleteFrame:SetFrameStrata("HIGH")
			deleteFrame:SetBackdrop(backdrop)
			deleteFrame:SetBackdropColor(0.1,0.1,0.1,0.8)
			deleteFrame:SetBackdropBorderColor(0,0,0,1)
			deleteFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
			-- na time toggle
			deleteFrame.timeFormat = CreateFrame("CheckButton", nil, deleteFrame, "ChatConfigCheckButtonTemplate")
			deleteFrame.timeFormat:SetSize(20, 20)
			deleteFrame.timeFormat.Text:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
			deleteFrame.timeFormat.Text:SetText("NA time format")
			deleteFrame.timeFormat.Text:ClearAllPoints()
			deleteFrame.timeFormat.Text:SetPoint("left", deleteFrame.timeFormat, "right", 1, 0)
			deleteFrame.timeFormat:SetPoint("topleft", deleteFrame, "topleft", 5, -5)
			deleteFrame.timeFormat:SetChecked(LiquidDB.timeFormat)
			deleteFrame.timeFormat:SetScript("OnClick", function(self)
				LiquidDB.timeFormat = self:GetChecked()
				refreshLines(deleteFrame)
			end)
			--WeakAuras roles
			deleteFrame.waRoles = CreateFrame("FRAME", nil, deleteFrame, "UIDropDownMenuTemplate")
			deleteFrame.waRoles:SetPoint("LEFT", deleteFrame.timeFormat, "RIGHT", 90, 0)
			UIDropDownMenu_SetWidth(deleteFrame.waRoles, 75)
			UIDropDownMenu_SetText(deleteFrame.waRoles, "WaRoles")
			
			local t = LiquidDB.dev and {"tank", "healer", "mdps", "rdps", "overview", "dev", "production", "overlaymax", "overlayluml"} or {"tank", "healer", "mdps", "rdps"}
			UIDropDownMenu_Initialize(deleteFrame.waRoles, function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				for _,role in ipairs(t) do
					info.func = function(self, arg1, arg2, checked) LiquidDB.WeakAuraRoles[arg1] = checked end
					info.text = ns:GetFormatedRoleText(role)
					info.arg1 = role
					info.checked = LiquidDB.WeakAuraRoles[role]
					info.keepShownOnClick	= true
					info.isNotRadio	= true
					UIDropDownMenu_AddButton(info, level)
				end
				info.text = "Close"
				info.notCheckable = true
				info.func = function() CloseDropDownMenus() end
				UIDropDownMenu_AddButton(info, level)
			end)
			-- Split Group names
			deleteFrame.splitNameDropwdown = CreateFrame("FRAME", nil, deleteFrame, "UIDropDownMenuTemplate")
			deleteFrame.splitNameDropwdown:SetPoint("TOPLEFT", deleteFrame.timeFormat, "BOTTOMLEFT", 0, -5)
			UIDropDownMenu_SetWidth(deleteFrame.splitNameDropwdown, 75)
			UIDropDownMenu_SetText(deleteFrame.splitNameDropwdown, "Split Name")
			
			local _t = {"Jug Juicers", "Gunden Mandans", "Severed Splits", "Happy Hill", "Five Big Booms", "None"}
			UIDropDownMenu_Initialize(deleteFrame.splitNameDropwdown, function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				for _,groupName in ipairs(_t) do
					info.func = function(self, arg1, arg2)
						if arg1 == "None" then
							LiquidDB.splitGroupName = nil
						else
							LiquidDB.splitGroupName = arg1
						end
					end
					info.text = groupName
					info.arg1 = groupName
					info.checked = (groupName == "None" and not LiquidDB.splitGroupName) or LiquidDB.splitGroupName == groupName
					--info.keepShownOnClick	= false
					--info.isNotRadio	= true
					UIDropDownMenu_AddButton(info, level)
				end
				info.text = "Close"
				info.notCheckable = true
				info.func = function() CloseDropDownMenus() end
				UIDropDownMenu_AddButton(info, level)
			end)
			-- simc button
			deleteFrame.simc = CreateFrame("button", nil, deleteFrame, "UIPanelButtonTemplate")
			deleteFrame.simc:SetSize(75, 20)
			deleteFrame.simc:SetPoint("LEFT", deleteFrame.waRoles, "RIGHT", 0, 0)
			deleteFrame.simc:SetText("Simc")
			deleteFrame.simc:SetScript("OnClick", function()
				StaticPopup_Show("LIQUID_SAVE_SIMC")
			end)
			-- version str
			deleteFrame.versionText = deleteFrame:CreateFontString()
			deleteFrame.versionText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
			deleteFrame.versionText:SetPoint('topright', deleteFrame, 'topright', -3, -3)
			deleteFrame.versionText:SetJustifyH("RIGHT")
			deleteFrame.versionText:SetText(sformat("v%s%s - LiquidWA:%s - BW:%s", LiquidDB.version.str, LiquidDB.dev and "Dev" or "", LiquidWeakAurasAPI and LiquidWeakAurasAPI.Version.str or "N/A",  BigWigsAPI and BigWigsAPI.GetVersion and select(2, BigWigsAPI.GetVersion()) or "N/A"))

			local closeButton = CreateFrame("button", nil, deleteFrame, "UIPanelButtonTemplate")
			closeButton:SetSize(100, 20)
			closeButton:SetPoint("bottom", deleteFrame, "bottom", 0, 5)
			closeButton:SetText("Close")
			closeButton:SetScript("OnClick", function() deleteFrame:Hide() end)
			refreshLines(deleteFrame)
			deleteFrame:Show()
		elseif deleteFrame:IsShown() then
			deleteFrame:Hide()
		else
			refreshLines(deleteFrame)
			deleteFrame.timeFormat:SetChecked(LiquidDB.timeFormat)
			--deleteFrame.oksyncText:SetText("Last OK sync: "..date(LiquidDB.timeFormat and "%m/%d/%y %I:%M%p" or "%d/%m/%y %H:%M", LiquidDB.lastOK))
			deleteFrame:Show()
		end
	end
end
--[[ disabled for now
-----------------
--AFK-animation--
-----------------
do 
	local afkStart = 0
	local afk
	local isAfk
	local afkText = '%d%d'
	local afkTicker
	local function updateAFKText()
		local seconds = math.floor(GetTime()-afkStart)
		local m = math.floor((seconds)/60)
		if not m then
			m = 0
		end
		local s = seconds%60
		afk.text:SetText(afkText:format(m,s))
	end
	function ns.events:PLAYER_FLAGS_CHANGED(unit)
		if not UnitIsAFK('player') and not isAfk then return end
		if UnitIsAFK('player') and isAfk then return end
		if isAfk and not UnitIsAFK('player') then
			isAfk = false
			if afk then
				afk.pulse:Stop()
				afk:Hide()
				afk.text:Hide()
				if afkTicker then
					afkTicker:Cancel()
				end
			end
			return
		end
		if UnitIsAFK('player') and not isAfk then
			if not afk then
				afk = CreateFrame('frame', nil, UIParent)
				afk:SetSize(512,512)
				afk:SetPoint('center', UIParent, 'top', 0,-335)
				afk.tex = afk:CreateTexture()
				afk.tex:SetAllPoints(afk)
				afk.tex:SetTexture('Interface\\AddOns\\Liquid\\Media\\pewpew') -- TODO if enabled at some point, update to correct texture

				afk.pulse = afk:CreateAnimationGroup()
				afk.pulse:SetLooping('REPEAT')

				local scalePush = 1.2
				local scalePull = 1 / scalePush

				afk.pulse.up = afk.pulse:CreateAnimation('Scale')
				afk.pulse.up:SetDuration(2)
				--afk.pulse.up:SetToScale(1.2,1.2)
				afk.pulse.up:SetOrder(1)
				afk.pulse.up:SetOrigin('bottom', 0, 0)
				afk.pulse.up:SetStartDelay(0.1)
				afk.pulse.up:SetSmoothing("IN_OUT")
				afk.pulse.up:SetFromScale(1, 1)
				afk.pulse.up:SetToScale(scalePush, scalePush)


				afk.pulse.down = afk.pulse:CreateAnimation('Scale')
				afk.pulse.down:SetDuration(2)
				afk.pulse.down:SetToScale(1,1)
				afk.pulse.down:SetOrder(2)
				afk.pulse.down:SetOrigin('bottom', 0, 0)
				afk.pulse.down:SetSmoothing("IN_OUT")
				afk.pulse.down:SetFromScale(1,1)
				afk.pulse.down:SetStartDelay(0.1)
				afk.pulse.down:SetToScale(scalePull, scalePull)

				afk.text = ns.events:CreateFontString()
				afk.text:SetParent(UIParent)
				afk.text:SetFont('Interface\\AddOns\\Liquid\\Media\\BebasNeue-Regular.ttf', 30, 'OUTLINE') -- TODO if enabled at some point, update font
				afk.text:SetPoint('top', UIParent, 'top', 0,-450)
				afk.text:SetTextColor(1,1,1,1)
				afk.text:SetText('')
				local name = iCN_GetName and iCN_GetName(UnitName('player')) or UnitName('player')
				afkText = name ..'\nSK Liquid\nAFK %02d:%02d'
			end
			isAfk = true
			afkStart = GetTime()
			afk.pulse:Play()
			afk.text:Show()
			afk:Show()
			afkTicker = C_Timer.NewTicker(.1, updateAFKText)
		end
	end
end
--]]
do
	local lastPress = 0
	function LIQUID_MANUAL_ACTION()
		if not WeakAuras then return end
		WeakAuras.ScanEvents("LIQUID_PRIVATE_AURA_MACRO", true)
		WeakAuras.ScanEvents("NS_PA_MACRO", true)
		-- send notification to ieet for now
		if lastPress + 1 > GetTime() then return end
		lastPress = GetTime()
		local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or IsInGroup() and "party" or nil
		if chatType then
			C_ChatInfo.SendAddonMessage("iEETSync", "LiquidWaMacro", chatType)
		end
	end
end
BINDING_HEADER_LIQUID = 'Liquid'
BINDING_NAME_LIQUID_MANUAL_ACTION = 'Manual data sending for WA (Liquid)'

SLASH_LIQUID1 = "/liquid"
SLASH_SETUPRAID1 = "/setupraid"
SLASH_LIQUIDWA1 = "/liquidwa"
SLASH_LIQUIDMOTIVATE1 = "/moti"
SLASH_LIQUIDMOTIVATE2 = "/motivate"
SLASH_LIQUIDGOODHELPER1 = "/pro"
SLASH_LIQUIDGOODHELPER2 = "/prohelper"
SlashCmdList["LIQUIDWA"] = function(msg)
	if InCombatLockdown() then
		print("Error: Cannot open export window in combat.")
		return
	end
	showExportButtons()
end
SlashCmdList["LIQUID"] = function(msg)
	local realmsg = msg
	if msg then msg = msg:lower() end
	if msg and msg == "debug" then
		if LiquidDB.debugging then
			print("Liquid: CD debugging is now >>disabled<<.")
			LiquidDB.debugging = false
		else
			print("Liquid: CD debugging is now >>enabled<<.")
			LiquidDB.debugging = true
		end
	elseif msg and msg == "version" then
		listening = true
		local chatType = IsInGuild() and "guild" or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party"
		print(sformat("User - version (%s)", chatType))
		C_ChatInfo.SendAddonMessage('Liquid', "userCheck", chatType)
		C_Timer.After(2, function() listening = false end)
	elseif msg and msg == "ieetcache" then
		--ns:handleHiddenAuras()
	elseif msg and msg == "wap" then
		if WeakAuras then
			autoProfilingWA = true
			WeakAuras.StartProfile("encounter")
		end
	elseif msg and msg == "charcheck" then
		if IsInRaid() then
			ns:CheckCharsInRaid()
		else
			print("Liquid: Error, you are not in a raid.")
		end
	elseif msg == "dev" then
		if LiquidDB.dev then
			ns:DisableDevMode()
			LiquidDB.dev = false
		else
			LiquidDB.dev = true
			print("Liquid: Developer mode activated.")
		end
	elseif msg == "trade" then
		if not ns.configs.lootTracking then return end
		ns.items:Export()
	elseif msg == "boetrade" then
		if not ns.configs.lootTracking then return end
		ns.items:Export("trash")
	elseif msg == "tradedebug" then
		if not ns.configs.lootTracking then return end
		ns.items:Import()
	elseif msg == "synctimedebug" then
		listeningForSyncDebugs = true
		print("-------")
		SendAddonMessage("Liquid","syncdebug", "guild")
		C_Timer.After(2, function() listeningForSyncDebugs = false end)
	elseif msg == "checkbags" then
		if not ns.configs.lootTracking then return end
		ns.items:CheckBagsForProblems()
	elseif msg == "showtrade" then
		if not ns.configs.lootTracking then return end
		ns.items:ShowTrade()
	elseif msg == "splitcheck" then
		SendAddonMessage("LiquidSplits", "check", "raid")
		checkedMembersForSplits = {}
		C_Timer.After(2, function() checkSplitMembers() end)
	elseif msg == "wamacro" then
		LIQUID_MANUAL_ACTION()
	elseif msg == "deleteextraitems" then
		local itemsToDelete = { -- return true to delete
			[210059] = function() return select(11,C_MountJournal.GetMountInfoByID(1815)) end,
		}
		for bagID = 0, 4 do
			for invID = 1, C_Container.GetContainerNumSlots(bagID) do
				local itemID = C_Container.GetContainerItemID(bagID, invID)
				if itemID and itemsToDelete[itemID] and itemsToDelete[itemID]() then
					ClearCursor()
					C_Container.PickupContainerItem(bagID, invID)
					DeleteCursorItem()
					return
				end
			end
		end
	elseif msg == "questitem" then
		ns.utility:EditMacroForQuestItem()
	elseif msg == "massnote" then
		if not ns.utility.notes then
			print("Error: functions for mass note not found.")
			return
		end
		ns.utility.notes:Show()
	elseif msg and msg:match("^bugsack .-$") then
		local msgType = IsInGuild() and "guild" or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or IsInGroup() and "party"
		if not msgType then print("Error: you are not in a guild or party.") return end
		local n = msg:match("^bugsack%s*(%S+)")
		if not n then return print("Error: no name found (matching error? report to Ironi on discord") end
		SendAddonMessage("Liquid", "bugsack "..n, msgType)
		print("BugSack request sent to :", n)
	elseif msg and msg:match("^extraframes .-$") then
		if not WeakAuras then
			print("Error, WeakAuras is not enabled.")
			return
		end
		local arg = msg:match("^extraframes%s*(%S+)")
		if not arg then return print("Error: no arg found (matching error? report to Ironi on discord") end
		WeakAuras.ScanEvents("LIQUID_EXTRA_FRAME", arg, true)
	else
		ns:showDeleteOptions()
	end
end
SlashCmdList["SETUPRAID"] = function(msg)
	if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
		for i = math.min(20, GetNumGroupMembers()), 1, -1 do
			SetRaidSubgroup(i, math.ceil(i/5)+4)
		end
	end
end
SlashCmdList["LIQUIDMOTIVATE"] = function()
	if not UnitExists("target") then return end
	local n = UnitNameUnmodified('target')
	if not n then return end
	local str = LiquidDB.motivationMessage
	if GetGuildInfo('target') == "Liquid" then
		local strs = {
			"Champion, Azeroth awaits your courage! Conquer dungeons, vanquish foes, and carve your name into legend. The battle never ends—push forward and claim your destiny!",
			"For the Horde! For the Alliance! No matter your banner, fight with honor, adventure with purpose, and never let defeat break your spirit! Azeroth is yours to shape!",
			"Heroes never rest! The battleground calls, the dungeons await, and the loot is yours for the taking. Keep grinding, keep raiding, and let your legend grow!",
			"Every boss is just another challenge waiting to fall! Gear up, rally your allies, and strike fear into the hearts of your enemies. The world of Warcraft is yours to conquer!",
			"Dare to be legendary! Azeroth is filled with battles to fight, treasures to claim, and stories to write. Your adventure has no limits—keep pushing forward!",
			"No dungeon is too dark, no enemy too strong! With courage, skill, and teamwork, victory is always within reach. Never stop adventuring!",
			"Stand tall, hero! Whether raiding, questing, or PvPing, your journey shapes Azeroth's fate. Keep fighting, keep exploring, and let your story be epic!",
			"Glory and adventure await! Gather your gear, summon your courage, and charge into battle. Azeroth is yours to explore—write your own legend!",
			"No matter the odds, no matter the fight—never back down! Face the darkness with fire in your heart and claim victory with steel in your hand!",
			"Victory belongs to those who never give up! Each dungeon, each battleground, each raid—another step toward greatness. Keep going, hero!",
			"Legends aren't born, they're forged in battle! Hone your skills, gather your allies, and leave your mark on Azeroth. Adventure awaits!",
			"Strength, honor, and courage—these are your weapons. Face every foe with pride, and let your deeds echo through the ages!",
			"Every challenge you face makes you stronger. Every boss you defeat, every dungeon you clear—you're building a legend! Keep pushing forward!",
			"The mightiest heroes rise from the toughest battles. Stay relentless, keep leveling up, and never fear the grind. Your time is now!",
			"Greatness isn't given—it's earned! Fight for your faction, your guild, and your honor. Azeroth rewards the bold!",
			"The call to arms has sounded! Rally your guild, sharpen your blade, and prepare for battle. Victory is waiting!",
			"Face the storm, charge into battle, and let nothing stand in your way! Your name will be whispered across Azeroth for ages to come!",
			"Power isn't just in gear—it's in perseverance! Keep fighting, keep grinding, and show the world what you're made of!",
			"Horde or Alliance, we all share one destiny: to become legends! Never stop questing, raiding, or fighting for glory!",
			"Your adventure is far from over! Azeroth is vast, the enemies are fierce, but the rewards are endless. Keep fighting, hero!",
			"The best loot comes to those who dare to fight for it! Face the toughest bosses, conquer the hardest raids, and claim what's yours!",
			"Every setback is just a setup for a greater comeback! Never surrender, never stop improving—your legend is still being written!",
			"Heroes never quit! Whether raiding, PvP, or grinding rep, every step brings you closer to greatness. Keep moving forward!",
			"Every battle, every quest, every victory—it all adds to your story. Make yours one of glory!",
			"Azeroth is filled with legends. Will yours be one of triumph or defeat? Stand tall, fight hard, and write your own fate!",
			"The world is vast, the enemies are strong, but so are you! Keep leveling, keep raiding, and keep proving your strength!",
			"Conquer your fears, defeat your enemies, and claim your rewards! Azeroth bows to those who never stop pushing forward!",
			"No boss is too powerful, no dungeon too deadly! With skill and determination, you can overcome anything. Keep grinding, hero!",
			"Stand firm, fight hard, and never back down! The battlefield awaits, and glory is yours for the taking!",
			"Only the brave achieve true greatness! Take risks, challenge yourself, and never stop pushing the limits of your power!",
			"The mightiest warriors don't just seek victory—they create it! Fight with honor and claim your place among the legends!",
			"Your fate is not written—it is forged in battle! Stand strong, embrace the challenge, and make your name known!",
			"Every adventure, every quest, every fight—it all leads to greatness! Keep pushing forward, hero!",
			"Legends rise from the ashes of battle! Never fear defeat, for every setback makes you stronger. Keep fighting!",
			"The road to glory is long, but the rewards are worth it! Keep pushing, keep raiding, and never stop chasing greatness!",
			"One more quest, one more battle, one more victory! The grind is real, but so is the glory. Keep going!",
			"Strength comes from the battles you fight, the enemies you defeat, and the challenges you overcome. Stay strong, champion!",
			"A hero's journey is never easy, but every challenge makes you stronger. Keep fighting, keep leveling, and let nothing stop you!",
			"The battlefield is unforgiving, but so are you! Charge in, fight hard, and let nothing stand in your way!",
			"Your name will be remembered, your deeds will be sung—if you have the courage to fight for it! Stand tall, hero!",
			"Victory is reserved for those who refuse to quit! Keep leveling, keep raiding, and claim your place among the legends!",
			"No warrior fights alone! Gather your allies, face the darkness, and emerge victorious! Azeroth is yours to conquer!",
			"The grind is tough, the battles are fierce, but the rewards are worth it! Keep fighting, hero!",
			"The best loot is always at the end of the hardest fights! Push forward, claim victory, and take what's yours!",
			"Your power is limitless, your journey never-ending! Keep questing, keep raiding, and never stop improving!",
			"Glory isn't given—it's earned in battle! Stand strong, fight hard, and claim your place in history!",
			"No enemy is unbeatable, no quest is too difficult! With determination and courage, you can overcome anything!",
			"The path to greatness is paved with battles—win them all and make Azeroth remember your name!",
			"Never stop adventuring! Each raid, each fight, each quest brings you closer to your ultimate destiny!",
			"Azeroth's greatest heroes started where you are now—keep pushing, keep fighting, and become the legend you were meant to be!",
		}
		str = strs[math.random(1, #strs)]
	end
	if not str then
		local potentialMessages = {
			"Hi, thank you for participating in liquid splits! We would like to see you up your gameplay so later bosses aren't a struggle. If it's not fixed we will be replacing you, but you will get gold for all bosses you have participated in up to that point!",
		}
		str = potentialMessages[math.random(1, #potentialMessages)]
	end
	SendChatMessage(str, "WHISPER", nil, Ambiguate(n, "none"))
	local nickName, colorstr, atlas = LiquidAPI:GetName('target', true, true)
	if IsInGroup() then
		SendAddonMessage("Liquid", sformat("%s;%s%s;%s", "MOTI", atlas, colorstr and colorstr:format(nickName) or nickName, LiquidAPI:GetName("player")), IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
	end
	if IsInGuild() then
		SendAddonMessage("Liquid", sformat("%s;%s%s;%s", "MOTI", atlas, colorstr and colorstr:format(nickName) or nickName, LiquidAPI:GetName("player")), "GUILD")
	end
end
SlashCmdList["LIQUIDGOODHELPER"] = function()
	if not UnitExists("target") then return end
	local n = UnitNameUnmodified('target')
	if not n then return end
	--[[
	if not LiquidDB.splitGroupName then
		print("Liquid: Error, splitGroupName not set.")
		return
	end
	--]]
	local str
	if GetGuildInfo('target') == "Liquid" then
	--if GetGuildInfo('target') == "Kultzipuppelit" then
		local strs = {
			"Your dedication, endurance, and execution in the Race to World First are nothing short of legendary. Every pull, every strat, every second counts—keep pushing!",
			"Your ability to adapt, analyze, and optimize strategies on the fly is what makes you a true RWF competitor. Your hard work shows in every pull.",
			"From split raids to sleepless nights, your commitment to perfection in the RWF is inspiring. Keep making history!",
			"Your mechanical precision and raid awareness under extreme pressure prove why you’re among the best in the world. Keep leading the charge!",
			"The grind, the focus, the flawless execution—your dedication to RWF raiding is incredible. Keep setting the standard!",
			"Watching you push progression and optimize every aspect of your gameplay is a masterclass in high-end raiding. Keep dominating!",
			"Your ability to adapt and strategize in real time is what sets you apart. Every pull brings you closer to greatness!",
			"Your resilience through countless wipes and strategy refinements is what makes you an RWF legend. Keep pushing forward!",
			"The sheer dedication and mental fortitude required for the RWF is immense, and you handle it like a pro. Keep making it look effortless!",
			"Your quick thinking, leadership, and execution in high-pressure moments make you a cornerstone of your team’s success.",
			"Every decision, every cooldown, every pull—you optimize and execute at a level few can reach. Your dedication to RWF is inspiring.",
			"Your relentless drive for perfection and mastery of boss mechanics is what makes you a key player in this race. Keep proving why you belong!",
			"Your ability to stay focused and make real-time adjustments during marathon raid sessions is the mark of a true RWF competitor.",
			"From split runs to progression pulls, your knowledge and execution are second to none. Keep pushing until the final boss falls!",
			"Every wipe is a step closer to victory, and your endurance in this race proves your dedication to high-end raiding. Keep going strong!",
			"Your ability to coordinate, adapt, and execute complex mechanics under extreme pressure is awe-inspiring. Keep up the grind!",
			"The work you put in outside of raid—spreadsheets, logs, strategy meetings—shows in every pull. Your dedication is unmatched!",
			"Every cooldown is perfectly timed, every mechanic expertly handled—your execution in the RWF is next level. Keep up the amazing work!",
			"The resilience to go again after hundreds of pulls, refining every mistake into perfection, is what makes you a world-class raider.",
			"You make high-end raiding look effortless, but the hours of preparation and sheer focus you bring prove why you’re one of the best.",
			"Your ability to perform under pressure, with thousands watching, is what makes you a true Race to World First competitor. Keep pushing limits!",
			"Your commitment to the race, from split raids to theorycrafting, is what separates casuals from legends. Keep grinding for that World First!",
			"Every boss you face is a challenge, but your ability to adapt, analyze logs, and refine strategies proves why you’re a top-tier raider.",
			"Your discipline, mechanical precision, and team synergy make you an invaluable player in the toughest raid race in gaming.",
			"You handle split-second decisions and high-pressure mechanics like a pro. Your contributions to your team’s success are undeniable!",
			"Your patience, endurance, and ability to execute complex mechanics flawlessly show why you're part of the world’s elite raiders.",
			"From min-maxing gear to perfecting mechanics, your attention to detail is what makes you a true competitor in the RWF.",
			"Your ability to handle the mental and physical endurance of RWF is truly impressive. Keep grinding and claim that World First!",
			"The precision and adaptability you bring to progression pulls make you a key player in this race. Keep pushing forward!",
			"Your split-second decision-making and deep knowledge of boss fights put you in a league of your own. Keep proving why you're among the best!",
			"Every cooldown, every defensive, every mechanic—you execute it all at an elite level. Your performance in the RWF is incredible!",
			"Your ability to stay focused after hours of progression and hundreds of wipes is what makes you a true world-class raider.",
			"Your resilience and determination to overcome seemingly impossible bosses is what makes RWF raiding so incredible to watch.",
			"Your leadership, decision-making, and flawless execution are crucial in this high-stakes competition. Keep carrying your team to victory!",
			"Every wipe is just data, and you analyze and adapt with precision. Your commitment to problem-solving and execution is unmatched.",
			"Your ability to push through exhaustion and maintain top-tier performance is what makes you a world-class raider.",
			"Your performance under pressure, with the whole world watching, is beyond impressive. Keep showing why you belong at the top!",
			"The way you optimize rotations, manage cooldowns, and execute mechanics is a testament to your dedication to high-end raiding.",
			"Your ability to execute perfect pulls after hours of attempts is a testament to your endurance and skill. Keep up the grind!",
			"You bring both skill and strategy to the toughest raid encounters in WoW. Your contributions to the RWF are undeniable!",
			"Your ability to push progression, adapt on the fly, and maintain composure under pressure makes you an elite raider.",
			"From preparation to execution, you embody everything that makes Race to World First raiding so thrilling to watch.",
			"Your ability to work with your team, adjust strategies mid-pull, and execute mechanics flawlessly makes you a top-tier competitor.",
			"Your focus, dedication, and drive set you apart in the RWF. Keep refining your craft and pushing for that World First!",
			"Your endurance in long raid days and ability to stay mentally sharp after countless wipes proves why you're one of the best.",
			"The way you push through exhaustion, adjust strategies, and keep executing at the highest level is what makes you an elite raider.",
			"Your ability to work under pressure, with every move being watched by thousands, is a testament to your skill and mental fortitude.",
			"You don’t just play the game—you master it. Your performance in the RWF shows a level of dedication and skill that few can match.",
			"Your contributions to your team’s success in the RWF are clear in every pull. Keep pushing until the final boss falls!",
			"You’re part of an elite group pushing WoW raiding to its limits. Your dedication, skill, and determination are what make the Race to World First so incredible to watch!",
		}
		str = strs[math.random(1, #strs)]
	end
	if not str then
		local potentialMessages = {
			"Hello! We believe you excelled in normal and want to invite you to our heroic runs later today!!  If you would like to participate please apply to any Liquid Heroic split in group finder and put '%s' in your note if you are unsaved to all heroic bosses!",
		}
		str = potentialMessages[math.random(1, #potentialMessages)]
	end
	local pw = "pro"
	SendChatMessage(str:format(pw), "WHISPER", nil, Ambiguate(n, "none"))
	local nickName, colorstr, atlas = LiquidAPI:GetName('target', true, true)
	if IsInGroup() then
		SendAddonMessage("Liquid", sformat("%s;%s;%s%s;%s", "GOODHELPER", pw, atlas, colorstr and colorstr:format(nickName) or nickName, LiquidAPI:GetName("player")), IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "instance_chat" or IsInRaid() and "raid" or "party")
	end
	if IsInGuild() then
		SendAddonMessage("Liquid", sformat("%s;%s;%s%s;%s", "GOODHELPER", pw, atlas, colorstr and colorstr:format(nickName) or nickName, LiquidAPI:GetName("player")), "GUILD")
	end
end
