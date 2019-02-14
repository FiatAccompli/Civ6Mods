-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

-- "Main" ui for mod settings.  Actually all this file does is handle the setup of the 
-- minimap bar button and handle keyboard input to open the popup. The real content 
-- lives in ModSettingsPopup.

include("mod_settings")
include("mod_settings_key_binding_helper")

function OpenModOptions()
  UIManager:QueuePopup(Controls.SettingsPopup, PopupPriority.Current);
end

-- Use this mod functionality to bind a key to bring up the mod setting ui popup.  
-- More just cool than actually useful.
ModSettings.PageHeader(
  "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_CATEGORY", 
  "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_CATEGORY",
  "LOC_MOD_SETTINGS_MANAGER_SETTINGS_DESCRIPTION", 
  "fiataccompli_logo.dds");

local showModSettingsPopupKeyBinding = ModSettings.KeyBinding:new(ModSettings.KeyBinding.MakeValue(Keys.VK_F1, {Ctrl=true}),
    "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_CATEGORY", 
    "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_ACCESS_KEY_BINDING_NAME", 
    "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_ACCESS_KEY_BINDING_TOOLTIP");

local MINIMAP_BAR_BUTTON_ID = "SettingsManagerMinimapButton";

function OnRegisterMinimapBarAdditions()
  local buttonInfo = {
    Texture = "mod_settings_minimap_icon.dds";
    Tooltip = "LOC_MOD_SETTINGS_MANAGER_MOD_SETTINGS";
    Id = MINIMAP_BAR_BUTTON_ID;
  };
  LuaEvents.MinimapBar_AddButton(buttonInfo);
end

function OnMinimapBarCustomButtonClicked(id:string)
  if id == MINIMAP_BAR_BUTTON_ID then
    OpenModOptions();
  end
end

function OnInput(input:table)
  if KeyBindingHelper.InputMatches(showModSettingsPopupKeyBinding.Value, input) then
    OpenModOptions();
  end
end

-- ===========================================================================
function Initialize()
  ContextPtr:SetInputHandler(OnInput, true);

  -- Minimap bar registration stuff
  LuaEvents.MinimapBar_RegisterAdditions.Add(OnRegisterMinimapBarAdditions);
  LuaEvents.MinimapBar_CustomButtonClicked.Add(OnMinimapBarCustomButtonClicked);

  -- Register button (if this is a reload of this context the MinimapBar_RegisterAdditions
  -- event will not be forthcoming).
  OnRegisterMinimapBarAdditions();
  ContextPtr:SetHide(false);
end

Initialize();