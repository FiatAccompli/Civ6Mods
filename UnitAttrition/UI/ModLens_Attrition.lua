-- File must be named ModLens_XYZ in order for MoreLenses to find it.

include("AttritionMaps")
include("DistanceCalculator")

local LENS_NAME = "UA_UNIT_ATTRITION"
local ML_LENS_LAYER = LensLayers.HEX_COLORING_APPEAL_LEVEL

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
  local localPlayer   :number = Game.GetLocalPlayer();
  local localPlayerVis:table = PlayersVisibility[localPlayer];

  local color5 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_5");
	local color10 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_10");
	local color15 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_15");
	local color20 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_20");
	local color25 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_25");
	local colorGT25 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_GT_25");
  local colorPlot:table = {};
	
  --local distanceMap = CalculateAttritionDistanceMap(0, nil);

  colorPlot[color5] = {}
	colorPlot[color10] = {}
	colorPlot[color15] = {}
	colorPlot[color20] = {}
	colorPlot[color25] = {}
	colorPlot[colorGT25] = {}

	colorPlotList = {colorPlot[color5], colorPlot[color10], colorPlot[color15], colorPlot[color20], colorPlot[color25], colorPlot[colorGT25]};

    for i = 0, plotCount - 1, 1 do
        --local pPlot:table = Map.GetPlotByIndex(i);
        --if localPlayerVis:IsRevealed(pPlot:GetX(), pPlot:GetY()) and plotHasBarbCamp(pPlot) then
		--end
		--if distanceMap[i] then
        --    table.insert(colorPlot[BarbarianColor], i);
		--end
		table.insert(colorPlotList[(i % 6) + 1], i);
		local plot = Map.GetPlotByIndex(i);
		UI.AddWorldViewText(0, "Id: " .. i, plot:GetX(), plot:GetY(), 0);
    end

    return colorPlot
end

local AttritionLensEntry = {
    LensButtonText = "LOC_HUD_UNIT_ATTRITION_LENS",
    LensButtonTooltip = "LOC_HUD_UNIT_ATTRITION_LENS_TOOLTIP",
    Initialize = nil,
    GetColorPlotTable = OnGetColorPlotTable
}

-- minimappanel.lua
if g_ModLenses ~= nil then
    g_ModLenses[LENS_NAME] = AttritionLensEntry
end

-- modallenspanel.lua
if g_ModLensModalPanel ~= nil then
    g_ModLensModalPanel[LENS_NAME] = {}
    g_ModLensModalPanel[LENS_NAME].LensTextKey = "LOC_HUD_UNIT_ATTRITION_LENS"
    g_ModLensModalPanel[LENS_NAME].Legend = {
        {"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_5", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_5")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_10", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_10")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_15", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_15")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_20", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_20")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_25", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_25")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_GT_25", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_GT_25")},
    }
end
