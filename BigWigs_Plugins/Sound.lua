-------------------------------------------------------------------------------
-- Module Declaration
--

local plugin = BigWigs:NewPlugin("Sounds", {
	"db",
	"soundOptions",
	"SetSoundOptions",
	"GetDefaultSound",
})
if not plugin then return end

-------------------------------------------------------------------------------
-- Locals
--

local L = BigWigsAPI:GetLocale("BigWigs")
local media = LibStub("LibSharedMedia-3.0")
local SOUND = media.MediaType and media.MediaType.SOUND or "sound"
local soundList = nil
local db
local sounds = {
	Long = "BigWigs: Long",
	Info = "BigWigs: Info",
	Alert = "BigWigs: Alert",
	Alarm = "BigWigs: Alarm",
	Warning = "BigWigs: Raid Warning",
	--onyou = L.spell_on_you,
	underyou = L.spell_under_you,
	privateaura = "BigWigs: Raid Warning",
}

--------------------------------------------------------------------------------
-- Profile
--

plugin.defaultDB = {
	media = {
		Long = sounds.Long,
		Info = sounds.Info,
		Alert = sounds.Alert,
		Alarm = sounds.Alarm,
		Warning = sounds.Warning,
		--onyou = L.spell_on_you,
		underyou = L.spell_under_you,
		privateaura = sounds.privateaura,
	},
	Long = {},
	Info = {},
	Alert = {},
	Alarm = {},
	Warning = {},
	underyou = {},
	privateaura = {},
}

local function updateProfile()
	db = plugin.db.profile
	for k, v in next, db do
		local defaultType = type(plugin.defaultDB[k])
		if defaultType == "nil" then
			db[k] = nil
		elseif type(v) ~= defaultType then
			db[k] = plugin.defaultDB[k]
		end
	end
	for k, v in next, db.media do
		local defaultType = type(plugin.defaultDB.media[k])
		if defaultType == "nil" then
			db.media[k] = nil
		elseif type(v) ~= defaultType then
			db.media[k] = plugin.defaultDB.media[k]
		end
	end
end

--------------------------------------------------------------------------------
-- Options
--

