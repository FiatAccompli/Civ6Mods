-- File must be named ModLens_XYZ in order for MoreLenses/CQUI to find it.
-- Lense that shows attrition per turn for the local player, both by shading and by writing the 
-- exact amount of attrition in each hex.

include("AttritionMaps")

local LENS_NAME = "UA_UNIT_ATTRITION"

local function GetColorPlotTable()
  local plotCount = Map.GetPlotCount();
  local localPlayerId = Game.GetLocalPlayer();
  local visibility = PlayerVisibilityManager.GetPlayerVisibility(localPlayerId);

  local color0 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_0");
  local color5 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_5");
	local color10 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_10");
	local color15 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_15");
	local color20 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_20");
	local colorGT20 = UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_GT_20");
  local colorPlot:table = {};

  colorPlot[color0] = {}
  colorPlot[color5] = {}
	colorPlot[color10] = {}
	colorPlot[color15] = {}
	colorPlot[color20] = {}
	--colorPlot[color25] = {}
  colorPlot[colorGT20] = {}

  local colorPlotList = {colorPlot[color0], colorPlot[color5], colorPlot[color10], colorPlot[color15], colorPlot[color20], colorPlot[colorGT20]};

  local attritionMaps = AttritionMaps:new(Players[localPlayerId]);
  local attritionRates = attritionMaps:GetAttritionMapForFormationClass("FORMATION_CLASS_LAND_COMBAT");

  local numBuckets = #colorPlotList;
  UILens.ClearLayerHexes(LensLayers.NUMBERS);

  for i = 0, plotCount - 1 do
    local attritionRate = attritionRates[i];
    local plot = Map.GetPlotByIndex(i);
    if visibility:IsRevealed(plot:GetX(), plot:GetY()) then
      UI.AddNumberToPath(attritionRate, i);
      table.insert(colorPlotList[math.min(math.ceil(attritionRate/5), numBuckets - 1) + 1], i);
    end
  end

  return colorPlot
end

local function Toggle()
  UILens.ClearLayerHexes(LensLayers.NUMBERS);
end

local function OnClose()
  UILens.ClearLayerHexes(LensLayers.NUMBERS);
end

local AttritionLensEntry = {
    LensButtonText = "LOC_HUD_UNIT_ATTRITION_LENS",
    LensButtonTooltip = "LOC_HUD_UNIT_ATTRITION_LENS_TOOLTIP",
    Initialize = nil,
    OnToggle = Toggle,
    GetColorPlotTable = GetColorPlotTable
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
    {"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_0", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_0")},
    {"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_5", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_5")},
  	{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_10", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_10")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_15", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_15")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_20", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_20")},
		{"LOC_TOOLTIP_UNIT_ATTRITION_LENS_RATE_GT_20", UI.GetColorValue("COLOR_UNIT_ATTRITION_LENS_RATE_GT_20")},
  };
end

LuaEvents.ML_CloseLensPanels.Add(OnClose);