-- ADDON LOADED fix

local ExRT = GExRT
local GlobalAddonName,DATA_TABLE = ...

setmetatable(DATA_TABLE, {__index=function (t, k)
	return ExRT[k]
end})

local ExRTmod = CreateFrame("Frame")
ExRTmod:SetScript("OnEvent",function (self, event, addonName)
	if addonName == GlobalAddonName then
		for i=1,#ExRT.Modules do
			if ExRT.Modules[i].name == "CSpells" then
				ExRT.Modules[i].main:ADDON_LOADED()
				ExRT.ModulesLoaded[i] = true
				break
			end
		end
	
		self:UnregisterEvent("ADDON_LOADED")		
	end
end)
ExRTmod:RegisterEvent("ADDON_LOADED") 