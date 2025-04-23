local _, ns = ...


-- Chars in raid check (/liquid charcheck)
do
	local editbox
	local function checkRaid(data)
		local t = {}
		local _, _s = UnitFullName("player")
		for i = 1, GetNumGroupMembers() do
			local _,s = UnitName("raid"..i)
			local n = UnitNameUnmodified("raid"..i)
			t[n:lower().."-"..(s or _s):lower()] = true
		end
		local d = {strsplit("\n", data)}
		--ViragDevTool_AddData(d, "splitted")
		--ViragDevTool_AddData(data, "presplit")
		local hasMissing = false
		for k,v in pairs(d) do
			if not t[v:lower()] then
				if not hasMissing then
					hasMissing = true
					print("--Missing Characters--")
				end
				print(v)
			end
		end
		if not hasMissing then
			print("Everyone is in raid.")
		end
	end
	function ns:CheckCharsInRaid()
		if editbox then
			editbox:SetText("")
			editbox:Show()
		else
			editbox = CreateFrame("EditBox", nil, UIParent, "BackdropTemplate")
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
			editbox:SetScript('OnEnterPressed', function(self)
				checkRaid(self:GetText())
				self:Hide()
			end)
			editbox:SetWidth(250)
			editbox:SetMultiLine(true)
			editbox:SetHeight(60)
			editbox:SetTextInsets(2, 2, 1, 0)
			editbox:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
			editbox:SetText("")
			editbox:SetAutoFocus(false)
			editbox:SetFont(STANDARD_TEXT_FONT, 10, "")
		end
	end
end