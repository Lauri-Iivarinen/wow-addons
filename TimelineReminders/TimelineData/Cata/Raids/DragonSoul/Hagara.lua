local _, LRP = ...

local instanceType = 1
local instance = 2
local encounter = 4

local heroic = {
    phases = {
        {
            event = "SPELL_AURA_APPLIED",
            value = 105256, -- Frozen Tempest
            count = 1,
            name = "Lightning phase (1)",
            shortName = "Lightning"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105256, -- Frozen Tempest
            count = 1,
            name = "Regular phase (2)",
            shortName = "P1"
        },

        {
            event = "SPELL_AURA_APPLIED",
            value = 105409, -- Water Shield
            count = 1,
            name = "Ice phase (1)",
            shortName = "Ice"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105409, -- Water Shield
            count = 1,
            name = "Regular phase (3)",
            shortName = "P1"
        },

        {
            event = "SPELL_AURA_APPLIED",
            value = 105256, -- Frozen Tempest
            count = 2,
            name = "Lightning phase (2)",
            shortName = "Lightning"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105256, -- Frozen Tempest
            count = 2,
            name = "Regular phase (4)",
            shortName = "P1"
        },

        {
            event = "SPELL_AURA_APPLIED",
            value = 105409, -- Water Shield
            count = 2,
            name = "Ice phase (2)",
            shortName = "Ice"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105409, -- Water Shield
            count = 2,
            name = "Regular phase (5)",
            shortName = "P1"
        },
    },

    events = {
        -- Water Shield
        {
            event = "SPELL_AURA_APPLIED",
            value = 105409,
            color = {79/255, 176/255, 176/255},
            show = true,
            entries = {
                {60 * 2 +  8.4, 30},
                {60 * 5 + 16.0, 28.8},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105409,
            show = false,
            entries = {
                {60 * 2 + 38.4},
                {60 * 5 + 44.8},
            }
        },

        -- Frozen Tempest
        {
            event = "SPELL_AURA_APPLIED",
            value = 105256,
            color = {219/255, 156/255, 240/255},
            show = true,
            entries = {
                {60 * 0 + 35.8, 27.7},
                {60 * 3 + 45.2, 26.5},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105256,
            show = false,
            entries = {
                {60 * 1 +  3.5},
                {60 * 4 + 11.7},
            }
        },

        -- Feedback
        {
            event = "SPELL_AURA_APPLIED",
            value = 108934,
            color = {90/255, 209/255, 140/255},
            show = true,
            entries = {
                {60 * 1 +  3.5, 15},
                {60 * 2 + 38.4, 15},
                {60 * 4 + 11.7, 15},
                {60 * 5 + 44.8, 15},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 108934,
            show = false,
            entries = {
                {60 * 1 + 18.5},
                {60 * 2 + 53.4},
                {60 * 4 + 26.7},
                {60 * 5 + 57.0},
            }
        },

        -- Ice Tomb
        {
            event = "SPELL_CAST_SUCCESS",
            value = 104448,
            color = {134/255, 90/255, 237/255},
            show = true,
            entries = {
                {60 * 1 + 26.8, 20},
                {60 * 3 +  0.8, 20},
                {60 * 4 + 34.6, 20},
            }
        },

        -- Ice Lance
        {
            event = "SPELL_CAST_SUCCESS",
            value = 105297,
            color = {59/255, 235/255, 223/255},
            show = true,
            entries = {
                {60 * 0 + 11.4, 15},
                {60 * 0 + 11.4, 15},
                {60 * 0 + 11.4, 15},

                {60 * 1 + 16.1, 15},
                {60 * 1 + 16.1, 15},
                {60 * 1 + 16.1, 15},

                {60 * 1 + 46.9, 15},
                {60 * 1 + 46.9, 15},
                {60 * 1 + 46.9, 15},

                {60 * 2 + 50.1, 15},
                {60 * 2 + 50.1, 15},
                {60 * 2 + 50.1, 15},

                {60 * 3 + 20.8, 15},
                {60 * 3 + 20.8, 15},
                {60 * 3 + 20.8, 15},

                {60 * 4 + 23.9, 15},
                {60 * 4 + 23.9, 15},
                {60 * 4 + 23.9, 15},

                {60 * 4 + 54.6, 15},
                {60 * 4 + 54.6, 15},
                {60 * 4 + 54.6, 15},
            }
        },

        -- Shattered Ice
        {
            event = "SPELL_CAST_SUCCESS",
            value = 105289,
            color = {50/255, 150/255, 255/255},
            show = true,
            entries = {
                {60 * 0 +  1.6, 4},
                {60 * 0 + 13.0, 4},
                {60 * 0 + 22.7, 4},

                {60 * 1 + 21.1, 4},
                {60 * 1 + 30.6, 4},
                {60 * 1 + 40.4, 4},
                {60 * 1 + 51.7, 4},
                {60 * 2 +  1.5, 4},

                {60 * 2 + 55.5, 4},
                {60 * 3 +  6.3, 4},
                {60 * 3 + 16.0, 4},
                {60 * 3 + 27.3, 4},
                {60 * 3 + 37.0, 4},

                {60 * 4 + 28.8, 4},
                {60 * 4 + 38.5, 4},
                {60 * 4 + 48.2, 4},
                {60 * 5 +  1.1, 4},
                {60 * 5 + 10.8, 4},
            }
        },

        -- Focused Assault
        {
            event = "SPELL_CAST_SUCCESS",
            value = 107851,
            color = {173/255, 151/255, 94/255},
            show = true,
            entries = {
                {60 * 0 +  3.2, 5},
                {60 * 0 + 19.5, 5},

                {60 * 1 + 18.7, 5},
                {60 * 1 + 33.9, 5},
                {60 * 1 + 50.1, 5},

                {60 * 2 + 53.9, 5},
                {60 * 3 +  9.5, 5},
                {60 * 3 + 25.7, 5},

                {60 * 4 + 27.1, 5},
                {60 * 4 + 43.3, 5},
                {60 * 4 + 59.6, 5},
            }
        },
	}
}

local mythic = {
    phases = {
        {
            event = "SPELL_AURA_APPLIED",
            value = 105409, -- Water Shield
            count = 1,
            name = "Ice phase (1)",
            shortName = "Ice"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105409, -- Water Shield
            count = 1,
            name = "Regular phase (2)",
            shortName = "P1"
        },

        {
            event = "SPELL_AURA_APPLIED",
            value = 105256, -- Frozen Tempest
            count = 1,
            name = "Lightning phase (1)",
            shortName = "Lightning"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105256, -- Frozen Tempest
            count = 1,
            name = "Regular phase (3)",
            shortName = "P1"
        },

        {
            event = "SPELL_AURA_APPLIED",
            value = 105409, -- Water Shield
            count = 2,
            name = "Ice phase (2)",
            shortName = "Ice"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105409, -- Water Shield
            count = 2,
            name = "Regular phase (4)",
            shortName = "P1"
        },

        {
            event = "SPELL_AURA_APPLIED",
            value = 105256, -- Frozen Tempest
            count = 2,
            name = "Lightning phase (2)",
            shortName = "Lightning"
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105256, -- Frozen Tempest
            count = 2,
            name = "Regular phase (5)",
            shortName = "P1"
        },
    },

    events = {
        -- Water Shield
        {
            event = "SPELL_AURA_APPLIED",
            value = 105409,
            color = {79/255, 176/255, 176/255},
            show = true,
            entries = {
                {60 * 0 + 32.5, 18.5},
                {60 * 4 + 25.5, 19.0},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105409,
            show = false,
            entries = {
                {60 * 0 + 51.0},
                {60 * 4 + 44.5},
            }
        },

        -- Frozen Tempest
        {
            event = "SPELL_AURA_APPLIED",
            value = 105256,
            color = {219/255, 156/255, 240/255},
            show = true,
            entries = {
                {60 * 1 + 58.1, 82.4},
                {60 * 5 + 52.6, 88.6},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 105256,
            show = false,
            entries = {
                {60 * 3 + 20.5},
                {60 * 7 + 21.2},
            }
        },

        -- Feedback
        {
            event = "SPELL_AURA_APPLIED",
            value = 108934,
            color = {90/255, 209/255, 140/255},
            show = true,
            entries = {
                {60 * 0 + 51.0, 15},
                {60 * 3 + 20.5, 15},
                {60 * 4 + 44.5, 15},
                {60 * 7 + 21.2, 15},
            }
        },
        {
            event = "SPELL_AURA_REMOVED",
            value = 108934,
            show = false,
            entries = {
                {60 * 1 +  6.0},
                {60 * 3 + 35.5},
                {60 * 4 + 59.5},
                {60 * 7 + 36.1},
            }
        },

        -- Ice Tomb
        {
            event = "SPELL_CAST_SUCCESS",
            value = 104448,
            color = {134/255, 90/255, 237/255},
            show = true,
            entries = {
                {60 * 1 + 13.6, 20},
                {60 * 3 + 44.1, 20},
                {60 * 5 +  8.2, 20},
                {60 * 7 + 43.4, 20},
            }
        },

        -- Ice Lance
        {
            event = "SPELL_CAST_SUCCESS",
            value = 105297,
            color = {59/255, 235/255, 223/255},
            show = true,
            entries = {
                {60 * 0 + 11.1, 15},
                {60 * 0 + 11.1, 15},
                {60 * 0 + 11.1, 15},

                {60 * 1 +  2.9, 15},
                {60 * 1 +  2.9, 15},
                {60 * 1 +  2.9, 15},
                {60 * 1 + 33.8, 15},
                {60 * 1 + 33.8, 15},
                {60 * 1 + 33.8, 15},

                {60 * 3 + 33.8, 15},
                {60 * 3 + 33.8, 15},
                {60 * 3 + 33.8, 15},
                {60 * 4 +  4.1, 15},
                {60 * 4 +  4.1, 15},
                {60 * 4 +  4.1, 15},

                {60 * 4 + 57.5, 15},
                {60 * 4 + 57.5, 15},
                {60 * 4 + 57.5, 15},
                {60 * 5 + 28.2, 15},
                {60 * 5 + 28.2, 15},
                {60 * 5 + 28.2, 15},

                {60 * 7 + 32.8, 15},
                {60 * 7 + 32.8, 15},
                {60 * 7 + 32.8, 15},
                {60 * 8 +  3.5, 8.5},
                {60 * 8 +  3.5, 8.5},
                {60 * 8 +  3.5, 8.5},
            }
        },

        -- Shattered Ice
        {
            event = "SPELL_CAST_SUCCESS",
            value = 105289,
            color = {50/255, 150/255, 255/255},
            show = true,
            entries = {
                {60 * 0 +  2.8, 4},
                {60 * 0 + 14.2, 4},
                {60 * 0 + 28.7, 4},
                {60 * 1 + 15.7, 4},
                {60 * 1 + 30.4, 4},
                {60 * 1 + 46.6, 4},
                {60 * 3 + 43.0, 4},
                {60 * 4 +  2.4, 4},
                {60 * 4 + 16.9, 4},
                {60 * 5 +  7.0, 4},
                {60 * 5 + 16.7, 4},
                {60 * 5 + 26.7, 4},
                {60 * 5 + 41.0, 4},
                {60 * 7 + 45.5, 4},
                {60 * 8 +  0.1, 4},
            }
        },

        -- Focused Assault
        {
            event = "SPELL_CAST_SUCCESS",
            value = 107851,
            color = {173/255, 151/255, 94/255},
            show = true,
            entries = {
                {60 * 0 +  4.6, 5},
                {60 * 0 + 20.8, 5},

                {60 * 1 +  6.1, 5},
                {60 * 1 + 22.3, 5},
                {60 * 1 + 38.5, 5},

                {60 * 3 + 35.5, 5},
                {60 * 3 + 51.2, 5},
                {60 * 4 +  7.3, 5},

                {60 * 5 +  0.3, 5},
                {60 * 5 + 17.0, 5},
                {60 * 5 + 33.3, 5},

                {60 * 7 + 36.3, 5},
                {60 * 7 + 52.1, 5},
                {60 * 8 +  8.4, 3.6},
            }
        },

        -- Berserk
        {
            event = "SPELL_AURA_APPLIED",
            value = 64238,
            color = {245/255, 22/255, 48/255},
            show = true,
            entries = {
                {60 * 8 +  0.2, 11.8},
            }
        },
	}
}

LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic