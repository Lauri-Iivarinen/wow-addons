local _, LRP = ...

local instanceType = 1
local instance = 2
local encounter = 6

local heroic = {
    phases = {
        {
            event = "SPELL_CAST_SUCCESS",
            value = 108045, -- Vengeance
            count = 1,
            name = "Phase 2",
            shortName = "P2"
        },
    },

    events = {
        -- Twilight Onslaught
        {
            event = "SPELL_CAST_START",
            value = 107588,
            color = {230/255, 17/255, 237/255},
            show = true,
            entries = {
                {60 * 0 + 25.2, 7},
                {60 * 1 +  0.1, 7},
                {60 * 1 + 35.2, 7},
                {60 * 2 + 10.2, 7},
                {60 * 2 + 45.2, 7},
                {60 * 3 + 20.2, 7},
                {60 * 3 + 55.2, 7},
            }
        },

        -- Disrupting Roar
        {
            event = "SPELL_CAST_SUCCESS",
            value = 108044,
            color = {245/255, 53/255, 20/255},
            show = true,
            entries = {
                {60 * 4 + 47.9, 1},
                {60 * 5 +  7.4, 1},
                {60 * 5 + 30.0, 1},
                {60 * 5 + 49.4, 1},
                {60 * 6 + 12.1, 1},
                {60 * 6 + 34.7, 1},
            }
        },

        -- Shockwave
        {
            event = "SPELL_CAST_START",
            value = 108046,
            color = {179/255, 143/255, 96/255},
            show = true,
            entries = {
                {60 * 4 + 52.8, 2.5},
                {60 * 5 + 13.8, 2.5},
                {60 * 5 + 39.7, 2.5},
                {60 * 6 +  0.7, 2.5},
                {60 * 6 + 25.0, 2.5},
                {60 * 6 + 49.3, 2.5},
            }
        },

        -- Vengeance
        {
            event = "SPELL_CAST_SUCCESS",
            value = 108045,
            show = false,
            entries = {
                {60 * 4 + 35.0},
            }
        },
	}
}

local mythic = {
    phases = {
        {
            event = "SPELL_CAST_SUCCESS",
            value = 108045, -- Vengeance
            count = 1,
            name = "Phase 2",
            shortName = "P2"
        },
    },

    events = {
        -- Twilight Onslaught
        {
            event = "SPELL_CAST_START",
            value = 107588,
            color = {230/255, 17/255, 237/255},
            show = true,
            entries = {
                {60 *  0 + 47.8, 7},
                {60 *  1 + 22.8, 7},
                {60 *  1 + 57.8, 7},
                {60 *  2 + 32.8, 7},
                {60 *  3 +  7.8, 7},
            }
        },

        -- Twilight Breath
        {
            event = "SPELL_CAST_START",
            value = 110212,
            color = {135/255, 43/255, 255/255},
            show = true,
            entries = {
                {60 *  4 + 10.3, 2},
                {60 *  4 + 32.9, 2},
                {60 *  4 + 58.8, 2},
                {60 *  5 + 24.7, 2},
            }
        },

        -- Consuming Shroud
        {
            event = "SPELL_CAST_START",
            value = 110214,
            color = {41/255, 64/255, 240/255},
            show = true,
            entries = {
                {60 *  4 + 18.3, 1.5},
                {60 *  4 + 50.7, 1.5},
                {60 *  5 + 23.1, 1.5},
            }
        },

        -- Disrupting Roar
        {
            event = "SPELL_CAST_SUCCESS",
            value = 108044,
            color = {245/255, 53/255, 20/255},
            show = true,
            entries = {
                {60 *  3 + 54.9, 1},
                {60 *  4 + 17.5, 1},
                {60 *  4 + 41.8, 1},
                {60 *  5 +  6.1, 1},
                {60 *  5 + 27.1, 1},
                {60 *  5 + 51.4, 1},
                {60 *  6 + 12.4, 1},
                {60 *  6 + 33.5, 1},
                {60 *  6 + 56.5, 1},
                {60 *  7 + 17.2, 1},
                {60 *  7 + 37.9, 1},
            }
        },

        -- Shockwave
        {
            event = "SPELL_CAST_START",
            value = 108046,
            color = {179/255, 143/255, 96/255},
            show = true,
            entries = {
                {60 *  4 +  1.4, 2.5},
                {60 *  4 + 24.0, 2.5},
                {60 *  4 + 49.9, 2.5},
                {60 *  5 + 14.2, 2.5},
                {60 *  5 + 36.8, 2.5},
                {60 *  5 + 57.9, 2.5},
                {60 *  6 + 20.5, 2.5},
                {60 *  6 + 46.4, 2.5},
                {60 *  7 +  9.0, 2.5},
                {60 *  7 + 33.3, 2.5},
                {60 *  7 + 56.0, 2.5},
            }
        },

        -- Vengeance
        {
            event = "SPELL_CAST_SUCCESS",
            value = 108045,
            show = false,
            entries = {
                {60 *  3 + 44.0},
            }
        },
	}
}

LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic