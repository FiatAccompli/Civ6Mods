-- Update the scaling parameter for time based harvest multiplier.  This also affects 
-- district cost scaling so another mod is necessary to deal with that.
UPDATE GlobalParameters SET Value = '100' WHERE Name = 'GAME_COST_ESCALATION';

-- Set rewards of harvesting forest/jungle/marsh to 2.5 times the base values.  This 
-- fixes the rewards of harvesting at essentially the equivalent of the start of the classical
-- era in the base game.
UPDATE Feature_Removes SET Yield = Yield * 2.5;

-- Update the rewards of harvesting resources in the same way.  Slightly higher multiplier here
-- (roughly equivalent to start of medieval era in base game) to make it more useful to harvest resources
-- (which are rarer and generally more valuable long-term than terrain features).
UPDATE Resource_Harvests SET Amount = Amount * 4;