-- File must be named ModLens_XYZ in order for MoreLenses to find it.
-- Adds a lens that shows the computed distance for attrition.  More for debugging than for anything else.

include("AttritionMaps.lua")

local ENABLED = true;
local LENS_NAME = "UA_UNIT_ATTRITION_DISTANCE"
local NUM_COLORS = 10

-- ===========================================================================
-- Attrition Lens Support
-- ===========================================================================

local function plotHasBarbCamp(plot)
    local improvementInfo = GameInfo.Improvements[plot:GetImprovementType()];
    if improvementInfo ~= nil and improvementInfo.ImprovementType == "IMPROVEMENT_BARBARIAN_CAMP" then
        return true;
    end
    return false;
end

-- ===========================================================================
-- Exported functions
-- ===========================================================================

local function OnGetColorPlotTable()
    local plotCount = Map.GetPlotCount();
    local localPlayer:number = Game.GetLocalPlayer();
    local localPlayerVis:table = PlayersVisibility[localPlayer];

	local colorPlot = {};
	local colorPlotList = {};
	local unreachable = {};
	for i = 0, NUM_COLORS-1 do 
	  local color = UI.GetColorValue("COLOR_UNIT_ATTRITION_DISTANCE_LENS_" .. i);
	  colorPlot[color] = {};
	  colorPlotList[i] = colorPlot[color];
    end
	colorPlot[UI.GetColorValue("COLOR_UNIT_ATTRITION_DISTANCE_LENS_UNREACHABLE")] = unreachable;

	local player = Players[localPlayer];
	local distances = CalculateAttritionDistanceMap(player, GameInfo.Eras[player:GetEra()].DefaultUnitAttritionSet);

    for i = 0, plotCount - 1 do
	  if distances[i] >= UA_ATTRITION_MAX_DISTANCE then
	    table.insert(unreachable, i);
	  else
		table.insert(colorPlotList[(distances[i] % NUM_COLORS)], i);
	  end
    end

    return colorPlot
end

local AttritionLensEntry = {
    LensButtonText = "LOC_HUD_UNIT_ATTRITION_DISTANCE_LENS",
    LensButtonTooltip = "LOC_HUD_UNIT_ATTRITION_DISTANCE_LENS_TOOLTIP",
    Initialize = nil,
    GetColorPlotTable = OnGetColorPlotTable
}

-- minimappanel.lua
if ENABLED and g_ModLenses ~= nil then
    g_ModLenses[LENS_NAME] = AttritionLensEntry
end

-- modallenspanel.lua
if ENABLED and g_ModLensModalPanel ~= nil then
  lense = {}
  lense.LensTextKey = "LOC_HUD_UNIT_ATTRITION_DISTANCE_LENS";
  lense.Legend = {};
  for i = 0, NUM_COLORS-1 do
    table.insert(lense.Legend, {"LOC_TOOLTIP_UNIT_ATTRITION_DISTANCE_" .. i, UI.GetColorValue("COLOR_UNIT_ATTRITION_DISTANCE_LENS_" .. i)});
  end
  table.insert(lense.Legend, {"LOC_TOOLTIP_UNIT_ATTRITION_DISTANCE_UNREACHABLE", UI.GetColorValue("COLOR_UNIT_ATTRITION_DISTANCE_LENS_UNREACHABLE")});
  g_ModLensModalPanel[LENS_NAME] = lense;
end
