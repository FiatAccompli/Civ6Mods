-- ============================= --
--	Copyright 2019 FiatAccompli  --
-- ============================= --

-- Code related to Melee Attack interface mode
include ("Civ6Common");

local ATTACK_INTERFACE_MODE = DB.MakeHash("INTERFACEMODE_MELEE_ATTACK");

function GetMeleeAttackPlotIds(unit:table)
  if not unit then
    return nil;
  end

  local plots = {};
  if not IsMeleeAttackUnit(unit) then
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

function IsMeleeAttackUnit(unit:table)
  if not unit then 
    return false;
  end

  local unitData = GameInfo.Units[unit:GetUnitType()];
  -- Must have movement remaining and be an appropriate type of unit to melee attack.
  return unit:GetMovesRemaining() > 0 and 
         unitData.Combat > 0 and 
         not (unitData.RangedCombat > 0) and 
         not (unitData.Bombard > 0) and
         (unitData.FormationClass == 'FORMATION_CLASS_LAND_COMBAT' or
          unitData.FormationClass == 'FORMATION_CLASS_NAVAL');
end

function EvaluateMeleeAttackAvailability(unit:table, availableActions:table)
  if IsMeleeAttackUnit(unit) then
    local disabled = #GetMeleeAttackPlotIds(unit) == 0;
    availableActions['MOD_KEYBOARD_NAVIGATION_UNITCOMMAND_MELEE_ATTACK'] = { Disabled = disabled };
  end
end

function OnUnitActionExecuted(action:string) 
  print("Action executed: ", action);
end

function OnPlotSelected(interfaceMode:number, plotId:number)
  if interfaceMode == ATTACK_INTERFACE_MODE then
		local plot = Map.GetPlotByIndex(plotId);

		local selectedUnit = UI.GetHeadSelectedUnit();
		local attackingPlayerId = selectedUnit:GetOwner();
		local unitComponentID:table = selectedUnit:GetComponentID();

		local willStartWar = false;
		local results = CombatManager.IsAttackChangeWarState(unitComponentID, plotX, plotY);
		if results ~= nil and #results > 0 then
		  willStartWar = true;
		end

		if willStartWar then
		  local defendingPlayerId = results[1];
			LuaEvents.Civ6Common_ConfirmWarDialog(attackingPlayerId, defendingPlayerId, WarTypes.SURPRISE_WAR);
		else
		  MoveUnitToPlot(selectedUnit, plot:GetX(), plot:GetY());
      UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
      --autoMoveKeyboardTargetForAttack:RecordLastTargetPlot(plot);
		end
  end
end

function OnInterfaceModeChanged(oldMode:number, newMode:number)
  if oldMode == ATTACK_INTERFACE_MODE then
    UILens.ToggleLayerOff( LensLayers.HEX_COLORING_ATTACK );
	  UILens.ClearLayerHexes( LensLayers.HEX_COLORING_ATTACK );
  end
  if newMode == ATTACK_INTERFACE_MODE then
    local selectedUnit = UI.GetHeadSelectedUnit();
	  if (selectedUnit ~= nil) then
		  targetPlots = GetMeleeAttackPlotIds(selectedUnit);
		  -- Highlight the plots available to attack
		  if table.count(targetPlots) ~= 0 then
			  local localPlayer = Game.GetLocalPlayer();
			  UILens.ToggleLayerOn(LensLayers.HEX_COLORING_ATTACK);
			  UILens.SetLayerHexesArea(LensLayers.HEX_COLORING_ATTACK, localPlayer, targetPlots);

        -- Register stuff here so it's always guaranteed to be in place regardless of context 
        -- initialization order (even on hotloads).
        LuaEvents.WorldNavigation_RegisterInterfaceModeHandling(ATTACK_INTERFACE_MODE, true, true);
        LuaEvents.WorldNavigation_RegisterKeyboardTargetDisplaySettings(ATTACK_INTERFACE_MODE, "ICON_NOTIFICATION_DECLARE_WAR");

        LuaEvents.WorldNavigation_RegisterSelectablePlots(targetPlots);
        --autoMoveKeyboardTargetForAttack:MaybeMoveKeyboardTarget(Map.GetPlotByIndex(pSelectedUnit:GetPlotId()));
		  end
	  end
  end
end

-- ===========================================================================
function Initialize()
  Events.InterfaceModeChanged.Add(OnInterfaceModeChanged);

  LuaEvents.ModUnitActions_EvaluateAvailableActions.Add(EvaluateMeleeAttackAvailability);
  LuaEvents.ModUnitActions_UnitActionExecuted.Add(OnUnitActionExecuted);

  LuaEvents.WorldNavigation_PlotSelected.Add(OnPlotSelected);
end

Initialize();