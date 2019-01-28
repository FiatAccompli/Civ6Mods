-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

include("InstanceManager")
include("InputSupport")
include("mod_settings")

-- Maps from categoryName to CategoryUI for settings in that category.
local categories = {};

local labelsManager = InstanceManager:new("CategoryLabel", "Label", Controls.CategoriesStack);
local tabsManager = InstanceManager:new("SettingTab", "Tab", Controls.TabsStack);

-- Hide all tabs in the right side of the popup (the actual setting manipulators) and deselect all the 
-- labels on the left side.
local function HideAllTabs()
  Controls.DefaultSqlTab:SetHide(true);
  Controls.ShowDefaultSql:SetSelected(false);
  for _, ui in pairs(categories) do 
    ui.tab.Tab:SetHide(true);
    ui.label.Label:SetSelected(false);
  end
end

----------------------------------------------------------------------
-- Wrapper classes around the ui and a setting.
----------------------------------------------------------------------
local BaseSettingUIHandler = {}
BaseSettingUIHandler.__index = BaseSettingUIHandler;

function BaseSettingUIHandler:new(setting:table, ui:table)
  local result = setmetatable({setting = setting, ui = ui, cachedValue = setting.Value}, self);
  return result;
end

function BaseSettingUIHandler:RaiseChange(value)
  local oldValue = self.setting.Value;
  LuaEvents.ModSettingsManager_SettingValueChange(
      self.setting.categoryName, self.setting.settingName, value);
  LuaEvents.ModSettingsManager_SettingValueChanged(
      self.setting.categoryName, self.setting.settingName, value, oldValue);
end

function BaseSettingUIHandler:CacheAndUpdateValue()
  self.cachedValue = self.setting.Value;
  self:UpdateUIToValue(self.cachedValue);
end

function BaseSettingUIHandler:RestoreDefault()
  local value = self.setting.playerDefaultValue;
  if value == nil then 
    value = self.setting.defaultValue;
  end
  self:RaiseChange(value);
end

-- Restore the setting to the value cached when the popup was opened (to support
-- cancellation of options screen and restoration of all values to initial values).
function BaseSettingUIHandler:RestoreSettingValue()
  if not self:ValuesEqual(self.setting.Value, self.cachedValue) then 
    self:RaiseChange(self.cachedValue);
  end
end

function BaseSettingUIHandler:SaveValue()
  -- Only save changes.
  if not self:ValuesEqual(self.setting.Value, self.cachedValue) then
    print("Saving value: ", self.setting.storageName, self.setting:ToStringValue());
    local saveValue = self.setting:ToStringValue();
    local defaultValue = self.setting.playerDefaultValue;
    if defaultValue == nil then
      defaultValue = self.setting.defaultValue;
    end
    if self:ValuesEqual(self.setting.Value, defaultValue) then
      print("Is default");
      saveValue = nil;
    end
    GameConfiguration.SetValue(self.setting.storageName, saveValue);
  end
end

function BaseSettingUIHandler:ValuesEqual(v1, v2) 
  return v1 == v2;
end

--------------------------------------------------------------
-- Boolean setting ui handler
--------------------------------------------------------------
local BooleanSettingUIHandler = {};
BooleanSettingUIHandler.__index = BooleanSettingUIHandler;
setmetatable(BooleanSettingUIHandler, BaseSettingUIHandler);

function BooleanSettingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);

  local checkbox = ui.SettingCheckbox;
  checkbox:LocalizeAndSetText(setting.settingName);
  checkbox:LocalizeAndSetToolTip(setting.tooltip);
  checkbox:RegisterCallback(Mouse.eLClick, 
    function()
			local selected = not checkbox:IsSelected();
      result:RaiseChange(selected);
    end);
  result:UpdateUIToValue(setting.Value);
  return result;
end

function BooleanSettingUIHandler:UpdateUIToValue(value)
  self.ui.SettingCheckbox:SetSelected(value);
end

--------------------------------------------------------------
-- Select setting ui handler
--------------------------------------------------------------
local SelectSettingUIHandler = {};
SelectSettingUIHandler.__index = SelectSettingUIHandler;
setmetatable(SelectSettingUIHandler, BaseSettingUIHandler);

function SelectSettingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);

  ui.SettingName:SetText(Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_SETTING_LABEL_FORMATTER", Locale.Lookup(setting.settingName)));
  ui.SettingName:LocalizeAndSetToolTip(setting.tooltip);

  local pulldown = ui.SettingPulldown;
  for i, v in ipairs(setting.values) do
    local instance = {};
    pulldown:BuildEntry("InstanceOne", instance);
    instance.Button:SetVoid1(i);
    instance.Button:LocalizeAndSetText(v);
	end
  
  pulldown:CalculateInternals();
  pulldown:RegisterSelectionCallback(
			function(index)
        local selectedValue = setting.values[index];
        result:RaiseChange(selectedValue);
			end
		);
  result:UpdateUIToValue(setting.Value);
  return result;
end

function SelectSettingUIHandler:UpdateUIToValue(value)
  self.ui.SettingPulldown:GetButton():LocalizeAndSetText(value or "");
end

--------------------------------------------------------------
-- Text setting ui handler
--------------------------------------------------------------
local TextSettingUIHandler = {};
TextSettingUIHandler.__index = TextSettingUIHandler;
setmetatable(TextSettingUIHandler, BaseSettingUIHandler);

function TextSettingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);

  ui.SettingName:SetText(Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_SETTING_LABEL_FORMATTER", Locale.Lookup(setting.settingName)));
  ui.SettingName:LocalizeAndSetToolTip(setting.tooltip);
  ui.SettingText:RegisterStringChangedCallback(function() 
      local value = ui.SettingText:GetText();
      if value ~= setting.Value then
        result:RaiseChange(value);
      end
    end);
  result:UpdateUIToValue(setting.Value);
  return result;
end

function TextSettingUIHandler:UpdateUIToValue(value)
  self.ui.SettingText:SetText(value);
end

-----------------------------------------------------------
-- Global stuff for all keybinding ui handlers as the "set binding" popup is shared among them all.
-----------------------------------------------------------

-- UI handler which is in the process of having its binding changed.  This is non-nil while 
-- we are showing the popup to prompt the user to enter the key.
local activeKeyBindingUIHandler = nil;

function StartActiveKeyBinding(uiHandler)
  activeKeyBindingUIHandler = uiHandler;
  Controls.KeyBindingPopupTitle:SetText(
      Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_KEY_BINDING_FORMATTER", Locale.Lookup(uiHandler.setting.settingName)));
	Controls.KeyBindingPopup:SetHide(false);
	Controls.KeyBindingAlpha:SetToBeginning();
	Controls.KeyBindingAlpha:Play();
	Controls.KeyBindingSlide:SetToBeginning();
	Controls.KeyBindingSlide:Play();
end

function StopActiveKeyBinding()
	Controls.KeyBindingPopup:SetHide(true);
  activeKeyBindingUIHandler = nil;
end

function HandlePossibleBinding(input)
  local uiMsg = input:GetMessageType();
	if uiMsg == KeyEvents.KeyUp then
		local keyCode = input:GetKey();
    if ModSettings.KeyBinding.KeyLocalizations[keyCode] then
      activeKeyBindingUIHandler:SetBinding(
          ModSettings.KeyBinding.MakeValue(keyCode, {Shift=input:IsShiftDown(), Ctrl=input:IsControlDown(), Alt=input:IsAltDown()}));
      StopActiveKeyBinding();
      return true;
    end
  end
  return false;
end

function ClearActiveKeyBinding()
  if (activeKeyBindingUIHandler) then 
    activeKeyBindingUIHandler:SetBinding(ModSettings.KeyBinding.UNBOUND);
	end
  StopActiveKeyBinding();	
end

-- Maps from localized key string to info about what is using that binding.
-- Lazily initialized.
local duplicateBindings = {};
setmetatable(duplicateBindings, 
  {
    __index = function(t,v)
      t[v] = { baseGameBindings = {}, modBindings = {} };
      return t[v];
    end 
  });

function InitializeKeyBindingsForDuplication() 
  -- Clear out all existing binding info
  for k, _ in pairs(duplicateBindings) do 
    duplicateBindings[k] = nil;
  end

  -- Get all the base game bindings
  local count = Input.GetActionCount();
  for i = 0, count-1 do
    local actionId = Input.GetActionId(i);
    if Input.GetActionEnabled(actionId) then
      local name = Locale.Lookup(Input.GetActionName(actionId));
		  local binding1 = Input.GetGestureDisplayString(actionId, 0);
		  local binding2 = Input.GetGestureDisplayString(actionId, 1);
      if binding1 then
        table.insert(duplicateBindings[binding1].baseGameBindings, name);
      end
      if binding2 then
        table.insert(duplicateBindings[binding2].baseGameBindings, name);
      end
    end
  end
end

function MakeDuplicatesActionsMessage(duplicateData)
  local duplicateStrings = {};
  for handler, _ in pairs(duplicateData.modBindings) do
    table.insert(duplicateStrings, "[ICON_Bullet]" .. Locale.Lookup(handler.setting.categoryName) .. ": " .. Locale.Lookup(handler.setting.settingName));
  end
  table.sort(duplicateStrings);
  for _, action in pairs(duplicateData.baseGameBindings) do 
    table.insert(duplicateStrings, 1, "[ICON_Bullet]" .. Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_KEY_BINDING_SOURCE_BASE_GAME", action));
  end
  if #duplicateStrings > 1 then
    return table.concat(duplicateStrings, "[NEWLINE]");
  end
end

function MakeDuplicateMessage(duplicateData)
  local actionsString = MakeDuplicatesActionsMessage(duplicateData);
  if actionsString then
    return Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_KEY_BINDING_DUPLICATE_WARNING_PREAMBLE") .. "[NEWLINE]" .. actionsString;
  end
end

function MakeAllDuplicatesMessage()
  local duplicateStrings = {};

  for binding, duplicateData in pairs(duplicateBindings) do
    local duplicatesMessage = MakeDuplicatesActionsMessage(duplicateData);
    if duplicatesMessage then
      table.insert(duplicateStrings, binding .. "[NEWLINE]" .. duplicatesMessage);
    end
  end
  return #duplicateStrings > 0 and table.concat(duplicateStrings, "[NEWLINE][NEWLINE]") or nil;
end

--------------------------------------------------------------
-- Keybinding ui handler
--------------------------------------------------------------
local KeyBindingUIHandler = {};
KeyBindingUIHandler.__index = KeyBindingUIHandler;
setmetatable(KeyBindingUIHandler, BaseSettingUIHandler);

function KeyBindingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);

  ui.SettingName:SetText(Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_KEY_BINDING_FORMATTER", Locale.Lookup(setting.settingName)));
  ui.SettingName:LocalizeAndSetToolTip(setting.tooltip);
  ui.Binding:RegisterCallback(Mouse.eLClick, 
    function()
      StartActiveKeyBinding(result);
    end);
  result:UpdateUIToValue(setting.Value);

  return result;
end

function KeyBindingUIHandler:ValueToString(value) 
  return ModSettings.KeyBinding.ValueToString(value);
end

function KeyBindingUIHandler:RemoveFromDuplicateDetection(value)
  if value ~= nil then
    local keyBindingString = self:ValueToString(value);
    local duplicateData = duplicateBindings[keyBindingString];
    duplicateData.modBindings[self] = nil;
    
    local duplicateMessage = MakeDuplicateMessage(duplicateData);
    for handler, _ in pairs(duplicateData.modBindings) do
      handler:UpdateDuplicateUI(duplicateMessage);
    end
  end
end

function KeyBindingUIHandler:AddToDuplicateDetection(value)
  if value ~= nil then
    local keyBindingString = self:ValueToString(value);
    local duplicateData = duplicateBindings[keyBindingString];
    duplicateData.modBindings[self] = true;

    local duplicateMessage = MakeDuplicateMessage(duplicateData);
    for handler, _ in pairs(duplicateData.modBindings) do
      handler:UpdateDuplicateUI(duplicateMessage);
    end
  end
end

function KeyBindingUIHandler:UpdateDuplicateUI(message:string)
  self.ui.Conflicts:SetHide(not message);
  self.ui.Conflicts:SetToolTipString(message);
end

function KeyBindingUIHandler:SetBinding(value) 
  self:RaiseChange(value);
end

function KeyBindingUIHandler:ValuesEqual(v1, v2)
  if v1 == nil or v2 == nil then 
    return v1 == v2;
  end
  return v1.KeyCode == v2.KeyCode and
         v1.IsShift == v2.IsShift and
         v1.IsControl == v2.IsControl and
         v1.IsAlt == v2.IsAlt;
end

function KeyBindingUIHandler:UpdateUIToValue(value, oldValue)
  self:RemoveFromDuplicateDetection(oldValue);
  if value then 
    self:AddToDuplicateDetection(value);
    self.ui.Binding:SetText(self:ValueToString(value));
  else
    self:UpdateDuplicateUI(nil);
    self.ui.Binding:SetText("");
  end
end

--------------------------------------------------------------
-- Range setting ui handler
--------------------------------------------------------------
local RangeSettingUIHandler = {};
RangeSettingUIHandler.__index = RangeSettingUIHandler;
setmetatable(RangeSettingUIHandler, BaseSettingUIHandler);

function RangeSettingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);

  ui.SettingName:SetText(Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_SETTING_LABEL_FORMATTER", Locale.Lookup(setting.settingName)));
  ui.SettingName:LocalizeAndSetToolTip(setting.tooltip);
  local steps = setting.steps;
  if steps and steps > 0 then
    ui.SettingSlider:SetNumSteps(steps);
    ui.SettingSlider:RegisterSliderCallback(function()
			  local step = ui.SettingSlider:GetStep();
        local value = setting.min + (setting.max - setting.min) / setting.steps * step;
        result:UpdateDisplayValue(value);
        if value ~= setting.Value then 
  			  result:RaiseChange(value);
        end
		  end);
  else
    ui.SettingSlider:SetValue((setting.Value - setting.min) / (setting.max - setting.min));
    ui.SettingSlider:RegisterSliderCallback(function()
      local value = setting.min + (setting.max - setting.min) * ui.SettingSlider:GetValue();
      result:UpdateDisplayValue(value);
      if value ~= setting.Value then
        result:RaiseChange(value); 
      end
    end);
  end
  result:UpdateUIToValue(setting.Value);
  return result;
end

function RangeSettingUIHandler:UpdateUIToValue(value)
  self:UpdateDisplayValue(value);
  local steps = self.setting.steps;
  if steps and steps > 0 then
    local stepSize = (self.setting.max - self.setting.min) / (steps);
    local step = (self.setting.Value - self.setting.min) / stepSize;
    step = math.min(steps, math.max(0, step));
    self.ui.SettingSlider:SetStep(step);
  else
    self.ui.SettingSlider:SetValue((self.setting.Value - self.setting.min) / (self.setting.max - self.setting.min));
  end
end

function RangeSettingUIHandler:UpdateDisplayValue(value)
  self.ui.DisplayValue:LocalizeAndSetText(self.setting.valueFormatter, value or 0);
end

--------------------------------------------------------------
-- Action ui handler
--------------------------------------------------------------
local ActionSettingUIHandler = {};
ActionSettingUIHandler.__index = ActionSettingUIHandler;
setmetatable(ActionSettingUIHandler, BaseSettingUIHandler);

function ActionSettingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);
  local button = ui.ActionButton;
  button:LocalizeAndSetText(setting.settingName);
  button:LocalizeAndSetToolTip(setting.tooltip);
  button:RegisterCallback(Mouse.eLClick, 
    function()
      result:RaiseChange(0);
    end);
  return result;
end

function ActionSettingUIHandler:RestoreDefault()
  -- Do nothing so we don't trigger the action.
end

function ActionSettingUIHandler:UpdateUIToValue(value)
  -- Nothing to do here.
end

--------------------------------------------------------------
-- Header ui handler
--------------------------------------------------------------
local HeaderSettingUIHandler = {};
HeaderSettingUIHandler.__index = HeaderSettingUIHandler;
setmetatable(HeaderSettingUIHandler, BaseSettingUIHandler);

function HeaderSettingUIHandler:new(setting:table, ui:table)
  local result = BaseSettingUIHandler.new(self, setting, ui);
  ui.Header:LocalizeAndSetText(setting.settingName);
  ui.Header:LocalizeAndSetToolTip(setting.tooltip);
  return result;
end

function HeaderSettingUIHandler:RestoreDefault()
end

function HeaderSettingUIHandler:HideSpacer()
  self.ui.Spacer:SetHide(true);
end

function HeaderSettingUIHandler:UpdateUIToValue(value)
  -- Nothing to do here.
end

------------------------------------------------------------------------------
-- Class to handle ui for a single category of settings.
------------------------------------------------------------------------------
local CategoryUI = {};
CategoryUI.__index = CategoryUI;

function CategoryUI:new(categoryName:string)
  local label = labelsManager:GetInstance();
  local displayName = Locale.ToUpper(Locale.Lookup(categoryName));
  label.Label:SetText(displayName);
  local tab = tabsManager:GetInstance();

  local booleansManager = InstanceManager:new("BooleanSetting", "Setting", tab.SettingsStack);
  local rangesManager = InstanceManager:new("RangeSetting", "Setting", tab.SettingsStack);
  local textsManager = InstanceManager:new("TextSetting", "Setting", tab.SettingsStack);
  local selectsManager = InstanceManager:new("SelectSetting", "Setting", tab.SettingsStack);
  local keyBindingsManager = InstanceManager:new("KeyBindingSetting", "Setting", tab.SettingsStack);
  local actionsManager = InstanceManager:new("ActionSetting", "Setting", tab.SettingsStack);
  local headersManager = InstanceManager:new("HeaderSetting", "Setting", tab.SettingsStack);

  local result = setmetatable({settings = {},
                               displayName = displayName,
                               label = label,
                               tab = tab,
                               booleansManager = booleansManager,
                               rangesManager = rangesManager,
                               textsManager = textsManager,
                               selectsManager = selectsManager,
                               keyBindingsManager = keyBindingsManager,
                               actionsManager = actionsManager,
                               headersManager = headersManager },
                              self);
  label.Label:RegisterCallback(Mouse.eLClick, 
    function()
      result:ShowSettings()
    end);
  tab.RestoreDefaults:RegisterCallback(Mouse.eLClick, 
    function()
      result:RestoreDefaults();
    end);
  return result;
end

function CategoryUI:ShowSettings()
  HideAllTabs();
  self.label.Label:SetSelected(true);
  self.tab.Tab:SetHide(false);
end

function CategoryUI:SetHeaderInfo(title:string, description:string, texture:string)
  self.tab.AboutTitle:SetText(Locale.ToUpper(Locale.Lookup(title)));
  self.tab.AboutDescription:LocalizeAndSetText(description);
  self.tab.AboutImage:SetTexture(texture);
  if self.tab.Header:IsHidden() then
    self.tab.Header:SetHide(false);
    self.tab.SettingsHolder:SetOffsetY(self.tab.SettingsHolder:GetOffsetY() + 75);
  end
end

function CategoryUI:AddSetting(setting:table)
  if self.settings[setting.settingName] then
    -- Already have a setting of this name registered.  We assume that mod writers are well behaved 
    -- and such a setting will be identical to what is already registered.  This way mods can refer 
    -- to the same setting across multiple files if they need to.
    return
  end

  local ui;
  local uiHandler;
  if setting.Type == ModSettings.Types.BOOLEAN then
    ui = self.booleansManager:GetInstance();
    uiHandler = BooleanSettingUIHandler:new(setting, ui);
  elseif setting.Type == ModSettings.Types.SELECT then
    ui = self.selectsManager:GetInstance();
    uiHandler = SelectSettingUIHandler:new(setting, ui);
  elseif setting.Type == ModSettings.Types.RANGE then
    ui = self.rangesManager:GetInstance();
    uiHandler = RangeSettingUIHandler:new(setting, ui);
  elseif setting.Type == ModSettings.Types.TEXT then
    ui = self.textsManager:GetInstance();
    uiHandler = TextSettingUIHandler:new(setting, ui);
  elseif setting.Type == ModSettings.Types.KEY_BINDING then
    ui = self.keyBindingsManager:GetInstance();
    uiHandler = KeyBindingUIHandler:new(setting, ui);
  elseif setting.Type == ModSettings.Types.ACTION then
    ui = self.actionsManager:GetInstance();
    uiHandler = ActionSettingUIHandler:new(setting, ui);
  elseif setting.Type == ModSettings.Types.HEADER then
    ui = self.headersManager:GetInstance();
    uiHandler = HeaderSettingUIHandler:new(setting, ui);
    if self.tab.SettingsStack:GetNumChildren() == 1 then 
      uiHandler:HideSpacer();
    end
  end

  self.settings[setting.settingName] = {
    setting = setting,
    uiHandler = uiHandler
  };
end

function CategoryUI:CacheAndUpdateValues()
  for _, s in pairs(self.settings) do 
    s.uiHandler:CacheAndUpdateValue();
  end
end

function CategoryUI:RestoreDefaults()
  for _, s in pairs(self.settings) do
    s.uiHandler:RestoreDefault();
  end
end

function RestoreAllDefaults()
  for _, ui in pairs(categories) do
    ui:RestoreDefaults();
  end
end

function GetCategory(name:string)
  -- Create category ui if we haven't seen this category before.
  local categoryUI = categories[name];
  if categoryUI == nil then 
    categoryUI = CategoryUI:new(name);
    categoryUI.tab.Tab:SetHide(true);
    categories[name] = categoryUI;
  end
  return categoryUI;
end

function RegisterPageHeader(categoryName:string, title:string, description:string, texture:string)
  print("RegisterPageHeader", categoryName, title, description, texture);
  GetCategory(categoryName):SetHeaderInfo(title, description, texture);
end

function RegisterModSetting(setting:table)
  GetCategory(setting.categoryName):AddSetting(setting); 
end

function OnSettingValueChanged(categoryName:string, settingName:string, value, oldValue)
  local categoryUI = categories[categoryName];
  if categoryUI ~= nil then
    local setting = categoryUI.settings[settingName];
    if setting ~= nil then
      setting.uiHandler:UpdateUIToValue(value, oldValue);
    end
  end
end

function CompareCategories(a, b)
  return a:GetText() < b:GetText();
end

function OnShow()
  for category in pairs(categories) do
    categories[category] = nil;
  end
  labelsManager:DestroyInstances();
  tabsManager:DestroyInstances();

  Controls.DuplicateBindingsPopup:SetHide(true);
  InitializeKeyBindingsForDuplication();
  LuaEvents.ModSettingsManager_UIReadyForRegistration();

  Controls.CategoriesStack:SortChildren(CompareCategories);

  local firstCategory = nil;
  for _, ui in pairs(categories) do 
    ui:CacheAndUpdateValues()
    firstCategory = firstCategory or ui;
    if ui.displayName < firstCategory.displayName then
      firstCategory = ui;
    end
    if ui.label.Label == firstLabel then
      ui:ShowSettings();
    end
  end

  firstCategory:ShowSettings();
  Controls.TabScrollPanel:SetScrollValue(0);

  -- Switch input context. This prevents base game bindings from applying while in this popup.
  if Input.GetActiveContext() ~= InputContext.GameOptions then
		Input.PushActiveContext( InputContext.GameOptions );
	end
end

function ClosePopup() 
	-- Only pop the context if what we expect is the current context.
	if(Input.GetActiveContext() == InputContext.GameOptions) then
		Input.PopContext();
	end
  UIManager:DequeuePopup(ContextPtr);
end

function CancelPopup()
  for _, ui in pairs(categories) do
    for _, s in pairs(ui.settings) do
      s.uiHandler:RestoreSettingValue();
    end
  end
  ClosePopup();
end

function SaveAndClosePopup()
  for _, ui in pairs(categories) do 
    for _, s in pairs(ui.settings) do 
      s.uiHandler:SaveValue();
    end
  end
  ClosePopup();
end

function CancelDuplicates()
  Controls.DuplicateBindingsPopup:SetHide(true);
end

function AcceptDuplicates()
  SaveAndClosePopup();
end

function ConfirmPopup()
  local duplicatesMessage = MakeAllDuplicatesMessage();
  print("All duplicates is", duplicatesMessage, duplicatesMessage and string.len(duplicatesMessage));
  if duplicatesMessage then
    Controls.AllDuplicatedBindingsLabel:SetText(duplicatesMessage);
    Controls.DuplicateBindingsPopup:SetHide(false);
  else
    SaveAndClosePopup();
  end
end

function SqlEscape(value:string)
  return value:gsub("\"", "\"\"");
end

function ShowDefaultsSql()
  HideAllTabs();
  Controls.ShowDefaultSql:SetSelected(true);
  local sql = {Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_DEFAULTS_SQL_PREAMBLE"), "", 
               "INSERT OR REPLACE INTO ModSettingsUserDefaults(StorageName, Value) VALUES " };
  for _, ui in pairs(categories) do 
    for _, s in pairs(ui.settings) do
      if not s.uiHandler:ValuesEqual(s.setting.Value, s.setting.defaultValue) then
        table.insert(sql, "-- " .. Locale.Lookup(s.setting.categoryName) .. ": " .. Locale.Lookup(s.setting.settingName));
        table.insert(sql, "(\"" .. SqlEscape(s.setting.storageName) .. "\", \"" .. SqlEscape(s.setting:ToStringValue()) .. "\"),");
      end
    end
  end
  table.insert(sql, table.remove(sql):sub(1, -2) .. ";");

  local sqlString = table.concat(sql, "\n");
  if #sql == 3 then
    sqlString = "-- " .. Locale.Lookup("LOC_MOD_SETTINGS_MANAGER_NO_SETTINGS_NON_DEFAULT_VALUES");
  end
  Controls.SqlText:SetText(sqlString);
  Controls.DefaultSqlTab:SetHide(false);
end

function OnInput(input) 
	local uiMsg = input:GetMessageType();
	if uiMsg == KeyEvents.KeyUp then
		local uiKey = input:GetKey();
    if activeKeyBindingUIHandler then
		  if uiKey == Keys.VK_ESCAPE then
        StopActiveKeyBinding();
        return true;
      else
        if HandlePossibleBinding(input) then
          return true;
        end
      end
    elseif not Controls.DuplicateBindingsPopup:IsHidden() then
      if uiKey == Keys.VK_ESCAPE then
        CancelDuplicates();
        return true;
      end
    else
      if uiKey == Keys.VK_ESCAPE then
			  CancelPopup();
        return true;
      end
		end
	end
	
	return false;
end

-- ===========================================================================
function Initialize()
  Controls.WindowCloseButton:RegisterCallback(Mouse.eLClick, CancelPopup);
  Controls.WindowCloseButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
  Controls.ConfirmButton:RegisterCallback(Mouse.eLClick, ConfirmPopup);
  Controls.ConfirmButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
  Controls.ShowDefaultSql:RegisterCallback(Mouse.eLClick, ShowDefaultsSql);
  Controls.ShowDefaultSql:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
  Controls.RestoreAllDefaults:RegisterCallback(Mouse.eLClick, RestoreAllDefaults);
  Controls.RestoreAllDefaults:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);

  Controls.ClearBindingButton:RegisterCallback(Mouse.eLClick, ClearActiveKeyBinding);
  Controls.ClearBindingButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
  Controls.CancelBindingButton:RegisterCallback(Mouse.eLClick, StopActiveKeyBinding);
  Controls.CancelBindingButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);

  Controls.CancelDuplicatesButton:RegisterCallback(Mouse.eLClick, CancelDuplicates);
  Controls.CancelDuplicatesButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
  Controls.AcceptDuplicatesButton:RegisterCallback(Mouse.eLClick, AcceptDuplicates);
  Controls.AcceptDuplicatesButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);

  ContextPtr:SetShowHandler(OnShow);
  ContextPtr:SetInputHandler(OnInput, true);

  LuaEvents.ModSettingsManager_RegisterSetting.Add(RegisterModSetting);
  LuaEvents.ModSettingsManager_RegisterPageHeader.Add(RegisterPageHeader);
  LuaEvents.ModSettingsManager_SettingValueChanged.Add(OnSettingValueChanged);
end

Initialize();
