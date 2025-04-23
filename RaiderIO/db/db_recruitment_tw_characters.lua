--
-- Copyright (c) 2025 by Ludicrous Speed, LLC
-- All rights reserved.
--
local provider={name=...,data=3,region="tw",date="2025-04-23T08:20:45Z",numCharacters=35046,db={}}
local F

F = function() provider.db["水晶之刺"]={0,"潘鳳"} end F()

F = nil
RaiderIO.AddProvider(provider)
