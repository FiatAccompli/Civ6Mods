-- "Main" ui for mod settings.  Actually all this file does is handle the button that is put in the 
-- minimap "toolbar" that opens the settings popup.  The real content lives in ModSettingsPopup.

local function ShowModOptions()
  UIManager:QueuePopup(Controls.SettingsPopup, PopupPriority.Current);
end

-- Move the access button from the ui space where it is create into the minimap toolbar.
local function InitializeUI() 
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

local function OnInit(isReload:boolean)
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

-- ===========================================================================
local function Initialize()
  ContextPtr:SetInitHandler(OnInit);  
  Events.LoadScreenClose.Add(InitializeUI);
end

Initialize();