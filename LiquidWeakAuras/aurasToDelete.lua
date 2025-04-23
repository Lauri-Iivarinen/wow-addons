local addonName, ns = ...
-- add uids to be deleted, every children in the group will also be deleted
-- remember that all auto imported weakauras are prefixed with "liquid-", eg "liquid-5f9FHK0WE8R"
ns.deleteData = {
    --"liquid-5f9FHK0WE8R",
    "liquid-ejsAva(PCfZ", -- The Bloodbound Horror: Crimson Rain (list)
    "liquid-zCcV1AXQ2Eo", -- Experimental Dosage big icon
    "liquid-oNQE5ZC8lWJ", -- Unstable Web (glow)
    "liquid-jR3y7Mux7zv", -- Liquid/Viserio MRT Reminders
    "liquid-)lbi(5qJE4a", -- Spike Storm (ticks)
    "liquid-YDviXKqI(a5", -- Feast cast (co-tank)
    "liquid-lZeoIyLeGnS", -- Feast taunt
    "liquid-IribfNpApzc", -- Glutton Threads (text)
    "liquid-FqRoOnv6MG)", -- Reckless Charge
    "liquid-VkoZsxh2ZV2", -- Predation (shield)
    "liquid-JwZHa3)DM25", -- Stinging Swarm get dispelled assignments
    "liquid-4DAG9FZlL1(", -- tried to push reloe's external group, isnt that easy -> do it after the progress
    "liquid-Q79PYeFMZgG", -- Broodtwister Ovi'nax - Tank Warnings (should be a dynamic group instead of regular group)

    "liquid-O5SlrIt0chv", -- Silken court mythic aura, remove later
    "liquid-aKSP4wpE5cJ", -- Queensbane application order
    "liquid-YXLFfnic9Ar", -- Assassination
    "liquid-YsJmHZzf9Q6", -- Stinging Swarm dispel assignments TEST
    "liquid-42TVsXd(Hhw", -- Shatter Existence/Spike Storm (shield)
    "liquid-O5SlrIt0chv", -- Stinging Swarm mythic (list)
    "liquid-RvQi6a(Mj4H", -- Stinging Swarm dispel assignments
	"liquid-h9RkQYRH)xy", -- take "next entropic barrage" WA out of the main group
    "liquid-ieip8rX3XYJ", -- Stinging Swarm dispel number on frames
    "liquid-cSuMYESurqx", -- Ulgrax Phase 2 energy, cba to fix this everytime
    "liquid-z4g72bE8bV8", -- Sticky Web macro
    "liquid-H271c8KN9lQ", -- Sticky Web (not safe)
    "liquid-yrZiq0h4IbD", -- Sticky Web (safe)
    "liquid-KxIn5iMeG6U", -- Experimental Dosage?
    "liquid-x6f(h5)yDjY", -- Experimental Dosage?
    "liquid-FTuV6hLx1Xu", -- Queen ansurek, essences
    "liquid-5f9FHK0WE8R", -- LiquidWeakAuras (uid changed??)
    "liquid-DYYTqehRXWV", -- KP Raid Interrupts
    "liquid-cxB8cdbbqx)", -- KP Note Reader
    "liquid-JgToFjn4Nh7", -- KP Raid WeakAuras: GetRaidMarkerIndex
    "liquid-8Zf51qqn33(", -- KP: Broodtwister Ovi'nax: Unstable Web Dispel Assignments
    "liquid-aXSlkclD8U9", -- KP: BroodTwister Ovi'nax: Egg Break Assignments (Note)
    "liquid-UMqPK3cKvv9", -- Withering Flames dispel assignment (macro) TEST
    "liquid-9mPGznQ9z6M", -- Chrome King Gallywix - Raid Leader Lists
    "liquid-CFiCSLjy2qe", -- Chrome King Gallywix - Big Icons
    "liquid-TD7Z45cdYsO", -- Chrome King Gallywix - Texts
    "liquid-E6t7ql7t3q)", -- Chrome King Gallywix - Position Assignments
    "liquid-8I9t2jwyuXn", -- Chrome King Gallywix - Miscellaneous
    "liquid-CanzyvHxQ8U", -- Prototype Hypercoil
    "liquid-c)74HvFKdJa", -- Faulty Zap
    "liquid-bnua15ALd7p", -- Demolish cast (co-tank)
    "liquid-a0kIZ1HwBS2", -- Demolish taunt
    "liquid-CSP)TCq)YiQ", -- Pyro Party Pack cast (co-tank)
    "liquid-8Gh(IvFrmy3", -- Reel Assistant nameplate glow 2 2
    "liquid-CjlgYBoYdZ6", -- Withering Flames (glow)
    "liquid-urcfGlSqaV8", -- Stix Bunkjunker - Assignments (dynamic group)
    "liquid-P(n8irGylSs", -- Screw Up "SAFE" text
    "liquid-7sJVx15DMwb", -- Screw Up old
    "liquid-YsyA(XXOlx)", -- Bait Pay-Line
    "liquid-w4KD5UMWrj9", -- Static Charge
    "liquid-1v2azQ6A4PM", -- Explosive Payload
    "liquid-ZPRpGDO2T31", -- Overloaded Rockets
    -- Combination Canisters position assignments (got duplicated, remove all of them)
    "liquid-8FT(JKz9jyJ", -- Combination Canisters position assignments
    "liquid-tvEuWOLwiao", -- Combination Canisters position assignments 2
    "liquid-jfEWJY8NFNl", -- Combination Canisters position assignments
    "liquid-X)1tCXx7UI5", -- Combination Canisters position assignment (background)
    "liquid-Sispewl)Vnu", -- Chrome King Gallywix - Position Assignments
    "liquid-Ka8pLANJlGu", -- Biggest Baddest Bomb Barrage assignment
    "liquid-)sr(gtzIMWo", -- Bait Pay-Line (ranged)
    "liquid-xMZPFEiGW5Q", -- Ego Check cast (co-tank)
    "liquid-(iq5dGNh0nV", -- Ego Check taunt
    "liquid-v8di7DS)c)x", -- Bait Static Charge
    "liquid-XuFcjCoIyCF", -- Lingering Voltage list
    "liquid-0RGHZ8YhtKn", -- left over aura of LiquidBreakTexture
}