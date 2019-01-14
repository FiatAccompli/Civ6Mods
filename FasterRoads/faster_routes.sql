-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

-- It's the default, but be explicit about it.
UPDATE Routes SET MovementCost = 1 WHERE RouteType = 'ROUTE_ANCIENT_ROAD';

-- The Romans had major roads in BCE and there were no substantial improvements 
-- on transportaion until the era of railroads.  Also make classical roads significantly more effective 
-- so it matters more where you send your limited early game traders to make them.
UPDATE Routes SET MovementCost = 0.5, PrereqEra = 'ERA_CLASSICAL' WHERE RouteType = 'ROUTE_MEDIEVAL_ROAD';

-- Simulate improved transportation in the industrial era, primarily the introduction of railroads and trams.
UPDATE Routes SET MovementCost = 0.333, PrereqEra = 'ERA_INDUSTRIAL' WHERE RouteType = 'ROUTE_INDUSTRIAL_ROAD';

-- Simulate improved transportation in the 20th century - cars, paved road systems, aircraft.  Not really that much 
-- of an improvement on industrial as moving large volumes of items really hasn't gotten faster since then.
UPDATE Routes SET MovementCost = 0.25, PrereqEra = 'ERA_MODERN' WHERE RouteType = 'ROUTE_MODERN_ROAD';