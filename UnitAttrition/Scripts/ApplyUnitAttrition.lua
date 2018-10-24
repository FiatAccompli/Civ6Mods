-- The ten lines of code that do the actual effect of this mod - decreasing unit health 
-- when units are out of support range.

function PrintEvents()
end

function OnTurnBegin() 
  print("-----------------Unit Attrition:OnTurnBegin()----------------------");
end

function OnTurnEnd() 
  print("-----------------Unit Attrition:OnTurnEnd()----------------------");
  PrintEvents();
end

function Initialize()
  print("------------------Unit Attrition:Initialize()-----------------------");
  Events.TurnBegin.Add(OnTurnBegin);
  Events.TurnEnd.Add(OnTurnEnd);
  PrintEvents();
end

Initialize();