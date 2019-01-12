--[[
-- Created by Brian Feldges, last modified by Sam Batista on Aug 02 2017
-- Copyright (c) Firaxis Games
--]]
-- ===========================================================================
-- INCLUDE BASE FILE
-- ===========================================================================
include("WorldInput");

------------------------------------------------------------------------------------------------
-- Code related to the Unit's 'Airdrop' mode
------------------------------------------------------------------------------------------------
function OnMouseParadropEnd(pInputStruct)
	-- If a drag was occurring, end it; otherwise raise event.
	if g_isMouseDragging then
		g_isMouseDragging = false;
	elseif IsSelectionAllowedAt( UI.GetCursorPlotID() ) then		
		UnitParadrop(pInputStruct);
	end
	EndDragMap();
	g_isMouseDownInWorld = false;
	return true;
end
------------------------------------------------------------------------------------------------
function UnitParadrop(pInputStruct)
	local plotID = UI.GetCursorPlotID();
	if Map.IsPlot(plotID) then
		local plot = Map.GetPlotByIndex(plotID);
			
		local tParameters = {};
		tParameters[UnitCommandTypes.PARAM_X] = plot:GetX();
		tParameters[UnitCommandTypes.PARAM_Y] = plot:GetY();

		local pSelectedUnit = UI.GetHeadSelectedUnit();
		if (UnitManager.CanStartCommand( pSelectedUnit, UnitCommandTypes.PARADROP, tParameters)) then
			UnitManager.RequestCommand( pSelectedUnit, UnitCommandTypes.PARADROP, tParameters);
			UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
			UI.PlaySound("Unit_Airlift");
		end
	end
	return true;
end
------------------------------------------------------------------------------------------------
function OnInterfaceModeChange_UnitParadrop(eNewMode)
	UIManager:SetUICursor(CursorTypes.RANGE_ATTACK);
	local pSelectedUnit = UI.GetHeadSelectedUnit();
	local tResults = UnitManager.GetCommandTargets(pSelectedUnit, UnitCommandTypes.PARADROP );
	local allPlots = tResults[CityCommandResults.PLOTS];
	if allPlots then
		g_targetPlots = {};
		for i,modifier in ipairs(tResults[CityCommandResults.PLOTS]) do
			table.insert(g_targetPlots, allPlots[i]);
		end 

		-- Highlight the plots available to airdrop to
		if (table.count(g_targetPlots) ~= 0) then
			UILens.ToggleLayerOn(LensLayers.HEX_COLORING_MOVEMENT);
			UILens.SetLayerHexesArea(LensLayers.HEX_COLORING_MOVEMENT, Game.GetLocalPlayer(), g_targetPlots);
		end
	end
end
--------------------------------------------------------------------------------------------------
function OnInterfaceModeLeave_UnitParadrop(eNewMode:number)
	UIManager:SetUICursor(CursorTypes.NORMAL);
	UILens.ToggleLayerOff(LensLayers.HEX_COLORING_MOVEMENT);
	UILens.ClearLayerHexes(LensLayers.HEX_COLORING_MOVEMENT);
end






------------------------------------------------------------------------------------------------
-- Code related to the Unit's 'PriorityTarget' mode
------------------------------------------------------------------------------------------------
function OnMousePriorityTargetEnd(pInputStruct)
	-- If a drag was occurring, end it; otherwise raise event.
	if g_isMouseDragging then
		g_isMouseDragging = false;
	elseif IsSelectionAllowedAt( UI.GetCursorPlotID() ) then		
		PriorityTarget(pInputStruct);
	end
	EndDragMap();
	g_isMouseDownInWorld = false;
	return true;
end
------------------------------------------------------------------------------------------------
function PriorityTarget(pInputStruct)
	local plotID = UI.GetCursorPlotID();
	if Map.IsPlot(plotID) then
		local plot = Map.GetPlotByIndex(plotID);
			
		local tParameters = {};
		tParameters[UnitCommandTypes.PARAM_X] = plot:GetX();
		tParameters[UnitCommandTypes.PARAM_Y] = plot:GetY();

		local pSelectedUnit = UI.GetHeadSelectedUnit();
		if (UnitManager.CanStartCommand( pSelectedUnit, UnitCommandTypes.PRIORITY_TARGET, tParameters)) then
			UnitManager.RequestCommand( pSelectedUnit, UnitCommandTypes.PRIORITY_TARGET, tParameters);
			UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
		end
	end
	return true;
end
------------------------------------------------------------------------------------------------
function OnInterfaceModeChange_PriorityTarget(eNewMode)
	UIManager:SetUICursor(CursorTypes.RANGE_ATTACK);
	local pSelectedUnit = UI.GetHeadSelectedUnit();
	local tResults = UnitManager.GetCommandTargets(pSelectedUnit, UnitCommandTypes.PRIORITY_TARGET );
	local allPlots = tResults[CityCommandResults.PLOTS];
	if allPlots then
		g_targetPlots = {};
		for i,modifier in ipairs(tResults[CityCommandResults.MODIFIERS]) do
			if(modifier == CityCommandResults.MODIFIER_IS_TARGET) then	
				table.insert(g_targetPlots, allPlots[i]);
			end
		end

		-- Highlight the plots available to attack a priority target
		if (table.count(g_targetPlots) ~= 0) then
			UILens.ToggleLayerOn(LensLayers.HEX_COLORING_MOVEMENT);
			UILens.SetLayerHexesArea(LensLayers.HEX_COLORING_MOVEMENT, Game.GetLocalPlayer(), g_targetPlots);
		end
	end
end
--------------------------------------------------------------------------------------------------
function OnInterfaceModeLeave_PriorityTarget(eNewMode:number)
	UIManager:SetUICursor(CursorTypes.NORMAL);
	UILens.ToggleLayerOff(LensLayers.HEX_COLORING_MOVEMENT);
	UILens.ClearLayerHexes(LensLayers.HEX_COLORING_MOVEMENT);
end

-- ===========================================================================
function Initialize()
	InterfaceModeMessageHandler[InterfaceModeTypes.PARADROP] = {};
	InterfaceModeMessageHandler[InterfaceModeTypes.PARADROP][INTERFACEMODE_ENTER]= OnInterfaceModeChange_UnitParadrop;
	InterfaceModeMessageHandler[InterfaceModeTypes.PARADROP][INTERFACEMODE_LEAVE] = OnInterfaceModeLeave_UnitParadrop;
	InterfaceModeMessageHandler[InterfaceModeTypes.PARADROP][MouseEvents.LButtonUp] = OnMouseParadropEnd;
	InterfaceModeMessageHandler[InterfaceModeTypes.PARADROP][KeyEvents.KeyUp]		= OnPlacementKeyUp;

	InterfaceModeMessageHandler[InterfaceModeTypes.PRIORITY_TARGET] = {};
	InterfaceModeMessageHandler[InterfaceModeTypes.PRIORITY_TARGET][INTERFACEMODE_ENTER]= OnInterfaceModeChange_PriorityTarget;
	InterfaceModeMessageHandler[InterfaceModeTypes.PRIORITY_TARGET][INTERFACEMODE_LEAVE] = OnInterfaceModeLeave_PriorityTarget;
	InterfaceModeMessageHandler[InterfaceModeTypes.PRIORITY_TARGET][MouseEvents.LButtonUp] = OnMousePriorityTargetEnd;
	InterfaceModeMessageHandler[InterfaceModeTypes.PRIORITY_TARGET][KeyEvents.KeyUp]		= OnPlacementKeyUp;
	
	if g_isTouchEnabled then
		InterfaceModeMessageHandler[InterfaceModeTypes.PARADROP][MouseEvents.PointerUp] = OnMouseParadropEnd;
		InterfaceModeMessageHandler[InterfaceModeTypes.PRIORITY_TARGET][MouseEvents.PointerUp] = OnMousePriorityTargetEnd;
	end
end
Initialize();