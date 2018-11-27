-- A very simple example of using mod setting provided by the Mod Settings Manager mod.
-- All this does is print out the values of the declared settings when they are changed.

include("mod_settings");
include("mod_settings_key_binding_helper");

local actionSetting = ModSettings.Action:new(
  "LOC_MOD_SETTING_EXAMPLE_CATEGORY", "LOC_MOD_SETTING_EXAMPLE_KEY_ACTION_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local booleanSetting = ModSettings.Boolean:new(false, "LOC_MOD_SETTING_EXAMPLE_CATEGORY", 
  "LOC_MOD_SETTING_EXAMPLE_BOOLEAN_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local booleanSetting2 = ModSettings.Boolean:new(false, "LOC_MOD_SETTING_EXAMPLE_CATEGORY", 
  "LOC_MOD_SETTING_EXAMPLE_BOOLEAN_SETTING_2", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local steppedRangeSetting = ModSettings.Range:new(50, 0, 100, "LOC_MOD_SETTING_EXAMPLE_CATEGORY", 
  "LOC_MOD_SETTING_EXAMPLE_STEPPED_RANGE_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP", 
  { Steps = 10, ValueFormatter = ModSettings.Range.PERCENT_FORMATTER });

local rangeSetting = ModSettings.Range:new(0, 0, 100, "LOC_MOD_SETTING_EXAMPLE_CATEGORY", 
  "LOC_MOD_SETTING_EXAMPLE_RANGE_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local textSetting = ModSettings.Text:new("Default value", "LOC_MOD_SETTING_EXAMPLE_CATEGORY",
  "LOC_MOD_SETTING_EXAMPLE_TEXT_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local selectValues = {"LOC_MOD_SETTING_EXAMPLE_SELECT_SETTING_VALUE_1",
                      "LOC_MOD_SETTING_EXAMPLE_SELECT_SETTING_VALUE_2",
                      "LOC_MOD_SETTING_EXAMPLE_SELECT_SETTING_VALUE_3"};
local selectSetting = ModSettings.Select:new(selectValues, 2, "LOC_MOD_SETTING_EXAMPLE_CATEGORY",
  "LOC_MOD_SETTING_EXAMPLE_SELECT_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local headerSetting = ModSettings.Header:new(
  "LOC_MOD_SETTING_EXAMPLE_CATEGORY", "LOC_MOD_SETTING_EXAMPLE_HEADER_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");

local keybindSetting = ModSettings.KeyBinding:new(ModSettings.KeyBinding.MakeValue(Keys.B, {Alt=true, Ctrl=true}),
  "LOC_MOD_SETTING_EXAMPLE_CATEGORY", "LOC_MOD_SETTING_EXAMPLE_KEY_BINDING_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");
-- Note that this will show the "conflict" UI for key bindings since it conflicts with a base game binding.
local keybindSetting2 = ModSettings.KeyBinding:new(ModSettings.KeyBinding.MakeValue(Keys.B),
  "LOC_MOD_SETTING_EXAMPLE_CATEGORY", "LOC_MOD_SETTING_EXAMPLE_KEY_BINDING_SETTING_2", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");


-- Create enough category tabs that it will have to scroll.  And also add a bunch of settings to the example category.
for i = 1, 20 do
  ModSettings.Boolean:new(math.fmod(i, 2) == 0, "z" .. tostring(i), 
    "LOC_MOD_SETTING_EXAMPLE_BOOLEAN_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");
  local booleanSetting = ModSettings.Boolean:new(math.fmod(i, 2) == 0, "LOC_MOD_SETTING_EXAMPLE_CATEGORY", 
    tostring(i), "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");
  local keybindSetting = ModSettings.KeyBinding:new(ModSettings.KeyBinding.MakeValue(Keys.K, {Alt=true, Ctrl=true}),
    "z" .. tostring(i), "LOC_MOD_SETTING_EXAMPLE_KEY_BINDING_SETTING", "LOC_MOD_SETTING_EXAMPLE_SETTING_TOOLTIP");
end

local function PrintSettings()
  print("Settings are: ---------------------------------------");
  print("Boolean: ", booleanSetting.Value);
  print("Boolean2: ", booleanSetting2.Value);
  print("Range: ", rangeSetting.Value);
  print("Stepped range: ", steppedRangeSetting.Value);
  print("Text: ", textSetting.Value);
  print("Select: ", selectSetting.Value);
  print("-----------------------------------------------------");
end

booleanSetting:AddChangedHandler(PrintSettings);
booleanSetting2:AddChangedHandler(PrintSettings);
rangeSetting:AddChangedHandler(PrintSettings);
steppedRangeSetting:AddChangedHandler(PrintSettings);
textSetting:AddChangedHandler(PrintSettings);
selectSetting:AddChangedHandler(PrintSettings);
actionSetting:AddChangedHandler(
  function() 
    print("Action!!!!!!");
    booleanSetting:Change(not booleanSetting.Value);
    booleanSetting2:Change(not booleanSetting2.Value);
    rangeSetting:Change(math.max(rangeSetting.Value - 10, 0));
    textSetting:Change(textSetting.Value .. '+');
  end);

ContextPtr:SetInputHandler(
  function(input)
    --[[
    local count = 100000;
    local start = os.clock();
    for i = 1,count do
      KeyBindingHelper.InputMatches(keybindSetting.Value, input);
    end
    print("Processed input events", count, os.clock() - start);
    --]]
    if KeyBindingHelper.InputMatches(keybindSetting.Value, input) then
      print("The bound key was pressed!");
      return true;
    end
  end, true);