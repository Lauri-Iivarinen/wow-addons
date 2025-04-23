local _, LRP = ...

local instanceType = 1
local instance = 2
local encounter = 2

local heroic = {
    phases = {
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 1,
            name = "Rotation 2",
            shortName = "R2"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 2,
            name = "Rotation 2",
            shortName = "R3"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 3,
            name = "Rotation 2",
            shortName = "R4"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 4,
            name = "Rotation 2",
            shortName = "R5"
        },
    },

    events = {
        -- Focused Anger
        {
            event = "SPELL_AURA_APPLIED",
            value = 104543,
            color = {219/255, 182/255, 240/255},
            show = true,
            entries = {
                {60 * 0 + 11.5, 42.1},
                {60 * 1 + 30.9, 50.2},
                {60 * 2 + 58.3, 50.2},
                {60 * 4 + 25.8, 56.6},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543,
            show = false,
            entries = {
                {60 * 0 + 53.6},
                {60 * 2 + 21.1},
                {60 * 3 + 48.5},
                {60 * 5 + 22.4},
            }
        },

        -- Disrupting Shadows
        {
            event = "SPELL_CAST_SUCCESS",
            value = 103434,
            color = {154/255, 17/255, 245/255},
            show = true,
            entries = {
                {60 * 0 + 24.5, 10},
                {60 * 0 + 52.0, 10},

                {60 * 1 + 30.9, 10},
                {60 * 2 +  0.0, 10},

                {60 * 2 + 58.3, 10},
                {60 * 3 + 25.9, 10},

                {60 * 4 + 25.8, 10},
                {60 * 4 + 53.2, 10},
            }
        },

        -- Psychic Drain
        {
            event = "SPELL_CAST_SUCCESS",
            value = 104322,
            color = {245/255, 17/255, 135/255},
            show = true,
            entries = {
                {60 * 0 + 16.4, 1},
                {60 * 0 + 37.4, 1},

                {60 * 1 + 43.8, 1},
                {60 * 2 +  6.5, 1},

                {60 * 3 + 14.5, 1},
                {60 * 3 + 37.2, 1},

                {60 * 4 + 45.1, 1},
                {60 * 5 +  9.4, 1},
            }
        },
	}
}

local mythic = {
    phases = {
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 1,
            name = "Rotation 2",
            shortName = "R2"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 2,
            name = "Rotation 2",
            shortName = "R3"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 3,
            name = "Rotation 2",
            shortName = "R4"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543, -- Focused Anger
            count = 4,
            name = "Rotation 2",
            shortName = "R5"
        },
    },

    events = {
        -- Focused Anger
        {
            event = "SPELL_AURA_APPLIED",
            value = 104543,
            color = {219/255, 182/255, 240/255},
            show = true,
            entries = {
                {60 * 0 + 11.2, 55.4},
                {60 * 1 + 53.2, 50.2},
                {60 * 3 + 30.3, 53.5},
                {60 * 5 + 10.7, 53.4},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 104543,
            show = false,
            entries = {
                {60 * 1 +  6.3},
                {60 * 2 + 43.4},
                {60 * 4 + 23.8},
                {60 * 6 +  4.1},
            }
        },

        -- Disrupting Shadows
        {
            event = "SPELL_CAST_SUCCESS",
            value = 103434,
            color = {154/255, 17/255, 245/255},
            show = true,
            entries = {
                {60 * 0 + 21.0, 20},
                {60 * 0 + 48.5, 20},

                {60 * 1 + 53.2, 20},
                {60 * 2 + 19.2, 20},

                {60 * 3 + 30.3, 20},
                {60 * 3 + 56.2, 20},

                {60 * 5 + 10.7, 20},
                {60 * 5 + 39.9, 20},
            }
        },

        -- Psychic Drain
        {
            event = "SPELL_CAST_SUCCESS",
            value = 104322,
            color = {245/255, 17/255, 135/255},
            show = true,
            entries = {
                {60 * 0 + 19.3, 1},
                {60 * 0 + 40.4, 1},
                {60 * 1 +  3.0, 1},

                {60 * 2 +  1.3, 1},
                {60 * 2 + 25.7, 1},

                {60 * 3 + 38.4, 1},
                {60 * 4 +  2.7, 1},

                {60 * 5 + 18.8, 1},
                {60 * 5 + 43.1, 1},
            }
        },

        -- Berserk
        {
            event = "SPELL_AURA_APPLIED",
            value = 26662,
            color = {245/255, 15/255, 42/255},
            show = true,
            entries = {
                {60 * 6 +  0.9, 30},
            }
        },
	}
}

LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic