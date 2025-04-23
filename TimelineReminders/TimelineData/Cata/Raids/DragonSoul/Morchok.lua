local _, LRP = ...

local instanceType = 1
local instance = 2
local encounter = 1

local heroic = {
    phases = {
    },

    events = {
        -- Summon Resonating Crystal
        {
            value = 103639,
            color = {209/255, 29/255, 98/255},
            show = true,
            entries = {
                {60 * 0 + 20.2, 13},
                {60 * 0 + 34.7, 13},

                {60 * 1 + 45.9, 13},
                {60 * 2 +  0.5, 13},
                {60 * 2 + 15.2, 13},

                {60 * 3 + 26.4, 13},
                {60 * 3 + 40.9, 13},
                {60 * 3 + 55.4, 13},
            }
        },

        -- Stomp
        {
            event = "SPELL_CAST_START",
            value = 103414,
            color = {189/255, 237/255, 145/255},
            show = true,
            entries = {
                {60 *  0 + 12.9, 1.5},
                {60 *  0 + 25.9, 1.5},
                {60 *  0 + 40.5, 1.5},

                {60 *  1 + 38.8, 1.5},
                {60 *  1 + 53.3, 1.5},
                {60 *  2 +  6.3, 1.5},
                {60 *  2 + 20.9, 1.5},

                {60 *  3 + 19.1, 1.5},
                {60 *  3 + 33.7, 1.5},
                {60 *  3 + 46.7, 1.5},
                {60 *  4 +  1.2, 1.5},
            }
        },

        -- Crush Armor
        {
            event = "SPELL_CAST_SUCCESS",
            value = 103687,
            color = {168/255, 109/255, 91/255},
            show = true,
            entries = {
                {60 *  0 +  5.5, 1},
                {60 *  0 + 11.3, 1},
                {60 *  0 + 17.8, 1},
                {60 *  0 + 24.3, 1},
                {60 *  0 + 30.8, 1},
                {60 *  0 + 37.2, 1},
                {60 *  0 + 43.1, 1},
                {60 *  0 + 48.6, 1},
                {60 *  0 + 55.0, 1},

                {60 *  1 + 27.5, 1},
                {60 *  1 + 33.9, 1},
                {60 *  1 + 40.4, 1},
                {60 *  1 + 46.8, 1},
                {60 *  1 + 55.0, 1},
                {60 *  2 +  1.4, 1},
                {60 *  2 +  7.9, 1},
                {60 *  2 + 14.4, 1},
                {60 *  2 + 22.5, 1},
                {60 *  2 + 29.0, 1},
                {60 *  2 + 35.4, 1},

                {60 *  3 +  7.8, 1},
                {60 *  3 + 14.3, 1},
                {60 *  3 + 20.8, 1},
                {60 *  3 + 27.2, 1},
                {60 *  3 + 35.3, 1},
                {60 *  3 + 41.8, 1},
                {60 *  3 + 48.3, 1},
                {60 *  3 + 54.8, 1},
                {60 *  4 +  2.8, 1},
                {60 *  4 +  9.3, 1},
                {60 *  4 + 15.8, 1},
            }
        },

        -- Falling Fragments
        {
            event = "SPELL_CAST_SUCCESS",
            value = 103176,
            color = {219/255, 181/255, 123/255},
            show = true,
            entries = {
                {60 *  0 + 58.3, 5},
                {60 *  2 + 38.7, 5},
                {60 *  4 + 19.0, 5},
            }
        },

        -- Black Blood of the Earth
        {
            event = "SPELL_AURA_APPLIED",
            value = 103851,
            color = {63/255, 129/255, 140/255},
            show = true,
            entries = {
                {60 *  1 +  5.3, 15},
                {60 *  2 + 45.7, 15},
                {60 *  4 + 26.0, 15},
            }
        },
	}
}

local mythic = {
    phases = {
        {
            event = "SPELL_CAST_SUCCESS",
            value = 109017, -- Summon Kohcrom
            count = 1,
            name = "Kohcrom",
            shortName = "P1"
        },
    },

    events = {
        -- Summon Kohcrom
        {
            event = "SPELL_CAST_SUCCESS",
            value = 109017,
            color = {239/255, 187/255, 240/255},
            show = true,
            entries = {
                {60 * 0 + 14.9, 2},
            }
        },

        -- Morchok: Summon Resonating Crystal
        {
            value = 103639,
            color = {209/255, 29/255, 98/255},
            show = true,
            nameOverride = "|cff8df7dfMorchok|r: Resonating Crystal",
            entries = {
                {60 * 0 + 22.2, 13},
                {60 * 0 + 36.7, 13},

                {60 * 1 + 47.9, 13},
                {60 * 2 +  2.5, 13},
                {60 * 2 + 17.0, 13},

                {60 * 3 + 28.3, 13},
                {60 * 3 + 42.7, 13},
                {60 * 3 + 57.4, 13},

                {60 * 5 +  8.5, 13},
                {60 * 5 + 23.2, 13},
                {60 * 5 + 37.6, 13},
            }
        },

        -- Morchok: Stomp
        {
            event = "SPELL_CAST_START",
            value = 103414,
            color = {189/255, 237/255, 145/255},
            show = true,
            nameOverride = "|cff8df7dfMorchok|r: Stomp",
            entries = {
                {60 *  0 + 13.3, 1.5},
                {60 *  0 + 27.8, 1.5},
                {60 *  0 + 42.4, 1.5},

                {60 *  1 + 40.6, 1.5},
                {60 *  1 + 55.2, 1.5},
                {60 *  2 +  8.1, 1.5},
                {60 *  2 + 22.7, 1.5},

                {60 *  3 + 21.0, 1.5},
                {60 *  3 + 35.6, 1.5},
                {60 *  3 + 48.5, 1.5},
                {60 *  4 +  3.0, 1.5},

                {60 *  5 +  1.2, 1.5},
                {60 *  5 + 15.8, 1.5},
                {60 *  5 + 28.8, 1.5},
                {60 *  5 + 42.4, 1.5},
            }
        },

        -- Kohcrom: Summon Resonating Crystal
        {
            value = 103639,
            color = {209/255, 29/255, 98/255},
            show = true,
            nameOverride = "|cffefbbf0Kohcrom|r: Resonating Crystal",
            entries = {
                {60 * 0 + 43.2, 13},

                {60 * 2 +  8.9, 13},
                {60 * 2 + 23.4, 13},

                {60 * 3 + 49.3, 13},
                {60 * 4 +  3.8, 13},

                {60 * 5 + 29.5, 13},
                {60 * 5 + 44.1, 13},
            }
        },

        -- Kohcrom: Stomp
        {
            event = "SPELL_CAST_START",
            value = 103414,
            color = {189/255, 237/255, 145/255},
            show = true,
            nameOverride = "|cffefbbf0Kohcrom|r: Stomp",
            entries = {
                {60 *  0 + 34.3, 1.5},
                {60 *  0 + 48.9, 1.5},

                {60 *  1 + 47.1, 1.5},
                {60 *  2 +  1.6, 1.5},
                {60 *  2 + 14.6, 1.5},
                {60 *  2 + 29.2, 1.5},

                {60 *  3 + 27.4, 1.5},
                {60 *  3 + 42.0, 1.5},
                {60 *  3 + 55.0, 1.5},
                {60 *  4 +  9.5, 1.5},

                {60 *  5 +  7.7, 1.5},
                {60 *  5 + 22.3, 1.5},
                {60 *  5 + 35.3, 1.5},
                {60 *  5 + 49.8, 1.5},
            }
        },

        -- Falling Fragments
        {
            event = "SPELL_CAST_SUCCESS",
            value = 103176,
            color = {219/255, 181/255, 123/255},
            show = true,
            entries = {
                {60 *  1 +  0.2, 5},
                {60 *  1 +  0.2, 5},

                {60 *  2 + 40.5, 5},
                {60 *  2 + 40.5, 5},

                {60 *  4 + 20.8, 5},
                {60 *  4 + 20.8, 5},

                {60 *  6 +  1.2, 5},
                {60 *  6 +  1.2, 5},
            }
        },

        -- Black Blood of the Earth
        {
            event = "SPELL_AURA_APPLIED",
            value = 103851,
            color = {63/255, 129/255, 140/255},
            show = true,
            entries = {
                {60 *  1 +  7.2, 15},
                {60 *  1 +  7.2, 15},

                {60 *  2 + 47.5, 15},
                {60 *  2 + 47.5, 15},

                {60 *  4 + 27.9, 15},
                {60 *  4 + 27.9, 15},

                {60 *  6 +  8.2, 15},
                {60 *  6 +  8.2, 15},
            }
        },
	}
}

LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic