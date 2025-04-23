local _, LRP = ...

if LRP.timelineData[1][2] then
    local instanceType = 1
    local instance = 2
    local encounter = 1

    local heroic = {
        phases = {},

        events = {
        }
    }

    local mythic = {
        phases = {
            {
                event = "SPELL_CAST_START",
                value = 460603, -- Mechanical Breakdown
                count = 1,
                name = "Phase 2 (1)",
                shortName = "P2 (1)"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 460116, -- Tune-Up
                count = 1,
                name = "Phase 1 (2)",
                shortName = "P1 (2)"
            },

            {
                event = "SPELL_CAST_START",
                value = 460603, -- Mechanical Breakdown
                count = 2,
                name = "Phase 2 (2)",
                shortName = "P2 (2)"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 460116, -- Tune-Up
                count = 2,
                name = "Phase 1 (3)",
                shortName = "P1 (3)"
            },

            {
                event = "SPELL_CAST_START",
                value = 460603, -- Mechanical Breakdown
                count = 3,
                name = "Phase 2 (3)",
                shortName = "P2 (3)"
            },
        },

        events = {
            -- Tune-Up
            {
                event = "SPELL_CAST_SUCCESS",
                value = 460116,
                show = false,
                entries = {
                    {60 * 2 +  1.4},

                    {60 * 5 +  3.6},

                    {60 * 8 +  1.8},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 460116,
                color = {210/255, 203/255, 214/255},
                show = true,
                entries = {
                    {60 * 2 +  1.4, 45},

                    {60 * 5 +  3.6, 45},

                    {60 * 8 +  1.8, 45},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 460116,
                show = false,
                entries = {
                    {60 * 2 + 46.4},

                    {60 * 5 + 48.6},

                    {60 * 8 + 46.8},
                }
            },

            -- Mechanical Breakdown
            {
                event = "SPELL_CAST_START",
                value = 460603,
                color = {250/255, 200/255, 35/255},
                show = true,
                entries = {
                    {60 * 1 + 57.4, 4},

                    {60 * 4 + 59.1, 4},

                    {60 * 7 + 57.0, 4},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 460603,
                show = false,
                entries = {
                    {60 * 2 +  1.4},

                    {60 * 5 +  3.1},

                    {60 * 8 +  1.0},
                }
            },

            -- Call Bikers
            {
                event = "SPELL_CAST_START",
                value = 459943,
                color = {113/255, 245/255, 93/255},
                show = true,
                entries = {
                    {60 * 0 + 20.6, 1},
                    {60 * 0 + 49.7, 1},
                    {60 * 1 + 18.9, 1},
                    {60 * 1 + 48.0, 1},

                    {60 * 3 + 10.6, 1},
                    {60 * 3 + 39.8, 1},
                    {60 * 4 + 13.7, 1},
                    {60 * 4 + 42.9, 1},

                    {60 * 6 + 12.4, 1},
                    {60 * 6 + 41.6, 1},
                    {60 * 7 + 13.1, 1},
                    {60 * 7 + 42.3, 1},
                }
            },

            -- Spew Oil
            {
                event = "SPELL_CAST_START",
                value = 459671,
                color = {65/255, 99/255, 87/255},
                show = true,
                entries = {
                    {60 * 0 + 12.0, 5},
                    {60 * 0 + 40.9, 5},
                    {60 * 1 + 28.6, 5},

                    {60 * 3 +  2.1, 5},
                    {60 * 3 + 24.0, 5},
                    {60 * 3 + 44.6, 5},
                    {60 * 4 +  5.2, 5},
                    {60 * 4 + 25.9, 5},
                    {60 * 4 + 46.6, 5},

                    {60 * 6 +  5.2, 5},
                    {60 * 6 + 25.8, 5},
                    {60 * 6 + 46.5, 5},
                    {60 * 7 +  7.1, 5},
                    {60 * 7 + 27.7, 5},
                    {60 * 7 + 48.4, 5},
                }
            },

            -- Incendiary Fire
            {
                event = "SPELL_CAST_START",
                value = 468487,
                color = {255/255, 119/255, 41/255},
                show = true,
                entries = {
                    {60 * 0 + 25.5, 3},
                    {60 * 0 + 59.4, 3},
                    {60 * 1 + 24.9, 3},
                    {60 * 1 + 50.5, 3},

                    {60 * 3 + 20.3, 3},
                    {60 * 3 + 55.6, 3},
                    {60 * 4 + 34.4, 3},

                    {60 * 6 + 22.2, 3},
                    {60 * 6 + 57.4, 3},
                    {60 * 7 + 36.2, 3},
                }
            },

            -- Tank Buster
            {
                event = "SPELL_CAST_START",
                value = 459627,
                color = {245/255, 29/255, 58/255},
                show = true,
                entries = {
                    {60 * 0 +  7.2, 1.5},
                    {60 * 0 + 29.1, 1.5},
                    {60 * 0 + 57.0, 1.5},
                    {60 * 1 + 20.1, 1.5},
                    {60 * 1 + 42.0, 1.5},

                    {60 * 2 + 56.0, 1.5},
                    {60 * 3 + 13.0, 1.5},
                    {60 * 3 + 30.0, 1.5},
                    {60 * 3 + 50.7, 1.5},
                    {60 * 4 + 11.3, 1.5},
                    {60 * 4 + 32.0, 1.5},

                    {60 * 5 + 59.1, 1.5},
                    {60 * 6 + 16.1, 1.5},
                    {60 * 6 + 33.1, 1.5},
                    {60 * 6 + 52.5, 1.5},
                    {60 * 7 + 14.4, 1.5},
                    {60 * 7 + 33.8, 1.5},
                }
            },
        }
    }

    heroic = CopyTable(mythic) -- Heroic and mythic timers look to be the same

    LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
    LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic
end