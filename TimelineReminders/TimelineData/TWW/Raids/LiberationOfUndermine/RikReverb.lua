local _, LRP = ...

if LRP.timelineData[1][2] then
    local instanceType = 1
    local instance = 2
    local encounter = 3

    local heroic = {
        phases = {
            {
                event = "SPELL_AURA_APPLIED",
                value = 464584, -- Sound Cloud
                count = 1,
                name = "Phase 2 (1)",
                shortName = "P2 (1)"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 464584, -- Sound Cloud
                count = 1,
                name = "Phase 1 (2)",
                shortName = "P1 (2)"
            },

            {
                event = "SPELL_AURA_APPLIED",
                value = 464584, -- Sound Cloud
                count = 2,
                name = "Phase 2 (2)",
                shortName = "P2 (2)"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 464584, -- Sound Cloud
                count = 2,
                name = "Phase 1 (3)",
                shortName = "P1 (3)"
            },
        },

        events = {
            -- Amplification!
            {
                event = "SPELL_CAST_START",
                value = 473748,
                color = {107/255, 114/255, 117/255},
                show = true,
                entries = {
                    {60 * 0 + 10.7, 3.3},
                    {60 * 0 + 51.1, 3.3},
                    {60 * 1 + 28.7, 3.3},

                    {60 * 2 + 44.3, 3.3},
                    {60 * 3 + 23.2, 3.3},
                    {60 * 4 +  2.2, 3.3},

                    {60 * 5 + 15.2, 3.3},
                    {60 * 5 + 55.4, 3.3},
                    {60 * 6 + 34.4, 3.3},
                }
            },

            -- Echoing Chant
            {
                event = "SPELL_CAST_START",
                value = 466866,
                color = {247/255, 177/255, 72/255},
                show = true,
                entries = {
                    {60 * 0 + 21.0, 3.5},
                    {60 * 1 + 19.5, 3.5},

                    {60 * 2 + 54.1, 3.5},
                    {60 * 3 + 52.5, 3.5},

                    {60 * 5 + 26.0, 3.5},
                    {60 * 6 + 24.5, 3.5},
                }
            },

            -- Sound Cannon
            {
                event = "SPELL_CAST_START",
                value = 467606,
                color = {131/255, 105/255, 201/255},
                show = true,
                entries = {
                    {60 * 0 + 32.0, 5},
                    {60 * 1 +  7.0, 5},

                    {60 * 3 +  5.1, 5},
                    {60 * 3 + 40.1, 5},

                    {60 * 5 + 37.1, 5},
                    {60 * 6 + 12.0, 5},
                }
            },

            -- Faulty Zap
            {
                event = "SPELL_CAST_START",
                value = 466979,
                color = {94/255, 191/255, 247/255},
                show = true,
                entries = {
                    {60 * 0 + 43.5, 2.125},
                    {60 * 1 + 15.0, 2.125},
                    {60 * 1 + 41.0, 2.125},

                    {60 * 3 + 16.5, 2.125},
                    {60 * 3 + 48.0, 2.125},
                    {60 * 4 + 14.0, 2.125},

                    {60 * 5 + 48.5, 2.125},
                    {60 * 6 + 20.0, 2.125},
                    {60 * 6 + 46.0, 2.125},
                }
            },

            -- Pyrotechnics
            {
                value = 1214688,
                color = {245/255, 68/255, 37/255},
                show = true,
                entries = {
                    {60 * 0 + 25.1, 15},
                    {60 * 1 +  4.5, 15},
                    {60 * 1 + 47.7, 15},

                    {60 * 2 + 58.1, 15},
                    {60 * 3 + 37.6, 15},
                    {60 * 4 + 20.7, 15},

                    {60 * 5 + 30.0, 15},
                    {60 * 6 +  9.6, 15},
                    {60 * 6 + 52.7, 15},
                }
            },

            -- Blaring Drop
            {
                event = "SPELL_CAST_START",
                value = 473260,
                color = {62/255, 79/255, 237/255},
                show = true,
                entries = {
                    {60 * 2 +  1.3, 6},
                    {60 * 2 +  9.3, 6},
                    {60 * 2 + 17.3, 6},
                    {60 * 2 + 25.2, 6},

                    {60 * 4 + 33.3, 6},
                    {60 * 4 + 41.3, 6},
                    {60 * 4 + 49.3, 6},
                    {60 * 4 + 57.3, 6},

                    {60 * 7 + 12.3, 6},
                    {60 * 7 + 24.3, 6},
                }
            },

            -- Sound Cloud
            {
                event = "SPELL_CAST_START",
                value = 464584,
                show = false,
                entries = {
                    {60 * 1 + 56.0, 5},
                    {60 * 4 + 58.0, 5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 464584,
                show = false,
                entries = {
                    {60 * 2 +  1.0},
                    {60 * 5 +  3.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 464584,
                color = {194/255, 245/255, 83/255},
                show = true,
                entries = {
                    {60 * 2 +  1.0, 32},
                    {60 * 4 + 33.0, 32},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 464584,
                show = false,
                entries = {
                    {60 * 2 + 33.0},
                    {60 * 5 +  5.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1213817,
                show = false,
                entries = {
                    {60 * 2 +  1.0, 32},
                    {60 * 4 + 33.0, 32},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1213817,
                show = false,
                entries = {
                    {60 * 2 + 33.0},
                    {60 * 5 +  5.0},
                }
            },

            -- Hype Fever
            {
                event = "SPELL_CAST_START",
                value = 473655,
                show = false,
                entries = {
                    {60 * 7 +  0.0, 12}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 473655,
                show = false,
                entries = {
                    {60 * 7 + 12.0}
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 473655,
                color = {237/255, 64/255, 234/255},
                show = true,
                entries = {
                    {60 * 7 + 12.0, 20}
                }
            },
        }
    }

    local mythic = {
        phases = {
            {
                event = "SPELL_AURA_APPLIED",
                value = 464584, -- Sound Cloud
                count = 1,
                name = "Phase 2 (1)",
                shortName = "P2 (1)"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 464584, -- Sound Cloud
                count = 1,
                name = "Phase 1 (2)",
                shortName = "P1 (2)"
            },

            {
                event = "SPELL_AURA_APPLIED",
                value = 464584, -- Sound Cloud
                count = 2,
                name = "Phase 2 (2)",
                shortName = "P2 (2)"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 464584, -- Sound Cloud
                count = 2,
                name = "Phase 1 (3)",
                shortName = "P1 (3)"
            },
        },

        events = {
            -- Amplification!
            {
                event = "SPELL_CAST_START",
                value = 473748,
                color = {107/255, 114/255, 117/255},
                show = true,
                entries = {
                    {60 * 0 + 10.8, 3.3},
                    {60 * 0 + 50.9, 3.3},
                    {60 * 1 + 29.8, 3.3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 473748,
                show = false,
                entries = {
                    {60 * 0 + 14.1},
                    {60 * 0 + 54.2},
                    {60 * 1 + 33.1},
                }
            },

            -- Echoing Chant
            {
                event = "SPELL_CAST_START",
                value = 466866,
                color = {247/255, 177/255, 72/255},
                show = true,
                entries = {
                    {60 * 0 + 21.0, 3.5},
                    {60 * 1 +  0.0, 3.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466866,
                show = false,
                entries = {
                    {60 * 0 + 24.5, 3.5},
                    {60 * 1 +  3.5, 3.5},
                }
            },

            -- Sound Cannon
            {
                event = "SPELL_CAST_START",
                value = 467606,
                color = {131/255, 105/255, 201/255},
                show = true,
                entries = {
                    {60 * 0 + 32.0, 5},
                    {60 * 1 +  7.0, 5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467606,
                show = false,
                entries = {
                    {60 * 0 + 37.0},
                    {60 * 1 + 12.0},
                }
            },

            -- Faulty Zap
            {
                event = "SPELL_CAST_START",
                value = 466979,
                color = {94/255, 191/255, 247/255},
                show = true,
                entries = {
                    {60 * 0 + 43.5, 2.125},
                    {60 * 1 + 15.0, 2.125},
                    {60 * 1 + 41.0, 2.125},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466979,
                show = false,
                entries = {
                    {60 * 0 + 45.7},
                    {60 * 1 + 17.1},
                    {60 * 1 + 43.1},
                }
            },

            -- Pyrotechnics
            {
                value = 1214688,
                color = {245/255, 68/255, 37/255},
                show = true,
                entries = {
                    {60 * 0 + 25.0, 15},
                    {60 * 1 + 24.0, 15},
                    {60 * 1 + 47.7, 15},
                }
            },

            -- Blaring Drop
            {
                event = "SPELL_CAST_START",
                value = 473260,
                color = {62/255, 79/255, 237/255},
                show = true,
                entries = {
                    {60 * 2 +  1.3, 5},
                    {60 * 2 +  8.3, 5},
                    {60 * 2 + 15.3, 5},
                    {60 * 2 + 22.2, 5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 473260,
                show = false,
                entries = {
                    {60 * 2 +  6.3},
                    {60 * 2 + 13.3},
                    {60 * 2 + 20.3},
                    {60 * 2 + 27.2},
                }
            },

            -- Sound Cloud
            {
                event = "SPELL_CAST_START",
                value = 464584,
                show = false,
                entries = {
                    {60 * 1 + 56.0, 5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 464584,
                show = false,
                entries = {
                    {60 * 2 +  1.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 464584,
                color = {194/255, 245/255, 83/255},
                show = true,
                entries = {
                    {60 * 2 +  1.0, 32},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 464584,
                show = false,
                entries = {
                    {60 * 2 + 33.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1213817,
                show = false,
                entries = {
                    {60 * 2 +  1.0, 32},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1213817,
                show = false,
                entries = {
                    {60 * 2 + 33.0},
                }
            },
        }
    }

    local interval = 60 * 2 + 29.5
    
    for _, eventInfo in ipairs(mythic.events) do
        local entries = eventInfo.entries
        local entryCount = entries and #entries or 0

        for i = 1, 2 do
            for j = 1, entryCount do
                local entry = entries[j]
                
                table.insert(
                    entries,
                    {entry[1] + i * interval, entry[2]}
                )
            end
        end
    end

    -- Remove last Sound Cloud
    for _, eventInfo in ipairs(mythic.events) do
        if eventInfo.value == 464584 or eventInfo.value == 1213817 then
            table.remove(eventInfo.entries, 3)
        end
    end

    -- Add Hype Fever
    tAppendAll(
        mythic.events,
        {
            {
                event = "SPELL_CAST_START",
                value = 473655,
                show = false,
                entries = {
                    {60 * 6 + 52.0}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 473655,
                show = false,
                entries = {
                    {60 * 6 + 57.0}
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 473655,
                color = {237/255, 64/255, 234/255},
                show = true,
                entries = {
                    {60 * 6 + 57.0, 30}
                }
            },
        }
    )

    LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
    LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic
end