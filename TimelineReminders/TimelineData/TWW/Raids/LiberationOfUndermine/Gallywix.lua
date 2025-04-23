local _, LRP = ...

local function AddTimeToTimeline(timeline, timeToAdd)
    for _, eventInfo in ipairs(timeline) do
        for _, entry in ipairs(eventInfo.entries) do
            entry[1] = entry[1] + timeToAdd
        end
    end
end

local function MergeTimeline(fromTimeline, toTimeline)
    for _, fromEventInfo in ipairs(fromTimeline) do
        local inserted = false

        local fromEvent = fromEventInfo.event
        local fromValue = fromEventInfo.value

        for _, toEventInfo in ipairs(toTimeline) do
            local toEvent = toEventInfo.event
            local toValue = toEventInfo.value

            if fromEvent == toEvent and fromValue == toValue then
                tAppendAll(
                    toEventInfo.entries,
                    fromEventInfo.entries
                )

                inserted = true

                break
            end
        end

        if not inserted then
            table.insert(
                toTimeline,
                fromEventInfo
            )
        end
    end
end

if LRP.timelineData[1][2] then
    local instanceType = 1
    local instance = 2
    local encounter = 8

    local heroic = {
        phases = {
            {
                event = "SPELL_AURA_APPLIED",
                value = 469387, -- Carrier Giga Bomb
                count = 1,
                name = "Phase 2 (rotation 1)",
                shortName = "P2 (1)"
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1216846, -- Holding a Wrench
                count = 1,
                name = "Phase 2 (rotation 2)",
                shortName = "P2 (2)"
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1216846, -- Holding a Wrench
                count = 5,
                name = "Phase 2 (rotation 3)",
                shortName = "P2 (3)"
            },

            {
                event = "SPELL_AURA_APPLIED",
                value = 1214229, -- Armageddon-class Plating
                count = 1,
                name = "Intermission",
                shortName = "Int"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1214369, -- TOTAL DESTRUCTION!!!
                count = 1,
                name = "Phase 3 (rotation 1)",
                shortName = "P3 (1)"
            },
            {
                event = "SPELL_CAST_START",
                value = 466342, -- Tick-Tock Canisters
                count = 2,
                name = "P3 (rotation 2)",
                shortName = "P3 (2)"
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223658, -- Suppression
                count = 3,
                name = "P3 (rotation 3)",
                shortName = "P3 (3)"
            },
            {
                event = "SPELL_CAST_START",
                value = 466342, -- Tick-Tock Canisters
                count = 5,
                name = "P3 (rotation 4)",
                shortName = "P3 (4)"
            },
        },

        events = {
            -- Giga Coils
            {
                event = "SPELL_AURA_APPLIED",
                value = 469293,
                color = {40/255, 122/255, 252/255},
                show = true,
                entries = {
                    {60 * 2 +  0.0, 17},
                    {60 * 3 + 15.5, 18},

                    {60 * 5 + 42.8, 22},
                    {60 * 7 +  5.8, 23},
                    {60 * 8 + 38.4, 20},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 469293,
                show = false,
                entries = {
                    {60 * 2 + 17.0},
                    {60 * 3 + 33.6},

                    {60 * 6 +  4.8},
                    {60 * 7 + 28.8},
                    {60 * 8 + 58.4},
                }
            },

            -- Giga Blast
            {
                event = "SPELL_CAST_START",
                value = 469327,
                color = {73/255, 228/255, 242/255},
                show = true,
                entries = {
                    {60 * 2 +  5.6, 4},
                    {60 * 2 + 12.1, 4},

                    {60 * 3 + 17.6, 4},
                    {60 * 3 + 24.1, 4},

                    {60 * 5 + 44.8, 4},
                    {60 * 5 + 51.3, 4},
                    {60 * 5 + 57.8, 4},

                    {60 * 7 +  7.7, 4},
                    {60 * 7 + 14.3, 4},
                    {60 * 7 + 20.8, 4},

                    {60 * 8 + 40.4, 4},
                    {60 * 8 + 47.0, 4},
                    {60 * 8 + 53.5, 4},
                }
            },

            -- Holding a Wrench
            {
                event = "SPELL_AURA_APPLIED",
                value = 1216846,
                show = false,
                entries = {
                    {60 * 2 + 17.3},
                    {60 * 2 + 17.3},
                    {60 * 2 + 17.3},
                    {60 * 2 + 17.3},

                    {60 * 3 + 33.6},
                }
            },

            -- Carried Giga Bomb
            {
                event = "SPELL_AURA_APPLIED",
                value = 469387,
                show = false,
                entries = {
                    {60 * 1 + 51.0},
                }
            },

            -- Circuit Reboot
            {
                event = "SPELL_AURA_APPLIED",
                value = 1219062,
                show = false,
                entries = {
                    {60 * 4 + 42.7},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1219062,
                show = false,
                entries = {
                    {60 * 4 + 45.7},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1226890,
                show = false,
                entries = {
                    {60 * 4 + 42.7},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1226890,
                show = false,
                entries = {
                    {60 * 4 + 45.7},
                }
            },

            -- Scatterblast Canisters
            {
                event = "SPELL_CAST_START",
                value = 466340,
                color = {247/255, 61/255, 15/255},
                show = true,
                entries = {
                    {60 * 0 +  6.6, 3},
                    {60 * 0 + 23.6, 3},
                    {60 * 0 + 42.0, 3},
                    {60 * 1 +  0.8, 3},
                    {60 * 1 + 17.3, 3},
                    {60 * 1 + 37.9, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466340,
                show = false,
                entries = {
                    {60 * 0 +  9.6, 3},
                    {60 * 0 + 26.6, 3},
                    {60 * 0 + 45.0, 3},
                    {60 * 1 +  3.8, 3},
                    {60 * 1 + 20.3, 3},
                    {60 * 1 + 40.9, 3},
                }
            },

            -- Big Bad Buncha Bombs
            {
                event = "SPELL_CAST_START",
                value = 465952,
                color = {92/255, 189/255, 187/255},
                show = true,
                entries = {
                    {60 * 0 + 20.1, 3},
                    {60 * 0 + 55.5, 3},
                    {60 * 1 + 30.9, 3},

                    {60 * 2 + 53.6, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465952,
                show = false,
                entries = {
                    {60 * 0 + 23.1, 3},
                    {60 * 0 + 58.5, 3},
                    {60 * 1 + 33.9, 3},

                    {60 * 2 + 56.6, 3},
                }
            },

            -- Venting Heat
            {
                event = "SPELL_CAST_START",
                value = 466751,
                show = false,
                entries = {
                    {60 *  0 + 12.6, 1},
                    {60 *  0 + 38.4, 1},
                    {60 *  1 +  6.8, 1},
                    {60 *  1 + 34.4, 1},

                    {60 *  2 + 37.5, 1},
                    {60 *  3 + 51.2, 1},

                    {60 *  5 +  0.7, 1},
                    {60 *  6 + 17.3, 1},
                    {60 *  6 + 54.3, 1},
                    {60 *  8 +  7.3, 1},
                    {60 *  9 + 18.3, 1},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466751,
                color = {245/255, 119/255, 22/255},
                show = true,
                entries = {
                    {60 *  0 + 13.6, 4},
                    {60 *  0 + 39.4, 5},
                    {60 *  1 +  7.8, 6},
                    {60 *  1 + 35.4, 7},

                    {60 *  2 + 38.5, 8},
                    {60 *  3 + 52.2, 9},

                    {60 *  5 +  1.7, 10},
                    {60 *  6 + 18.3, 11},
                    {60 *  6 + 55.3, 12},
                    {60 *  8 +  8.3, 13},
                    {60 *  9 + 19.3, 14},
                }
            },

            -- Suppression
            {
                event = "SPELL_CAST_START",
                value = 467182,
                show = false,
                entries = {
                    {60 *  0 + 31.4, 1.5},
                    {60 *  1 + 10.3, 1.5},
                    {60 *  1 + 43.9, 1.5},
                    {60 *  2 + 41.1, 1.5},
                    {60 *  3 + 42.4, 1.5},
                    {60 *  5 + 15.7, 1.5},
                    {60 *  6 + 25.3, 1.5},
                    {60 *  7 + 36.3, 1.5},
                    {60 *  8 + 13.3, 1.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467182,
                color = {237/255, 207/255, 107/255},
                show = true,
                entries = {
                    {60 *  0 + 32.9, 3},
                    {60 *  1 + 11.8, 3},
                    {60 *  1 + 45.4, 3},
                    {60 *  2 + 42.6, 3},
                    {60 *  3 + 43.9, 3},
                    {60 *  5 + 17.2, 3},
                    {60 *  6 + 26.8, 3},
                    {60 *  7 + 37.8, 3},
                    {60 *  8 + 14.8, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223658,
                show = false,
                entries = {
                    {60 *  5 + 17.2, 3},
                    {60 *  6 + 26.8, 3},
                    {60 *  7 + 37.8, 3},
                    {60 *  8 + 14.8, 3},
                }
            },

            -- Gallybux Finale Blast
            {
                event = "SPELL_CAST_START",
                value = 1219333,
                color = {237/255, 26/255, 68/255},
                show = true,
                entries = {
                    {60 *  5 + 20.2, 1.5},
                    {60 *  6 + 29.8, 1.5},
                    {60 *  7 + 40.8, 1.5},
                    {60 *  8 + 17.8, 1.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1219333,
                show = false,
                entries = {
                    {60 *  5 + 21.7},
                    {60 *  6 + 31.3},
                    {60 *  7 + 42.3},
                    {60 *  8 + 19.3},
                }
            },

            -- Fused Canisters
            {
                event = "SPELL_CAST_START",
                value = 466341,
                color = {247/255, 185/255, 15/255},
                show = true,
                entries = {
                    {60 * 2 + 27.1, 3},
                    {60 * 3 +  0.1, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466341,
                show = false,
                entries = {
                    {60 * 2 + 30.1},
                    {60 * 3 +  3.1},
                }
            },

            -- Bigger Badder Bomb Blast
            {
                event = "SPELL_CAST_START",
                value = 1214607,
                color = {92/255, 189/255, 187/255},
                show = true,
                entries = {
                    {60 * 4 + 50.7, 4},
                    {60 * 5 + 26.7, 4},
                    {60 * 6 + 36.3, 4},
                    {60 * 7 + 47.3, 4},
                    {60 * 8 + 22.3, 4},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1214607,
                show = false,
                entries = {
                    {60 * 4 + 54.7},
                    {60 * 5 + 30.7},
                    {60 * 6 + 40.3},
                    {60 * 7 + 51.3},
                    {60 * 8 + 26.3},
                }
            },

            -- Tick-Tock Canisters
            {
                event = "SPELL_CAST_START",
                value = 466342,
                color = {123/255, 116/255, 145/255},
                show = true,
                entries = {
                    {60 * 5 +  4.7, 3},
                    {60 * 6 + 12.3, 3},
                    {60 * 6 + 47.3, 3},
                    {60 * 7 + 56.3, 3},
                    {60 * 9 +  2.3, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466342,
                show = false,
                entries = {
                    {60 * 5 +  7.7},
                    {60 * 6 + 15.3},
                    {60 * 6 + 50.3},
                    {60 * 7 + 59.3},
                    {60 * 9 +  5.3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223680,
                show = false,
                entries = {
                    {60 * 5 +  7.7},
                    {60 * 6 + 15.3},
                    {60 * 6 + 50.3},
                    {60 * 7 + 59.3},
                    {60 * 9 +  5.3},
                }
            },

            
            -- Armageddon-class Plating
            {
                event = "SPELL_AURA_APPLIED",
                value = 1214229,
                color = {185/255, 140/255, 237/255},
                show = true,
                entries = {
                    {60 * 4 + 12.4, 29.6},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1214229,
                show = false,
                entries = {
                    {60 * 4 + 42.0},
                }
            },

            -- TOTAL DESTRUCTION!!!
            {
                event = "SPELL_CAST_START",
                value = 1214369,
                color = {195/255, 219/255, 72/255},
                show = true,
                entries = {
                    {60 * 4 + 22.0, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1214369,
                show = false,
                entries = {
                    {60 * 4 + 25.1},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1214590,
                show = false,
                entries = {
                    {60 * 4 + 25.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1214590,
                show = false,
                entries = {
                    {60 * 4 + 25.0},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1214590,
                show = false,
                entries = {
                    {60 * 4 + 43.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1214369,
                show = false,
                entries = {
                    {60 * 4 + 25.0},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 1214369,
                show = false,
                entries = {
                    {60 * 4 + 42.7},
                }
            },
        }
    }

    local mythic = {
        phases = {
            {
                event = "SPELL_AURA_REMOVED",
                value = 1214369, -- TOTAL DESTRUCTION!!!
                count = 1,
                name = "Phase 1",
                shortName = "P1"
            },

            -- Phase 2
            {
                event = "SPELL_AURA_APPLIED",
                value = 1226891, -- Circuit Reboot
                count = 1,
                name = "Phase 2",
                shortName = "P2"
            },

            -- Phase 3
            {
                event = "SPELL_AURA_APPLIED",
                value = 1226891, -- Circuit Reboot
                count = 2,
                name = "Phase 3",
                shortName = "P3"
            },
        },

        desired_phase2_rotation1_start = 60 * 3 + 57.5, -- When first Circuit Reboot (1226891) aura_applied should be
        phase2_rotation1 = {
            -- Circuit Reboot
            {
                event = "SPELL_AURA_APPLIED",
                value = 1226891,
                show = false,
                entries = {
                    {60 * 3 + 57.1},
                }
            },

            -- Biggest Baddest Bomb Barrage
            {
                event = "SPELL_CAST_START",
                value = 1218546,
                color = {92/255, 189/255, 187/255},
                show = true,
                entries = {
                    {60 * 5 +  8.0, 3},
                    {60 * 5 + 56.0, 3},
                    {60 * 6 + 50.1, 3},
                }
            },

            -- Suppression
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467182,
                color = {237/255, 207/255, 107/255},
                show = true,
                entries = {
                    {60 * 4 + 55.0, 3},
                    {60 * 5 + 39.1, 3},
                    {60 * 6 + 24.0, 3},
                }
            },

            -- Gallybux Finale Blast
            {
                event = "SPELL_CAST_START",
                value = 1219333,
                color = {237/255, 26/255, 68/255},
                show = true,
                entries = {
                    {60 * 4 + 58.0, 1.5},
                    {60 * 5 + 42.1, 1.5},
                    {60 * 6 + 27.0, 1.5},
                }
            },

            -- Venting Heat
            {
                event = "SPELL_AURA_APPLIED",
                value = 466751,
                color = {245/255, 119/255, 22/255},
                show = true,
                entries = {
                    {60 * 4 + 40.5, 12},
                    {60 * 5 + 15.5, 12},
                    {60 * 5 + 35.1, 12},
                    {60 * 6 + 12.0, 12},
                    {60 * 6 + 32.5, 12},
                    {60 * 6 + 57.6, 12},
                }
            },

            -- Scatterbomb Canisters
            {
                event = "SPELL_CAST_START",
                value = 1218488,
                color = {247/255, 61/255, 15/255},
                show = true,
                entries = {
                    {60 * 4 + 43.0, 3.5},
                    {60 * 5 + 25.5, 3.5},
                    {60 * 6 +  2.5, 3.5},
                    {60 * 6 + 37.0, 3.5},
                }
            },

            -- Ego Check
            {
                event = "SPELL_CAST_START",
                value = 466958,
                color = {122/255, 114/255, 102/255},
                show = true,
                entries = {
                    {60 * 4 + 51.5, 1.5},
                    {60 * 5 + 18.0, 1.5},
                    {60 * 5 + 46.6, 1.5},
                    {60 * 6 + 14.5, 1.5},
                    {60 * 6 + 35.0, 1.5},
                }
            },

            -- Giga Blast
            {
                event = "SPELL_CAST_START",
                value = 469327,
                color = {73/255, 228/255, 242/255},
                show = true,
                entries = {
                    {60 * 5 + 20.0, 3},
                    {60 * 6 + 16.5, 3},
                    {60 * 7 +  0.1, 3},
                }
            },

            -- Mayhem Rockets
            {
                event = "SPELL_CAST_START",
                value = 1218696,
                color = {237/255, 76/255, 178/255},
                show = true,
                entries = {
                    {60 * 4 +  4.5, 5},
                    {60 * 4 + 10.5, 5},
                    {60 * 4 + 16.6, 5},
                    {60 * 4 + 22.6, 5},
                }
            },
        },

        desired_phase2_rotation2_start = 60 * 7 + 18.8, -- When first Circuit Reboot (1226891) aura_applied should be
        phase2_rotation2 = {
            -- Circuit Reboot
            {
                event = "SPELL_AURA_APPLIED",
                value = 1226891,
                show = false,
                entries = {
                    {60 * 7 +  18.8},
                }
            },

            -- Biggest Baddest Bomb Barrage
            {
                event = "SPELL_CAST_START",
                value = 1218546,
                color = {92/255, 189/255, 187/255},
                show = true,
                entries = {
                    {60 * 8 + 22.7, 3}
                }
            },

            -- Suppression
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467182,
                color = {237/255, 207/255, 107/255},
                show = true,
                entries = {
                }
            },

            -- Gallybux Finale Blast
            {
                event = "SPELL_CAST_START",
                value = 1219333,
                color = {237/255, 26/255, 68/255},
                show = true,
                entries = {
                }
            },

            -- Venting Heat
            {
                event = "SPELL_AURA_APPLIED",
                value = 466751,
                color = {245/255, 119/255, 22/255},
                show = true,
                entries = {
                    {60 * 8 + 13.2, 12},
                }
            },

            -- Scatterbomb Canisters
            {
                event = "SPELL_CAST_START",
                value = 1218488,
                color = {247/255, 61/255, 15/255},
                show = true,
                entries = {
                    {60 * 8 +  0.2, 3.5},
                    {60 * 8 + 37.2, 3.5}
                }
            },

            -- Ego Check
            {
                event = "SPELL_CAST_START",
                value = 466958,
                color = {122/255, 114/255, 102/255},
                show = true,
                entries = {
                    {60 * 8 + 15.7, 1.5},
                }
            },

            -- Giga Blast
            {
                event = "SPELL_CAST_START",
                value = 469327,
                color = {73/255, 228/255, 242/255},
                show = true,
                entries = {
                }
            },

            -- Mayhem Rockets
            {
                event = "SPELL_CAST_START",
                value = 1218696,
                color = {237/255, 76/255, 178/255},
                show = true,
                entries = {
                    {60 * 7 + 26.3, 5},
                    {60 * 7 + 32.3, 5},
                    {60 * 7 + 38.3, 5},
                    {60 * 7 + 44.3, 5},
                }
            },
        },

        -- Intermission + phase 1 events
        events = {
            -- Armageddon-class Plating
            {
                event = "SPELL_AURA_APPLIED",
                value = 1214229,
                color = {185/255, 140/255, 237/255},
                show = true,
                entries = {
                    {60 * 0 + 0.2, 27.7},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 1214229,
                show = false,
                entries = {
                    {60 * 0 + 27.9},
                }
            },

            -- TOTAL DESTRUCTION!!! (phase trigger)
            {
                event = "SPELL_AURA_REMOVED",
                value = 1214369,
                show = false,
                entries = {
                    {60 * 0 + 28.4},
                }
            },

            -- Giga Coils
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1224378,
                show = false,
                entries = {
                    {60 * 0 + 55.5},
                    {60 * 1 + 53.6},
                    {60 * 2 + 54.0},
                    {60 * 3 + 53.1},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 469293,
                color = {40/255, 122/255, 252/255},
                show = true,
                entries = {
                    {60 * 0 + 55.5, 3},
                    {60 * 1 + 53.6, 3},
                    {60 * 2 + 54.0, 3},
                    {60 * 3 + 53.1, 3},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 469293,
                show = false,
                entries = {
                    {60 * 0 + 58.5, 3},
                    {60 * 1 + 56.6, 3},
                    {60 * 2 + 57.0, 3},
                    {60 * 3 + 56.1, 3},
                }
            },

            -- Giga Blast (assume a single cast per Giga Coils)
            {
                event = "SPELL_CAST_START",
                value = 469327,
                color = {73/255, 228/255, 242/255},
                show = true,
                entries = {
                    {60 * 0 + 46.4, 3},
                    {60 * 1 + 42.5, 3},
                    {60 * 2 + 44.5, 3},
                    {60 * 3 + 37.0, 3},
                }
            },

            -- Bigger Badder Bomb Blast
            {
                event = "SPELL_CAST_START",
                value = 1214607,
                color = {92/255, 189/255, 187/255},
                show = true,
                entries = {
                    {60 * 0 + 36.4, 4},
                    {60 * 1 + 34.5, 4},
                    {60 * 2 + 32.0, 4},
                    {60 * 3 + 27.5, 4},
                }
            },

            -- Suppression
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467182,
                color = {237/255, 207/255, 107/255},
                show = true,
                entries = {
                    {60 * 1 + 13.0, 3},
                    {60 * 2 + 13.5, 3},
                    {60 * 3 + 17.9, 3},
                }
            },

            -- Gallybux Finale Blast
            {
                event = "SPELL_CAST_START",
                value = 1219333,
                color = {237/255, 26/255, 68/255},
                show = true,
                entries = {
                    {60 * 1 + 16.0, 1.5},
                    {60 * 2 + 16.5, 1.5},
                    {60 * 3 + 22.5, 1.5},
                }
            },

            -- Venting Heat
            {
                event = "SPELL_AURA_APPLIED",
                value = 466751,
                color = {245/255, 119/255, 22/255},
                show = true,
                entries = {
                    {60 * 1 +  9.0, 4},
                    {60 * 1 + 25.4, 5},
                    {60 * 1 + 49.1, 6},
                    {60 * 2 +  7.4, 7},
                    {60 * 2 + 29.5, 8},
                    {60 * 2 + 59.1, 9},
                    {60 * 3 + 11.1, 10},
                    {60 * 3 + 34.5, 11},
                }
            },

            -- Combination Canisters
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1217987,
                color = {120/255, 33/255, 219/255},
                show = true,
                entries = {
                    {60 * 0 + 59.4, 8},
                    {60 * 1 + 28.0, 8},
                    {60 * 1 + 59.6, 8},
                    {60 * 2 + 38.0, 8},
                    {60 * 3 +  3.6, 8},
                    {60 * 3 + 44.6, 8},
                }
            },

            -- Ego Check
            {
                event = "SPELL_CAST_START",
                value = 466958,
                color = {122/255, 114/255, 102/255},
                show = true,
                entries = {
                    {60 * 0 + 44.4, 1.5},
                    {60 * 1 +  6.0, 1.5},
                    {60 * 1 + 20.5, 1.5},
                    {60 * 1 + 40.5, 1.5},
                    {60 * 1 + 57.6, 1.5},
                    {60 * 2 + 10.0, 1.5},
                    {60 * 2 + 26.4, 1.5},
                    {60 * 2 + 50.0, 1.5},
                    {60 * 3 +  1.6, 1.5},
                    {60 * 3 + 25.5, 1.5},
                    {60 * 3 + 42.5, 1.5},
                }
            },
        }
    }

    -- Phase 2 rotation 1
    AddTimeToTimeline(mythic.phase2_rotation1, -mythic.phase2_rotation1[1].entries[1][1])
    AddTimeToTimeline(mythic.phase2_rotation1, mythic.desired_phase2_rotation1_start)
    MergeTimeline(mythic.phase2_rotation1, mythic.events)
    
    AddTimeToTimeline(mythic.phase2_rotation2, -mythic.phase2_rotation2[1].entries[1][1])
    AddTimeToTimeline(mythic.phase2_rotation2, mythic.desired_phase2_rotation2_start)
    MergeTimeline(mythic.phase2_rotation2, mythic.events)

    LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
    LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic
end