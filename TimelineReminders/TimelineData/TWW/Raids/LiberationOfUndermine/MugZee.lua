local _, LRP = ...

if LRP.timelineData[1][2] then
    local instanceType = 1
    local instance = 2
    local encounter = 7

    local heroic = {
        -- Any P1 Mug rotation (first or second doesn't matter)
        -- The Mug Taking Charge start time is subtracted from all events
        mug = {
            -- Mug Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468728,
                show = false,
                entries = {
                    {60 * 2 + 14.5},
                }
            },

            -- Head Honcho: Mug
            {
                event = "SPELL_AURA_APPLIED",
                value = 466459,
                show = false,
                entries = {
                    {60 * 2 + 14.5},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466459,
                show = false,
                entries = {
                    -- This is set based on interval time
                }
            },

            -- Elemental Carnage
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468658,
                show = false,
                entries = {
                    {60 * 2 + 14.5},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468658,
                color = {46/255, 240/255, 143/255},
                show = true,
                entries = {
                    {60 * 2 + 14.5, 6},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468658,
                show = false,
                entries = {
                    {60 * 2 + 20.5},
                }
            },

            -- Earthshaker Gaol
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472631,
                color = {201/255, 151/255, 50/255},
                show = true,
                entries = {
                    {60 * 2 + 28.4, 6},
                }
            },
            {
                event = "SPELL_CAST_START",
                value = 474461,
                show = false,
                entries = {
                    {60 * 2 + 31.9, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 474461,
                show = false,
                entries = {
                    {60 * 2 + 24.4},
                }
            },

            -- Frostshatter Boots
            {
                event = "SPELL_CAST_START",
                value = 466470,
                show = false,
                entries = {
                    {60 * 2 + 57.3, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466470,
                show = false,
                entries = {
                    {60 * 2 + 59.3},
                }
            },
            { -- Actual cast event has no tooltip
                value = 466476,
                color = {110/255, 225/255, 240/255},
                show = true,
                entries = {
                    {60 * 2 + 59.3, 8},
                }
            },
            
            -- Stormfury Finger Gun
            {
                event = "SPELL_CAST_START",
                value = 466509,
                show = false,
                entries = {
                    {60 * 3 +  9.5, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466509,
                color = {56/255, 99/255, 242/255},
                show = true,
                entries = {
                    {60 * 3 + 12.5, 4},
                }
            },

            -- Molten Gold Knuckles
            {
                event = "SPELL_CAST_START",
                value = 466518,
                color = {247/255, 234/255, 92/255},
                show = true,
                entries = {
                    {60 * 2 + 45.1, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466518,
                show = false,
                entries = {
                    {60 * 2 + 47.6},
                }
            },
        },

        -- Any P1 Zee rotation (first or second doesn't matter)
        -- The Zee Taking Charge start time is subtracted from all events
        zee = {
            -- Zee Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468794,
                show = false,
                entries = {
                    {60 * 1 +  8.0},
                }
            },

            -- Head Honcho: Zee
            {
                event = "SPELL_AURA_APPLIED",
                value = 466460,
                show = false,
                entries = {
                    {60 * 1 +  8.0},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466460,
                show = false,
                entries = {
                    -- This is set based on interval
                }
            },

            -- Uncontrolled Destruction
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468694,
                show = false,
                entries = {
                    {60 * 1 + 8.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468694,
                color = {237/255, 26/255, 75/255},
                show = true,
                entries = {
                    {60 * 1 +  8.0, 6},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468694,
                show = false,
                entries = {
                    {60 * 1 + 14.0},
                }
            },

            -- Unstable Crawler Mines
            {
                event = "SPELL_CAST_START",
                value = 472458,
                show = false,
                entries = {
                    {60 * 1 + 21.9, 1.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472458,
                show = false,
                entries = {
                    {60 * 1 + 23.4},
                }
            },
            { -- The actual cast doesn't have a tooltip
                value = 466539,
                color = {108/255, 117/255, 108/255},
                show = true,
                entries = {
                    {60 * 1 + 21.9, 4},
                }
            },

            -- Goblin-guided Rocket
            {
                event = "SPELL_CAST_START",
                value = 467379,
                show = false,
                entries = {
                    {60 * 1 + 38.6, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467379,
                show = false,
                entries = {
                    {60 * 1 + 40.6},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 467380,
                color = {242/255, 210/255, 65/255},
                show = true,
                entries = {
                    {60 * 1 + 40.6, 8},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 467380,
                show = false,
                entries = {
                    {60 * 1 + 48.6},
                }
            },

            -- Spray and Pray
            {
                event = "SPELL_CAST_START",
                value = 466545,
                show = false,
                entries = {
                    {60 * 2 +  3.0, 3.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466545,
                color = {148/255, 39/255, 22/255},
                show = true,
                entries = {
                    {60 * 2 +  6.5, 3},
                }
            },

            -- Double Whammy Shot
            {
                event = "SPELL_CAST_START",
                value = 1223085,
                color = {245/255, 80/255, 20/255},
                show = true,
                entries = {
                    {60 * 1 + 54.3, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223085,
                show = false,
                entries = {
                    {60 * 1 + 56.8},
                }
            },
        },

        intermissionStartTime = 60 * 4 + 19.6, -- Time of the last Head Honcho: Mug/Zee falling off
        intermissionEndTime = 60 * 5 + 2.6, -- Time of Head Honcho: Mug'Zee application
        intermission = {
            -- Static Charge
            {
                event = "SPELL_CAST_START",
                value = 1215953,
                color = {142/255, 179/255, 70/255},
                show = true,
                entries = {
                    {60 * 4 + 21.6, 3},
                    {60 * 4 + 35.9, 3},
                    {60 * 4 + 50.0, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1215953,
                show = false,
                entries = {
                    {60 * 4 + 24.6},
                    {60 * 4 + 38.9},
                    {60 * 4 + 53.0},
                }
            },
    
            -- Bulletstorm
            {
                event = "SPELL_CAST_SUCCESS",
                value = 471419,
                color = {235/255, 87/255, 210/255},
                show = true,
                entries = {
                    {60 * 4 + 25.3, 8},
                    {60 * 4 + 39.5, 8},
                    {60 * 4 + 53.5, 8},
                }
            },
        },

        -- Phase 3
        -- Start time is equal to end of p1 + intermissionDuration
        -- The indices for abilities correspond to those in Mug's/Zee's phase 1 tables
        logP3StartTime = 60 * 5 + 1.5, -- Head Honcho: Mug'Zee application time from log
        fightTime = 60 * 7 + 14, -- Fight time from log

        mugP3 = {
            -- Mug Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468728,
                show = false,
                entries = {
                }
            },
    
            -- Head Honcho: Mug
            {
                event = "SPELL_AURA_APPLIED",
                value = 466459,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466459,
                show = false,
                entries = {
                }
            },
    
            -- Elemental Carnage
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468658,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468658,
                color = {46/255, 240/255, 143/255},
                show = true,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468658,
                show = false,
                entries = {
                }
            },
    
            -- Earthshaker Gaol
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472631,
                color = {201/255, 151/255, 50/255},
                show = true,
                entries = {
                    {60 * 5 + 32.8, 6},
                }
            },
            {
                event = "SPELL_CAST_START",
                value = 474461,
                show = false,
                entries = {
                    {60 * 5 + 36.9, 1.92},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 474461,
                show = false,
                entries = {
                    {60 * 5 + 38.8},
                }
            },
    
            -- Frostshatter Boots
            {
                event = "SPELL_CAST_START",
                value = 466470,
                show = false,
                entries = {
                    {60 * 5 + 20.3, 1.5},
                    {60 * 6 + 46.5, 1.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466470,
                show = false,
                entries = {
                    {60 * 5 + 21.8},
                    {60 * 6 + 48.1},
                }
            },
            { -- Actual cast event has no tooltip
                value = 466476,
                color = {110/255, 225/255, 240/255},
                show = true,
                entries = {
                    {60 * 5 + 21.8, 8},
                    {60 * 6 + 48.1, 8},
                }
            },
            
            -- Stormfury Finger Gun
            {
                event = "SPELL_CAST_START",
                value = 466509,
                show = false,
                entries = {
                    {60 * 6 +  6.5, 2.3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466509,
                color = {56/255, 99/255, 242/255},
                show = true,
                entries = {
                    {60 * 6 +  8.8, 4},
                }
            },
    
            -- Molten Gold Knuckles
            {
                event = "SPELL_CAST_START",
                value = 466518,
                color = {247/255, 234/255, 92/255},
                show = true,
                entries = {
                    {60 * 5 + 54.0, 1.94},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466518,
                show = false,
                entries = {
                    {60 * 5 + 56.0},
                }
            },
        },
    
        zeeP3 = {
            -- Zee Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468794,
                show = false,
                entries = {
                }
            },
    
            -- Head Honcho: Zee
            {
                event = "SPELL_AURA_APPLIED",
                value = 466460,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466460,
                show = false,
                entries = {
                }
            },
    
            -- Uncontrolled Destruction
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468694,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468694,
                color = {237/255, 26/255, 75/255},
                show = true,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468694,
                show = false,
                entries = {
                }
            },
    
            -- Unstable Crawler Mines
            {
                event = "SPELL_CAST_START",
                value = 472458,
                show = false,
                entries = {
                    {60 * 5 +  7.8, 1.18},
                    {60 * 6 + 36.5, 1.18},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472458,
                show = false,
                entries = {
                    {60 * 5 +  9.0},
                    {60 * 6 + 37.7},
                }
            },
            { -- The actual cast doesn't have a tooltip
                value = 466539,
                color = {108/255, 117/255, 108/255},
                show = true,
                entries = {
                    {60 * 5 +  7.8, 4},
                    {60 * 6 + 36.5, 4},
                }
            },
    
            -- Goblin-guided Rocket
            {
                event = "SPELL_CAST_START",
                value = 467379,
                show = false,
                entries = {
                    {60 * 5 + 42.7, 1.56},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467379,
                show = false,
                entries = {
                    {60 * 5 + 44.3},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 467380,
                color = {242/255, 210/255, 65/255},
                show = true,
                entries = {
                    {60 * 5 + 44.3, 8},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 467380,
                show = false,
                entries = {
                    {60 * 5 + 52.3},
                }
            },
    
            -- Spray and Pray
            {
                event = "SPELL_CAST_START",
                value = 466545,
                show = false,
                entries = {
                    {60 * 6 + 25.3, 2.71},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466545,
                color = {148/255, 39/255, 22/255},
                show = true,
                entries = {
                    {60 * 6 + 28.0, 3},
                }
            },
    
            -- Double Whammy Shot
            {
                event = "SPELL_CAST_START",
                value = 1223085,
                color = {245/255, 80/255, 20/255},
                show = true,
                entries = {
                    {60 * 6 + 19.3, 1.93},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223085,
                show = false,
                entries = {
                    {60 * 6 + 21.3},
                }
            },
        },

        phases = {
        },

        events = {
        }
    }
    
    do
        -- Configuration variables
        local mugFirst = true
        local repeatCount = 4 -- Number of P1 phases we do (should be at least 2)
        local interval = 65 -- Duration of each phase 1 Mug/Zee phase

        -- Calculate number of Mug and Zee phases
        local mugPhaseCount = mugFirst and math.ceil(repeatCount / 2) or math.floor(repeatCount / 2)
        local zeePhaseCount = not mugFirst and math.ceil(repeatCount / 2) or math.floor(repeatCount / 2)

        -- Subtract Mug start time from all the Mug events
        -- Set Head Honcho: Mug end time equal to interval
        local mugStartTime = heroic.mug[1].entries[1][1]

        for _, eventInfo in ipairs(heroic.mug) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - mugStartTime + (mugFirst and 0 or interval)
            end
        end
        
        heroic.mug[2].entries[1][2] = interval + (mugFirst and 0 or interval)
        heroic.mug[3].entries[1] = {interval + (mugFirst and 0 or interval)}

        -- Subtract Zee start time from all the Zee entries
        -- Set Head Honcho: Zee end time equal to interval
        local zeeStartTime = heroic.zee[1].entries[1][1]

        for _, eventInfo in ipairs(heroic.zee) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - zeeStartTime + (not mugFirst and 0 or interval)
            end
        end

        heroic.zee[2].entries[1][2] = interval + (not mugFirst and 0 or interval)
        heroic.zee[3].entries[1] = {interval + (not mugFirst and 0 or interval)}

        -- Repeat Mug phase 1 events
        for _, eventInfo in ipairs(heroic.mug) do
            local entries = eventInfo.entries
            local entryCount = entries and #entries or 0

            for i = 1, mugPhaseCount - 1 do
                -- Add events
                for j = 1, entryCount do
                    local entry = entries[j]
                    
                    table.insert(
                        entries,
                        {entry[1] + i * 2 * interval, entry[2]}
                    )
                end
            end
        end

        -- Repeat Zee phase 1 events
        for _, eventInfo in ipairs(heroic.zee) do
            local entries = eventInfo.entries
            local entryCount = entries and #entries or 0

            for i = 1, zeePhaseCount - 1 do
                for j = 1, entryCount do
                    local entry = entries[j]
                    
                    table.insert(
                        entries,
                        {entry[1] + i * 2 * interval, entry[2]}
                    )
                end
            end
        end

        -- Add Mug phases
        for i = 1, mugPhaseCount - (mugFirst and 1 or 0) do
            table.insert(
                heroic.phases,
                {
                    event = "SPELL_AURA_APPLIED",
                    value = 468658, -- Elemental Carnage
                    count = i + (mugFirst and 1 or 0),
                    name = string.format("Mug %d", i + (mugFirst and 1 or 0)),
                    shortName = string.format("Mug %d", i + (mugFirst and 1 or 0))
                }
            )
        end

        -- Add Zee phases
        for i = 1, zeePhaseCount - (not mugFirst and 1 or 0) do
            table.insert(
                heroic.phases,
                {
                    event = "SPELL_AURA_APPLIED",
                    value = 468694, -- Uncontrolled Destruction
                    count = i + (not mugFirst and 1 or 0),
                    name = string.format("Zee %d", i + (not mugFirst and 1 or 0)),
                    shortName = string.format("Zee %d", i + (not mugFirst and 1 or 0))
                }
            )
        end

        -- Remove the first Head Honcho SPELL_AURA_APPLIED from the fight (this one happens before the pull)
        for _, eventInfo in ipairs(heroic.events) do
            if eventInfo.event == "SPELL_AURA_APPLIED" and eventInfo.value == (mugFirst and 466459 or 466460) then
                table.remove(eventInfo.entries, 1)

                break
            end
        end

        -- Add intermission phase change
        local mugLast = mugFirst and repeatCount % 2 == 1 or not mugFirst and repeatCount % 2 == 0

        table.insert(
            heroic.phases,
            {
                event = "SPELL_AURA_REMOVED",
                value = mugLast and 466459 or 466460, -- Head Honcho: Mug/Zee
                count = mugLast and mugPhaseCount or zeePhaseCount,
                name = "Intermission",
                shortName = "Int"
            }
        )

        -- Subtract intermission start time from all intermission events
        -- Add calculated intermission start time (from number of P1 phases we play)
        for _, eventInfo in ipairs(heroic.intermission) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - heroic.intermissionStartTime + repeatCount * interval
            end
        end

        tAppendAll(heroic.events, heroic.mug)
        tAppendAll(heroic.events, heroic.zee)
        tAppendAll(heroic.events, heroic.intermission)

        -- Adjust p3 timers to fit our fight length
        local intermissionDuration = heroic.intermissionEndTime - heroic.intermissionStartTime
        local p3StartTime = repeatCount * interval + intermissionDuration

        for _, eventInfo in ipairs(heroic.zeeP3) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - heroic.logP3StartTime + p3StartTime
            end
        end

        for _, eventInfo in ipairs(heroic.mugP3) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - heroic.logP3StartTime + p3StartTime
            end
        end

        -- Merge p3 timers
        for i, eventInfo in ipairs(heroic.zeeP3) do
            for _, entry in ipairs(eventInfo.entries) do
                table.insert(heroic.zee[i].entries, entry)
            end
        end

        for i, eventInfo in ipairs(heroic.mugP3) do
            for _, entry in ipairs(eventInfo.entries) do
                table.insert(heroic.mug[i].entries, entry)
            end
        end

        -- Add Head Honcho: Mug'Zee event
        table.insert(
            heroic.events,
            {
                event = "SPELL_AURA_APPLIED",
                value = 1222408,
                show = false,
                entries = {
                    {p3StartTime, heroic.fightTime - p3StartTime}
                }
            }
        )

        -- Add phase 2 change
        table.insert(
            heroic.phases,
            {
                event = "SPELL_AURA_APPLIED",
                value = 1222408, -- Head Honcho: Mug'Zee
                count = 1,
                name = "Phase 2",
                shortName = "P2"
            }
        )
    end

    local mythic = {
        -- Any P1 Mug rotation (first or second doesn't matter)
        -- The Mug Taking Charge start time is subtracted from all events
        mug = {
            -- Mug Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468728,
                show = false,
                entries = {
                    {60 * 1 +  0.0},
                }
            },

            -- Head Honcho: Mug
            {
                event = "SPELL_AURA_APPLIED",
                value = 466459,
                show = false,
                entries = {
                    {60 * 1 +  0.0},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466459,
                show = false,
                entries = {
                    -- This is set based on interval time
                }
            },

            -- Elemental Carnage
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468658,
                show = false,
                entries = {
                    {60 * 1 + 0.0},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468658,
                color = {46/255, 240/255, 143/255},
                show = true,
                entries = {
                    {60 * 1 +  0.0, 6},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468658,
                show = false,
                entries = {
                    {60 * 1 +  6.0},
                }
            },

            -- Earthshaker Gaol
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472631,
                color = {201/255, 151/255, 50/255},
                show = true,
                entries = {
                    {60 * 1 + 13.9, 6},
                }
            },
            {
                event = "SPELL_CAST_START",
                value = 474461,
                show = false,
                entries = {
                    {60 * 1 + 17.4, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 474461,
                show = false,
                entries = {
                    {60 * 1 + 19.9},
                }
            },

            -- Frostshatter Boots
            {
                event = "SPELL_CAST_START",
                value = 466470,
                show = false,
                entries = {
                    {60 * 1 + 34.7, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466470,
                show = false,
                entries = {
                    {60 * 1 + 36.7},
                }
            },
            { -- Actual cast event has no tooltip
                value = 466476,
                color = {110/255, 225/255, 240/255},
                show = true,
                entries = {
                    {60 * 1 + 36.7, 8},
                }
            },
            
            -- Stormfury Finger Gun
            {
                event = "SPELL_CAST_START",
                value = 466509,
                show = false,
                entries = {
                    {60 * 1 + 50.0, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466509,
                color = {56/255, 99/255, 242/255},
                show = true,
                entries = {
                    {60 * 1 + 53.0, 4},
                }
            },

            -- Molten Gold Knuckles
            {
                event = "SPELL_CAST_START",
                value = 466518,
                color = {247/255, 234/255, 92/255},
                show = true,
                entries = {
                    {60 * 1 + 27.8, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466518,
                show = false,
                entries = {
                    {60 * 1 + 30.3},
                }
            },
        },

        -- Any P1 Zee rotation (first or second doesn't matter)
        -- The Zee Taking Charge start time is subtracted from all events
        zee = {
            -- Zee Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468794,
                show = false,
                entries = {
                    {60 * 2 +  0.5},
                }
            },

            -- Head Honcho: Zee
            {
                event = "SPELL_AURA_APPLIED",
                value = 466460,
                show = false,
                entries = {
                    {60 * 2 +  0.5},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466460,
                show = false,
                entries = {
                    -- This is set based on interval
                }
            },

            -- Uncontrolled Destruction
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468694,
                show = false,
                entries = {
                    {60 * 2 +  0.5},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468694,
                color = {237/255, 26/255, 75/255},
                show = true,
                entries = {
                    {60 * 2 +  0.5, 6},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468694,
                show = false,
                entries = {
                    {60 * 2 +  6.5},
                }
            },

            -- Unstable Crawler Mines
            {
                event = "SPELL_CAST_START",
                value = 472458,
                show = false,
                entries = {
                    {60 * 2 + 14.4, 1.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472458,
                show = false,
                entries = {
                    {60 * 2 + 15.9},
                }
            },
            { -- The actual cast doesn't have a tooltip
                value = 466539,
                color = {108/255, 117/255, 108/255},
                show = true,
                entries = {
                    {60 * 2 + 14.4, 4},
                }
            },

            -- Goblin-guided Rocket
            {
                event = "SPELL_CAST_START",
                value = 467379,
                show = false,
                entries = {
                    {60 * 2 + 28.3, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467379,
                show = false,
                entries = {
                    {60 * 2 + 30.3},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 467380,
                color = {242/255, 210/255, 65/255},
                show = true,
                entries = {
                    {60 * 2 + 30.3, 8},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 467380,
                show = false,
                entries = {
                    {60 * 2 + 38.3},
                }
            },

            -- Spray and Pray
            {
                event = "SPELL_CAST_START",
                value = 466545,
                show = false,
                entries = {
                    {60 * 2 + 50.5, 3.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466545,
                color = {148/255, 39/255, 22/255},
                show = true,
                entries = {
                    {60 * 2 + 54.0, 3},
                }
            },

            -- Double Whammy Shot
            {
                event = "SPELL_CAST_START",
                value = 1223085,
                color = {245/255, 80/255, 20/255},
                show = true,
                entries = {
                    {60 * 2 + 42.9, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223085,
                show = false,
                entries = {
                    {60 * 2 + 45.4},
                }
            },
        },

        intermissionStartTime = 60 * 5 + 2.5, -- Time of the last Head Honcho: Mug/Zee falling off
        intermissionEndTime = 60 * 5 + 54.7, -- Head Honcho: Mug'Zee application
        intermission = {
            -- Static Charge
            {
                event = "SPELL_CAST_START",
                value = 1215953,
                color = {142/255, 179/255, 70/255},
                show = true,
                entries = {
                    {60 * 5 + 14.9, 3},
                    {60 * 5 + 28.9, 3},
                    {60 * 5 + 42.9, 3},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1215953,
                show = false,
                entries = {
                    {60 * 5 + 17.9},
                    {60 * 5 + 31.9},
                    {60 * 5 + 45.9},
                }
            },
    
            -- Bulletstorm
            {
                event = "SPELL_CAST_SUCCESS",
                value = 471419,
                color = {235/255, 87/255, 210/255},
                show = true,
                entries = {
                    {60 * 5 + 18.4, 8},
                    {60 * 5 + 32.4, 8},
                    {60 * 5 + 46.7, 8},
                }
            },
        },

        -- Phase 3
        -- Start time is equal to end of p1 + intermissionDuration
        -- The indices for abilities correspond to those in Mug's/Zee's phase 1 tables
        logP3StartTime = 60 * 5 + 56.8, -- Head Honcho: Mug'Zee application time from log
        fightTime = 60 * 8 + 20, -- Fight time from log

        mugP3 = {
            -- Mug Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468728,
                show = false,
                entries = {
                }
            },
    
            -- Head Honcho: Mug
            {
                event = "SPELL_AURA_APPLIED",
                value = 466459,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466459,
                show = false,
                entries = {
                }
            },
    
            -- Elemental Carnage
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468658,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468658,
                color = {46/255, 240/255, 143/255},
                show = true,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468658,
                show = false,
                entries = {
                }
            },
    
            -- Earthshaker Gaol
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472631,
                color = {201/255, 151/255, 50/255},
                show = true,
                entries = {
                    {60 * 6 + 28.1, 6}
                }
            },
            {
                event = "SPELL_CAST_START",
                value = 474461,
                show = false,
                entries = {
                    {60 * 6 + 31.6}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 474461,
                show = false,
                entries = {
                    {60 * 6 + 34.1}
                }
            },
    
            -- Frostshatter Boots
            {
                event = "SPELL_CAST_START",
                value = 466470,
                show = false,
                entries = {
                    {60 * 6 + 15.6, 2},
                    {60 * 7 + 41.8, 2}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466470,
                show = false,
                entries = {
                    {60 * 6 + 19.6},
                    {60 * 7 + 43.4},
                }
            },
            { -- Actual cast event has no tooltip
                value = 466476,
                color = {110/255, 225/255, 240/255},
                show = true,
                entries = {
                    {60 * 6 + 19.6, 8},
                    {60 * 7 + 43.4, 8}
                }
            },
            
            -- Stormfury Finger Gun
            {
                event = "SPELL_CAST_START",
                value = 466509,
                show = false,
                entries = {
                    {60 * 7 + 1.8}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466509,
                color = {56/255, 99/255, 242/255},
                show = true,
                entries = {
                    {60 * 7 + 4.8, 4}
                }
            },
    
            -- Molten Gold Knuckles
            {
                event = "SPELL_CAST_START",
                value = 466518,
                color = {247/255, 234/255, 92/255},
                show = true,
                entries = {
                    {60 * 6 + 49.3, 2.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466518,
                show = false,
                entries = {
                    {60 * 6 + 51.8},
                }
            },
        },
    
        zeeP3 = {
            -- Zee Taking Charge
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468794,
                show = false,
                entries = {
                }
            },
    
            -- Head Honcho: Zee
            {
                event = "SPELL_AURA_APPLIED",
                value = 466460,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 466460,
                show = false,
                entries = {
                }
            },
    
            -- Uncontrolled Destruction
            {
                event = "SPELL_CAST_SUCCESS",
                value = 468694,
                show = false,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 468694,
                color = {237/255, 26/255, 75/255},
                show = true,
                entries = {
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 468694,
                show = false,
                entries = {
                }
            },
    
            -- Unstable Crawler Mines
            {
                event = "SPELL_CAST_START",
                value = 472458,
                show = false,
                entries = {
                    {60 * 6 +  3.1, 1.5},
                    {60 * 7 + 31.8, 1.5},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 472458,
                show = false,
                entries = {
                    {60 * 6 +  4.6},
                    {60 * 7 + 33.3},
                }
            },
            { -- The actual cast doesn't have a tooltip
                value = 466539,
                color = {108/255, 117/255, 108/255},
                show = true,
                entries = {
                    {60 * 6 +  3.1, 4},
                    {60 * 7 + 31.8, 4},
                }
            },
    
            -- Goblin-guided Rocket
            {
                event = "SPELL_CAST_START",
                value = 467379,
                show = false,
                entries = {
                    {60 * 6 + 38.1, 2},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 467379,
                show = false,
                entries = {
                    {60 * 6 + 40.1},
                }
            },
            {
                event = "SPELL_AURA_APPLIED",
                value = 467380,
                color = {242/255, 210/255, 65/255},
                show = true,
                entries = {
                    {60 * 6 + 40.1, 8},
                }
            },
            {
                event = "SPELL_AURA_REMOVED",
                value = 467380,
                show = false,
                entries = {
                    {60 * 6 + 48.1},
                }
            },
    
            -- Spray and Pray
            {
                event = "SPELL_CAST_START",
                value = 466545,
                show = false,
                entries = {
                    {60 * 7 + 20.6},
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 466545,
                color = {148/255, 39/255, 22/255},
                show = true,
                entries = {
                    {60 * 7 + 24.1, 3},
                }
            },
    
            -- Double Whammy Shot
            {
                event = "SPELL_CAST_START",
                value = 1223085,
                color = {245/255, 80/255, 20/255},
                show = true,
                entries = {
                    {60 * 7 + 13.3, 2.5}
                }
            },
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1223085,
                show = false,
                entries = {
                    {60 * 7 + 15,8}
                }
            },
        },

        phases = {
        },

        events = {
        }
    }

    do
        -- Configuration variables
        local mugFirst = false
        local repeatCount = 5 -- Number of P1 phases we do (should be at least 2)
        local interval = 60 -- Duration of each phase 1 Mug/Zee phase

        -- Calculate number of Mug and Zee phases
        local mugPhaseCount = mugFirst and math.ceil(repeatCount / 2) or math.floor(repeatCount / 2)
        local zeePhaseCount = not mugFirst and math.ceil(repeatCount / 2) or math.floor(repeatCount / 2)

        -- Subtract Mug start time from all the Mug events
        -- Set Head Honcho: Mug end time equal to interval
        local mugStartTime = mythic.mug[1].entries[1][1]

        for _, eventInfo in ipairs(mythic.mug) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - mugStartTime + (mugFirst and 0 or interval)
            end
        end
        
        mythic.mug[2].entries[1][2] = interval + (mugFirst and 0 or interval)
        mythic.mug[3].entries[1] = {interval + (mugFirst and 0 or interval)}

        -- Subtract Zee start time from all the Zee entries
        -- Set Head Honcho: Zee end time equal to interval
        local zeeStartTime = mythic.zee[1].entries[1][1]

        for _, eventInfo in ipairs(mythic.zee) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - zeeStartTime + (not mugFirst and 0 or interval)
            end
        end

        mythic.zee[2].entries[1][2] = interval + (not mugFirst and 0 or interval)
        mythic.zee[3].entries[1] = {interval + (not mugFirst and 0 or interval)}

        -- Repeat Mug phase 1 events
        for _, eventInfo in ipairs(mythic.mug) do
            local entries = eventInfo.entries
            local entryCount = entries and #entries or 0

            for i = 1, mugPhaseCount - 1 do
                -- Add events
                for j = 1, entryCount do
                    local entry = entries[j]
                    
                    table.insert(
                        entries,
                        {entry[1] + i * 2 * interval, entry[2]}
                    )
                end
            end
        end

        -- Repeat Zee phase 1 events
        for _, eventInfo in ipairs(mythic.zee) do
            local entries = eventInfo.entries
            local entryCount = entries and #entries or 0

            for i = 1, zeePhaseCount - 1 do
                for j = 1, entryCount do
                    local entry = entries[j]
                    
                    table.insert(
                        entries,
                        {entry[1] + i * 2 * interval, entry[2]}
                    )
                end
            end
        end

        -- Add Mug phases
        for i = 1, mugPhaseCount - (mugFirst and 1 or 0) do
            table.insert(
                mythic.phases,
                {
                    event = "SPELL_AURA_APPLIED",
                    value = 468658, -- Elemental Carnage
                    count = i + (mugFirst and 1 or 0),
                    name = string.format("Mug %d", i + (mugFirst and 1 or 0)),
                    shortName = string.format("Mug %d", i + (mugFirst and 1 or 0))
                }
            )
        end

        -- Add Zee phases
        for i = 1, zeePhaseCount - (not mugFirst and 1 or 0) do
            table.insert(
                mythic.phases,
                {
                    event = "SPELL_AURA_APPLIED",
                    value = 468694, -- Uncontrolled Destruction
                    count = i + (not mugFirst and 1 or 0),
                    name = string.format("Zee %d", i + (not mugFirst and 1 or 0)),
                    shortName = string.format("Zee %d", i + (not mugFirst and 1 or 0))
                }
            )
        end

        -- Remove the first Head Honcho SPELL_AURA_APPLIED from the fight (this one happens before the pull)
        for _, eventInfo in ipairs(heroic.events) do
            if eventInfo.event == "SPELL_AURA_APPLIED" and eventInfo.value == (mugFirst and 466459 or 466460) then
                table.remove(eventInfo.entries, 1)

                break
            end
        end

        -- Add intermission phase change
        local intermissionStart = repeatCount * interval + 2.5

        table.insert(
            mythic.events,
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1216491, -- Electrocution Matrix
                show = false,
                entries = {
                    {intermissionStart},
                }
            }
        )

        table.insert(
            mythic.phases,
            {
                event = "SPELL_CAST_SUCCESS",
                value = 1216491, -- Head Honcho: Mug/Zee
                count = 1,
                name = "Intermission",
                shortName = "Int"
            }
        )

        -- Subtract intermission start time from all intermission events
        -- Add calculated intermission start time (from number of P1 phases we play)
        for _, eventInfo in ipairs(mythic.intermission) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - mythic.intermissionStartTime + repeatCount * interval
            end
        end

        tAppendAll(mythic.events, mythic.mug)
        tAppendAll(mythic.events, mythic.zee)
        tAppendAll(mythic.events, mythic.intermission)

        -- Adjust p3 timers to fit our fight length
        local intermissionDuration = mythic.intermissionEndTime - mythic.intermissionStartTime
        local p3StartTime = repeatCount * interval + intermissionDuration

        for _, eventInfo in ipairs(mythic.zeeP3) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - mythic.logP3StartTime + p3StartTime
            end
        end

        for _, eventInfo in ipairs(mythic.mugP3) do
            for _, entry in ipairs(eventInfo.entries) do
                entry[1] = entry[1] - mythic.logP3StartTime + p3StartTime
            end
        end

        -- Merge p3 timers
        for i, eventInfo in ipairs(mythic.zeeP3) do
            for _, entry in ipairs(eventInfo.entries) do
                table.insert(mythic.zee[i].entries, entry)
            end
        end

        for i, eventInfo in ipairs(mythic.mugP3) do
            for _, entry in ipairs(eventInfo.entries) do
                table.insert(mythic.mug[i].entries, entry)
            end
        end

        -- Add Head Honcho: Mug'Zee event
        table.insert(
            mythic.events,
            {
                event = "SPELL_AURA_APPLIED",
                value = 1222408,
                show = false,
                entries = {
                    {p3StartTime, mythic.fightTime - p3StartTime}
                }
            }
        )

        -- Add phase 2 change
        table.insert(
            mythic.phases,
            {
                event = "SPELL_AURA_APPLIED",
                value = 1222408, -- Head Honcho: Mug'Zee
                count = 1,
                name = "Phase 2",
                shortName = "P2"
            }
        )

        -- Add Double-Minded Fury
        tAppendAll(
            mythic.events,
            {
                -- Double-Minded Fury
                {
                    event = "SPELL_CAST_START",
                    value = 1216142,
                    color = {245/255, 20/255, 42/255},
                    show = true,
                    entries = {
                        {p3StartTime + 60 * 2 +  0.5, 10}
                    }
                },
                {
                    event = "SPELL_CAST_SUCCESS",
                    value = 1216142,
                    show = false,
                    entries = {
                        {p3StartTime + 60 * 2 + 10.5}
                    }
                }
            }
        )
    end

    LRP.timelineData[instanceType][instance].encounters[encounter][1] = heroic
    LRP.timelineData[instanceType][instance].encounters[encounter][2] = mythic
end