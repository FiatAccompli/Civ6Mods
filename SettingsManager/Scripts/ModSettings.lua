-- Provides the public api (in the ModSettings table) that other mods use to declare and use settings.

local STORAGE_NAME_PREFIX = 'MOD_SETTING_';

local Types = {
  BOOLEAN = 1,
  SELECT = 2,
  RANGE = 3,
  TEXT = 4,
};

local function MakeFullStorageName(categoryName:string, settingName:string)
  return STORAGE_NAME_PREFIX .. categoryName .. "_" .. settingName;
end

local BaseSetting = {};
BaseSetting.__index = BaseSetting;

function BaseSetting:new(defaultValue, categoryName:string, settingName:string, tooltip:string, onChanged:ifunction)
  local storageName = MakeFullStorageName(categoryName, settingName);
  local setting = setmetatable(
    {storageName = storageName,
     Value = defaultValue,
     defaultValue = defaultValue,
     categoryName = categoryName,
     settingName = settingName,
     tooltip = tooltip,
     changeCallback = onChanged}, 
    self);

  LuaEvents.ModSettingsManager_UIReadyForRegistration.Add(function() 
      LuaEvents.ModSettingsManager_RegisterSetting(setting);
    end);
  LuaEvents.ModSettingsManager_SettingValueChange.Add(
    function(cName:string, sName:string, value)
      if (categoryName == cName) and (settingName == sName) then
        setting.Value = value;
        if onChanged then
          onChanged(value);
        end
      end
    end);
  Events.LoadGameViewStateDone.Add(function()
      setting:LoadSavedValue();
      if setting.onChanged then
        setting.onChanged(self.Value);
      end
    end);
  return setting;
end

function BaseSetting:LoadSavedValue()
  local playerDefault = (GameInfo.ModSettingsUserDefaults or {})[self.storageName];
  local loadedValue = nil;
  if playerDefault ~= nil then
    loadedValue = playerDefault.Value;
  end
  loadedValue = GameConfiguration.GetValue(self.storageName) or loadedValue;
  local value = self.defaultValue;
  if loadedValue ~= nil and type(loadedValue) == "string" then
    local parsedValue = self:ParseValue(loadedValue);
    if parsedValue ~= nil then
      value = parsedValue;
    end
  end
  self.Value = value;
end

----------------------------------------------------------------------------------------------------
-- A simple boolean setting.  defaultValue should be either true or false.
----------------------------------------------------------------------------------------------------
local BooleanSetting = {
  Type = Types.BOOLEAN 
};
BooleanSetting.__index = BooleanSetting;
setmetatable(BooleanSetting, BaseSetting);

function BooleanSetting:new(defaultValue:boolean, categoryName:string, settingName:string, tooltip:string, onChanged:ifunction)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip, onChanged);
  result:LoadSavedValue();
  return result;
end

function BooleanSetting:ParseValue(value:string)
  if value == nil then 
    return false;
  end
  return string.lower(value) == 'true'
end

------------------------------------------------------------------------------------------------------
-- A selection setting allows the player to choose one of a preset number of options for the setting.
-- Available options are given in the values array passed to the constructor.  (These should be 
-- localizable strings.)  The Value of the setting is the (non-localized) string value of the selected
-- option and the default value is values[defaultIndex].
------------------------------------------------------------------------------------------------------
local SelectSetting = {
  Type = Types.SELECT
};
SelectSetting.__index = SelectSetting;
setmetatable(SelectSetting, BaseSetting);

function SelectSetting:new(values:table, defaultIndex:number, categoryName:string, settingName:string, tooltip:string, onChanged:ifunction)
  local result = BaseSetting.new(self, values[defaultIndex], categoryName, settingName, tooltip, onChanged);
  result.values = values;
  result.defaultIndex = defaultIndex;
  result:LoadSavedValue();
  return result;
end

function SelectSetting:ParseValue(value:string)
  for _, v in ipairs(self.values) do
    if v == value then
      return value;
    end
  end
  return self.values[self.defaultIndex];
end

----------------------------------------------------------------------------------------------------
-- A range settings allows the player to choose any value between a min and max (optionally stepped 
-- so that only regularly spaced values in this range are possible).  
-- valueFormatter is a localized string for formatting the value currently selected by the user.
-- Two reasonable defaults for this are provided.
----------------------------------------------------------------------------------------------------
local RangeSetting = {
  Type = Types.RANGE,
  DEFAULT_VALUE_FORMATTER = "LOC_MOD_SETTINGS_MANAGER_DEFAULT_RANGE_SETTING_VALUE_FORMATTER",
  PERCENT_FORMATTER = "LOC_MOD_SETTINGS_MANAGER_PERCENT_RANGE_SETTING_VALUE_FORMATTER"
};
RangeSetting.__index = RangeSetting;
setmetatable(RangeSetting, BaseSetting);

function RangeSetting:new(defaultValue:number, min:number, max:number, steps:number, 
    categoryName:string, settingName:string, tooltip:string, onChanged:ifunction, valueFormatter:string)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip, onChanged);
  result.min = min;
  result.max = max;
  result.steps = steps;
  result.valueFormatter = valueFormatter or self.DEFAULT_VALUE_FORMATTER;
  result:LoadSavedValue();
  return result;
end

function RangeSetting:ParseValue(value:string)
  local parsedValue = tonumber(value);
  if not parsedValue then
    return self.defaultValue;
  end
  return math.min(self.max, math.max(0, parsedValue));
end

----------------------------------------------------------------------------------------------------
-- A text setting allows the player to provide any string as a setting value.
----------------------------------------------------------------------------------------------------
local TextSetting = {
  Type = Types.TEXT;
};

TextSetting.__index = TextSetting;
setmetatable(TextSetting, BaseSetting);

function TextSetting:new(defaultValue:string, categoryName:string, settingName:string, tooltip:string, onChanged:ifunction)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip, onChanged);
  result:LoadSavedValue();
  return result;
end

function TextSetting:ParseValue(value:string)
  return value;
end

ModSettings = {
  Types = Types,
  Boolean = BooleanSetting,
  Select = SelectSetting,
  Range = RangeSetting,
  Text = TextSetting,
};