
MeleeAttackHandling = {};

MeleeAttackHandling.ActionHash = DB.MakeHash('MORE_KEYBINDING_UNITCOMMAND_MELEE_ATTACK');

function MeleeAttackHandling.GetMeleeAttackPlotIds(unit:table)
  if not unit then
    return nil;
  end

  local plots = {};
  if not MeleeAttackHandling.CanMeleeAttack(unit, true) then
    return plots;
  end
  for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1 do 
    local adjacentPlot = Map.GetAdjacentPlot(unit:GetX(), unit:GetY(), direction);
    if adjacentPlot then
      local combatSim = CombatManager.SimulateAttackInto(unit:GetComponentID(), CombatTypes.MELEE, adjacentPlot:GetX(), adjacentPlot:GetY());
      if combatSim then
        table.insert(plots, adjacentPlot:GetIndex());
      end
    end
  end
  return plots
end

function MeleeAttackHandling.CanMeleeAttack(unit:table, simple:boolean)
  if not unit then 
    return false;
  end
  if simple then
    local unitData = GameInfo.Units[unit:GetUnitType()];
    -- Must have movement remaining and be an appropriate type of unit to melee attack.
    return unit:GetMovesRemaining() > 0 and unitData.Combat > 0 and 
      (unitData.FormationClass == 'FORMATION_CLASS_LAND_COMBAT' or
       unitData.FormationClass == 'FORMATION_CLASS_NAVAL');
  else 
    return unit and #MeleeAttackHandling.GetMeleeAttackPlotIds(unit) > 0 or false;
  end
end