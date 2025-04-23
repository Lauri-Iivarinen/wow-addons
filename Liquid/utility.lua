local addonName, ns = ...
ns.utility = {}
local displayButtons = {}
local displayButtonsParent

-- Change the color of an aura's display button red if it's set to never load.
local function ChangeColorFromData(data)
	if data and type(data) == "table" and data.id and data.load and displayButtons[data.id] then
		if data.load.use_never then
			displayButtons[data.id].background:SetVertexColor(1, 0, 0)
		else
			displayButtons[data.id].background:SetVertexColor(128/255, 128/255, 128/255)
		end
	end
end

-- Updates references to aura display buttons.
-- Should be called whenever a new aura is created, renamed, or deleted.
local function IndexWeakAurasDisplayButtons(count)
	-- Try for a maximum of 10 seconds to index the display buttons.
	count = count or 1
	
	if count > 10 then
		print("|cFFFF0000Liquid|r failed to index WeakAuras display buttons.")
		return
	end
	
	-- If we have not indexed the aura display button frame before, we need to search for it.
	if not displayButtonsParent then
		-- Loop through WeakAurasDisplayButtons until we find one that belongs to an aura.
		-- These can also belong to other buttons in WeakAurasOptions, like "new aura" etc.
		-- We cannot rely on them having consistent names between sessions, hence the loop.
		for i = 0, 30 do
			local buttonName = "WeakAurasDisplayButton" .. i
			local button = _G[buttonName]
			
			-- If the button has an id attached to it, it belongs to an aura.
			if button and button.id then
				displayButtonsParent = button:GetParent()
				break
			end
		end
	end
	
	-- If we've found the parent frame, index all the aura display buttons.
	-- If not, then the aura buttons have likely not been loaded yet: try again in 1 second.
	if displayButtonsParent then
		displayButtons = {}
	
		for _, button in pairs({displayButtonsParent:GetChildren()}) do
			if button.id then -- Also contains some buttons not belonging to auras, so check if there's an id.
				displayButtons[button.id] = button
				
				local data = WeakAuras.GetData(button.id)
				ChangeColorFromData(data)
			end
		end
	else
		C_Timer.After(1, function() IndexWeakAurasDisplayButtons(count + 1) end)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent",
	function(self, event, name)
	
		if name == "WeakAurasOptions" then
			IndexWeakAurasDisplayButtons()
			
			-- This is called both when a new aura is made, and when an aura's load conditions are updated.
			-- We want to check if the aura's display button was already indexed.
			-- If so, we know its load conditions were updated, so we directly recolor it
			hooksecurefunc(
				WeakAuras,
				"Add",
				function(data)
					if displayButtons[data.id] then -- Load conditions update
						ChangeColorFromData(data)
					else -- Newly created aura
						IndexWeakAurasDisplayButtons()
					end
				end
			)
			
			-- Called when an aura is renamed
			hooksecurefunc(
				WeakAuras,
				"Rename",
				function() IndexWeakAurasDisplayButtons() end
			)
			
			-- Called when an aura is deleted
			hooksecurefunc(
				WeakAuras,
				"Delete",
				function() IndexWeakAurasDisplayButtons() end
			)
		end
	end
)
do
	-- tag main groups here
	local waGroups = {
		 --[[ ["max"] = {
			[1080] = {
				"Liquid:1080:Overlay:Max",
			},
			[1440] = {
				"Liquid:1440:Overlay:Max",
			},
		},
		["luml"] = {
			[1080] = {
				"Liquid:1080:Overlay:Luml",
			},
			[1440] = {
				"Liquid:1440:Overlay:Luml",
			},
		} --]]
	}
	local function toggleChildren(id,loadNever)
		if not WeakAurasSaved.displays[id] then return end
		if WeakAurasSaved.displays[id].controlledChildren then
			for k,v in pairs(WeakAurasSaved.displays[id].controlledChildren) do
				toggleChildren(v, loadNever)
			end
		else
			WeakAurasSaved.displays[id].load.use_never = loadNever
		end
	end
	function ns:SetupWAStuff()
		local target = LiquidOverwatchHelperDB and LiquidOverwatchHelperDB.target
		local resolution = GetScreenHeight() > 1300 and 1440 or 1080
		--local _, resolution = GetPhysicalScreenSize()
		--resolution = resolution > 1300 and 1440 or 1080
		for targetName,targetData in pairs(waGroups) do
			for reso, resolutionData in pairs(targetData) do
				for _, auraName in pairs(resolutionData) do
					toggleChildren(auraName, not (targetName == target and resolution == reso))
				end
			end
		end
	end
end

-- Crafting Order functions
do
	local liquidCrafterChars = {
		["valantor"] = true,
		["partypetee"] = true,
		["currency"] = true,
		["bonusrep"] = true,
		["astolfo"] = true,
		["faen"] = true,
		["fean"] = true,
		["gleipnir"] = true,
		["dragonbane"] = true,
		["gil"] = true,
		["chromaggus"] = true,
		["chromagus"] = true,
		["amanthi"] = true,
		["fistsofurry"] = true,
		["rayquaza"] = true,
		["cliff"] = true,
		["oceanus"] = true,
		["kt"] = true,
		["epic"] = true,
		["bettersk"] = true,
		["drakkan"] = true,
		["rafaam"] = true,
		["sneakypetee"] = true,
		["colyhows"] = true,
		["peteexecutes"] = true,
		["taira"] = true,
		["aviceborn"] = true,
		["sangaruis"] = true,
		["guifei"] = true,
		["drakkano"] = true,
		["peteesneaks"] = true,
		["adhiarja"] = true,
		["mstrbtr"] = true,
		["healinglul"] = true,
		["azetodeth"] = true,
		["peteeslams"] = true,
	}
	local lastOrder = {}
	function ns.utility:InitializeCraftOrder()
		EventRegistry:RegisterCallback("ProfessionsCustomerOrders.RecipeSelected", function(_, itemID)
			if itemID then
				lastOrder.itemID = itemID
			end
		end)

		hooksecurefunc(C_CraftingOrders, "PlaceNewOrder", function(order)
			if not order.skillLineAbilityID then
				print("|cFFFF0000Liquid: Missing skillLineAbilityID - REPORT TO IRONI|r")
				return
			end
			local professionName = C_TradeSkillUI.GetProfessionNameForSkillLineAbility(order.skillLineAbilityID)
			if not professionName then
				print("|cFFFF0000Liquid: Missing professionName - REPORT TO IRONI|r")
				return
			end
			local targetProfession = Enum.Profession[professionName]
			if not targetProfession then
				print("|cFFFF0000Liquid: Missing professionEnum - REPORT TO IRONI|r", professionName)
				return
			end
			if order.recraftItem then
				local itemID = C_Item.GetItemIDByGUID(order.recraftItem)
				lastOrder.itemID = itemID
			end
			if not lastOrder.itemID then
				print("|cFFFF0000Liquid: Missing itemID - REPORT TO IRONI|r")
				return
			end
			lastOrder.placed = GetTime()
			lastOrder.data = order
			lastOrder.profession = targetProfession
		end)
	end

	function ns.utility:CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE(result)
		if not IsInGuild() then return end
		if result ~= Enum.CraftingOrderResult.Ok then return end -- 0 == Success
		if not lastOrder then return end
		if (lastOrder.placed or 0) + 5 < GetTime() then return end
		if lastOrder.data.orderType == Enum.CraftingOrderType.Public then return end
		local targetNickName = lastOrder.data.orderTarget and LiquidAPI:GetName(lastOrder.data.orderTarget)
		if lastOrder.data.orderTarget then -- overwrite for designed crafter
			if liquidCrafterChars[lastOrder.data.orderTarget:lower()] then
				targetNickName = "PartyPetee"
			end
		end
		local ownNickname = ns.me.nickname
		if not ownNickname or ownNickname == "" then -- saw something weird in screenshots, trying to fix it here
			ownNickname = LiquidAPI:GetName("player")
		end
		C_ChatInfo.SendAddonMessage("LiquidWA", string.format("LiquidCrafts;%s;%s;%s;%s;%s;%s;%s;%s", lastOrder.data.orderType, lastOrder.profession, lastOrder.itemID, ownNickname, lastOrder.data.recraftItem and "1" or "0", math.floor(lastOrder.data.tipAmount/1e4),targetNickName or "", lastOrder.data.orderTarget or ""), "GUILD")
	end
end

function ns.utility:EditMacroForQuestItem()
	if InCombatLockdown() then
		return
	end
	local mouseFoci = GetMouseFoci()
	if not mouseFoci then
		return
	end
---@diagnostic disable-next-line: undefined-field
	if not(mouseFoci and mouseFoci[1] and mouseFoci[1].questLogIndex) then
		return
	end
---@diagnostic disable-next-line: undefined-field
	local questItemLink, questItemIcon = GetQuestLogSpecialItemInfo(mouseFoci[1].questLogIndex)
	if not questItemLink then
		return
	end
	local itemName = C_Item.GetItemInfo(questItemLink)
	if not itemName then
		return
	end
	local macroText = string.format([[#showtooltip %s
/liquid questitem
/use %s]], itemName, itemName)
	local macroName = "LiquidQuestMacro"
	if not GetMacroInfo(macroName) then
			CreateMacro(macroName, "INV_Misc_QuestionMark", macroText)
			if WeakAuras then
				local text = string.format('Created macro "LiquidQuestMacro" for: %s%s', CreateSimpleTextureMarkup(questItemIcon), itemName)
				WeakAuras.ScanEvents("IRONI_LIQUIDQUESTITEMUPDATED", text)
			end
			print('Created macro: "LiquidQuestMacro"')
	else
		---@diagnostic disable-next-line: param-type-mismatch
		EditMacro(macroName, nil, nil, macroText)
		print("Liquid: Edited QuestItem macro for: ", itemName)
		if WeakAuras then
			local text = string.format("Updated: %s%s", CreateSimpleTextureMarkup(questItemIcon), itemName)
			WeakAuras.ScanEvents("IRONI_LIQUIDQUESTITEMUPDATED", text)
		end
	end
end
-- mass send "personal notes"
do
	function LIQUID_PRIVATE_NOTE_CHANGED(add, encounterID, difID) end -- Empty function just so Bart can hook into it, maybe change later to actual callbacks?
	function LiquidAPI:GetNote(encounterID, difID)
		if not (encounterID and difID) then return end
		return LiquidCharDB.notes and LiquidCharDB.notes[encounterID] and LiquidCharDB.notes[encounterID][difID]
	end
	local importFrame
	local currentData = {
		encounterInfo = {},
		targets = {},
	}
	local aceCom = LibStub("AceComm-3.0", true)
	local aceSer = LibStub("AceSerializer-3.0", true)
	local function commReceived(prefix, msg, chatType, sender)
		if prefix ~= "LiquidMassNote" then return end
		if msg == "OK" or msg == "ERROR" then
			local _sender = strsplit("-", sender)
			_sender = _sender:lower()
			for k,v in pairs(currentData.targets) do
				if v.actualTarget == _sender then
					v.reply = msg
					if importFrame and importFrame:IsShown() then
						local temp = {}
						tinsert(temp, string.format("EncounterID: %s - Difficulty: %s", currentData.encounterInfo.encounterID, currentData.encounterInfo.instanceDif == 16 and "Mythic" or currentData.encounterInfo.instanceDif == 15 and "Heroic" or currentData.encounterInfo.instanceDif))
						for k,v in ns:spairs(currentData.targets) do
							tinsert(temp, string.format("%s (%s) - #%s - %d%%%s", k, v.actualTarget or "NOT FOUND",v.textLength, v.progress or 0, v.reply and (" - " .. v.reply) or ""))
						end
						importFrame.content:SetText(table.concat(temp, "|n"))
					end
					return
				end
			end
			if msg == "OK" then
				print("received OK from unknown sender:", sender)
			elseif msg == "ERROR" then
				print("Error on receiving note from:", sender)
			end
			return
		end
		local ok, data = aceSer:Deserialize(msg)
		if not ok then
			aceCom:SendCommMessage("LiquidMassNote", "ERROR", "WHISPER", sender, "NORMAL")
			print("Liquid: Error deserializing incoming message, report to IRONI on discord!")
			return
		end
		if not LiquidCharDB.notes then
			LiquidCharDB.notes = {}
		end
		if not LiquidCharDB.notes[data.encounterID] then
			LiquidCharDB.notes[data.encounterID] = {}
		end
		LiquidCharDB.notes[data.encounterID][data.difID] = data.data
		LIQUID_PRIVATE_NOTE_CHANGED(true, data.encounterID, data.difID)
		print("Received new personal note for encounterID:", data.encounterID, "dif:", data.difID)
		aceCom:SendCommMessage("LiquidMassNote", "OK", "WHISPER", sender, "NORMAL")
	end
	local function progressUpdate(target, progress, total)
		if currentData.targets[target] then
			currentData.targets[target].progress = math.floor(progress/total*100)
			local temp = {}
			tinsert(temp, string.format("EncounterID: %s - Difficulty: %s", currentData.encounterInfo.encounterID, currentData.encounterInfo.instanceDif == 16 and "Mythic" or currentData.encounterInfo.instanceDif == 15 and "Heroic" or currentData.encounterInfo.instanceDif))
			for k,v in ns:spairs(currentData.targets) do
				tinsert(temp, string.format("%s (%s) - #%s - %d%%", k, v.actualTarget or "NOT FOUND",v.textLength, v.progress or 0))
			end
			importFrame.content:SetText(table.concat(temp, "|n"))
		else
			print("received update for unknown target:", target)
		end
	end
	local function parseEditbox(text, contentFrame)
		local encounterID, instanceDif = text:match("^>(%d+):(%d+)<")
		if not (encounterID and instanceDif) then
			contentFrame:SetText("ERROR - Incorrect paste, no encounterID and/or instanceDif found.")
			currentData = {
				encounterInfo = {},
				targets = {},
			}
			return
		end
		currentData = {
			encounterInfo = {
				encounterID = tonumber(encounterID),
				instanceDif = tonumber(instanceDif)
			},
			targets = {},
		}
		for target,targetData in text:gmatch('>>target:(.-)>(.-)<<end<') do
			local actualTarget
			if UnitExists(target) then
				actualTarget = target:lower()
			else
				local char = LiquidAPI:GetCharacterInGroup(target)
				if char then
					actualTarget = char:lower()
				end
			end
			currentData.targets[target:lower()] = {
				data = targetData,
				textLength = targetData:len(),
				actualTarget = actualTarget,
			}
		end
		local temp = {}
		tinsert(temp, string.format("EncounterID: %s - Difficulty: %s", currentData.encounterInfo.encounterID, currentData.encounterInfo.instanceDif == 16 and "Mythic" or currentData.encounterInfo.instanceDif == 15 and "Heroic" or currentData.encounterInfo.instanceDif))
		for k,v in ns:spairs(currentData.targets) do
			tinsert(temp, string.format("%s (%s) - #%s", k, v.actualTarget or "NOT FOUND",v.textLength))
		end
		contentFrame:SetText(table.concat(temp, "|n"))
	end
	aceCom:RegisterComm("LiquidMassNote", commReceived)
	ns.utility.notes = {}
	function ns.utility.notes:Show()
		if importFrame and importFrame:IsShown() then
			importFrame:Hide()
			return
		end
		if not importFrame then
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
			importFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
			importFrame:SetSize(600, 500)
			importFrame:SetFrameStrata("HIGH")
			importFrame:SetBackdrop(backdrop)
			importFrame:SetBackdropColor(0.1,0.1,0.1,0.8)
			importFrame:SetBackdropBorderColor(0,0,0,1)
			importFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
			importFrame.editbox = CreateFrame("EditBox", nil, importFrame, "BackdropTemplate")
			importFrame.editbox:SetBackdrop({
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
			importFrame.editbox:SetBackdropColor(.1,.1,.1,.8)
			importFrame.editbox:SetBackdropBorderColor(0,1,0,1)
			importFrame.editbox:SetScript('OnEnterPressed', function(self)
				self:ClearFocus()
				parseEditbox(self:GetText(), importFrame.content)
				self:SetText("")
			end)
			importFrame.editbox:SetAutoFocus(false)
			importFrame.editbox:SetWidth(595)
			importFrame.editbox:SetHeight(21)
			importFrame.editbox:SetTextInsets(2, 2, 1, 0)
			importFrame.editbox:SetPoint('TOP', importFrame, 'TOP', 0,-5)
			importFrame.editbox:SetFont(STANDARD_TEXT_FONT, 10, "")
			-- import button
			importFrame.importButton = CreateFrame("button", nil, importFrame, "UIPanelButtonTemplate")
			importFrame.importButton:SetSize(75, 20)
			importFrame.importButton:SetPoint("bottomright", importFrame, "bottomright", -5, 5)
			importFrame.importButton:SetText("Send")
			importFrame.importButton:SetScript("OnClick", function()
				print("Sending")
				for k,v in pairs(currentData.targets) do
					local ser = aceSer:Serialize({encounterID = currentData.encounterInfo.encounterID, difID = currentData.encounterInfo.instanceDif, data = v.data})
					if v.actualTarget then
						if not UnitIsUnit("player", v.actualTarget) then
							aceCom:SendCommMessage("LiquidMassNote", ser, "WHISPER", v.actualTarget, "BULK", progressUpdate, k)
						else
							print("Trying to send to yourself, skipping")
						end
					else
						print("No target:", k)
					end
				end
			end)
			importFrame.content = importFrame:CreateFontString()
			importFrame.content:SetFont(STANDARD_TEXT_FONT, 16, 'OUTLINE')
			importFrame.content:SetPoint('TOPLEFT', importFrame, 'TOPLEFT', 5, -30)
			importFrame.content:SetJustifyH("LEFT")

			local closeButton = CreateFrame("button", nil, importFrame, "UIPanelButtonTemplate")
			closeButton:SetSize(100, 20)
			closeButton:SetPoint("bottom", importFrame, "bottom", 0, 5)
			closeButton:SetText("Close")
			closeButton:SetScript("OnClick", function() importFrame:Hide() end)
		end
		importFrame:Show()
	end
end
StaticPopupDialogs.LIQUID_WARNING_RANDOM_NOTIFICATION = {
	text = "%s",
	button1 = OKAY,
	hideOnEscape = true,
	--exclusive = 0,
}
function ns.utility.randomNotifications()
	local _, realm = UnitFullName("player")
	if realm == "Illidan" then return end
	if not WeakAurasSaved or GetCurrentRegion() ~= 1 then return end
	--if not WeakAurasSaved then return end
	if WeakAurasSaved.displays["LiquidSplits:AutoPass"] and
		WeakAurasSaved.displays["LiquidSplits:AutoPass"].load and
		WeakAurasSaved.displays["LiquidSplits:AutoPass"].load.use_never then
			StaticPopup_Show("LIQUID_WARNING_RANDOM_NOTIFICATION", 'WA "LiquidSplits:AutoPass" is set to never loaded - enable it unless its disabled for a *reason*')
	end
end

function ns.PrintDebug(str, ...)
	if not ns.debugMode then return end
	local args = {...}
	for k,v in pairs(args) do
		args[k] = tostring(v)
	end
	local success, error = pcall(function() print(string.format("LiquidDebug - %s", (#args > 0 and str:format(unpack(args))) or str)) return true end )
	if success then return end
	print("Error from PrintDebug:", error, "str:", str)
end

--TODO teach how to count

