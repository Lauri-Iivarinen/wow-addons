local _, LRP = ...

if LRP.timelineData[1][2] then
    local instanceType = 1
    local instance = 2
    local encounter = 6

    local heroic = {
        phases = {
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 1,
                name = "Rotation 2",
                shortName = "R2"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 2,
                name = "Rotation 3",
                shortName = "R3"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 3,
                name = "Rotation 4",
                shortName = "R4"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 4,
                name = "Rotation 5",
                shortName = "R5"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 5,
                name = "Rotation 6",
                shortName = "R6"
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465765, -- Maintenance Cycle
                count = 1,
                name = "Phase 2",
                shortName = "P2"
            },
        },

        events = {
            -- Spin To Win!
            {
                event = "SPELL_CAST_START",
                value = 461060,
                show = false,
                entries = {
                    {60 * 0 + 20.5, 2},
                    {60 * 1 + 22.5, 2},
                    {60 * 2 + 24.6, 2},
                    {60 * 3 + 26.9, 2},
                    {60 * 4 + 28.9, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 461060,
                show = false,
                entries = {
                    {60 * 0 + 22.5},
                    {60 * 1 + 24.5},
                    {60 * 2 + 26.6},
                    {60 * 3 + 28.9},
                    {60 * 4 + 30.9},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 461060,
                color = {71/255, 204/255, 171/255},
                show = true,
                entries = {
                    {60 * 0 + 22.5, 25.2},
                    {60 * 1 + 24.5, 23.9},
                    {60 * 2 + 26.6, 25.8},
                    {60 * 3 + 28.9, 27.8},
                    {60 * 4 + 30.9, 24.4},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060,
                show = false,
                entries = {
                    {60 * 0 + 47.7},
                    {60 * 1 + 48.4},
                    {60 * 2 + 52.4},
                    {60 * 3 + 56.7},
                    {60 * 4 + 55.3},
                }
            },

            -- Pay-Line
            {
                event = "SPELL_CAST_START",
                value = 460181,
                color = {212/255, 148/255, 30/255},
                show = true,
                entries = {
                    {60 * 0 +  4.5, 1},
                    {60 * 0 + 59.4, 1},
                    {60 * 1 + 40.7, 1},
                    {60 * 1 + 55.8, 1},
                    {60 * 2 + 28.3, 1},
                    {60 * 2 + 58.9, 1},
                    {60 * 3 + 30.6, 1},
                    {60 * 4 +  3.4, 1},
                    {60 * 4 + 46.0, 1},
                    {60 * 5 +  1.9, 1},
                    {60 * 5 + 47.0, 1},
                    {60 * 6 + 23.5, 1},
                }
            },

            -- Foul Exhaust
            {
                event = "SPELL_CAST_START",
                value = 469993,
                color = {88/255, 29/255, 224/255},
                show = true,
                entries = {
                    {60 * 0 +  9.4, 2},
                    {60 * 0 + 41.2, 2},
                    {60 * 1 +  4.3, 2},
                    {60 * 1 + 35.1, 2},
                    {60 * 2 +  0.3, 2},
                    {60 * 2 + 33.2, 2},
                    {60 * 3 +  3.7, 2},
                    {60 * 3 + 35.4, 2},
                    {60 * 4 +  8.2, 2},
                    {60 * 4 + 39.9, 2},
                    {60 * 5 +  6.8, 2},
                    {60 * 5 + 40.9, 2},
                    {60 * 6 +  6.5, 2},
                    {60 * 6 + 36.9, 2},
                }
            },

            -- The Big Hit
            {
                event = "SPELL_CAST_START",
                value = 460472,
                color = {124/255, 119/255, 125/255},
                show = true,
                entries = {
                    {60 * 0 + 15.5, 2.5},
                    {60 * 0 + 34.8, 2.5},
                    {60 * 1 +  9.5, 2.5},
                    {60 * 1 + 29.0, 2.5},
                    {60 * 2 +  6.4, 2.5},
                    {60 * 2 + 39.3, 2.5},
                    {60 * 3 +  9.8, 2.5},
                    {60 * 3 + 41.5, 2.5},
                    {60 * 4 + 14.3, 2.5},
                    {60 * 4 + 33.8, 2.5},
                    {60 * 4 + 53.3, 2.5},
                    {60 * 5 + 12.9, 2.5},
                    {60 * 5 + 51.0, 2.5},
                    {60 * 6 + 12.6, 2.5},
                    {60 * 6 + 30.8, 2.5},
                    {60 * 6 + 49.1, 2.5},
                }
            },

            -- Cheat to Win!
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465309,
                show = false,
                entries = {
                    {60 * 5 + 36.0},
                    {60 * 6 +  1.6},
                    {60 * 6 + 26.0},
                    {60 * 6 + 52.3},
                }
            },

            -- Linked Machines
            {
                event = "SPELL_CAST_START",
                value = 465432,
                color = {75/255, 178/255, 219/255},
                show = true,
                entries = {
                    {60 * 5 + 36.3, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465432,
                show = false,
                entries = {
                    {60 * 5 + 39.3},
                }
            },

            -- Hot Hot Heat
            {
                event = "SPELL_CAST_START",
                value = 465322,
                color = {245/255, 128/255, 44/255},
                show = true,
                entries = {
                    {60 * 6 +  1.9, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465322,
                show = false,
                entries = {
                    {60 * 6 +  4.9},
                }
            },

            -- Scattered Payout
            {
                event = "SPELL_CAST_START",
                value = 465580,
                color = {217/255, 181/255, 52/255},
                show = true,
                entries = {
                    {60 * 6 + 26.2, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465580,
                show = false,
                entries = {
                    {60 * 6 + 29.2},
                }
            },

            -- Explosive Jackpot
            {
                event = "SPELL_CAST_START",
                value = 465587,
                color = {230/255, 54/255, 34/255},
                show = true,
                entries = {
                    {60 * 6 + 52.6, 10},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465587,
                show = false,
                entries = {
                    {60 * 7 +  2.6},
                }
            },

            -- Maintenance Cycle
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465765,
                show = false,
                entries = {
                    {60 * 5 + 25.8, 6},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 465765,
                show = false,
                entries = {
                    {60 * 5 + 25.8, 6},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 465765,
                show = false,
                entries = {
                    {60 * 5 + 31.8},
                }
            },
        }
    }

    local mythic = {
        phases = {
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 1,
                name = "Rotation 2",
                shortName = "R2"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 2,
                name = "Rotation 3",
                shortName = "R3"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 3,
                name = "Rotation 4",
                shortName = "R4"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 4,
                name = "Rotation 5",
                shortName = "R5"
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060, -- Spin To Win!
                count = 5,
                name = "Rotation 6",
                shortName = "R6"
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465765, -- Maintenance Cycle
                count = 1,
                name = "Phase 2",
                shortName = "P2"
            },
        },

        -- Rotation from first Spin To Win! buff dropping to the second one dropping
        interval = 52.3, -- Time between Spin To Win! applying
        rotation = {
            -- Spin To Win!
            {
                event = "SPELL_CAST_START",
                value = 461060,
                show = false,
                entries = {
                    {60 * 1 +  7.3, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 461060,
                show = false,
                entries = {
                    {60 * 1 +  9.3, 2},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 461060,
                color = {71/255, 204/255, 171/255},
                show = true,
                entries = {
                    {60 * 1 +  9.3, 30},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060,
                show = false,
                entries = {
                    {60 * 1 + 39.3},
                }
            },

            -- Pay-Line
            {
                event = "SPELL_CAST_START",
                value = 460181,
                color = {212/255, 148/255, 30/255},
                show = true,
                entries = {
                    {60 * 0 + 51.6, 1},
                    {60 * 1 + 18.3, 1},
                }
            },

            -- Foul Exhaust
            {
                event = "SPELL_CAST_START",
                value = 469993,
                color = {88/255, 29/255, 224/255},
                show = true,
                entries = {
                    {60 * 0 + 56.5, 2},
                    {60 * 1 + 29.2, 2},
                }
            },

            -- The Big Hit
            {
                event = "SPELL_CAST_START",
                value = 460472,
                color = {124/255, 119/255, 125/255},
                show = true,
                entries = {
                    {60 * 1 +  2.5, 2.5},
                    {60 * 1 + 23.2, 2.5},
                }
            },
        },

        -- Can be any log's P3 timers
        p3 = {
            -- Spin To Win!
            {
                event = "SPELL_CAST_START",
                value = 461060,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 461060,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 461060,
                color = {71/255, 204/255, 171/255},
                show = true,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060,
                show = false,
                entries = {
                }
            },

            -- Pay-Line
            {
                event = "SPELL_CAST_START",
                value = 460181,
                color = {212/255, 148/255, 30/255},
                show = true,
                entries = {
                    {60 * 5 + 34.4, 1},
                    {60 * 6 + 10.9, 1},
                }
            },

            -- Foul Exhaust
            {
                event = "SPELL_CAST_START",
                value = 469993,
                color = {88/255, 29/255, 224/255},
                show = true,
                entries = {
                    {60 * 5 + 28.7, 2},
                    {60 * 5 + 55.1, 2},
                    {60 * 6 + 25.9, 2},
                }
            },

            -- The Big Hit
            {
                event = "SPELL_CAST_START",
                value = 460472,
                color = {124/255, 119/255, 125/255},
                show = true,
                entries = {
                    {60 * 5 + 38.5, 2.5},
                    {60 * 6 +  1.6, 2.5},
                    {60 * 6 + 19.9, 2.5},
                }
            },
            
            -- Cheat to Win!
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465309,
                show = false,
                entries = {
                    {60 * 5 + 23.4},
                    {60 * 5 + 48.2},
                    {60 * 6 + 13.4},
                    {60 * 6 + 38.1},
                }
            },

            -- Linked Machines
            {
                event = "SPELL_CAST_START",
                value = 465432,
                color = {75/255, 178/255, 219/255},
                show = true,
                entries = {
                    {60 * 5 + 23.7, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465432,
                show = false,
                entries = {
                    {60 * 5 + 26.7},
                }
            },

            -- Hot Hot Heat
            {
                event = "SPELL_CAST_START",
                value = 465322,
                color = {245/255, 128/255, 44/255},
                show = true,
                entries = {
                    {60 * 5 + 48.5, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465322,
                show = false,
                entries = {
                    {60 * 5 + 51.5},
                }
            },

            -- Scattered Payout
            {
                event = "SPELL_CAST_START",
                value = 465580,
                color = {217/255, 181/255, 52/255},
                show = true,
                entries = {
                    {60 * 6 + 13.6, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465580,
                show = false,
                entries = {
                    {60 * 6 + 16.7},
                }
            },

            -- Explosive Jackpot
            {
                event = "SPELL_CAST_START",
                value = 465587,
                color = {230/255, 54/255, 34/255},
                show = true,
                entries = {
                    {60 * 6 + 38.4, 10},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465587,
                show = false,
                entries = {
                    {60 * 6 + 48.4},
                }
            },

            -- Maintenance Cycle
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465765,
                show = false,
                entries = {
                    {60 * 5 +  9.8}
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 465765,
                show = false,
                entries = {
                    {60 * 5 +  9.8, 6}
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 465765,
                show = false,
                entries = {
                    {60 * 5 + 15.8}
                }
            },

            -- Rig the Game!
            {
                event = "SPELL_CAST_START",
                value = 465761,
                show = false,
                entries = {
                    {60 * 5 + 16.8, 4}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 465761,
                show = false,
                entries = {
                    {60 * 5 + 20.8}
                }
            },
        },

        -- Should only include the very first rotation (until the first Spin To Win! drops)
        -- And the P3 events
        events = {
            -- Spin To Win!
            {
                event = "SPELL_CAST_START",
                value = 461060,
                show = false,
                entries = {
                    {60 * 0 + 15.0, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 461060,
                show = false,
                entries = {
                    {60 * 0 + 17.0, 2},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 461060,
                color = {71/255, 204/255, 171/255},
                show = true,
                entries = {
                    {60 * 0 + 17.0, 30},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 461060,
                show = false,
                entries = {
                    {60 * 0 + 47.0},
                }
            },

            -- Pay-Line
            {
                event = "SPELL_CAST_START",
                value = 460181,
                color = {212/255, 148/255, 30/255},
                show = true,
                entries = {
                    {60 * 0 +  4.0, 1},
                    {60 * 0 + 30.8, 1},
                }
            },

            -- Foul Exhaust
            {
                event = "SPELL_CAST_START",
                value = 469993,
                color = {88/255, 29/255, 224/255},
                show = true,
                entries = {
                    {60 * 0 +  8.9, 2},
                    {60 * 0 + 43.0, 2},
                }
            },

            -- The Big Hit
            {
                event = "SPELL_CAST_START",
                value = 460472,
                color = {124/255, 119/255, 125/255},
                show = true,
                entries = {
                    {60 * 0 + 18.6, 2.5},
                    {60 * 0 + 36.9, 2.5},
                }
            },
        }
    }

    -- Add p1 cycles
    for i = 1, 5 do
        local rotation = CopyTable(mythic.rotation)
        local offset = (i - 1) * mythic.interval

        -- Add offset to all entries
        for _, eventInfo in ipairs(rotation) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] + offset
            end
        end

        -- Add events to rotation table
        for j, eventInfo in ipairs(rotation) do
            tAppendAll(
                mythic.events[j].entries,
                eventInfo.entries
            )
        end
    end

    -- Find p3 start time from log
    local logPhaseStart -- Phase 3 start in the log we used

    for _, eventInfo in ipairs(mythic.p3) do
        if eventInfo.event == "SPELL_CAST_SUCCESS" and eventInfo.value == 465765 then -- Maintenance Cycle
            logPhaseStart = eventInfo.entries[1][1]
        end
    end

    -- Find when p3 should start (1 second before 6th Spin To Win! ends)
    local phaseThreeStart

    for _, eventInfo in ipairs(mythic.events) do
        if eventInfo.event == "SPELL_AURA_APPLIED" and eventInfo.value == 461060 then -- Spin To Win!
            eventInfo.entries[6][2] = eventInfo.entries[6][2] - 1
        end

        if eventInfo.event == "SPELL_AURA_REMOVED" and eventInfo.value == 461060 then -- Spin To Win!
            eventInfo.entries[6][1] = eventInfo.entries[6][1] - 1

            phaseThreeStart = eventInfo.entries[6][1]
        end
    end

    -- Subtract p3 start time from all p3 entries
    -- Add the desired phase start
    for _, eventInfo in ipairs(mythic.p3) do
        for _, entry in ipairs(eventInfo.entries) do
            entry[1] = entry[1] - logPhaseStart
            entry[1] = entry[1] + phaseThreeStart
        end
    end
    
    -- Add P3 entries to events table
    for i, eventInfo in ipairs(mythic.p3) do
        if mythic.events[i] then
            tAppendAll(
                mythic.events[i].entries,
                eventInfo.entries
            )
        else
            table.insert(
                mythic.events,
                eventInfo
            )
        end
    end

    LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
    LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic
end