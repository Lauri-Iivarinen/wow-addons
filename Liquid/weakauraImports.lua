local _, ns = ...

if not (C_AddOns.IsAddOnLoaded("LiquidWeakAuras") and C_AddOns.IsAddOnLoaded("WeakAuras")) then return end
local sformat, tinsert, CopyTable, tremove = string.format, table.insert, CopyTable, table.remove
local fileWideTable = {}
local UIDsToIDs = {}
for waName,v in pairs(WeakAurasSaved.displays) do
  UIDsToIDs[v.uid] = waName
end
--if true then return end
local gameVersion
do
  --local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
  if GetCurrentRegion() == 72 then
    gameVersion = "ptr"
  elseif PTR_IssueReporter or IsTestBuild() then
    gameVersion = "beta"
  else
    gameVersion = "live"
  end
end
do
  local updateMode = {
    NEW = 0,
    UPDATE = 1,
    CURRENT = 2,
  }
  local function tcontains(t, value)
    if not t then return false end
    local i = 1
    while t[i] do
      if t[i] == value then return true end
      i = i +1
    end
    return false
  end
  local function _tremove(t, value)
    if not t then return end
    local i = 1
    while t[i] do
      if t[i] == value then
        tremove(t, i)
        return
      end
      i = i +1
    end
    return false
  end
  local expansionsIds = { -- include all old expansions, just because it looks better
    [1] = "Classic",
    [2] = "TBC",
    [3] = "WotLK",
    [4] = "Cata",
    [5] = "MoP",
    [6] = "WoD",
    [7] = "Legion",
    [8] = "BFA",
    [9] = "SL",
    [10] = "DF",
    [11] = "TWW",
    [12] = "MN",
    [13] = "TLT",
  }
  local defaults = {
    liquidData = {
      tag = "",
      cur = "",
    },
    customOptions = {
      ["subOptions"] = {
        [1] = {
            ["type"] = "header",
            ["useName"] = true,
            ["text"] = "Auto import options",
            ["noMerge"] = true,
            ["width"] = 1,
        },
        [2] = {
            ["type"] = "toggle",
            ["key"] = "display",
            ["desc"] = "This includes position, font, font size etc where ever possible",
            ["useDesc"] = true,
            ["name"] = "Preserve Display",
            ["default"] = true,
            ["width"] = 1,
        },
        [3] = {
            ["type"] = "toggle",
            ["key"] = "sounds",
            ["desc"] = "Will only work for options where you can choose a sound",
            ["useDesc"] = true,
            ["name"] = "Preserve Sounds",
            ["default"] = true,
            ["width"] = 1,
        },
        [4] = {
          ["type"] = "toggle",
          ["key"] = "roleload",
          ["desc"] = "Preserve Role load condition",
          ["useDesc"] = true,
          ["name"] = "Preserve Role load condition",
          ["default"] = false,
          ["width"] = 1,
        },
      },
      ["type"] = "group",
      ["useDesc"] = false,
      ["nameSource"] = 0,
      ["name"] = "Auto Import",
      ["width"] = 1,
      ["useCollapse"] = false,
      ["noMerge"] = true,
      ["key"] = "LiquidAutoImportOptions",
      ["collapse"] = false,
      ["limitType"] = "none",
      ["groupType"] = "simple",
      ["hideReorder"] = true,
      ["size"] = 10,
    },
    mainGroup = {
      ["backdropColor"] = {
          [1] = 1,
          [2] = 1,
          [3] = 1,
          [4] = 0.5,
      },
      ["controlledChildren"] = {
      },
      ["borderBackdrop"] = "Blizzard Tooltip",
      ["scale"] = 1,
      ["xOffset"] = 0,
      ["config"] = {
      },
      ["border"] = false,
      ["borderEdge"] = "Square Full White",
      ["regionType"] = "group",
      ["borderSize"] = 2,
      ["borderColor"] = {
          [1] = 0,
          [2] = 0,
          [3] = 0,
          [4] = 1,
      },
      ["authorOptions"] = {
      },
      ["actions"] = {
          ["start"] = {
          },
          ["init"] = {
          },
          ["finish"] = {
          },
      },
      ["triggers"] = {
          [1] = {
              ["trigger"] = {
                  ["names"] = {
                  },
                  ["type"] = "aura2",
                  ["spellIds"] = {
                  },
                  ["subeventSuffix"] = "_CAST_START",
                  ["unit"] = "player",
                  ["subeventPrefix"] = "SPELL",
                  ["event"] = "Health",
                  ["debuffType"] = "HELPFUL",
              },
              ["untrigger"] = {
              },
          },
      },
      ["borderInset"] = 1,
      ["internalVersion"] = 65,
      ["yOffset"] = 0,
      ["animation"] = {
          ["start"] = {
              ["type"] = "none",
              ["easeStrength"] = 3,
              ["duration_type"] = "seconds",
              ["easeType"] = "none",
          },
          ["main"] = {
              ["type"] = "none",
              ["easeStrength"] = 3,
              ["duration_type"] = "seconds",
              ["easeType"] = "none",
          },
          ["finish"] = {
              ["type"] = "none",
              ["easeStrength"] = 3,
              ["duration_type"] = "seconds",
              ["easeType"] = "none",
          },
      },
      ["id"] = "LiquidAutoImports",
      ["anchorPoint"] = "CENTER",
      ["frameStrata"] = 1,
      ["anchorFrameType"] = "SCREEN",
      ["selfPoint"] = "CENTER",
      ["uid"] = "liquid-URlhke5xzn8",
      ["borderOffset"] = 4,
      ["subRegions"] = {
      },
      ["conditions"] = {
      },
      ["information"] = {
      },
      ["load"] = {
          ["size"] = {
              ["multi"] = {
              },
          },
          ["spec"] = {
              ["multi"] = {
              },
          },
          ["class"] = {
              ["multi"] = {
              },
          },
          ["talent"] = {
              ["multi"] = {
              },
          },
      },
    },
  }
  
  local displayValueKeysToCareAbout = {
    ["aurabar"] = {"selfPoint", "xOffset", "anchorPoint", "height", "barColor", "sparkHidden", "sparkTexture", "icon_color", "iconSource", "texture", "anchorFrameType", "spark", "orientation", "sparkOffsetX", "sparkHeight", "sparkRotation", "sparkRotationMode", "sparkBlendMode", "width", "zoom", "icon", "sparkOffsetY", "frameStrata", "enableGradient", "desaturate", "sparkWidth", "yOffset", "sparkColor", "icon_side", "barColor2", "gradientOrientation", "backgroundColor",
      --"inverse" disable for now
    },
    ["dynamicgroup"] = {"fullCircle", "gridType", "animate", "border", "align", "yOffset", "xOffset", "anchorFrameType", "borderSize", "borderBackdrop", "gridWidth", "borderEdge", "borderOffset", "grow",
    --"sort", disable this for now
      "borderInset", "limit", "useLimit", "scale", "borderColor", "columnSpace", "rowSpace", "centerType", "space", "frameStrata", "constantFactor", "arcLength", "stagger", "anchorPoint", "radius", "rotation", "selfPoint", "backdropColor"},
    ["group"] = {"borderBackdrop", "borderInset", "borderColor", "border", "anchorPoint", "backdropColor", "borderEdge", "scale", "anchorFrameType", "yOffset", "xOffset", "frameStrata", "borderOffset", "borderSize"},
    ["icon"] = {"cooldown", "selfPoint", "cooldownTextDisabled", "iconSource", "inverse", "desaturate", "anchorPoint", "cooldownSwipe", "width", "keepAspectRatio", "zoom", "anchorFrameType", "icon", "frameStrata", "useCooldownModRate", "yOffset", "xOffset", "height", "cooldownEdge", "color"},
    ["model"] = {"api", "anchorPoint", "borderBackdrop", "scale", "borderSize", "borderInset", "border", "model_z", "model_y", "rotation", "model_path", "advance", "model_fileId", "borderEdge", "model_st_rx", "backdropColor", "model_st_ty", "borderOffset", "xOffset", "yOffset", "width", "model_st_ry", "borderColor", "frameStrata", "height", "modelIsUnit", "model_st_us", "anchorFrameType", "selfPoint", "sequence", "model_x", "model_st_rz", "model_st_tz", "model_st_tx"},
    ["progresstexture"] = {"backgroundOffset", "foregroundColor", "rotation", "compress", "inverse", "foregroundTexture", "blendMode", "desaturateBackground", "mirror", "selfPoint", "user_y", "desaturateForeground", "crop_x", "anchorPoint", "frameStrata", "sameTexture", "backgroundTexture", "textureWrapMode", "auraRotation", "orientation", "height", "width", "startAngle", "endAngle", "anchorFrameType", "slantMode", "yOffset", "xOffset", "crop_y", "user_x", "backgroundColor"},
    ["stopmotion"] = {"desaturateBackground", "animationType", "selfPoint", "mirror", "customForegroundRows", "xOffset", "hideBackground", "foregroundColor", "customBackgroundColumns", "customForegroundColumns", "foregroundTexture", "backgroundTexture", "desaturateForeground", "customForegroundFrames", "backgroundColor", "anchorFrameType", "backgroundPercent", "height", "anchorPoint", "customBackgroundRows", "blendMode", "customForegroundFrameHeight", "customForegroundFrameWidth", "customForegroundFileHeight", "sameTexture", "frameRate", "inverse", "customBackgroundFrames", "frameStrata", "customForegroundFileWidth", "endPercent", "yOffset", "startPercent", "width"},
    ["text"] = {"fixedWidth", "anchorFrameType", "shadowYOffset", "justify", "xOffset", "yOffset", "selfPoint", "wordWrap", "color", "outline", "shadowXOffset", "shadowColor", "automaticWidth", "frameStrata", "anchorPoint"},
    ["texture"] = {"rotate", "color", "mirror", "desaturate", "rotation", "frameStrata", "anchorPoint", "xOffset", "yOffset", "width", "anchorFrameType", "selfPoint", "height", "blendMode", "texture", "textureWrapMode"},
    ["empty"] = {"width","height","selfPoint","anchorPoint", "anchorFrameType", "xOffset", "yOffset", "frameStrata"},
    --["subbackground"] = {},
    --["subforeground"] = {},
    ["subborder"] = {"border_visible","border_color","border_edge","border_offset","border_size","anchor_area"},
    ["subcirculartexture"] = {"circularTextureVisible","circularTextureTexture","circularTextureDesaturate","circularTextureColor","circularTextureBlendMode","circularTextureStartAngle","circularTextureEndAngle","circularTextureClockwise","circularTextureCrop_x","circularTextureCrop_y","circularTextureRotation","circularTextureAuraRotation","circularTextureMirror","anchor_mode","self_point","anchor_point","width","height","scale","progressSource", "anchor_area"},
    ["subglow"] = {"glow","useGlowColor","glowColor","glowType","glowLines","glowFrequency","glowDuration","glowLength","glowThickness","glowScale","glowBorder","glowXOffset","glowYOffset", "anchor_area"},
    ["sublineartexture"] = {"linearTextureVisible","linearTextureTexture","linearTextureDesaturate","linearTextureColor","linearTextureBlendMode","linearTextureOrientation","linearTextureWrapMode","linearTextureUser_x","linearTextureUser_y","linearTextureCrop_x","linearTextureCrop_y","linearTextureRotation","linearTextureAuraRotation","linearTextureMirror","anchor_mode","self_point","anchor_point","width","height","scale","progressSource", "anchor_area"},
    ["submodel"] = {"model_visible","model_alpha","api","model_x","model_y","model_z","rotation","model_st_tx","model_st_ty","model_st_tz","model_st_rx","model_st_ry","model_st_rz","model_st_us","model_fileId","bar_model_clip"},
    ["substopmotion"] = {"stopmotionVisible","barModelClip","stopmotionTexture","stopmotionDesaturate","stopmotionColor","stopmotionBlendMode","startPercent","endPercent","frameRate","animationType","inverse","customFrames","customRows","customColumns","customFileWidth","customFileHeight","customFrameWidth","customFrameHeight","anchor_mode","self_point","anchor_point","width","height","scale","progressSource", "anchor_area"},
    ["subtext"] = {"text_text","text_color","text_font","text_fontSize","text_fontType","text_visible","text_justify","text_selfPoint","anchor_point","anchorXOffset","anchorYOffset","text_shadowColor","text_shadowXOffset","text_shadowYOffset","rotateText","text_automaticWidth","text_fixedWidth","text_wordWrap"},
    ["subtexture"] = {"textureVisible","textureTexture","textureDesaturate","textureColor","textureBlendMode","textureMirror","textureRotate","textureRotation","anchor_mode","self_point","anchor_point","width","height","scale","mirror","rotate", "anchor_area"},
    ["subtick"] = {"tick_visible", "tick_color", "tick_placement_mode", "tick_placements","progressSources","automatic_length","tick_thickness","tick_length","use_texture","tick_texture","tick_blend_mode","tick_desaturate","tick_rotation","tick_xOffset","tick_yOffset","tick_mirror"},
  }
  -- add common keys to all
  for _, key in pairs({"alpha",
    --"useAdjustededMax", removed for now
    --"useAdjustededMin", removed for now
    "saved"}) do
    for _,v in pairs(displayValueKeysToCareAbout) do
      tinsert(v, key)
    end
  end

  local function checkUID(uid)
    return uid:sub(1,6) == "liquid"
  end
  local function clearExtras(t)
    t.url = nil
    t.wagoID = nil
    return t
  end
  local function modernize(t)
    local success, error = pcall(function() fileWideTable.Modernize(t) return true end )
    if not success then
      print("Liquid: Error modernizing, if this *actually* causes problems contact Ironi with a screenshot of this", t.id, error)
    end
  end
  local function NeedsUpdating(t, tag)
    local currentDisplay = UIDsToIDs[t.uid] and WeakAurasSaved.displays[UIDsToIDs[t.uid]]
    if not currentDisplay then
      modernize(t)
      return updateMode.NEW, nil
    end
    if currentDisplay.liquidData and currentDisplay.liquidData.tag ~= tag then
      modernize(currentDisplay)
      return updateMode.UPDATE, currentDisplay
    end
    return updateMode.CURRENT, currentDisplay
  end
  local function handleSubRegions(incomingDisplaySubRegions, currentRegion, count)
    -- assume all these types are in the same order,there isn't really anything else that we can rely on
    local typesFound = 0
    --local found = false
    local i = 1
    while incomingDisplaySubRegions[i] do
      if incomingDisplaySubRegions[i].type == currentRegion.type then
        typesFound = typesFound + 1
        if typesFound == count then
          incomingDisplaySubRegions[i] = CopyTable(currentRegion)
          --found = true
          break
        end
      end
      i = i + 1
    end
    -- remove this for now
    --if not found then -- user created a new glow, drop it at the end
     -- tinsert(incomingDisplaySubRegions, CopyTable(currentRegion))
    --end
  end
  local ignoreUserSettings = {
    subtick = true,
  }
  local function setDisplaySettings(incomingDisplay, SVDisplay)
    if incomingDisplay.regionType ~=  SVDisplay.regionType then return end -- assume the aura has changed so much that overwrite everything
    if SVDisplay.subRegions then
      if not incomingDisplay.subRegions then
        incomingDisplay.subRegions = {}
      end
      local subRegionTypeCounts = {}
      for _, d in ipairs(SVDisplay.subRegions) do
        if d.type == "subtext" then
          local i = 1
          while incomingDisplay.subRegions[i] do
            if incomingDisplay.subRegions[i].text_text == d.text_text then
              incomingDisplay.subRegions[i] = CopyTable(d)
              break
            end
            i = i + 1
          end
          -- remove this for now
          --if not found then -- user created a new text, drop it at the end
            --tinsert(incomingDisplay.subRegions, CopyTable(d))
          --end
        elseif not ignoreUserSettings[d.type] then
          if not subRegionTypeCounts[d.type] then
            subRegionTypeCounts[d.type] = 0
          end
          subRegionTypeCounts[d.type] = subRegionTypeCounts[d.type] + 1
          handleSubRegions(incomingDisplay.subRegions, d, subRegionTypeCounts[d.type])
        end
        --[[
        elseif d.type == "subglow" then
          glowCount = glowCount + 1
          handleSubRegions(incomingDisplay.subRegions, d, glowCount, "subglow")
        elseif d.type == "subborder" then
          borderCount = borderCount + 1
          handleSubRegions(incomingDisplay.subRegions, d, borderCount, "subborder")
        elseif d.type == "submodel" then
          modelCount = modelCount + 1
          handleSubRegions(incomingDisplay.subRegions, d, modelCount, "submodel")
        elseif d.type == "subbackground" then
          backgroundCount = backgroundCount + 1
          handleSubRegions(incomingDisplay.subRegions, d, modelCount, "subbackground")
        --elseif d.type == "subtick" then
          --tickCount = tickCount + 1
          --handleSubRegions(incomingDisplay.subRegions, d, tickCount, "subtick")
        end
        --]]
      end
    end
    if not displayValueKeysToCareAbout[incomingDisplay.regionType] then return end -- we don't care about any of the keys, shouldn't really happen
    for _, key in pairs(displayValueKeysToCareAbout[incomingDisplay.regionType]) do
      if key == "grow" then
        if incomingDisplay.grow ~= "CUSTOM" then -- always overwrite custom from incoming display
          incomingDisplay.grow = SVDisplay.grow
        end
      elseif type(SVDisplay[key]) == "table" then
        incomingDisplay[key] = CopyTable(SVDisplay[key])
      elseif SVDisplay[key] ~= nil then
        incomingDisplay[key] = SVDisplay[key]
      end
    end
    -- fetch glows under actions
    if SVDisplay.actions then
      if SVDisplay.actions.start and SVDisplay.actions.start.do_glow then
        if not incomingDisplay.actions then
          incomingDisplay.actions = {}
        end
        if not incomingDisplay.actions.start then
          incomingDisplay.actions.start = {
            do_glow = false,
            do_custom = false,
          }
        end
        for actionKey,actionValue in pairs(SVDisplay.actions.start) do
          if actionKey:find("glow",nil, true) then
            incomingDisplay.actions.start[actionKey] = type(actionValue) == "table" and CopyTable(actionValue) or actionValue
          end
        end
      end
      if SVDisplay.actions.finish then
        if not incomingDisplay.actions then
          incomingDisplay.actions = {}
        end
        if not incomingDisplay.actions.finish then
          incomingDisplay.actions.finish = {}
        end
        for actionKey,actionValue in pairs(SVDisplay.actions.finish) do
          if actionKey:find("glow",nil, true) then
            incomingDisplay.actions.finish[actionKey] = type(actionValue) == "table" and CopyTable(actionValue) or actionValue
          end
        end
      end
    end
  end
  local function setSoundSettings(incomingDisplay, SVDisplay)
    -- check conditions first
    if SVDisplay.conditions then
      for conditionID,conditionData in pairs(SVDisplay.conditions) do
        if conditionData.changes then
          for k,v in pairs(conditionData.changes) do
            if type(v.value) == "table" and v.value.sound then
              if incomingDisplay.conditions and incomingDisplay.conditions[conditionID] and incomingDisplay.conditions[conditionID].changes
                and incomingDisplay.conditions[conditionID].changes[k] and incomingDisplay.conditions[conditionID].changes[k].value
                and incomingDisplay.conditions[conditionID].changes[k] and incomingDisplay.conditions[conditionID].changes[k].value.sound then
                incomingDisplay.conditions[conditionID].changes[k].value = CopyTable(v.value)
              end
            end
          end
        end
      end
    end
    -- actions
    if SVDisplay.actions then
      if SVDisplay.actions.start and SVDisplay.actions.start.do_sound then
        if not incomingDisplay.actions then
          incomingDisplay.actions = {}
        end
        if not incomingDisplay.actions.start then
          incomingDisplay.actions.start = {
            do_glow = false,
            do_custom = false,
          }
        end
        incomingDisplay.actions.start.do_sound = SVDisplay.actions.start.do_sound
        incomingDisplay.actions.start.sound = SVDisplay.actions.start.sound
        incomingDisplay.actions.start.sound_channel = SVDisplay.actions.start.sound_channel
      end
      if SVDisplay.actions.finish and SVDisplay.actions.finish.do_sound then
        if not incomingDisplay.actions then
          incomingDisplay.actions = {}
        end
        if not incomingDisplay.actions.finish then
          incomingDisplay.actions.finish = {
            do_glow = false,
            do_custom = false,
          }
        end
        incomingDisplay.actions.finish.do_sound = SVDisplay.actions.finish.do_sound
        incomingDisplay.actions.finish.sound = SVDisplay.actions.finish.sound
        incomingDisplay.actions.finish.sound_channel = SVDisplay.actions.finish.sound_channel
      end
    end
  end
  local function handleCustomOptions(incomingDisplay, SVDisplay)
    local hasOptions = false
    local keyToData = {}
    for k,v in pairs(incomingDisplay.authorOptions) do
      if v.key == "LiquidAutoImportOptions" then -- update options TODO add to documentation
        incomingDisplay.authorOptions[k] = CopyTable(defaults.customOptions)
        hasOptions = true
        break
      end
    end
    if not hasOptions then
      if not incomingDisplay.authorOptions then
        incomingDisplay.authorOptions = {}
      end
      tinsert(incomingDisplay.authorOptions, CopyTable(defaults.customOptions))
    end
    if not SVDisplay then return end
    if not SVDisplay.load.use_never then -- enabled, don't care
      incomingDisplay.load.use_never = false
    else
      -- check if its force enabled
      if incomingDisplay.desc then
        if incomingDisplay.desc:lower():match("forceenable") then -- force enable
          incomingDisplay.load.use_never = false
        else -- keep same
          incomingDisplay.load.use_never = SVDisplay.load.use_never
        end
      else -- keep same
        incomingDisplay.load.use_never = SVDisplay.load.use_never
      end
    end
    if SVDisplay.config then
      if SVDisplay.config and SVDisplay.config.LiquidAutoImportOptions and SVDisplay.config.LiquidAutoImportOptions.display then
        setDisplaySettings(incomingDisplay, SVDisplay)
      end
      if SVDisplay.config and SVDisplay.config.LiquidAutoImportOptions and SVDisplay.config.LiquidAutoImportOptions.sounds then
        setSoundSettings(incomingDisplay, SVDisplay)
      end
      if SVDisplay.config and SVDisplay.config.LiquidAutoImportOptions and SVDisplay.config.LiquidAutoImportOptions.roleload then
        incomingDisplay.load.use_role = SVDisplay.load.use_role
        if SVDisplay.load.role then
          incomingDisplay.load.role = CopyTable(SVDisplay.load.role)
        else
          incomingDisplay.load.role = nil
        end
      end
      for k,v in pairs(SVDisplay.config) do
        if not incomingDisplay.config then
          incomingDisplay.config = {}
        end
        if k ~= "LiquidDevOptions" then -- TODO add to documentation
          if type(v) == "table" then
            incomingDisplay.config[k] = CopyTable(v)
          else
            incomingDisplay.config[k] = v
          end
        end
      end
    end
  end
  local _cur
  local function applyLiquidData(incomingDisplay, SVDisplay, tag)
    if not _cur then
      _cur = LiquidAPI:GetName('player')
    end
    if not incomingDisplay.liquidData then
      incomingDisplay.liquidData = CopyTable(defaults.liquidData)
    end
    if SVDisplay and SVDisplay.liquidData then
      for k,v in pairs(SVDisplay.liquidData) do -- Not actually needed rn, do it anyway in case we use this for something later on
        incomingDisplay.liquidData[k] = v
      end
    end
    incomingDisplay.liquidData.tag = tag
    incomingDisplay.liquidData.cur = _cur
  end
  local function renameIfNeeded(incomingDisplay, renamedTable)
    local currentAura = UIDsToIDs[incomingDisplay.uid] and WeakAurasSaved.displays[UIDsToIDs[incomingDisplay.uid]] or nil
    if not currentAura then -- uid doesn't exist, check if we still need to rename incoming wa
      if WeakAurasSaved.displays[incomingDisplay.id] then
        local newName = incomingDisplay.id .. " A"
        renamedTable[incomingDisplay.id] = newName
        incomingDisplay.id = newName
      end
      return
    end
    -- aura exists, lets see if it has the sama name
    if currentAura.id == incomingDisplay.id then return end
    -- aura with same name exists, we need to rename incoming wa
    renamedTable[incomingDisplay.id] = currentAura.id
    incomingDisplay.id = currentAura.id
  end
  local function fetchAllChildren(display, childrenTable, sortedWATable)
    if not display.controlledChildren then return end
    for _, childrenName in ipairs(display.controlledChildren) do
      if sortedWATable then -- used *ONLY* for auto deleting
        local d = sortedWATable[childrenName] or WeakAurasSaved.displays[childrenName]
        if d then
          childrenTable[childrenName] = true
          fetchAllChildren(d, childrenTable, sortedWATable)
        else
          print("LiquidWeakAuras: error finding children:", childrenName)
        end
      else
        if WeakAurasSaved.displays[childrenName] then
          childrenTable[childrenName] = true
          fetchAllChildren(WeakAurasSaved.displays[childrenName], childrenTable)
        end
      end
    end
  end
  local function getAutoImportGroupName(expansion, season)
    if expansion == 0 or season == 0 then -- LiquidAutoImports (default group)
      if not WeakAurasSaved.displays[defaults.mainGroup.id] then
        WeakAurasSaved.displays[defaults.mainGroup.id] = CopyTable(defaults.mainGroup)
      end
      return defaults.mainGroup.id
    else
      local groupName = sformat("%s:%s:S%s", defaults.mainGroup.id, expansionsIds[expansion] or "UNKNOWN", season or 0)
      if WeakAurasSaved.displays[groupName] then
        return groupName
      end
      local grp = CopyTable(defaults.mainGroup)
      grp.id = groupName
      grp.uid = sformat("%s%s%s", defaults.mainGroup.uid, expansionsIds[expansion] or "UNKNOWN", season or 0)
      WeakAurasSaved.displays[groupName] = grp
      return groupName
    end
  end
  local function isAutoImportGroupID(id)
    return id:sub(1,17) == "LiquidAutoImports"
  end

  function ns:handleWeakAuraImports()
    local data = LiquidWeakAurasAPI:GetData()
    local aurasToCareAbout = {}
    for k,v in ns:spairs(data, function(t,a,b) return t[b].priority < t[a].priority end) do
      if v.clients[gameVersion] then
        -- check blacklist first
        local isBlacklisted = v.blacklistNicknames[ns.me.nickname] or v.blacklistNicknames[ns.me.nickname:lower()] or v.blacklistCharacters[ns.me.currentCharName] or v.blacklistCharacters[ns.me.currentCharName:lower()]
        if not isBlacklisted then
          for waRole in pairs(LiquidDB.WeakAuraRoles) do
            if v.blacklistRoles[waRole] or v.blacklistRoles[waRole:lower()] then
              isBlacklisted = true
              break
            end
          end
        end
        if not isBlacklisted then
          local shouldCare = v.whitelistRoles.all or v.whitelistRoles.All or v.whitelistNicknames[ns.me.nickname] or v.whitelistNicknames[ns.me.nickname:lower()] or v.whitelistCharacters[ns.me.currentCharName] or v.whitelistCharacters[ns.me.currentCharName:lower()]
          if not shouldCare then
            for waRole in pairs(LiquidDB.WeakAuraRoles) do
              if v.whitelistRoles[waRole] or v.whitelistRoles[waRole:lower()] then
                shouldCare = true
                break
              end
            end
          end
          if shouldCare then
            tinsert(aurasToCareAbout, k)
          end
        end
      end
    end
    local sortedWAs = {}
    local renamed = {}
    for _, tag in ipairs(aurasToCareAbout) do
      local importData = data[tag].waTable
      local mainDisplay = importData.d
      if not checkUID(mainDisplay.uid) then
        mainDisplay.uid = sformat("liquid-%s", mainDisplay.uid)
      end
      renameIfNeeded(mainDisplay, renamed) -- temp
      local _mode, SVDisplay = NeedsUpdating(mainDisplay, tag)
      if _mode == updateMode.CURRENT and not importData.c then -- is current and doesn't have children incoming, don't touch
      else
        applyLiquidData(mainDisplay, SVDisplay, tag)
        handleCustomOptions(mainDisplay, SVDisplay)
        if importData.c then -- main display has children
          local manuallyAdd = false
          if not mainDisplay.controlledChildren then
            manuallyAdd = true
            mainDisplay.controlledChildren = {}
          end
          for _,children in pairs(importData.c) do
            if not checkUID(children.uid) then
              children.uid = sformat("liquid-%s", children.uid)
            end
            renameIfNeeded(children, renamed)
            if manuallyAdd then
              tinsert(mainDisplay.controlledChildren, children.id)
            end
            if not children.parent then
              children.parent = mainDisplay.id
            end
            local _childrenMode, childrenSVDisplay = NeedsUpdating(children, tag)
            if _childrenMode == updateMode.CURRENT and not children.controlledChildren then -- don't touch
            else
              applyLiquidData(children, childrenSVDisplay, tag)
              handleCustomOptions(children, childrenSVDisplay)
              sortedWAs[children.id] = children
            end
          end
        end
        sortedWAs[mainDisplay.id] = mainDisplay
      end
    end
    -- Update WA's and make sure group relationships are correctly merged
    for k,v in pairs(sortedWAs) do
      if v.parent and renamed[v.parent] then
        v.parent = renamed[v.parent]
        if sortedWAs[v.parent] then
          if not tcontains(sortedWAs[v.parent].controlledChildren, v.id) then
            tinsert(sortedWAs[v.parent].controlledChildren, v.id)
          end
        end
      --elseif not v.parent or (v.parent and (v.parent == defaults.mainGroup.id or (not sortedWAs[v.parent] and not WeakAurasSaved.displays[v.parent]))) then
      elseif not v.parent or (v.parent and (isAutoImportGroupID(v.parent) or (not sortedWAs[v.parent] and not WeakAurasSaved.displays[v.parent]))) then
        local targetAutoImportGroup
        if not v.liquidData then -- cba to check if this can even happen, doubt it
          targetAutoImportGroup = getAutoImportGroupName(0, 0)
        else
          targetAutoImportGroup = getAutoImportGroupName(data[v.liquidData.tag] and data[v.liquidData.tag].expansion or 0, data[v.liquidData.tag] and data[v.liquidData.tag].season or 0)
        end
        --v.parent = defaults.mainGroup.id
        v.parent = targetAutoImportGroup
        if not tcontains(WeakAurasSaved.displays[targetAutoImportGroup].controlledChildren, v.id) then
          tinsert(WeakAurasSaved.displays[targetAutoImportGroup].controlledChildren, v.id)
        end
      else
        if sortedWAs[v.parent] then
          if not tcontains(sortedWAs[v.parent].controlledChildren, v.id) then
            tinsert(sortedWAs[v.parent].controlledChildren, v.id)
          end
        end
      end
      if v.controlledChildren then
        local i = 1
        local keyCount = {}
        while v.controlledChildren[i] do
          if renamed[v.controlledChildren[i]] then
            if not tcontains(v.controlledChildren, renamed[v.controlledChildren[i]]) then
              v.controlledChildren[i] = renamed[v.controlledChildren[i]]
            end
            keyCount[v.controlledChildren[i]] = (keyCount[v.controlledChildren[i]] and keyCount[v.controlledChildren[i]] or 0) + 1
          end
          keyCount[v.controlledChildren[i]] = (keyCount[v.controlledChildren[i]] and keyCount[v.controlledChildren[i]] or 0) + 1
          i = i + 1
        end
        for _k,_v in pairs(keyCount) do -- clean up duplicates TODO find the source
          if _v > 1 then
            local j = 1
            while v.controlledChildren[j] do
              if v.controlledChildren[j] == _k then
                tremove(v.controlledChildren, j) -- remove first duplicate
                break
              end
              j = j + 1
            end
          end
        end
        local d = WeakAurasSaved.displays[k]
        if d and d.controlledChildren then
          for _, id in ipairs(d.controlledChildren) do
            if not tcontains(v.controlledChildren, id) then -- insert "extra" children at the bottom, which are not present in incoming wa, but are in current version (user added something inside the group)
              tinsert(v.controlledChildren, id)
            end
          end
        end
      end
    end
    --local aurasToDelete = {}
    for k,v in pairs(sortedWAs) do
      WeakAurasSaved.displays[k] = clearExtras(v)
      --WeakAuras.Add(clearExtras(v), false, true)
      if not UIDsToIDs[v.uid] then -- fill the table incase we want to delete one of these auras (why would we want to do that??)
        UIDsToIDs[v.uid] = v.id
      end
      --[[
      if v.controlledChildren and v.uid ~= "liquid-URlhke5xzn8" and v.liquidData and v.liquidData.tag then -- only check groups, and ignore main group
        for _,childrenID in pairs(v.controlledChildren) do
          local d = sortedWAs[childrenID] or WeakAurasSaved.displays[childrenID]
          if not d then
            print("LiquidWeakAuras:error finding", childrenID)
          elseif d.liquidData and d.liquidData.tag and d.liquidData.tag ~= v.liquidData.tag and checkUID(d.uid) then -- only care about wa's that we have imported through LiquidClient
            local t = {}
            if not aurasToDelete[childrenID] then
              aurasToDelete[childrenID] = true
              fetchAllChildren(d, t, sortedWAs)
              for __k in pairs(t) do
                aurasToDelete[__k] = true
              end
            end
          end
        end
      end
      --]]
    end
    --[[
    local deleteCount = 0
    for k in pairs(aurasToDelete) do
      if WeakAurasSaved.displays[k] then -- this should be useless check, but do it for safety
        deleteCount = deleteCount + 1
        --WeakAuras.Delete(WeakAurasSaved.displays[k])
        C_Timer.After(.5*deleteCount, function()
          if WeakAurasSaved.displays[k] then
            print("LiquidWeakAuras auto deleting:", k)
            if WeakAurasSaved.displays[k].controlledChildren then
              WeakAurasSaved.displays[k].controlledChildren = {}
            end
            if pcall(function() WeakAuras.Delete(WeakAurasSaved.displays[k]) return true end) then
            else
              print("error from:", k)
            end
          else
            print("no longer found:", k)
          end
        end)
      end
    end
    if deleteCount > 0 then
      print(sformat("LiquidWeakAuras: Automatically deleted %s auras.", deleteCount))
    end
    --]]
  end
  local function _delete(d)
    if pcall(function() WeakAuras.Delete(WeakAurasSaved.displays[d]) return true end ) then
    else
      print("Liquid - error deleting specific WA, screenshot this and contact IRONI: ",d )
    end
  end
  function ns:handleSpecificWACleanups() -- this is called before updating auras, mainly used for 11.1 liquid anchor deleting, can be used in the future for something else too
    for _,uid in pairs({
        "liquid-NhHE87l0W2n", -- Liquid Anchors < 11.1
      }) do
        if UIDsToIDs[uid] then
          if WeakAurasSaved.displays[UIDsToIDs[uid]] then -- double checking
            local childrens = {}
            fetchAllChildren(WeakAurasSaved.displays[UIDsToIDs[uid]], childrens)
            for childrenID in pairs(childrens) do
              if WeakAurasSaved.displays[childrenID] then
                print("Deleting children:", childrenID)
                _delete(childrenID)
              end
            end
            if WeakAurasSaved.displays[UIDsToIDs[uid]] then
              print("Deleting main:", UIDsToIDs[uid])
              _delete(UIDsToIDs[uid])
            end
          end
        end
    end
  end
  function ns:handleWeakAuraDeleting()
    -- temp solution
    --[=[
    for k,v in pairs(LiquidWeakAurasAPI:GetDeleteData()) do
      if UIDsToIDs[v] and WeakAurasSaved.displays[UIDsToIDs[v]] then
        WeakAurasSaved.displays[UIDsToIDs[v]].load.use_never = true
        local childrens = {}
        fetchAllChildren(WeakAurasSaved.displays[UIDsToIDs[v]], childrens)
        for _k in pairs(childrens) do
          if WeakAurasSaved.displays[_k] then
            WeakAurasSaved.displays[_k].load.use_never = true
          end
        end
      end
    end
    --]=]
    --incomingDisplay.load.use_never = true
    --
    --if true then return end
    local counter = 0
    local time1 = debugprofilestop()
    local aurasToDelete = LiquidWeakAurasAPI:GetDeleteData()
    for uid,tag in pairs({ -- Add *specific* weakaura imports for cleanup
        ["liquid-E0X8ypWPX4h"] = "fa45eb66-b640-4f30-ae3a-c0f4974ca28e",
      }) do
      if UIDsToIDs[uid] then
        if WeakAurasSaved.displays[UIDsToIDs[uid]] then -- double checking
          if WeakAurasSaved.displays[UIDsToIDs[uid]].liquidData and WeakAurasSaved.displays[UIDsToIDs[uid]].liquidData.tag == tag then
            if not tcontains(aurasToDelete, uid) then
              tinsert(aurasToDelete, uid)
            end
          end
        end
      end
    end
    local auraNames = {}
    for _,uid in pairs(aurasToDelete) do
      if UIDsToIDs[uid] then
        if WeakAurasSaved.displays[UIDsToIDs[uid]] then -- double checking
          table.insert(auraNames, UIDsToIDs[uid])
          local childrens = {}
          fetchAllChildren(WeakAurasSaved.displays[UIDsToIDs[uid]], childrens)
          counter = counter + 1
          for childrenID in pairs(childrens) do
            if WeakAurasSaved.displays[childrenID] then
              counter = counter + 1
              print("Deleting children:", childrenID)
              _delete(childrenID)
            end
          end
          if WeakAurasSaved.displays[UIDsToIDs[uid]] then
            print("Deleting main:", UIDsToIDs[uid])
            _delete(UIDsToIDs[uid])
          end
        end
      end
    end
    if counter > 0 then
      local time2 = debugprofilestop()
      print(sformat("Liquid: Deleted %s auras. Total time spent %dms.\n Main auras that were deleted: %s.", counter, time2-time1, table.concat(auraNames, ", ")))
    end
  end
