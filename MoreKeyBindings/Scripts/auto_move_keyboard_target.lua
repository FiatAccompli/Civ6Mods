-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

print("In AMKT");

local autoMoveKeyboardTargetModeValues = {
    "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_DISABLED",
    "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_PREVIOUS",
    "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_CLOSEST_TO_PREVIOUS",
    "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_FIRST",
    "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_CLOSEST" };

AutoMoveKeyboardTargetHandler = {};
AutoMoveKeyboardTargetHandler.__index = AutoMoveKeyboardTargetHandler;

function AutoMoveKeyboardTargetHandler:new(mode:string, defaultIndex:number, modeValues:table)
  local setting = ModSettings.Select:new(
      modeValues or autoMoveKeyboardTargetModeValues, defaultIndex or 1, 
      "LOC_MORE_KEY_BINDINGS_MOD_SETTINGS_CATEGORY",
      "LOC_MORE_KEY_BINDINGS_AUTO_SELECT_MODE_FOR_" .. mode,
      "LOC_MORE_KEY_BINDINGS_AUTO_SELECT_MODE_TOOLTIP");

  local handler = setmetatable({setting = setting, previousPlotIndex = -1}, self);
  return handler;
end

function AutoMoveKeyboardTargetHandler:RecordLastTargetPlot(plot:table)
  print("Recording", plot, plot and plot:GetIndex());
  self.lastTargetPlot = plot;
end

function AutoMoveKeyboardTargetHandler:FindClosest(plot:table, targetPlots:table)
  local closest = nil;
  local closestDistance = 1000000;
  for _, plotIndex in ipairs(targetPlots) do 
    if Map.IsPlot(plotIndex) then
      local p = Map.GetPlotByIndex(plotIndex);
      local distance = Map.GetPlotDistance(plot:GetX(), plot:GetY(), p:GetX(), p:GetY());
      if distance < closestDistance then
        closestDistance = distance;
        closest = p;
      end
    end
  end
  return closest;
end

function AutoMoveKeyboardTargetHandler:MaybeMoveKeyboardTarget(sourcePlot:table, targetPlots:table)
  local targetPlots = targetPlots or g_targetPlots;
  local targetPlot = keyboardTargetingPlot;
  local mode = self.setting.Value; 

  if mode == "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_PREVIOUS" then
    if self.lastTargetPlot and IsInList(targetPlots, self.lastTargetPlot:GetIndex()) then
      targetPlot = self.lastTargetPlot;
    end
  elseif mode == "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_CLOSEST_TO_PREVIOUS" then
    targetPlot = self:FindClosest(self.lastTargetPlot or sourcePlot, targetPlots);
  elseif mode == "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_FIRST" then
    targetPlot = targetPlots and targetPlots[1] and Map.GetPlotByIndex(targetPlots[1]);
  elseif mode == "LOC_MORE_KEY_BINDINGS_KEYBOARD_TARGETING_MOVE_KEYBOARD_TARGET_CLOSEST" then
    targetPlot = self:FindClosest(sourcePlot, targetPlots);
  end
  if targetPlot then
    MoveKeyboardTargetingTo(targetPlot, true);
    return;
  end
  if GetKeyboardTargetingPlot() then
    MoveKeyboardTargetingTo(GetKeyboardTargetingPlot(), true);
    return;
  end
end