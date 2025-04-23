local _, LRP = ...

local instanceType = 1
local instance = 2
local encounter = 8

local heroic = {
    phases = {
    },

    events = {
	}
}

local mythic = {
    phases = {
    },

    events = {
	}
}

LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic