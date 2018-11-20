-- "Main" ui for mod settings.  Actually all this file does is handle the button that is put in the 
-- minimap "toolbar" that opens the settings popup.  The real content lives in ModSettingsPopup.

include("ModSettings")

function ShowModOptions()
  UIManager:QueuePopup(Controls.SettingsPopup, PopupPriority.Current);
end

-- Use this mod functionality to bind a key to bring up the mod setting ui popup.  
-- More just cool than actually useful.
local showModSettingsPopupKeyBinding = ModSettings.KeyBinding:new(ModSettings.KeyBinding.MakeValue(Keys.VK_F5, {CTRL=true}),
    "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_CATEGORY", 
    "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_ACCESS_KEY_BINDING_NAME", 
    "LOC_MOD_SETTINGS_MANAGER_SETTINGS_UI_ACCESS_KEY_BINDING_TOOLTIP");

-- Move the access button from the ui space where it is create into the minimap toolbar.
function InitializeUI() 
  local settingsButton = Controls.SettingsButton;
  local settingsButtonSpacer = Controls.SettingsButtonSpacer;
  local minimapBar = ContextPtr:LookUpControl("/InGame/MinimapPanel/OptionsStack");
  local minimapWoodBackground = ContextPtr:LookUpControl("/InGame/MinimapPanel/MinimapBacking");

  settingsButton:ChangeParent(minimapBar);
  settingsButtonSpacer:ChangeParent(minimapBar);
  minimapBar:CalculateSize();
  minimapBar:ReprocessAnchoring();

  -- Extend wood background by the length of stuff we're adding.
  minimapWoodBackground:SetSizeX(
      minimapWoodBackground:GetSizeX() + settingsButton:GetSizeX() + settingsButtonSpacer:GetSizeX());

  settingsButton:RegisterCallback(Mouse.eLClick, ShowModOptions);
  settingsButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over") end);

  ContextPtr:SetShutdown(OnShutdown);
end

function OnInit(isReload:boolean)
  if isReload then
    InitializeUI();
  end
end

-- Put the minimap toolbar button and other ui elements back in our ui space so it gets destroyed properly.
function OnShutdown()
  local settingsButton = Controls.SettingsButton;
  local settingsButtonSpacer = Controls.SettingsButtonSpacer;
  local minimapWoodBackground = ContextPtr:LookUpControl("/InGame/MinimapPanel/MinimapBacking");

  settingsButton:ChangeParent(ContextPtr);
  settingsButtonSpacer:ChangeParent(ContextPtr);
  -- May not exist when UI is being torn down on loading a new game or exiting to menu.
  if minimapWoodBackground then 
    minimapWoodBackground:SetSizeX(
        minimapWoodBackground:GetSizeX() - settingsButton:GetSizeX() - settingsButtonSpacer:GetSizeX()); 
  end
end

function OnInput(input:table)
  if showModSettingsPopupKeyBinding:MatchesInput(input) then
    ShowModOptions();
  end
end

-- ===========================================================================
function Initialize()
  ContextPtr:SetInitHandler(OnInit);
  ContextPtr:SetInputHandler(OnInput, true);
  Events.LoadScreenClose.Add(InitializeUI);
end

Initialize();