end
function ns:handleWeakAuraFrontEndOptions()
  local options = ns.cooldowns:GetCustomOptions()
  local i = 0
  for id,data in pairs(WeakAurasSaved.displays) do
    for k,v in pairs(data.authorOptions) do
      if v.key == "LiquidFrontEndCooldownsConfig" then -- update options TODO add to documentation
        data.authorOptions[k] = CopyTable(options)
        --v = CopyTable(options)
        break
      end
    end
  end
end

--Modernize.lua, yoinked from WA, this is just to make my life easier, and in the future can be easily updated by whoever without understanding any of the code above
--Most of this could be removed, but just keep it to make it ctrl+a friendly

-- Takes as input a table of display data and attempts to update it to be compatible with the current version
--- Modernizes the aura data
function fileWideTable.Modernize(data, oldSnapshot)
  if not data.internalVersion or data.internalVersion < 2 then
    WeakAuras.prettyPrint(string.format("Data for '%s' is too old, can't modernize.", data.id))
    data.internalVersion = 2
  end

  -- Version 3 was introduced April 2018 in Legion
  if data.internalVersion < 3 then
    if data.parent then
      local parentData = WeakAuras.GetData(data.parent)
      if parentData and parentData.regionType == "dynamicgroup" then
        -- Version 3 allowed for offsets for dynamic groups, before that they were ignored
        -- Thus reset them in the V2 to V3 upgrade
        data.xOffset = 0
        data.yOffset = 0
      end
    end
  end

  -- Version 4 was introduced July 2018 in BfA
  if data.internalVersion < 4 then
    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        if condition.check then
          local triggernum = condition.check.trigger
          if triggernum then
            local trigger
            if triggernum == 0 then
              trigger = data.trigger
            elseif data.additional_triggers and data.additional_triggers[triggernum] then
              trigger = data.additional_triggers[triggernum].trigger
            end
            if trigger and trigger.event == "Cooldown Progress (Spell)" then
              if condition.check.variable == "stacks" then
                condition.check.variable = "charges"
              end
            end
          end
        end
      end
    end
  end

  -- Version 5 was introduced July 2018 in BfA
  if data.internalVersion < 5 then
    -- this is to fix hybrid sorting
    if data.sortHybridTable then
      if data.controlledChildren then
        local newSortTable = {}
        for index, isHybrid in pairs(data.sortHybridTable) do
          local childID = data.controlledChildren[index]
          if childID then
            newSortTable[childID] = isHybrid
          end
        end
        data.sortHybridTable = newSortTable
      end
    end
  end

  -- Version 6 was introduced July 30 2018 in BfA
  if data.internalVersion < 6 then
    if data.triggers then
      for triggernum, triggerData in ipairs(data.triggers) do
        local trigger = triggerData.trigger
        if trigger and trigger.type == "aura" then
          if trigger.showOn == "showOnMissing" then
            trigger.buffShowOn = "showOnMissing"
          elseif trigger.showOn == "showActiveOrMissing" then
            trigger.buffShowOn = "showAlways"
          else
            trigger.buffShowOn = "showOnActive"
          end
          trigger.showOn = nil
        elseif trigger and trigger.type ~= "aura" then
          trigger.genericShowOn = trigger.showOn or "showOnActive"
          trigger.showOn = nil
          trigger.use_genericShowOn = trigger.use_showOn
        end
      end
    end
  end

  -- Version 7 was introduced September 1 2018 in BfA
  -- Triggers were cleaned up into a 1-indexed array
  if data.internalVersion < 7 then
    -- migrate trigger data
    data.triggers = data.additional_triggers or {}
    tinsert(data.triggers, 1, {
      trigger = data.trigger or {},
      untrigger = data.untrigger or {},
    })
    data.additional_triggers = nil
    data.trigger = nil
    data.untrigger = nil
    data.numTriggers = nil
    data.triggers.customTriggerLogic = data.customTriggerLogic
    data.customTriggerLogic = nil
    local activeTriggerMode = data.activeTriggerMode or Private.trigger_modes.first_active
    if activeTriggerMode ~= Private.trigger_modes.first_active then
      activeTriggerMode = activeTriggerMode + 1
    end
    data.triggers.activeTriggerMode = activeTriggerMode
    data.activeTriggerMode = nil
    data.triggers.disjunctive = data.disjunctive
    data.disjunctive = nil
    -- migrate condition trigger references
    local function recurseRepairChecks(checks)
      if not checks then
        return
      end
      for _, check in pairs(checks) do
        if check.trigger and check.trigger >= 0 then
          check.trigger = check.trigger + 1
        end
        recurseRepairChecks(check.checks)
      end
    end
    for _, condition in pairs(data.conditions) do
      if condition.check.trigger and condition.check.trigger >= 0 then
        condition.check.trigger = condition.check.trigger + 1
      end
      recurseRepairChecks(condition.check.checks)
    end
  end

  -- Version 8 was introduced in September 2018
  -- Changes are in PreAdd

  -- Version 9 was introduced in September 2018
  if data.internalVersion < 9 then
    local function repairCheck(check)
      if check and check.variable == "buffed" then
        local trigger = check.trigger and data.triggers[check.trigger] and data.triggers[check.trigger].trigger
        if trigger then
          if trigger.buffShowOn == "showOnActive" then
            check.variable = "show"
          elseif trigger.buffShowOn == "showOnMissing" then
            check.variable = "show"
            check.value = check.value == 0 and 1 or 0
          end
        end
      end
    end

    local function recurseRepairChecks(checks)
      if not checks then
        return
      end
      for _, check in pairs(checks) do
        repairCheck(check)
        recurseRepairChecks(check.checks)
      end
    end
    for _, condition in pairs(data.conditions) do
      repairCheck(condition.check)
      recurseRepairChecks(condition.check.checks)
    end
  end

  -- Version 10 is skipped, due to a bad migration script (see https://github.com/WeakAuras/WeakAuras2/pull/1091)

  -- Version 11 was introduced in January 2019
  if data.internalVersion < 11 then
    if data.url and data.url ~= "" then
      local slug, version = data.url:match("wago.io/([^/]+)/([0-9]+)")
      if not slug and not version then
        version = 1
      end
      if version and tonumber(version) then
        data.version = tonumber(version)
      end
    end
  end

  -- Version 12 was introduced February 2019 in BfA
  if data.internalVersion < 12 then
    if data.cooldownTextEnabled ~= nil then
      data.cooldownTextDisabled = not data.cooldownTextEnabled
      data.cooldownTextEnabled = nil
    end
  end

  -- Version 13 was introduced March 2019 in BfA
  if data.internalVersion < 13 then
    if data.regionType == "dynamicgroup" then
      local selfPoints = {
        default = "CENTER",
        RIGHT = function(data)
          if data.align == "LEFT" then
            return "TOPLEFT"
          elseif data.align == "RIGHT" then
            return "BOTTOMLEFT"
          else
            return "LEFT"
          end
        end,
        LEFT = function(data)
          if data.align == "LEFT" then
            return "TOPRIGHT"
          elseif data.align == "RIGHT" then
            return "BOTTOMRIGHT"
          else
            return "RIGHT"
          end
        end,
        UP = function(data)
          if data.align == "LEFT" then
            return "BOTTOMLEFT"
          elseif data.align == "RIGHT" then
            return "BOTTOMRIGHT"
          else
            return "BOTTOM"
          end
        end,
        DOWN = function(data)
          if data.align == "LEFT" then
            return "TOPLEFT"
          elseif data.align == "RIGHT" then
            return "TOPRIGHT"
          else
            return "TOP"
          end
        end,
        HORIZONTAL = function(data)
          if data.align == "LEFT" then
            return "TOP"
          elseif data.align == "RIGHT" then
            return "BOTTOM"
          else
            return "CENTER"
          end
        end,
        VERTICAL = function(data)
          if data.align == "LEFT" then
            return "LEFT"
          elseif data.align == "RIGHT" then
            return "RIGHT"
          else
            return "CENTER"
          end
        end,
        CIRCLE = "CENTER",
        COUNTERCIRCLE = "CENTER",
      }
      local selfPoint = selfPoints[data.grow or "DOWN"] or selfPoints.DOWN
      if type(selfPoint) == "function" then
        selfPoint = selfPoint(data)
      end
      data.selfPoint = selfPoint
    end
  end

  -- Version 14 was introduced March 2019 in BfA
  if data.internalVersion < 14 then
    if data.triggers then
      for triggerId, triggerData in pairs(data.triggers) do
        if
          type(triggerData) == "table"
          and triggerData.trigger
          and triggerData.trigger.debuffClass
          and type(triggerData.trigger.debuffClass) == "string"
          and triggerData.trigger.debuffClass ~= ""
        then
          local idx = triggerData.trigger.debuffClass
          data.triggers[triggerId].trigger.debuffClass = { [idx] = true }
        end
      end
    end
  end

  -- Version 15 was introduced April 2019 in BfA
  if data.internalVersion < 15 then
    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        if triggerData.trigger.type == "status" and triggerData.trigger.event == "Spell Known" then
          triggerData.trigger.use_exact_spellName = true
        end
      end
    end
  end

  -- Version 16 was introduced May 2019 in BfA
  if data.internalVersion < 16 then
    -- first conversion: attempt to migrate texture paths to file ids
    if data.regionType == "texture" and type(data.texture) == "string" then
      local textureId = GetFileIDFromPath(data.texture:gsub("\\\\", "\\"))
      if textureId and textureId > 0 then
        data.texture = tostring(textureId)
      end
    end
    if data.regionType == "progresstexture" then
      if type(data.foregroundTexture) == "string" then
        local textureId = GetFileIDFromPath(data.foregroundTexture:gsub("\\\\", "\\"))
        if textureId and textureId > 0 then
          data.foregroundTexture = tostring(textureId)
        end
      end
      if type(data.backgroundTexture) == "string" then
        local textureId = GetFileIDFromPath(data.backgroundTexture:gsub("\\\\", "\\"))
        if textureId and textureId > 0 then
          data.backgroundTexture = tostring(textureId)
        end
      end
    end
    -- second conversion: migrate name/realm conditions to tristate
    if data.load.use_name == false then
      data.load.use_name = nil
    end
    if data.load.use_realm == false then
      data.load.use_realm = nil
    end
  end

  -- Version 18 was a migration for stance/form trigger, but deleted later because of migration issue

  -- Version 19 were introduced in July 2019 in BfA
  if data.internalVersion < 19 then
    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        if triggerData.trigger.type == "status" and triggerData.trigger.event == "Cast" and triggerData.trigger.unit == "multi" then
          triggerData.trigger.unit = "nameplate"
        end
      end
    end
  end

  -- Version 20 was introduced July 2019 in BfA
  if data.internalVersion < 20 then
    if data.regionType == "icon" then
      local convertPoint = function(containment, point)
        if not point or point == "CENTER" then
          return "CENTER"
        elseif containment == "INSIDE" then
          return "INNER_" .. point
        elseif containment == "OUTSIDE" then
          return "OUTER_" .. point
        end
      end

      local text1 = {
        ["type"] = "subtext",
        text_visible = data.text1Enabled ~= false,
        text_color = data.text1Color,
        text_text = data.text1,
        text_font = data.text1Font,
        text_fontSize = data.text1FontSize,
        text_fontType = data.text1FontFlags,
        text_selfPoint = "AUTO",
        text_anchorPoint = convertPoint(data.text1Containment, data.text1Point),
        anchorXOffset = 0,
        anchorYOffset = 0,
        text_shadowColor = { 0, 0, 0, 1 },
        text_shadowXOffset = 0,
        text_shadowYOffset = 0,
      }

      local usetext2 = data.text2Enabled

      local text2 = {
        ["type"] = "subtext",
        text_visible = data.text2Enabled or false,
        text_color = data.text2Color,
        text_text = data.text2,
        text_font = data.text2Font,
        text_fontSize = data.text2FontSize,
        text_fontType = data.text2FontFlags,
        text_selfPoint = "AUTO",
        text_anchorPoint = convertPoint(data.text2Containment, data.text2Point),
        anchorXOffset = 0,
        anchorYOffset = 0,
        text_shadowColor = { 0, 0, 0, 1 },
        text_shadowXOffset = 0,
        text_shadowYOffset = 0,
      }

      data.text1Enabled = nil
      data.text1Color = nil
      data.text1 = nil
      data.text1Font = nil
      data.text1FontSize = nil
      data.text1FontFlags = nil
      data.text1Containment = nil
      data.text1Point = nil

      data.text2Enabled = nil
      data.text2Color = nil
      data.text2 = nil
      data.text2Font = nil
      data.text2FontSize = nil
      data.text2FontFlags = nil
      data.text2Containment = nil
      data.text2Point = nil

      local propertyRenames = {
        text1Color = "sub.1.text_color",
        text1FontSize = "sub.1.text_fontSize",
        text2Color = "sub.2.text_color",
        text2FontSize = "sub.2.text_fontSize",
      }

      data.subRegions = data.subRegions or {}
      tinsert(data.subRegions, text1)
      if usetext2 then
        tinsert(data.subRegions, text2)
      end

      if data.conditions then
        for conditionIndex, condition in ipairs(data.conditions) do
          for changeIndex, change in ipairs(condition.changes) do
            if propertyRenames[change.property] then
              change.property = propertyRenames[change.property]
            end
          end
        end
      end
    end
  end

  -- Version 20 was introduced May 2019 in BfA
  if data.internalVersion < 20 then
    if data.regionType == "aurabar" then
      local orientationToPostion = {
        HORIZONTAL_INVERSE = { "INNER_LEFT", "INNER_RIGHT" },
        HORIZONTAL = { "INNER_RIGHT", "INNER_LEFT" },
        VERTICAL_INVERSE = { "INNER_BOTTOM", "INNER_TOP" },
        VERTICAL = { "INNER_TOP", "INNER_BOTTOM" },
      }

      local positions = orientationToPostion[data.orientation] or { "INNER_LEFT", "INNER_RIGHT" }

      local text1 = {
        ["type"] = "subtext",
        text_visible = data.timer,
        text_color = data.timerColor,
        text_text = data.displayTextRight,
        text_font = data.timerFont,
        text_fontSize = data.timerSize,
        text_fontType = data.timerFlags,
        text_selfPoint = "AUTO",
        text_anchorPoint = positions[1],
        anchorXOffset = 0,
        anchorYOffset = 0,
        text_shadowColor = { 0, 0, 0, 1 },
        text_shadowXOffset = 1,
        text_shadowYOffset = -1,
        rotateText = data.rotateText,
      }

      local text2 = {
        ["type"] = "subtext",
        text_visible = data.text,
        text_color = data.textColor,
        text_text = data.displayTextLeft,
        text_font = data.textFont,
        text_fontSize = data.textSize,
        text_fontType = data.textFlags,
        text_selfPoint = "AUTO",
        text_anchorPoint = positions[2],
        anchorXOffset = 0,
        anchorYOffset = 0,
        text_shadowColor = { 0, 0, 0, 1 },
        text_shadowXOffset = 1,
        text_shadowYOffset = -1,
        rotateText = data.rotateText,
      }

      local text3 = {
        ["type"] = "subtext",
        text_visible = data.stacks,
        text_color = data.stacksColor,
        text_text = "%s",
        text_font = data.stacksFont,
        text_fontSize = data.stacksSize,
        text_fontType = data.stacksFlags,
        text_selfPoint = "AUTO",
        text_anchorPoint = "ICON_CENTER",
        anchorXOffset = 0,
        anchorYOffset = 0,
        text_shadowColor = { 0, 0, 0, 1 },
        text_shadowXOffset = 1,
        text_shadowYOffset = -1,
        rotateText = data.rotateText,
      }

      data.timer = nil
      data.textColor = nil
      data.displayTextRight = nil
      data.textFont = nil
      data.textSize = nil
      data.textFlags = nil
      data.text = nil
      data.timerColor = nil
      data.displayTextLeft = nil
      data.timerFont = nil
      data.timerSize = nil
      data.timerFlags = nil
      data.stacks = nil
      data.stacksColor = nil
      data.stacksFont = nil
      data.stacksSize = nil
      data.stacksFlags = nil
      data.rotateText = nil

      local propertyRenames = {
        timerColor = "sub.1.text_color",
        timerSize = "sub.1.text_fontSize",
        textColor = "sub.2.text_color",
        textSize = "sub.2.text_fontSize",
        stacksColor = "sub.3.text_color",
        stacksSize = "sub.3.text_fontSize",
      }

      data.subRegions = data.subRegions or {}
      tinsert(data.subRegions, text1)
      tinsert(data.subRegions, text2)
      tinsert(data.subRegions, text3)

      if data.conditions then
        for conditionIndex, condition in ipairs(data.conditions) do
          for changeIndex, change in ipairs(condition.changes) do
            if propertyRenames[change.property] then
              change.property = propertyRenames[change.property]
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 21 then
    if data.regionType == "dynamicgroup" then
      data.border = data.background and data.background ~= "None"
      data.borderEdge = data.border
      data.borderBackdrop = data.background ~= "None" and data.background
      data.borderInset = data.backgroundInset
      data.background = nil
      data.backgroundInset = nil
    end
  end

  if data.internalVersion < 22 then
    if data.regionType == "aurabar" then
      data.subRegions = data.subRegions or {}

      local border = {
        ["type"] = "subborder",
        border_visible = data.border,
        border_color = data.borderColor,
        border_edge = data.borderEdge,
        border_offset = data.borderOffset,
        border_size = data.borderSize,
        border_anchor = "bar",
      }

      data.border = nil
      data.borderColor = nil
      data.borderEdge = nil
      data.borderOffset = nil
      data.borderInset = nil
      data.borderSize = nil
      if data.borderInFront then
        tinsert(data.subRegions, border)
      else
        tinsert(data.subRegions, 1, border)
      end

      local propertyRenames = {
        borderColor = "sub." .. #data.subRegions .. ".border_color",
      }

      if data.conditions then
        for conditionIndex, condition in ipairs(data.conditions) do
          for changeIndex, change in ipairs(condition.changes) do
            if propertyRenames[change.property] then
              change.property = propertyRenames[change.property]
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 23 then
    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        local trigger = triggerData.trigger
        -- Stance/Form/Aura form field type changed from type="select" to type="multiselect"
        if trigger and trigger.type == "status" and trigger.event == "Stance/Form/Aura" then
          local value = trigger.form
          if type(value) ~= "table" then
            if trigger.use_form == false then
              if value then
                trigger.form = { multi = { [value] = true } }
              else
                trigger.form = { multi = {} }
              end
            elseif trigger.use_form then
              trigger.form = { single = value }
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 24 then
    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        local trigger = triggerData.trigger
        if trigger and trigger.type == "status" and trigger.event == "Weapon Enchant" then
          if trigger.use_inverse then
            trigger.showOn = "showOnMissing"
          else
            trigger.showOn = "showOnActive"
          end
          trigger.use_inverse = nil
          if not trigger.use_weapon then
            trigger.use_weapon = "true"
            trigger.weapon = "main"
          end
        end
      end
    end
  end

  if data.internalVersion < 25 then
    if data.regionType == "icon" then
      data.subRegions = data.subRegions or {}
      -- Need to check if glow is needed

      local prefix = "sub." .. #data.subRegions + 1 .. "."
      -- For Conditions
      local propertyRenames = {
        glow = prefix .. "glow",
        useGlowColor = prefix .. "useGlowColor",
        glowColor = prefix .. "glowColor",
        glowType = prefix .. "glowType",
        glowLines = prefix .. "glowLines",
        glowFrequency = prefix .. "glowFrequency",
        glowLength = prefix .. "glowLength",
        glowThickness = prefix .. "glowThickness",
        glowScale = prefix .. "glowScale",
        glowBorder = prefix .. "glowBorder",
        glowXOffset = prefix .. "glowXOffset",
        glowYOffset = prefix .. "glowYOffset",
      }

      local needsGlow = data.glow
      if not needsGlow and data.conditions then
        for conditionIndex, condition in ipairs(data.conditions) do
          for changeIndex, change in ipairs(condition.changes) do
            if propertyRenames[change.property] then
              needsGlow = true
              break
            end
          end
        end
      end

      if needsGlow then
        local glow = {
          ["type"] = "subglow",
          glow = data.glow,
          useGlowColor = data.useGlowColor,
          glowColor = data.glowColor,
          glowType = data.glowType,
          glowLines = data.glowLines,
          glowFrequency = data.glowFrequency,
          glowLength = data.glowLength,
          glowThickness = data.glowThickness,
          glowScale = data.glowScale,
          glowBorder = data.glowBorder,
          glowXOffset = data.glowXOffset,
          glowYOffset = data.glowYOffset,
        }
        tinsert(data.subRegions, glow)
      end

      data.glow = nil
      data.useglowColor = nil
      data.useGlowColor = nil
      data.glowColor = nil
      data.glowType = nil
      data.glowLines = nil
      data.glowFrequency = nil
      data.glowLength = nil
      data.glowThickness = nil
      data.glowScale = nil
      data.glowBorder = nil
      data.glowXOffset = nil
      data.glowYOffset = nil

      if data.conditions then
        for conditionIndex, condition in ipairs(data.conditions) do
          for changeIndex, change in ipairs(condition.changes) do
            if propertyRenames[change.property] then
              change.property = propertyRenames[change.property]
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 26 then
    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if change.property == "xOffset" or change.property == "yOffset" then
            change.value = (change.value or 0) - (data[change.property] or 0)
            change.property = change.property .. "Relative"
          end
        end
      end
    end
  end

  if data.internalVersion < 28 then
    if data.actions then
      if data.actions.start and data.actions.start.do_glow then
        data.actions.start.glow_frame_type = "FRAMESELECTOR"
      end
      if data.actions.finish and data.actions.finish.do_glow then
        data.actions.finish.glow_frame_type = "FRAMESELECTOR"
      end
    end
  end

  if data.internalVersion < 29 then
    if data.actions then
      if data.actions.start and data.actions.start.do_glow and data.actions.start.glow_type == nil then
        data.actions.start.glow_type = "buttonOverlay"
      end
      if data.actions.finish and data.actions.finish.do_glow and data.actions.finish.glow_type == nil then
        data.actions.finish.glow_type = "buttonOverlay"
      end
    end
  end

  if data.internalVersion < 30 then
    local convertLegacyPrecision = function(precision)
      if not precision then
        return 1
      end
      if precision < 4 then
        return precision, false
      else
        return precision - 3, true
      end
    end

    local progressPrecision = data.progressPrecision
    local totalPrecision = data.totalPrecision
    if data.regionType == "text" then
      local seenSymbols = {}
      Private.ParseTextStr(data.displayText, function(symbol)
        if not seenSymbols[symbol] then
          local triggerNum, sym = string.match(symbol, "(.+)%.(.+)")
          sym = sym or symbol
          if sym == "p" or sym == "t" then
            data["displayText_format_" .. symbol .. "_format"] = "timed"
            data["displayText_format_" .. symbol .. "_time_precision"], data["displayText_format_" .. symbol .. "_time_dynamic"] =
              convertLegacyPrecision(sym == "p" and progressPrecision or totalPrecision)
          end
        end
        seenSymbols[symbol] = symbol
      end)
    end

    if data.subRegions then
      for index, subRegionData in ipairs(data.subRegions) do
        if subRegionData.type == "subtext" then
          local seenSymbols = {}
          Private.ParseTextStr(subRegionData.text_text, function(symbol)
            if not seenSymbols[symbol] then
              local triggerNum, sym = string.match(symbol, "(.+)%.(.+)")
              sym = sym or symbol
              if sym == "p" or sym == "t" then
                subRegionData["text_text_format_" .. symbol .. "_format"] = "timed"
                subRegionData["text_text_format_" .. symbol .. "_time_precision"], subRegionData["text_text_format_" .. symbol .. "_time_dynamic"] =
                  convertLegacyPrecision(sym == "p" and progressPrecision or totalPrecision)
              end
            end
            seenSymbols[symbol] = symbol
          end)
        end
      end
    end

    if data.actions then
      for _, when in ipairs({ "start", "finish" }) do
        if data.actions[when] then
          local seenSymbols = {}
          Private.ParseTextStr(data.actions[when].message, function(symbol)
            if not seenSymbols[symbol] then
              local triggerNum, sym = string.match(symbol, "(.+)%.(.+)")
              sym = sym or symbol
              if sym == "p" or sym == "t" then
                data.actions[when]["message_format_" .. symbol .. "_format"] = "timed"
                data.actions[when]["message_format_" .. symbol .. "_time_precision"], data.actions[when]["message_format_" .. symbol .. "_time_dynamic"] =
                  convertLegacyPrecision(sym == "p" and progressPrecision or totalPrecision)
              end
            end
            seenSymbols[symbol] = symbol
          end)
        end
      end
    end

    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if change.property == "chat" and change.value then
            local seenSymbols = {}
            Private.ParseTextStr(change.value.message, function(symbol)
              if not seenSymbols[symbol] then
                local triggerNum, sym = string.match(symbol, "(.+)%.(.+)")
                sym = sym or symbol
                if sym == "p" or sym == "t" then
                  change.value["message_format_" .. symbol .. "_format"] = "timed"
                  change.value["message_format_" .. symbol .. "_time_precision"], change.value["message_format_" .. symbol .. "_time_dynamic"] =
                    convertLegacyPrecision(sym == "p" and progressPrecision or totalPrecision)
                end
              end
              seenSymbols[symbol] = symbol
            end)
          end
        end
      end
    end

    data.progressPrecision = nil
    data.totalPrecision = nil
  end

  -- Introduced in June 2020 in BfA
  if data.internalVersion < 31 then
    local allowedNames
    local ignoredNames
    if data.load.use_name == true and data.load.name then
      allowedNames = data.load.name
    elseif data.load.use_name == false and data.load.name then
      ignoredNames = data.load.name
    end

    if data.load.use_realm == true and data.load.realm then
      allowedNames = (allowedNames or "") .. "-" .. data.load.realm
    elseif data.load.use_realm == false and data.load.realm then
      ignoredNames = (ignoredNames or "") .. "-" .. data.load.realm
    end

    if allowedNames then
      data.load.use_namerealm = true
      data.load.namerealm = allowedNames
    end

    if ignoredNames then
      data.load.use_namerealmblack = true
      data.load.namerealmblack = ignoredNames
    end

    data.load.use_name = nil
    data.load.name = nil
    data.load.use_realm = nil
    data.load.realm = nil
  end

  -- Introduced in June 2020 in BfA
  if data.internalVersion < 32 then
    local replacements = {}
    local function repairCheck(replacements, check)
      if check and check.trigger then
        if replacements[check.trigger] then
          if replacements[check.trigger][check.variable] then
            check.variable = replacements[check.trigger][check.variable]
          end
        end
      end
    end

    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        if triggerData.trigger.type == "status" then
          local event = triggerData.trigger.event
          if event == "Unit Characteristics" or event == "Health" or event == "Power" then
            replacements[triggerId] = {}
            replacements[triggerId]["use_name"] = "use_namerealm"
            replacements[triggerId]["name"] = "namerealm"
          elseif event == "Alternate Power" then
            replacements[triggerId] = {}
            replacements[triggerId]["use_unitname"] = "use_namerealm"
            replacements[triggerId]["unitname"] = "namerealm"
          elseif event == "Cast" then
            replacements[triggerId] = {}
            replacements[triggerId]["use_sourceName"] = "use_sourceNameRealm"
            replacements[triggerId]["sourceName"] = "sourceNameRealm"
            replacements[triggerId]["use_destName"] = "use_destNameRealm"
            replacements[triggerId]["destName"] = "destNameRealm"
          end

          if replacements[triggerId] then
            for old, new in pairs(replacements[triggerId]) do
              triggerData.trigger[new] = triggerData.trigger[old]
              triggerData.trigger[old] = nil
            end

            local function recurseRepairChecks(replacements, checks)
              if not checks then
                return
              end
              for _, check in pairs(checks) do
                repairCheck(replacements, check)
                recurseRepairChecks(replacements, check.checks)
              end
            end
            for _, condition in pairs(data.conditions) do
              repairCheck(replacements, condition.check)
              recurseRepairChecks(replacements, condition.check.checks)
            end
          end
        end
      end
    end
  end

  -- Introduced in July 2020 in BfA
  if data.internalVersion < 33 then
    data.load.use_ignoreNameRealm = data.load.use_namerealmblack
    data.load.ignoreNameRealm = data.load.namerealmblack
    data.load.use_namerealmblack = nil
    data.load.namerealmblack = nil

    -- trigger.useBlackExactSpellId and trigger.blackauraspellids
    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        triggerData.trigger.useIgnoreName = triggerData.trigger.useBlackName
        triggerData.trigger.ignoreAuraNames = triggerData.trigger.blackauranames
        triggerData.trigger.useIgnoreExactSpellId = triggerData.trigger.useBlackExactSpellId
        triggerData.trigger.ignoreAuraSpellids = triggerData.trigger.blackauraspellids

        triggerData.trigger.useBlackName = nil
        triggerData.trigger.blackauranames = nil
        triggerData.trigger.useBlackExactSpellId = nil
        triggerData.trigger.blackauraspellids = nil
      end
    end
  end

  -- Introduced in July 2020 in Shadowlands
  if data.internalVersion < 34 then
    if data.regionType == "dynamicgroup" and (data.grow == "CIRCLE" or data.grow == "COUNTERCIRCLE") then
      if data.arcLength == 360 then
        data.fullCircle = true
      else
        data.fullCircle = false
      end
    end
  end

  if data.internalVersion < 35 then
    if data.regionType == "texture" then
      data.textureWrapMode = "CLAMP"
    end
  end

  if data.internalVersion < 36 then
    data.ignoreOptionsEventErrors = true
  end

  if data.internalVersion < 37 then
    for triggerId, triggerData in ipairs(data.triggers) do
      if triggerData.trigger.type == "aura2" then
        local group_role = triggerData.trigger.group_role
        if group_role then
          triggerData.trigger.group_role = {}
          triggerData.trigger.group_role[group_role] = true
        end
      end
    end
  end

  if data.internalVersion < 38 then
    for triggerId, triggerData in ipairs(data.triggers) do
      if triggerData.trigger.type == "status" then
        if triggerData.trigger.event == "Item Type Equipped" then
          if triggerData.trigger.itemTypeName then
            if triggerData.trigger.itemTypeName.single then
              triggerData.trigger.itemTypeName.single = triggerData.trigger.itemTypeName.single + 2 * 256
            end
            if triggerData.trigger.itemTypeName.multi then
              local converted = {}
              for v in pairs(triggerData.trigger.itemTypeName.multi) do
                converted[v + 512] = true
              end
              triggerData.trigger.itemTypeName.multi = converted
            end
          end
        end
      end
    end
    if data.load.itemtypeequipped then
      if data.load.itemtypeequipped.single then
        data.load.itemtypeequipped.single = data.load.itemtypeequipped.single + 2 * 256
      end
      if data.load.itemtypeequipped.multi then
        local converted = {}
        for v in pairs(data.load.itemtypeequipped.multi) do
          converted[v + 512] = true
        end
        data.load.itemtypeequipped.multi = converted
      end
    end
  end

  if data.internalVersion < 39 then
    if data.regionType == "icon" or data.regionType == "aurabar" then
      if data.auto then
        data.iconSource = -1
      else
        data.iconSource = 0
      end
    end
  end

  if data.internalVersion < 40 then
    data.information = data.information or {}
    if data.regionType == "group" then
      data.information.groupOffset = true
    end
    data.information.ignoreOptionsEventErrors = data.ignoreOptionsEventErrors
    data.ignoreOptionsEventErrors = nil
  end

  if data.internalVersion < 41 then
    local newTypes = {
      ["Cooldown Ready (Spell)"] = "spell",
      ["Queued Action"] = "spell",
      ["Charges Changed"] = "spell",
      ["Action Usable"] = "spell",
      ["Chat Message"] = "event",
      ["Unit Characteristics"] = "unit",
      ["Cooldown Progress (Spell)"] = "spell",
      ["Power"] = "unit",
      ["PvP Talent Selected"] = "unit",
      ["Combat Log"] = "combatlog",
      ["Item Set"] = "item",
      ["Health"] = "unit",
      ["Cooldown Progress (Item)"] = "item",
      ["Conditions"] = "unit",
      ["Spell Known"] = "spell",
      ["Cooldown Ready (Item)"] = "item",
      ["Faction Reputation"] = "unit",
      ["Pet Behavior"] = "unit",
      ["Range Check"] = "unit",
      ["Character Stats"] = "unit",
      ["Talent Known"] = "unit",
      ["Threat Situation"] = "unit",
      ["Equipment Set"] = "item",
      ["Death Knight Rune"] = "unit",
      ["Cast"] = "unit",
      ["Item Count"] = "item",
      ["BigWigs Timer"] = "addons",
      ["Spell Activation Overlay"] = "spell",
      ["DBM Timer"] = "addons",
      ["Item Type Equipped"] = "item",
      ["Alternate Power"] = "unit",
      ["Item Equipped"] = "item",
      ["Item Bonus Id Equipped"] = "item",
      ["DBM Announce"] = "addons",
      ["Swing Timer"] = "unit",
      ["Totem"] = "spell",
      ["Ready Check"] = "event",
      ["BigWigs Message"] = "addons",
      ["Class/Spec"] = "unit",
      ["Stance/Form/Aura"] = "unit",
      ["Weapon Enchant"] = "item",
      ["Global Cooldown"] = "spell",
      ["Experience"] = "unit",
      ["GTFO"] = "addons",
      ["Cooldown Ready (Equipment Slot)"] = "item",
      ["Crowd Controlled"] = "unit",
      ["Cooldown Progress (Equipment Slot)"] = "item",
      ["Combat Events"] = "event",
    }

    for triggerId, triggerData in ipairs(data.triggers) do
      if triggerData.trigger.type == "status" or triggerData.trigger.type == "event" then
        local newType = newTypes[triggerData.trigger.event]
        if newType then
          triggerData.trigger.type = newType
        else
          WeakAuras.prettyPrint("Unknown trigger type found in, please report: ", data.id, triggerData.trigger.event)
        end
      end
    end
  end

  if data.internalVersion < 43 then
    -- The merging of zone ids and group ids went a bit wrong,
    -- fortunately that was caught before a actual release
    -- still try to recover the data
    if data.internalVersion == 42 then
      if data.load.zoneIds then
        local newstring = ""
        local first = true
        for id in data.load.zoneIds:gmatch("%d+") do
          if not first then
            newstring = newstring .. ", "
          end

          -- If the id is potentially a group, assume it is a group
          if C_Map.GetMapGroupMembersInfo(tonumber(id)) then
            newstring = newstring .. "g" .. id
          else
            newstring = newstring .. id
          end
          first = false
        end
        data.load.zoneIds = newstring
      end
    else
      if data.load.use_zoneId == data.load.use_zonegroupId then
        data.load.use_zoneIds = data.load.use_zoneId

        local zoneIds = strtrim(data.load.zoneId or "")
        local zoneGroupIds = strtrim(data.load.zonegroupId or "")

        zoneGroupIds = zoneGroupIds:gsub("(%d+)", "g%1")

        if zoneIds ~= "" or zoneGroupIds ~= "" then
          data.load.zoneIds = zoneIds .. ", " .. zoneGroupIds
        else
          -- One of them is empty
          data.load.zoneIds = zoneIds .. zoneGroupIds
        end
      elseif data.load.use_zoneId then
        data.load.use_zoneIds = true
        data.load.zoneIds = data.load.zoneId
      elseif data.load.use_zonegroupId then
        data.load.use_zoneIds = true
        local zoneGroupIds = strtrim(data.load.zonegroupId or "")
        zoneGroupIds = zoneGroupIds:gsub("(%d+)", "g%1")
        data.load.zoneIds = zoneGroupIds
      end
      data.load.use_zoneId = nil
      data.load.use_zonegroupId = nil
      data.load.zoneId = nil
      data.load.zonegroupId = nil
    end
  end

  if data.internalVersion < 44 then
    local function fixUp(data, prefix)
      local pattern = prefix .. "(.*)_format"

      local found = false
      for property in pairs(data) do
        local symbol = property:match(pattern)
        if symbol then
          found = true
          break
        end
      end

      if not found then
        return
      end

      local old = CopyTable(data)
      for property in pairs(old) do
        local symbol = property:match(pattern)
        if symbol then
          if data[property] == "timed" then
            data[prefix .. symbol .. "_time_format"] = 0

            local oldDynamic = data[prefix .. symbol .. "_time_dynamic"]
            data[prefix .. symbol .. "_time_dynamic_threshold"] = oldDynamic and 3 or 60
          end
          data[prefix .. symbol .. "_time_dynamic"] = nil
          if data[prefix .. symbol .. "_time_precision"] == 0 then
            data[prefix .. symbol .. "_time_precision"] = 1
            data[prefix .. symbol .. "_time_dynamic_threshold"] = 0
          end
        end
      end
    end

    if data.regionType == "text" then
      fixUp(data, "displayText_format_")
    end

    if data.subRegions then
      for index, subRegionData in ipairs(data.subRegions) do
        if subRegionData.type == "subtext" then
          fixUp(subRegionData, "text_text_format_")
        end
      end
    end

    if data.actions then
      for _, when in ipairs({ "start", "finish" }) do
        if data.actions[when] then
          fixUp(data.actions[when], "message_format_")
        end
      end
    end

    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if change.property == "chat" and change.value then
            fixUp(change.value, "message_format_")
          end
        end
      end
    end
  end

  if data.internalVersion < 45 then
    for triggerId, triggerData in ipairs(data.triggers) do
      local trigger = triggerData.trigger
      if trigger.type == "unit" and trigger.event == "Conditions" then
        if trigger.use_instance_size then
          -- Single Selection
          if trigger.instance_size.single then
            if trigger.instance_size.single == "arena" then
              trigger.use_instance_size = false
              trigger.instance_size.multi = {
                arena = true,
                ratedarena = true,
              }
            elseif trigger.instance_size.single == "pvp" then
              trigger.use_instance_size = false
              trigger.instance_size.multi = {
                pvp = true,
                ratedpvp = true,
              }
            end
          end
        elseif trigger.use_instance_size == false then
          -- Multi selection
          if trigger.instance_size.multi then
            if trigger.instance_size.multi.arena then
              trigger.instance_size.multi.ratedarena = true
            end
            if trigger.instance_size.multi.pvp then
              trigger.instance_size.multi.ratedpvp = true
            end
          end
        end
      end
    end

    if data.load.use_size == true then
      if data.load.size.single == "arena" then
        data.load.use_size = false
        data.load.size.multi = {
          arena = true,
          ratedarena = true,
        }
      elseif data.load.size.single == "pvp" then
        data.load.use_size = false
        data.load.size.multi = {
          pvp = true,
          ratedpvp = true,
        }
      end
    elseif data.load.use_size == false then
      if data.load.size.multi then
        if data.load.size.multi.arena then
          data.load.size.multi.ratedarena = true
        end
        if data.load.size.multi.pvp then
          data.load.size.multi.ratedpvp = true
        end
      end
    end
  end

  if data.internalVersion < 46 then
    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        if condition.check then
          local triggernum = condition.check.trigger
          if triggernum then
            local trigger = data.triggers[triggernum]
            if trigger and trigger.trigger and trigger.trigger.event == "Power" then
              if condition.check.variable == "chargedComboPoint" then
                condition.check.variable = "chargedComboPoint1"
              end
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 49 then
    if not data.regionType:match("group") then
      data.subRegions = data.subRegions or {}
      -- rename aurabar_bar into subforeground, and subbarmodel into submodel
      for index, subRegionData in ipairs(data.subRegions) do
        if subRegionData.type == "aurabar_bar" then
          subRegionData.type = "subforeground"
        elseif subRegionData.type == "subbarmodel" then
          subRegionData.type = "submodel"
        end
        if subRegionData.bar_model_visible ~= nil then
          subRegionData.model_visible = subRegionData.bar_model_visible
          subRegionData.bar_model_visible = nil
        end
        if subRegionData.bar_model_alpha ~= nil then
          subRegionData.model_alpha = subRegionData.bar_model_alpha
          subRegionData.bar_model_alpha = nil
        end
      end
      -- rename conditions for bar_model_visible and bar_model_alpha
      if data.conditions then
        for conditionIndex, condition in ipairs(data.conditions) do
          if type(condition.changes) == "table" then
            for changeIndex, change in ipairs(condition.changes) do
              if change.property then
                local prefix, property = change.property:match("(sub%.%d+%.)(.*)")
                if prefix and property then
                  if property == "bar_model_visible" then
                    change.property = prefix .. "model_visible"
                  elseif property == "bar_model_alpha" then
                    change.property = prefix .. "model_alpha"
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  if data.internalVersion == 49 then
    -- Version 49 was a dud and contained a broken validation. Try to salvage the data, as
    -- best as we can.
    local broken = false
    local properties = {}
    Private.GetSubRegionProperties(data, properties)
    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        if type(condition.changes) == "table" then
          for changeIndex, change in ipairs(condition.changes) do
            if change.property then
              if not properties[change.property] then
                -- The property does not exist, so maybe it's one that was accidentally not moved
                local subRegionIndex, property = change.property:match("^sub%.(%d+)%.(.*)")
                if subRegionIndex and property then
                  broken = true
                  for _, offset in ipairs({ -1, 1 }) do
                    local newProperty = "sub." .. subRegionIndex + offset .. "." .. property
                    if properties[newProperty] then
                      change.property = newProperty
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if broken then
      WeakAuras.prettyPrint(L["Trying to repair broken conditions in %s likely caused by a WeakAuras bug."]:format(data.id))
    end
  end

  if data.internalVersion < 51 then
    for triggerId, triggerData in ipairs(data.triggers) do
      if triggerData.trigger.event == "Threat Situation" then
        triggerData.trigger.unit = triggerData.trigger.threatUnit
        triggerData.trigger.use_unit = triggerData.trigger.use_threatUnit
        triggerData.trigger.threatUnit = nil
        triggerData.trigger.use_threatUnit = nil
      end
    end
  end

  if data.internalVersion < 52 then
    local function matchTarget(input)
      return input == "target" or input == "'target'" or input == '"target"' or input == "%t" or input == "'%t'" or input == '"%t"'
    end

    if data.conditions then
      for _, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if change.property == "chat" and change.value then
            if matchTarget(change.value.message_dest) then
              change.value.message_dest = "target"
              change.value.message_dest_isunit = true
            end
          end
        end
      end
    end

    if data.actions.start.do_message and data.actions.start.message_type == "WHISPER" and matchTarget(data.actions.start.message_dest) then
      data.actions.start.message_dest = "target"
      data.actions.start.message_dest_isunit = true
    end

    if data.actions.finish.do_message and data.actions.finish.message_type == "WHISPER" and matchTarget(data.actions.finish.message_dest) then
      data.actions.finish.message_dest = "target"
      data.actions.finish.message_dest_isunit = true
    end
  end

  if data.internalVersion < 53 then
    local function ReplaceIn(text, table, prefix)
      local seenSymbols = {}
      Private.ParseTextStr(text, function(symbol)
        if not seenSymbols[symbol] then
          if table[prefix .. symbol .. "_format"] == "timed" and table[prefix .. symbol .. "_time_format"] == 0 then
            table[prefix .. symbol .. "_time_legacy_floor"] = true
          end
        end
        seenSymbols[symbol] = symbol
      end)
    end

    if data.regionType == "text" then
      ReplaceIn(data.displayText, data, "displayText_format_")
    end

    if data.subRegions then
      for index, subRegionData in ipairs(data.subRegions) do
        if subRegionData.type == "subtext" then
          ReplaceIn(subRegionData.text_text, subRegionData, "text_text_format_")
        end
      end
    end

    if data.actions then
      if data.actions.start then
        ReplaceIn(data.actions.start.message, data.actions.start, "message_format_")
      end
      if data.actions.finish then
        ReplaceIn(data.actions.finish.message, data.actions.finish, "message_format_")
      end
    end

    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if change.property == "chat" and change.value then
            ReplaceIn(change.value.message, change.value, "message_format_")
          end
        end
      end
    end
  end

  if data.internalVersion < 54 then
    for triggerId, triggerData in ipairs(data.triggers) do
      if triggerData.trigger.type == "aura" then
        triggerData.trigger.type = "unit"
        triggerData.trigger.event = "Conditions"
        triggerData.trigger.use_alwaystrue = false
      end
    end
  end

  if data.internalVersion < 55 then
    data.forceEvents = true
  end

  -- Internal version 55 contained a incorrect Modernize
  if data.internalVersion < 56 then
    data.information.forceEvents = data.forceEvents
    data.forceEvents = nil
  end

  if data.internalVersion < 57 then
    if WeakAuras.IsRetail() then
      local function GetField(load, field)
        local data = {}
        if load["use_" .. field] == true then
          if load[field].single then
            table.insert(data, load[field].single)
          end
        elseif load["use_" .. field] == false then
          for d in pairs(load[field].multi) do
            table.insert(data, d)
          end
        end
        return data
      end
      local function GetClassId(classFile)
        for classID = 1, GetNumClasses() do
          local _, thisClassFile = GetClassInfo(classID)
          if classFile == thisClassFile then
            return classID
          end
        end
      end
      local function SetSpec(load, specID)
        if load.use_class_and_spec == true then
          load.use_class_and_spec = false -- multi
        elseif load.use_class_and_spec == nil then
          load.use_class_and_spec = true -- single
        end
        load.class_and_spec = load.class_and_spec or {}
        load.class_and_spec.single = specID
        load.class_and_spec.multi = load.class_and_spec.multi or {}
        load.class_and_spec.multi[specID] = true
      end
      local load = data.load
      if load.use_class_and_spec == nil then
        local classes = GetField(load, "class")
        local specs = GetField(load, "spec")
        for i, class in ipairs(classes) do
          local classID = GetClassId(class)
          if #specs == 0 then -- add all specs
            for specIndex = 1, 4 do
              local specID = GetSpecializationInfoForClassID(classID, specIndex)
              if specID then
                SetSpec(load, specID)
              end
            end
          else
            for j, specIndex in ipairs(specs) do
              local specID = GetSpecializationInfoForClassID(classID, specIndex)
              if specID then
                SetSpec(load, specID)
              end
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 58 then
    -- convert key use for talent load condition from talent's index to spellId
    if WeakAuras.IsRetail() then
      local function migrateTalent(load, specId, field)
        if load[field] and load[field].multi then
          local newData = {}
          for key, value in pairs(load[field].multi) do
            if value ~= nil then
              local talentData = Private.GetTalentData(specId)
              if type(talentData) == "table" and talentData[key] then
                newData[talentData[key][2]] = value
              end
            end
          end
          load[field].multi = newData
        end
      end
      local load = data.load
      local specId = Private.checkForSingleLoadCondition(load, "class_and_spec")
      if specId then
        migrateTalent(load, specId, "talent")
        migrateTalent(load, specId, "talent2")
        migrateTalent(load, specId, "talent3")
      end
    end
  end

  if data.internalVersion < 59 then
    -- convert key use for talent known trigger from talent's index to spellId
    if WeakAuras.IsRetail() then
      local function migrateTalent(load, specId, field)
        if load[field] and load[field].multi then
          local newData = {}
          for key, value in pairs(load[field].multi) do
            if value ~= nil then
              local talentData = Private.GetTalentData(specId)
              if type(talentData) == "table" and talentData[key] then
                newData[talentData[key][2]] = value
              end
            end
          end
          load[field].multi = newData
        end
      end
      for triggerId, triggerData in ipairs(data.triggers) do
        if triggerData.trigger.type == "unit" and triggerData.trigger.event == "Talent Known" then
          local classId
          for i = 1, GetNumClasses() do
            if select(2, GetClassInfo(i)) == triggerData.trigger.class then
              classId = i
            end
          end
          if classId and triggerData.trigger.spec then
            local specId = GetSpecializationInfoForClassID(classId, triggerData.trigger.spec)
            if specId then
              migrateTalent(triggerData.trigger, specId, "talent")
            end
          end
        end
      end
    end
  end

  if data.internalVersion < 60 then
    -- convert texture rotation
    if data.regionType == "texture" then
      if data.rotate then
        -- Full Rotate is enabled
        data.legacyZoomOut = true
      else
        -- Discrete Rotation
        data.rotation = data.discrete_rotation
      end
      data.discrete_rotation = nil
    end
  end

  if data.internalVersion < 61 then
    -- convert texture rotation
    if data.regionType == "texture" then
      if data.legacyZoomOut then
        data.rotate = true
      else
        data.rotate = false
        data.discrete_rotation = data.rotation
      end
      data.legacyZoomOut = nil
    end
  end

  -- version 62 became 64 to fix a broken modernize

  if data.internalVersion < 63 then
    if data.regionType == "texture" then
      local GetAtlasInfo = C_Texture and C_Texture.GetAtlasInfo or GetAtlasInfo
      local function IsAtlas(input)
        return type(input) == "string" and GetAtlasInfo(input) ~= nil
      end

      if not data.rotate or IsAtlas(data.texture) then
        data.rotation = data.discrete_rotation
      end
    end
  end

  if data.internalVersion < 64 then
    if data.regionType == "dynamicgroup" then
      if data.sort == "custom" and type(data.sortOn) ~= "string" or data.sortOn == "" then
        data.sortOn = "changed"
      end
      if data.grow == "CUSTOM" and type(data.growOn) ~= "string" then
        data.growOn = "changed"
      end
    end
  end

  if data.internalVersion < 65 then
    for triggerId, triggerData in ipairs(data.triggers) do
      if triggerData.trigger.type == "item"
      and triggerData.trigger.event == "Item Count"
      and type(triggerData.trigger.itemName) == "number"
      then
        triggerData.trigger.use_exact_itemName = true
      end
    end
  end

  local function spellIdToTalent(specId, spellId)
    local talents = Private.GetTalentData(specId)
    for _, talent in ipairs(talents) do
      if talent[2] == spellId then
        return talent[1]
      end
    end
  end

  if data.internalVersion < 66 then
    if WeakAuras.IsRetail() then
      for triggerId, triggerData in ipairs(data.triggers) do
        if triggerData.trigger.type == "unit"
          and triggerData.trigger.event == "Talent Known"
          and triggerData.trigger.talent
          and triggerData.trigger.talent.multi
        then
          local classId
          for i = 1, GetNumClasses() do
            if select(2, GetClassInfo(i)) == triggerData.trigger.class then
              classId = i
            end
          end
          if classId and triggerData.trigger.spec then
            local specId = GetSpecializationInfoForClassID(classId, triggerData.trigger.spec)
            if specId then
              local newMulti = { }
              for spellId, value in pairs(triggerData.trigger.talent.multi) do
                local talentId = spellIdToTalent(specId, spellId)
                if talentId then
                  newMulti[talentId] = value
                end
              end
              triggerData.trigger.talent.multi = newMulti
            end
          end
        end
      end
      local specId = Private.checkForSingleLoadCondition(data.load, "class_and_spec")


      if specId then
        for _, property in ipairs({"talent", "talent2", "talent3"}) do
          local use = "use_" .. property
          if data.load[use] ~= nil and data.load[property] and data.load[property].multi then
            local newMulti = { }
            for spellId, value in pairs(data.load[property].multi) do
              local talentId = spellIdToTalent(specId, spellId)
              if talentId then
                newMulti[talentId] = value
              end
            end
            data.load[property].multi = newMulti
          end

        end
      end
    end
  end

  local function migrateToTable(tab, field)
    local value = tab[field]
    if value ~= nil and type(value) ~= "table" then
      tab[field] = { value }
    end
  end

  if data.internalVersion < 67 then
    do
      local trigger_migration = {
        ["Cast"] = {
          "stage",
          "stage_operator",
        },
        ["Experience"] = {
          "level",
          "level_operator",
          "currentXP",
          "currentXP_operator",
          "totalXP",
          "totalXP_operator",
          "percentXP",
          "percentXP_operator",
          "restedXP",
          "restedXP_operator",
          "percentrested",
          "percentrested_operator",
        },
        ["Health"] = {
          "health",
          "health_operator",
          "percenthealth",
          "percenthealth_operator",
          "deficit",
          "deficit_operator",
          "maxhealth",
          "maxhealth_operator",
          "absorb",
          "absorb_operator",
          "healabsorb",
          "healabsorb_operator",
          "healprediction",
          "healprediction_operator",
        },
        ["Power"] = {
          "power",
          "power_operator",
          "percentpower",
          "percentpower_operator",
          "deficit",
          "deficit_operator",
          "maxpower",
          "maxpower_operator",
        },
        ["Character Stats"] = {
          "mainstat",
          "mainstat_operator",
          "strength",
          "strength_operator",
          "agility",
          "agility_operator",
          "intellect",
          "intellect_operator",
          "spirit",
          "spirit_operator",
          "stamina",
          "stamina_operator",
          "criticalrating",
          "criticalrating_operator",
          "criticalpercent",
          "criticalpercent_operator",
          "hitrating",
          "hitrating_operator",
          "hitpercent",
          "hitpercent_operator",
          "hasterating",
          "hasterating_operator",
          "hastepercent",
          "hastepercent_operator",
          "meleehastepercent",
          "meleehastepercent_operator",
          "expertiserating",
          "expertiserating_operator",
          "expertisebonus",
          "expertisebonus_operator",
          "armorpenrating",
          "armorpenrating_operator",
          "armorpenpercent",
          "armorpenpercent_operator",
          "resiliencerating",
          "resiliencerating_operator",
          "resiliencepercent",
          "resiliencepercent_operator",
          "spellpenpercent",
          "spellpenpercent_operator",
          "masteryrating",
          "masteryrating_operator",
          "masterypercent",
          "masterypercent_operator",
          "versatilityrating",
          "versatilityrating_operator",
          "versatilitypercent",
          "versatilitypercent_operator",
          "attackpower",
          "attackpower_operator",
          "resistanceholy",
          "resistanceholy_operator",
          "resistancefire",
          "resistancefire_operator",
          "resistancenature",
          "resistancenature_operator",
          "resistancefrost",
          "resistancefrost_operator",
          "resistanceshadow",
          "resistanceshadow_operator",
          "resistancearcane",
          "resistancearcane_operator",
          "leechrating",
          "leechrating_operator",
          "leechpercent",
          "leechpercent_operator",
          "movespeedrating",
          "movespeedrating_operator",
          "movespeedpercent",
          "movespeedpercent_operator",
          "runspeedpercent",
          "runspeedpercent_operator",
          "avoidancerating",
          "avoidancerating_operator",
          "avoidancepercent",
          "avoidancepercent_operator",
          "defense",
          "defense_operator",
          "dodgerating",
          "dodgerating_operator",
          "dodgepercent",
          "dodgepercent_operator",
          "parryrating",
          "parryrating_operator",
          "parrypercent",
          "parrypercent_operator",
          "blockpercent",
          "blockpercent_operator",
          "blocktargetpercent",
          "blocktargetpercent_operator",
          "blockvalue",
          "blockvalue_operator",
          "staggerpercent",
          "staggerpercent_operator",
          "staggertargetpercent",
          "staggertargetpercent_operator",
          "armorrating",
          "armorrating_operator",
          "armorpercent",
          "armorpercent_operator",
          "armortargetpercent",
          "armortargetpercent_operator",
        },
        ["Threat Situation"] = {
          "threatpct",
          "threatpct_operator",
          "rawthreatpct",
          "rawthreatpct_operator",
          "threatvalue",
          "threatvalue_operator",
        },
        ["Unit Characteristics"] = {
          "level",
          "level_operator",
        },
        ["Combat Log"] = {
          "spellId",
          "spellName",
        },
        ["Spell Cast Succeeded"] = {
          "spellId"
        }
      }
      for _, triggerData in ipairs(data.triggers) do
        local t = triggerData.trigger
        local fieldsToMigrate = trigger_migration[t.event]
        if fieldsToMigrate then
          for _, field in ipairs(fieldsToMigrate) do
            migrateToTable(t, field)
          end
        end
        -- cast trigger move data from 'spell' & 'spellId' to 'spellIds' & 'spellNames'
        if t.event == "Cast" and t.type == "unit" then
          if t.spellId then
            if t.useExactSpellId then
              t.use_spellIds = t.use_spellId
              t.spellIds = t.spellIds or {}
              tinsert(t.spellIds, t.spellId)
            else
              t.use_spellNames = t.use_spellId
              t.spellNames = t.spellNames or {}
              tinsert(t.spellNames, t.spellId)
            end
          end
          if t.use_spell and t.spell then
            t.use_spellNames = true
            t.spellNames = t.spellNames or {}
            tinsert(t.spellNames, t.spell)
          end
          t.use_spellId = nil
          t.spellId = nil
          t.use_spell = nil
          t.spell = nil
        end
      end
    end
    do
      local loadFields = {
        "level", "effectiveLevel"
      }

      for _, field in ipairs(loadFields) do
        migrateToTable(data.load, field)
        migrateToTable(data.load, field .. "_operator")
      end
    end
  end

  if data.internalVersion < 68 then
    if data.parent then
      local parentData = WeakAuras.GetData(data.parent)
      if parentData and parentData.regionType == "dynamicgroup" then
        if data.anchorFrameParent == nil then
          data.anchorFrameParent = false
        end
      end
    end
  end

  if data.internalVersion < 69 then
    migrateToTable(data.load, "itemequiped")
  end

  if data.internalVersion < 70 then
    local trigger_migration = {
      Power = {
        "power",
        "power_operator"
      }
    }
    for _, triggerData in ipairs(data.triggers) do
      local t = triggerData.trigger
      local fieldsToMigrate = trigger_migration[t.event]
      if fieldsToMigrate then
        for _, field in ipairs(fieldsToMigrate) do
          migrateToTable(t, field)
        end
      end
    end
  end

  if data.internalVersion < 71 then
    if data.regionType == 'icon' or data.regionType == 'aurabar'
       or data.regionType == 'progresstexture'
       or data.regionType == 'stopmotion'
    then
      data.progressSource = {-1, ""}
    else
      data.progressSource = nil
    end
    if data.subRegions then
      for index, subRegionData in ipairs(data.subRegions) do
        if subRegionData.type == "subtick" then
          local tick_placement = subRegionData.tick_placement
          subRegionData.tick_placements = {}
          subRegionData.tick_placements[1] = tick_placement
          subRegionData.progressSources = {{-2, ""}}
          subRegionData.tick_placement = nil
        end
      end
    end
  end

  if data.internalVersion < 72 then
    if WeakAuras.IsClassic() then
      if data.model_path and data.modelIsUnit then
        data.model_fileId = data.model_path
      end
    end
  end

  if data.internalVersion < 73 then
    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if type(change.property) == "string" then
            change.property = string.gsub(change.property, "(sub.%d.tick_placement)(%d)", "%1s.%2")
          end
        end
      end
    end
  end

  if data.internalVersion < 74 then
    for _, triggerData in ipairs(data.triggers) do
      local t = triggerData.trigger
      if t.type == "spell" and t.event == "Cooldown Progress (Spell)" then
        if t.use_exact_spellName then
          t.use_ignoreoverride = true
        end
      end
    end
  end

  if data.internalVersion < 75 then
    -- this commit from nov 2019 https://github.com/WeakAuras/WeakAuras2/commit/6d8f11c17422aeffdb82a0aa05181edfdd137896
    -- changed adjustedMin & adjustedMax type from number to string (range => input)
    -- but didn't include a migration
    if type(data.adjustedMin) == "number" then
      data.adjustedMin = tostring(data.adjustedMin)
    end
    if type(data.adjustedMax) == "number" then
      data.adjustedMax = tostring(data.adjustedMax)
    end
    -- this commit https://github.com/WeakAuras/WeakAuras2/commit/dbcb70b1e4df262af82f63620b3b0d80741e6df2
    -- set a default for adjustedMin & adjustedMax with an empty string
    -- in Private.validate if type of value is different from type of default, value is set to default
    -- which had effect to lose data if aura was made before nov 2019 ~ 2020
    -- try detect data loss and restore from Archivist
    if data.internalVersion == 74 and oldSnapshot then
      local restoreMin = data.useAdjustededMin and data.adjustedMin == ""
      local restoreMax = data.useAdjustededMax and data.adjustedMax == ""
      if restoreMin or restoreMax then
        if restoreMin and type(oldSnapshot.adjustedMin) == "number" then
          data.adjustedMin = tostring(oldSnapshot.adjustedMin)
        end
        if restoreMax and type(oldSnapshot.adjustedMax) == "number" then
          data.adjustedMax = tostring(oldSnapshot.adjustedMax)
        end
      end
    end
  end

  if data.internalVersion < 76 then
    local function removeHoles(t)
      local keys = {}
      for key in pairs(t) do
        table.insert(keys, key)
      end
      if #keys ~= #t then
        table.sort(keys)
        local newTable = {}
        for i, key in ipairs(keys) do
          newTable[i] = t[key]
        end
        return newTable
      else
        return t
      end
    end
    local trigger_migration = {
      ["Spell Cast Succeeded"] = {
        "spellId",
      },
      ["Unit Characteristics"] = {
        "level",
      },
      ["Power"] = {
        "power",
        "percentpower",
        "deficit",
        "maxpower",
      },
      ["Combat Log"] = {
        "spellId",
        "spellName",
      },
      ["Health"] = {
        "health",
        "percenthealth",
        "deficit",
        "maxhealth",
        "absorb",
        "healabsorb",
        "healprediction",
      },
      ["Faction Reputation"] = {
        "value",
        "total",
        "percentRep",
      },
      ["Location"] = {
        "zone",
        "subzone",
      },
      ["Threat Situation"] = {
        "threatpct",
        "rawthreatpct",
        "threatvalue",
      },
      ["Character Stats"] = {
        "mainstat",
        "strength",
        "agility",
        "intellect",
        "spirit",
        "stamina",
        "criticalrating",
        "criticalpercent",
        "hitrating",
        "hitpercent",
        "hasterating",
        "hastepercent",
        "meleehastepercent",
        "expertiserating",
        "expertisebonus",
        "spellpenpercent",
        "masteryrating",
        "masterypercent",
        "versatilityrating",
        "versatilitypercent",
        "attackpower",
        "leechrating",
        "leechpercent",
        "movespeedrating",
        "movespeedpercent",
        "runspeedpercent",
        "avoidancerating",
        "avoidancepercent",
        "dodgerating",
        "dodgepercent",
        "parryrating",
        "parrypercent",
        "blockpercent",
        "blocktargetpercent",
        "blockvalue",
        "staggerpercent",
        "staggertargetpercent",
        "armorrating",
        "armorpercent",
        "armortargetpercent",
        "resistanceholy",
        "resistancefire",
        "resistancenature",
        "resistancefrost",
        "resistanceshadow",
        "resistancearcane",
      },
      ["Cast"] = {
        "spellNames",
        "spellIds",
        "stage",
      },
      ["Alternate Power"] = {
        "power",
      },
      ["Experience"] = {
        "level",
        "currentXP",
        "totalXP",
        "percentXP",
        "restedXP",
        "percentrested",
      }
    }
    for _, triggerData in ipairs(data.triggers) do
      local trigger = triggerData.trigger
      local fieldsToMigrate = trigger_migration[trigger.event]
      if fieldsToMigrate then
        for _, field in ipairs(fieldsToMigrate) do
          if type(trigger[field]) == "table" then
            trigger[field] = removeHoles(trigger[field])
          end
        end
      end
    end
  end

  if data.internalVersion < 77 then
    -- fix data broken by wago export
    local triggerFix = {
      talent = {
        multi = true
      },
      herotalent = {
        multi = true
      },
      form = {
        multi = true
      },
      specId = {
        multi = true
      },
      actualSpec = true,
      arena_spec = true
    }
    local loadFix = {
      talent = {
        multi = true
      },
      talent2 = {
        multi = true
      },
      talent3 = {
        multi = true
      },
      herotalent = {
        multi = true
      },
      class_and_spec = {
        multi = true
      }
    }

    local function fixData(data, fields)
      for k, v in pairs(fields) do
        if v == true and type(data[k]) == "table" then
          -- fix field k
          local tofix = {}
          for key in pairs(data[k]) do
              if type(key) == "string" then
                table.insert(tofix, key)
              end
          end
          for _, oldkey in ipairs(tofix) do
              local newkey = tonumber(oldkey)
              if newkey then
                data[k][newkey] = data[k][oldkey]
              end
              data[k][oldkey] = nil
          end
        elseif type(v) == "table" and type(data[k]) == "table" then
          -- recurse
          fixData(data[k], fields[k])
        end
      end
    end

    for _, triggerData in ipairs(data.triggers) do
      fixData(triggerData.trigger, triggerFix)
    end
    fixData(data.load, loadFix)
  end

  if data.internalVersion < 78 then
    if data.triggers then
      for triggerId, triggerData in ipairs(data.triggers) do
        local trigger = triggerData.trigger
        -- Item Type is now always a multi selection
        if trigger and trigger.type == "item" and trigger.event == "Item Type Equipped" then
          local value = trigger.itemTypeName and trigger.itemTypeName.single or nil
          if trigger.use_itemTypeName and value then
            trigger.use_itemTypeName = false
            trigger.itemTypeName = {multi = {[value] = true}}
          else
            trigger.itemTypeName = {multi = {}}
          end
        end
      end
    end
  end

  if data.internalVersion < 79 then
    if data.triggers then
      for _, triggerData in ipairs(data.triggers) do
        local trigger = triggerData.trigger
        if trigger and trigger.type == "unit" and trigger.event == "Unit Characteristics" then
          if trigger.use_ignoreDead then
            if trigger.unit == "group" or trigger.unit == "raid" or trigger.unit == "party" then
              trigger.use_dead = false
            else
              -- since this option was previously only available for group units,
              -- nil it out if the unit isn't group to avoid surprises from vestigial data
              trigger.use_dead = nil
            end
          end
          trigger.use_ignoreDead = nil
        end
      end
    end
  end


  if data.internalVersion < 80 then
    -- Use common names for anchor areas/points so
    -- that up/down of sub regions can adapt that

    local conversions = {
      subborder = {
        border_anchor = "anchor_area",
      },
      subglow = {
        glow_anchor = "anchor_area"
      },
      subtext = {
        text_anchorPoint = "anchor_point"
      }
    }

    if data.subRegions then
      for index, subRegionData in ipairs(data.subRegions) do
        if conversions[subRegionData.type] then
          for oldKey, newKey in pairs(conversions[subRegionData.type]) do
            subRegionData[newKey] = subRegionData[oldKey]
            subRegionData[oldKey] = nil
          end
        end
      end
    end
  end

  if data.internalVersion < 81 then
    -- Rename 'progressSources' to 'progressSource' for Linear/CircularProgressTexture/StopMotion sub elements
    local conversions = {
      sublineartexture = {
        progressSources = "progressSource",
      },
      subcirculartexture = {
        progressSources = "progressSource",
      },
      substopmotion = {
        progressSources = "progressSource",
      }
    }
    if data.subRegions then
      for index, subRegionData in ipairs(data.subRegions) do
        if conversions[subRegionData.type] then
          for oldKey, newKey in pairs(conversions[subRegionData.type]) do
            subRegionData[newKey] = subRegionData[oldKey]
            subRegionData[oldKey] = nil
          end
        end
      end
    end
  end

  if data.internalVersion < 82 then
    -- noMerge for separator custom option doesn't make sense,
    -- and groups achieve the desired effect better,
    -- so drop the feature
    if data.authorOptions then
      for _, optionData in ipairs(data.authorOptions) do
        if optionData.type == "header" then
          optionData.noMerge = nil
        end
      end
    end
  end

  if data.internalVersion < 83 then
    local propertyRenames = {
      cooldownText = "cooldownTextDisabled",
    }

    if data.conditions then
      for conditionIndex, condition in ipairs(data.conditions) do
        for changeIndex, change in ipairs(condition.changes) do
          if propertyRenames[change.property] then
            change.property = propertyRenames[change.property]
          end
        end
      end
    end
  end

  data.internalVersion = max(data.internalVersion or 0, WeakAuras.InternalVersion())
end