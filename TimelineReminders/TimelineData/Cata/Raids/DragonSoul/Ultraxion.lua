local _, LRP = ...

local instanceType = 1
local instance = 2
local encounter = 5

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
        -- Hour of Twilight
        {
            event = "SPELL_CAST_START",
            value = 106371,
            color = {222/255, 26/255, 232/255},
            show = true,
            entries = {
                {60 * 0 + 45.3, 3},
                {60 * 1 + 30.6, 3},
                {60 * 2 + 16.0, 3},
                {60 * 3 +  1.3, 3},
                {60 * 3 + 46.7, 3},
                {60 * 4 + 32.0, 3},
                {60 * 5 + 17.4, 3},
            }
        },
        {
            event = "SPELL_CAST_SUCCESS",
            value = 106371,
            show = false,
            entries = {
                {60 * 0 + 48.3},
                {60 * 1 + 33.6},
                {60 * 2 + 19.0},
                {60 * 3 +  4.3},
                {60 * 3 + 49.7},
                {60 * 4 + 35.0},
                {60 * 5 + 20.4},
            }
        },

        -- Last Defender of Azeroth
        {
            value = 106218,
            color = {141/255, 107/255, 214/255},
            show = true,
            entries = {
                {60 * 0 +  8.0, 2},
            }
        },

        -- Gift of Life
        {
            value = 105896,
            color = {232/255, 58/255, 28/255},
            show = true,
            entries = {
                {60 * 1 + 16.0, 2},
            }
        },

        -- Essence of Dreams
        {
            value = 105996,
            color = {17/255, 217/255, 124/255},
            show = true,
            entries = {
                {60 * 2 + 31.0, 2},
            }
        },

        -- Source of Magic
        {
            value = 105903,
            color = {30/255, 102/255, 227/255},
            show = true,
            entries = {
                {60 * 3 + 31.0, 2},
            }
        },

        -- Timeloop
        {
            value = 105984,
            color = {222/255, 207/255, 38/255},
            show = true,
            entries = {
                {60 * 4 + 46.6, 2},
            }
        },

        -- Twilight Eruption
        {
            event = "SPELL_CAST_START",
            value = 106388,
            color = {240/255, 14/255, 48/255},
            show = true,
            entries = {
                {60 * 6 +  1.1, 5},
            }
        },
	}
}

for i = 1, 7 do
    table.insert(
        mythic.phases,
        {
            event = "SPELL_CAST_SUCCESS",
            value = 106371, -- Hour of Twilight
            count = i,
            name = string.format("Rotation %d", i + 1),
            shortName = string.format("R %d", i + 1)
        }
    )
end

heroic = CopyTable(mythic)

LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic