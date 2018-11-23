-- Provides the public api (in the ModSettings table) that other mods use to declare and use settings.

if not ModSettings then
print("Executing ModSettings.lua");

local STORAGE_NAME_PREFIX = 'MOD_SETTING_';

local NO_OPTIONS = {};

local Types = {
  BOOLEAN = 1,
  SELECT = 2,
  RANGE = 3,
  TEXT = 4,
  KEY_BINDING = 5,
  ACTION = 6,
};

local function MakeFullStorageName(categoryName:string, settingName:string)
  return STORAGE_NAME_PREFIX .. categoryName .. "_" .. settingName;
end

local BaseSetting = {};
BaseSetting.__index = BaseSetting;

function BaseSetting:new(defaultValue, categoryName:string, settingName:string, tooltip:string)
  local storageName = MakeFullStorageName(categoryName, settingName);
  local setting = setmetatable(
    {storageName = storageName,
     Value = defaultValue,
     defaultValue = defaultValue,
     categoryName = categoryName,
     settingName = settingName,
     tooltip = tooltip,}, 
    self);
  LuaEvents.ModSettingsManager_SettingValueChange.Add(
    function(cName:string, sName:string, value)
      if (categoryName == cName) and (settingName == sName) then
        setting.Value = value;
      end
    end);
  LuaEvents.ModSettingsManager_UIReadyForRegistration.Add(
    function() 
      LuaEvents.ModSettingsManager_RegisterSetting(setting);
    end);
--  Events.LoadGameViewStateDone.Add(
--    function()
--      setting:LoadSavedValue();
--    end);
  return setting;
end

function BaseSetting:Change(value)
  local oldValue = self.Value;
  LuaEvents.ModSettingsManager_SettingValueChange(self.categoryName, self.settingName, value);
  LuaEvents.ModSettingsManager_SettingValueChanged(self.categoryName, self.settingName, value, oldValue);
end

function BaseSetting:ToStringValue()
  return tostring(self.Value);
end

function BaseSetting:AddChangedHandler(onChanged:ifunction)
  local categoryName = self.categoryName;
  local settingName = self.settingName;
  LuaEvents.ModSettingsManager_SettingValueChanged.Add(
    function(cName:string, sName:string, value)
      if (categoryName == cName) and (settingName == sName) then
        onChanged(value);
      end
    end);
end

function BaseSetting:LoadSavedValue()
  local playerDefault = (GameInfo.ModSettingsUserDefaults or {})[self.storageName];
  local oldValue = self.Value;
  if playerDefault ~= nil then
    local parsedValue = self:ParseValue(playerDefault);
    if parsedValue ~= nil then
      self.defaultValue = parsedValue;
      self.Value = parsedValue;
    end
  end
  local loadedValue = GameConfiguration.GetValue(self.storageName);
  if loadedValue ~= nil and type(loadedValue) == "string" then
    local parsedValue = self:ParseValue(loadedValue);
    if parsedValue ~= nil then
      self.Value = value;
    end
  end
  LuaEvents.ModSettingsManager_SettingValueChanged(self.categoryName, self.settingName, self.Value, oldValue);
end

----------------------------------------------------------------------------------------------------
-- A simple boolean setting.  defaultValue should be either true or false.
----------------------------------------------------------------------------------------------------
local BooleanSetting = {
  Type = Types.BOOLEAN 
};
BooleanSetting.__index = BooleanSetting;
setmetatable(BooleanSetting, BaseSetting);

function BooleanSetting:new(defaultValue:boolean, categoryName:string, settingName:string, tooltip:string)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip);
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

function SelectSetting:new(values:table, defaultIndex:number, categoryName:string, settingName:string, tooltip:string)
  local result = BaseSetting.new(self, values[defaultIndex], categoryName, settingName, tooltip);
  result.values = values;
  result:LoadSavedValue();
  return result;
end

function SelectSetting:ParseValue(value:string)
  for _, v in ipairs(self.values) do
    if v == value then
      return value;
    end
  end
  return self.defaultValue;
end

----------------------------------------------------------------------------------------------------
-- A range settings allows the player to choose any value between a min and max (optionally stepped 
-- so that only regularly spaced values in this range are possible).  
----------------------------------------------------------------------------------------------------
local RangeSetting = {
  Type = Types.RANGE,
  DEFAULT_VALUE_FORMATTER = "LOC_MOD_SETTINGS_MANAGER_DEFAULT_RANGE_SETTING_VALUE_FORMATTER",
  PERCENT_FORMATTER = "LOC_MOD_SETTINGS_MANAGER_PERCENT_RANGE_SETTING_VALUE_FORMATTER"
};
RangeSetting.__index = RangeSetting;
setmetatable(RangeSetting, BaseSetting);

function RangeSetting:new(defaultValue:number, min:number, max:number, 
    categoryName:string, settingName:string, tooltip:string, options:table)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip);
  options = options or NO_OPTIONS;
  result.min = min;
  result.max = max;
  result.steps = steps;
  result.valueFormatter = options.ValueFormatter or self.DEFAULT_VALUE_FORMATTER;
  result.steps = options.Steps;
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

function TextSetting:new(defaultValue:string, categoryName:string, settingName:string, tooltip:string)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip);
  result:LoadSavedValue();
  return result;
end

function TextSetting:ParseValue(value:string)
  return value;
end


--------------------------------------------------------------------------------------------------
-- A key setting allows the player to configure a keybinding for an action.
--------------------------------------------------------------------------------------------------

local KeyBindingSetting = {
  Type = Types.KEY_BINDING,
  -- Maps from key code to localization for displaying.
  -- Conveniently the game provides localization for keys even though the translations are not referenced 
  -- in the lua game code.  (They are likely the translations used by the c++ code though.  
  -- Whether that's the case or not, these translations exist, so I'll use them.)
  -- This list also serves to define the valid keys that can be bound.
  KeyLocalizations = { 
    [Keys["0"]] = "LOC_OPTIONS_KEY_0",
    [Keys["1"]] = "LOC_OPTIONS_KEY_1",
    [Keys["2"]] = "LOC_OPTIONS_KEY_2",
    [Keys["3"]] = "LOC_OPTIONS_KEY_3",
    [Keys["4"]] = "LOC_OPTIONS_KEY_4",
    [Keys["5"]] = "LOC_OPTIONS_KEY_5",
    [Keys["6"]] = "LOC_OPTIONS_KEY_6",
    [Keys["7"]] = "LOC_OPTIONS_KEY_7",
    [Keys["8"]] = "LOC_OPTIONS_KEY_8",
    [Keys["9"]] = "LOC_OPTIONS_KEY_9",
    [Keys.A] = "LOC_OPTIONS_KEY_A",
    -- Modifier key
    -- "LOC_OPTIONS_KEY_ALT"
    [Keys.VK_APPS] = "LOC_OPTIONS_KEY_APPS",
    [Keys.B] = "LOC_OPTIONS_KEY_B",
    [Keys.VK_OEM_2] = "LOC_OPTIONS_KEY_BACKSLASH",
    [Keys.VK_BACK] = "LOC_OPTIONS_KEY_BACKSPACE",
    [Keys.C] = "LOC_OPTIONS_KEY_C",
    [Keys.VK_PAUSE] = "LOC_OPTIONS_KEY_CANCEL",
    -- Not allowed to bind it in main game options 
    -- "LOC_OPTIONS_KEY_CAPSLOCK"
    [Keys.VK_OEM_COMMA] = "LOC_OPTIONS_KEY_COMMA",
    -- Modifier key
    -- "LOC_OPTIONS_KEY_CONTROL"
    [Keys.D] = "LOC_OPTIONS_KEY_D",
    -- No fucking clue.  Only Polish has translation in game and it's just a 0.  ???  Googling didn't turn up anything.
    -- "LOC_OPTIONS_KEY_DANOMITE"
    [Keys.VK_DELETE] = "LOC_OPTIONS_KEY_DELETE",
    [Keys.VK_DOWN] = "LOC_OPTIONS_KEY_DOWN",
    [Keys.E] = "LOC_OPTIONS_KEY_E",
    [Keys.VK_END] = "LOC_OPTIONS_KEY_END",
    -- Used throughout the UI as a "back" or "escape" key.
    -- "LOC_OPTIONS_KEY_ESCAPE"
    [Keys.F] = "LOC_OPTIONS_KEY_F",
    [Keys.VK_F1] = "LOC_OPTIONS_KEY_F1",
    [Keys.VK_F10] = "LOC_OPTIONS_KEY_F10",
    [Keys.VK_F11] = "LOC_OPTIONS_KEY_F11",
    [Keys.VK_F12] = "LOC_OPTIONS_KEY_F12",
    [Keys.VK_F13] = "LOC_OPTIONS_KEY_F13",
    [Keys.VK_F14] = "LOC_OPTIONS_KEY_F14",
    [Keys.VK_F15] = "LOC_OPTIONS_KEY_F15",
    [Keys.VK_F16] = "LOC_OPTIONS_KEY_F16",
    [Keys.VK_F17] = "LOC_OPTIONS_KEY_F17",
    [Keys.VK_F18] = "LOC_OPTIONS_KEY_F18",
    [Keys.VK_F19] = "LOC_OPTIONS_KEY_F19",
    [Keys.VK_F2] = "LOC_OPTIONS_KEY_F2",
    [Keys.VK_F20] = "LOC_OPTIONS_KEY_F20",
    [Keys.VK_F21] = "LOC_OPTIONS_KEY_F21",
    [Keys.VK_F22] = "LOC_OPTIONS_KEY_F22",
    [Keys.VK_F23] = "LOC_OPTIONS_KEY_F23",
    [Keys.VK_F24] = "LOC_OPTIONS_KEY_F24",
    [Keys.VK_F3] = "LOC_OPTIONS_KEY_F3",
    [Keys.VK_F4] = "LOC_OPTIONS_KEY_F4",
    [Keys.VK_F5] = "LOC_OPTIONS_KEY_F5",
    [Keys.VK_F6] = "LOC_OPTIONS_KEY_F6",
    [Keys.VK_F7] = "LOC_OPTIONS_KEY_F7",
    [Keys.VK_F8] = "LOC_OPTIONS_KEY_F8",
    [Keys.VK_F9] = "LOC_OPTIONS_KEY_F9",
    [Keys.G] = "LOC_OPTIONS_KEY_G",
    [Keys.H] = "LOC_OPTIONS_KEY_H",
    [Keys.VK_HOME] = "LOC_OPTIONS_KEY_HOME",
    [Keys.I] = "LOC_OPTIONS_KEY_I",
    -- Apparently hanging out with danomite
    -- "LOC_OPTIONS_KEY_IGNORE"
    [Keys.VK_INSERT] = "LOC_OPTIONS_KEY_INSERT",
    [Keys.J] = "LOC_OPTIONS_KEY_J",
    [Keys.K] = "LOC_OPTIONS_KEY_K",
    [Keys.L] = "LOC_OPTIONS_KEY_L",
    -- Modifier key
    -- "LOC_OPTIONS_KEY_LALT"
    [Keys.VK_OEM_4] = "LOC_OPTIONS_KEY_LBRACKET",
    -- Mouse Input 
    -- "LOC_OPTIONS_KEY_LBUTTON",
    -- Modifier Key
    -- "LOC_OPTIONS_KEY_LCONTROL"
    [Keys.VK_LEFT] = "LOC_OPTIONS_KEY_LEFT",
    -- Modifier keys
    -- "LOC_OPTIONS_KEY_LSHIFT"
    -- "LOC_OPTIONS_KEY_LWIN"
    [Keys.M] = "LOC_OPTIONS_KEY_M",
    -- Mouse 
    -- "LOC_OPTIONS_KEY_MBUTTON"
    [Keys.VK_MEDIA_NEXT_TRACK] = "LOC_OPTIONS_KEY_MEDIA_NEXT_TRACK",
    [Keys.VK_MEDIA_PLAY_PAUSE] = "LOC_OPTIONS_KEY_MEDIA_PLAY_PAUSE",
    [Keys.VK_MEDIA_PREV_TRACK] = "LOC_OPTIONS_KEY_MEDIA_PREV_TRACK",
    [Keys.VK_MEDIA_STOP] = "LOC_OPTIONS_KEY_MEDIA_STOP",
    [Keys.VK_OEM_MINUS] = "LOC_OPTIONS_KEY_MINUS",
    [Keys.N] = "LOC_OPTIONS_KEY_N",
    [Keys.VK_NUMPAD0] = "LOC_OPTIONS_KEY_NP_0",
    [Keys.VK_NUMPAD1] = "LOC_OPTIONS_KEY_NP_1",
    [Keys.VK_NUMPAD2] = "LOC_OPTIONS_KEY_NP_2",
    [Keys.VK_NUMPAD3] = "LOC_OPTIONS_KEY_NP_3",
    [Keys.VK_NUMPAD4] = "LOC_OPTIONS_KEY_NP_4",
    [Keys.VK_NUMPAD5] = "LOC_OPTIONS_KEY_NP_5",
    [Keys.VK_NUMPAD6] = "LOC_OPTIONS_KEY_NP_6",
    [Keys.VK_NUMPAD7] = "LOC_OPTIONS_KEY_NP_7",
    [Keys.VK_NUMPAD8] = "LOC_OPTIONS_KEY_NP_8",
    [Keys.VK_NUMPAD9] = "LOC_OPTIONS_KEY_NP_9",
    [Keys.VK_SEPARATOR] = "LOC_OPTIONS_KEY_NP_CENTER",
    [Keys.VK_DECIMAL] = "LOC_OPTIONS_KEY_NP_DECIMAL",
    [Keys.VK_DIVIDE] = "LOC_OPTIONS_KEY_NP_DIVIDE",
    [Keys.VK_SUBTRACT] = "LOC_OPTIONS_KEY_NP_MINUS",
    [Keys.VK_MULTIPLY] = "LOC_OPTIONS_KEY_NP_MULTIPLY",
    [Keys.VK_ADD] = "LOC_OPTIONS_KEY_NP_PLUS",
    -- It actually is valid to bind NumLock in the base game.  Disallow it because it feels weird.
    -- "LOC_OPTIONS_KEY_NUMLOCK"
    -- Not sure what this is supposed to be
    -- "LOC_OPTIONS_KEY_NUM_KEYS"
    [Keys.O] = "LOC_OPTIONS_KEY_O",
    [Keys.P] = "LOC_OPTIONS_KEY_P",
    [Keys.VK_NEXT] = "LOC_OPTIONS_KEY_PAGEDOWN",
    [Keys.VK_PRIOR] = "LOC_OPTIONS_KEY_PAGEUP",
    [Keys.VK_PAUSE] = "LOC_OPTIONS_KEY_PAUSE",
    [Keys.VK_OEM_PERIOD] = "LOC_OPTIONS_KEY_PERIOD",
    -- Which, ironically, is actually the = key.
    [Keys.VK_OEM_PLUS] = "LOC_OPTIONS_KEY_PLUS",
    -- Not allowed to bind it in main game options.
    -- "LOC_OPTIONS_KEY_PRINTSCREEN"
    [Keys.Q] = "LOC_OPTIONS_KEY_Q",
    [Keys.VK_OEM_7] = "LOC_OPTIONS_KEY_QUOTE",
    [Keys.R] = "LOC_OPTIONS_KEY_R",
    -- Modifier key
    -- "LOC_OPTIONS_KEY_RALT"
    [Keys.VK_OEM_6] = "LOC_OPTIONS_KEY_RBRACKET",
    -- Mouse
    -- "LOC_OPTIONS_KEY_RBUTTON"
    -- Modifier key
    -- "LOC_OPTIONS_KEY_RCONTROL"
    -- Not allowed to bind it in main game options.
    -- "LOC_OPTIONS_KEY_RETURN"
    [Keys.VK_RIGHT] = "LOC_OPTIONS_KEY_RIGHT",
    -- Modifier key
    -- "LOC_OPTIONS_KEY_RSHIFT"
    -- "LOC_OPTIONS_KEY_RWIN"
    [Keys.S] = "LOC_OPTIONS_KEY_S",
    -- It actually is valid to bind ScrollLock in the base game.  Disallow it because it feels weird.
    --"LOC_OPTIONS_KEY_SCROLLLOCK"
    [Keys.VK_OEM_1] = "LOC_OPTIONS_KEY_SEMICOLON",
    -- Modifier key
    -- "LOC_OPTIONS_KEY_SHIFT"
    [Keys.VK_OEM_2] = "LOC_OPTIONS_KEY_SLASH",
    [Keys.VK_SPACE] = "LOC_OPTIONS_KEY_SPACE",
    [Keys.T] = "LOC_OPTIONS_KEY_T",
    -- Not allowed to bind it in main game options.
    -- "LOC_OPTIONS_KEY_TAB"
    -- Is this meant to be the backtick key `?  If so, it's not bindable in main game options.
    -- "LOC_OPTIONS_KEY_TILDE"
    [Keys.U] = "LOC_OPTIONS_KEY_U",
    -- Don't know which key this is supposed to be.  Underscore is shift + VK_OEM_MINUS on standard English keyboards and VK_OEM_MINUS is already accounted for.
    -- "LOC_OPTIONS_KEY_UNDERSCORE"
    [Keys.VK_UP] = "LOC_OPTIONS_KEY_UP",
    [Keys.V] = "LOC_OPTIONS_KEY_V",
    [Keys.VK_VOLUME_DOWN] = "LOC_OPTIONS_KEY_VOLUME_DOWN",
    [Keys.VK_VOLUME_MUTE] ="LOC_OPTIONS_KEY_VOLUME_MUTE",
    [Keys.VK_VOLUME_UP] = "LOC_OPTIONS_KEY_VOLUME_UP",
    [Keys.W] = "LOC_OPTIONS_KEY_W",
    [Keys.X] = "LOC_OPTIONS_KEY_X",
    [Keys.Y] = "LOC_OPTIONS_KEY_Y",
    [Keys.Z] = "LOC_OPTIONS_KEY_Z",
  }
};

KeyBindingSetting.__index = KeyBindingSetting;
setmetatable(KeyBindingSetting, BaseSetting);

function KeyBindingSetting:new(defaultValue:table, categoryName:string, settingName:string, tooltip:string, options:table)
  local result = BaseSetting.new(self, defaultValue, categoryName, settingName, tooltip);
  options = options or {};
  result.allowsModifiers = not options.DisallowModifiers;
  result:LoadSavedValue();
  return result;
end

function KeyBindingSetting.MakeValue(keyCode:number, modifiers:table)
  modifiers = modifiers or NO_OPTIONS;
  if KeyBindingSetting.KeyLocalizations[keyCode] then
    return { IsShift = modifiers.Shift or false, IsControl = modifiers.Ctrl or false, IsAlt = modifiers.Alt or false, KeyCode = keyCode };
  else
    return nil;
  end
end

function KeyBindingSetting:ToStringValue() 
  local value = self.Value;
  if value == nil then
    return "";
  else
    return (value.IsShift and "S" or "-") .. (value.IsControl and "C" or "-") .. 
           (value.IsAlt and "A" or "-") .. "+" .. tostring(value.KeyCode);
  end
end

function KeyBindingSetting:ParseValue(value:string)
  if value == "" then 
    return nil;
  end

  return KeyBindingSetting.MakeValue(tonumber(value:sub(5,-1)), 
        {Shift=(value:sub(1,1) == "S"), Ctrl=(value:sub(2,2) == "C"), Alt=(value:sub(3,3) == "A")});
end

---------------------------------------------------------------------------------------------
-- Psuedo-setting that allows mods to show a clickable button in configuration and 
-- attach logic when its value changes.
---------------------------------------------------------------------------------------------
local ActionSetting = {
  Type = Types.ACTION
};
ActionSetting.__index = ActionSetting;
setmetatable(ActionSetting, BaseSetting);

function ActionSetting:new(categoryName:string, settingName:string, tooltip:string)
  local result = BaseSetting.new(self, 0, categoryName, settingName, tooltip);
  return result;
end

function BooleanSetting:ParseValue(value:string)
  return 0;
end

--------------------------------------------------------------------------------------------------
-- Expose the public api in ModSettings.
--------------------------------------------------------------------------------------------------
ModSettings = {
  Types = Types,
  Boolean = BooleanSetting,
  Select = SelectSetting,
  Range = RangeSetting,
  Text = TextSetting,
  KeyBinding = KeyBindingSetting,
  Action = ActionSetting,
};

end