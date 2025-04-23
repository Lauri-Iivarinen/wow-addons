---@diagnostic disable: inject-field
local _addonName, ns = ...



local frames = {}

LiquidAPI.UnitFrames = {}
function LiquidAPI.UnitFrames:GenerateClickableFrame(id, unit, condition, position, size)
  if InCombatLockdown() then error("You can't generate unit frames in combat") end
  local f
  if frames[id] then
    f = frames[id]
  else
    f = CreateFrame("Button", "LiquidClickableFrame"..id, UIParent, "SecureUnitButtonTemplate,BackdropTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerStateTemplate")
    --SecureHandlerClickTemplate
    --f:SetAttribute("type1", "macro") -- left click causes macro
    --f:SetAttribute("macrotext1", "/s zomg a left click!") -- text for macro on left click
    --f:Show()
    --RegisterUnitWatch(f)
    f:RegisterForClicks("AnyUp")
    f:SetAttribute("*type1", "target")
    f:SetAttribute("*type2", "togglemenu")
    --f.tex = f:CreateTexture()
    --f.tex:SetAllPoints()
    --f.tex:SetColorTexture(.5,.5,.5,.5)
    f:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8x8',
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      }}
    )
    f:SetBackdropColor(.5,.5,.5,.2)
    ClickCastFrames[f] = true -- enables clique etc
    frames[id] = f
  end
  f.isActivated = true
  f:ClearAllPoints()
  f:SetSize(size.width, size.height)
  f:SetPoint(position.from, UIParent, position.to, position.x, position.y)
  f:SetAttribute("unit", unit)
  RegisterAttributeDriver(f, "state-visibility", condition)
  print("Enabling frame for id:", id, unit)
  return f
  --RegisterAttributeDriver(f, "state-visibility", "[@target, help] show; hide")
end
function LiquidAPI.UnitFrames:DisableClickableFrame(id)
  if InCombatLockdown() then
    print("Can't disable frames in combat, trying again in 3 seconds")
    C_Timer.After(3, function ()
      LiquidAPI.UnitFrames:DisableClickableFrame(id)
    end)
    return
  end
  if not frames[id] then return end
  if not frames[id].isActivated then return end
  frames[id].isActivated = false
  UnregisterAttributeDriver(frames[id], "state-visibility")
  frames[id]:Hide()
  print("Disabling frame for id:", id)
end
function LiquidAPI.UnitFrames:IsActive(id)
  return frames[id] and frames[id].isActivated
end
