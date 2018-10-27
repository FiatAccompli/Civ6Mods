-- The dozen lines of code that do the actual effect of this mod in removing health from units.

include("AttritionMaps")

function OnPlayerTurnDeactivated(playerId) 
  print("-----------------Unit Attrition:OnPlayerTurnDeactivated(): " .. playerId .. ' -------------------');
  local player = Players[playerId];

  -- Barbarians don't suffer from attrition - that's whey they're barbarians.  Also it makes them rather 
  -- pointless if they just die off a couple turns after spawning.
  if player:IsBarbarian() then
    return;
  end
  
  local attritionMap = AttritionMaps:new(player);
  local attritionSpec = attritionMap.attritionSpec;
  local isAI = not player:IsHuman();

  for _, unit in player:GetUnits():Members() do
    -- Ignore units that are not alive.  Not sure what all can get units in these states.  One source is that when the 
    -- final charge of a builder is used it doesn't get removed from the game immediately.  Instead it goes into some sort of limbo
    -- state known as delayeddeath where it is moved to plot (-9999, -9999) (obviously not an actual plot, but that's the x and y coordinates 
    -- it claims to be at) until it is really cleaned up and removed from the player's units at some point before the next turn.
    if not unit:IsDead() and not unit:IsDelayedDeath() then
      local attrition = attritionMap:GetAttritionForUnit(unit:GetType(), unit:GetX(), unit:GetY());
    
      assert(attrition ~= nil, "Unexpected attrition value of nil");
      assert(attrition >= 0, "Unexpected attrition value " .. attrition);

      local hasNotMoved = (unit:GetMaxMoves() == unit:GetMovesRemaining());

      if hasNotMoved and isAI and not attritionSpec.ApplyToAINonMovingUnits then
        print("Handling attrition for:", unit:GetID(), unit:GetX(), unit:GetY(), "<has not moved>");
      else
        local currentDamage = unit:GetDamage();
        local maxDamage = unit:GetMaxDamage();
        if currentDamage + attrition >= maxDamage then
          print("Unit killed: ", unit:GetID(), unit:GetX(), unit:GetY());
          UnitManager.Kill(unit);
        else
          print("Added attrition to unit: ", unit:GetID(), unit:GetX(), unit:GetY(), attrition);
          unit:ChangeDamage(attrition);
        end
      end
    end
  end
end

Events.PlayerTurnDeactivated.Add(OnPlayerTurnDeactivated);