plugin.pluginOptions = {
	type = "group",
	name = "|TInterface\\AddOns\\BigWigs\\Media\\Icons\\Menus\\Sounds:20|t ".. L.Sounds,
	get = function(info)
		for i, v in next, soundList do
			if v == db.media[info[#info]] then
				return i
			end
		end
	end,
	set = function(info, value)
		local sound = info[#info]
		db.media[sound] = soundList[value]
		plugin:PlaySoundFile(media:Fetch(SOUND, soundList[value]))
	end,
	order = 4,
	args = {
		heading = {
			type = "description",
			name = L.soundsDesc,
			order = 1,
			width = "full",
			fontSize = "medium",
		},
		-- Begin sound dropdowns
		--onyou = {
		--	type = "select",
		--	name = L.onyou,
		--	order = 2,
		--	values = function() return soundList end,
		--	width = "full",
		--	dialogControl = "SharedDropdown",
		--	itemControl = "DDI-Sound",
		--},
		underyou = {
			type = "select",
			name = L.underyou,
			order = 3,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		},
		privateaura = {
			type = "select",
			name = L.privateaura,
			order = 4,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
			hidden = BigWigsLoader.isClassic,
		},
		newline2 = {
			type = "description",
			name = "\n\n",
			order = 20,
		},
		oldSounds = {
			type = "header",
			name = L.oldSounds,
			order = 21,
		},
		Alarm = {
			type = "select",
			name = L.Alarm,
			order = 22,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		},
		Alert = {
			type = "select",
			name = L.Alert,
			order = 23,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		},
		Info = {
			type = "select",
			name = L.Info,
			order = 24,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		},
		Long = {
			type = "select",
			name = L.Long,
			order = 25,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		},
		Warning = {
			type = "select",
			name = L.Warning,
			order = 26,
			values = function() return soundList end,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		},
		-- End sound dropdowns
		reset = {
			type = "execute",
			name = L.reset,
			desc = L.resetSoundDesc,
			func = function()
				for k in next, plugin.db.profile.media do
					plugin.db.profile.media[k] = sounds[k]
				end
			end,
			order = 27,
		},
		resetAll = {
			type = "execute",
			name = L.resetAll,
			desc = L.resetAllCustomSound,
			func = function() plugin.db:ResetProfile() updateProfile() end,
			order = 28,
		},
	}
}

local soundOptions = {
	type = "group",
	name = L.Sounds,
	handler = plugin,
	inline = true,
	args = {
		customSoundDesc = {
			name = L.customSoundDesc,
			type = "description",
			order = 1,
			width = "full",
		},
	},
}
plugin.soundOptions = soundOptions

do
	local function addKey(t, key)
		if t.type and t.type == "select" then
			t.arg = key
		elseif t.args then
			for k, v in next, t.args do
				t.args[k] = addKey(v, key)
			end
		end
		return t
	end

	local C = BigWigs.C
	local keyTable = {}
	function plugin:SetSoundOptions(name, key, flags)
		table.wipe(keyTable)
		keyTable[1] = name
		keyTable[2] = key
		local t = addKey(soundOptions, keyTable)
		if t.args.countdown then
			t.args.countdown.disabled = not flags or bit.band(flags, C.COUNTDOWN) == 0
		end
		return t
	end
end

-------------------------------------------------------------------------------
-- Initialization
--

function plugin:OnRegister()
	updateProfile()

	soundList = media:List(SOUND)

	for k in next, sounds do
		local n = L[k] or k
		soundOptions.args[k] = {
			name = n,
			get = function(info)
				local name, key = unpack(info.arg)
				local optionName = info[#info]
				for i, v in next, soundList do
					-- If no custom sound exists for this option, fall back to global sound option
					if v == (db[optionName][name] and db[optionName][name][key] or db.media[optionName]) then
						return i
					end
				end
			end,
			set = function(info, value)
				local name, key = unpack(info.arg)
				local optionName = info[#info]
				if not db[optionName][name] then db[optionName][name] = {} end
				db[optionName][name][key] = soundList[value]
				self:PlaySoundFile(media:Fetch(SOUND, soundList[value]))
				-- We don't cleanup/reset the DB as someone may have a custom global sound but wish to use the default sound on a specific option
			end,
			hidden = function(info)
				local name, key = unpack(info.arg)
				local module = BigWigs:GetBossModule(name:sub(16), true)
				if not module or not module.soundOptions then -- no module entry? show all sounds
					return false
				end
				local optionSounds = module.soundOptions[key]
				if not optionSounds then
					return true
				end
				local optionName = info[#info]:lower()
				if type(optionSounds) == "table" then
					for _, sound in next, optionSounds do
						if sound:lower() == optionName then
							return false
						end
					end
				else
					return optionName ~= optionSounds:lower()
				end
				return true
			end,
			type = "select",
			values = soundList,
			order = 2,
			width = "full",
			dialogControl = "SharedDropdown",
			itemControl = "DDI-Sound",
		}
	end
end

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_Sound")
	self:RegisterMessage("BigWigs_ProfileUpdate", updateProfile)
	updateProfile()
end

-------------------------------------------------------------------------------
-- Event Handlers
--

do
	local tmp = { -- XXX temp
		["long"] = "Long",
		["info"] = "Info",
		["alert"] = "Alert",
		["alarm"] = "Alarm",
		["warning"] = "Warning",
	}
	function plugin:GetSoundFile(module, key, soundName)
		soundName = tmp[soundName] or soundName
		local sDb = db[soundName]
		if not module or not key or not sDb or not sDb[module.name] or not sDb[module.name][key] then
			local path = db.media[soundName] and media:Fetch(SOUND, db.media[soundName], true) or media:Fetch(SOUND, soundName, true)
			return path
		else
			local newSound = sDb[module.name][key]
			local path = db.media[newSound] and media:Fetch(SOUND, db.media[newSound], true) or media:Fetch(SOUND, newSound, true)
			return path
		end
	end

	function plugin:GetDefaultSound(soundName)
		if not soundName then return end
		if soundName == "none" then
			return "None"
		end
		soundName = tmp[soundName] or soundName

		local custom = soundName:match("^name:(.+)$")
		if custom and not media:Fetch(SOUND, custom, true) then
			return
		end
		return custom or db.media[soundName]
	end
end

function plugin:BigWigs_Sound(event, module, key, soundName)
	local soundPath = self:GetSoundFile(module, key, soundName)
	if soundPath then
		self:PlaySoundFile(soundPath)
	end
end
