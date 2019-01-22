-- ============================= --
--	Copyright 2019 FiatAccompli  --
-- ============================= --

-- Using a different technique for the minimap toolbar because other mods (notably More Lenses) 
-- change minimappanel.lua/minimappanel.xml in meaningful ways so the more straightforward 
-- (and notably more desirable) technique of replacing the base file would make that mod 
-- incompatible.  And since I like that mod something different needs to be done.  
-- The technique of reparenting a control into the minimap toolbar achieves the same 
-- result (although it is notably more ugly (e.g. broken) for context hotloads).

local minimapBarButtons = {};

function UpdateMinimapWoodBackgroundSize()
  local minimapBar = ContextPtr:LookUpControl("/InGame/MinimapPanel/OptionsStack");
  local minimapWoodBackground = ContextPtr:LookUpControl("/InGame/MinimapPanel/MinimapBacking");

  -- May not exist when UI is being torn down on loading a new game or exiting to menu.
  if minimapWoodBackground and minimapBar then
    minimapBar:CalculateSize();
    minimapBar:ReprocessAnchoring();

    minimapWoodBackground:SetSizeX(minimapBar:GetSizeX() + 75);
  end
end

function OnAddMinimapBarButton(buttonInfo:table) 
  local buttonId = buttonInfo.Id;
  local buttonInstance = minimapBarButtons[buttonId];

  if not buttonInstance then
    buttonInstance = {};
    ContextPtr:BuildInstanceForControl("MinimapBarButtonInstance", buttonInstance, Controls.AdditionalButtons);
    minimapBarButtons[buttonId] = buttonInstance;
    UpdateMinimapWoodBackgroundSize();
  end

  if buttonInfo.Icon then
    buttonInstance.Image:SetIcon(buttonInfo.Icon);
  else
	  buttonInstance.Image:SetTexture(buttonInfo.Texture);
  end
  buttonInstance.Image:SetColor(buttonInfo.Color or 0xFFFFFFFF);
	buttonInstance.Button:LocalizeAndSetToolTip(buttonInfo.Tooltip or "");
	buttonInstance.Button:RegisterCallback(Mouse.eLClick, 
      function()
        LuaEvents.MinimapBar_CustomButtonClicked(buttonId);
      end);
	buttonInstance.Button:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
end

-- Move the access button from the ui space where it is created into the minimap toolbar.
function InitializeUI() 
  local buttonsHolder = Controls.AdditionalButtons;
  local minimapBar = ContextPtr:LookUpControl("/InGame/MinimapPanel/OptionsStack");

  buttonsHolder:ChangeParent(minimapBar);

  UpdateMinimapWoodBackgroundSize();

  LuaEvents.MinimapBar_RegisterAdditions();
end

function OnInit(isReload:boolean)
  if isReload then
    InitializeUI();
  end
end

-- Put the additonal toolbar buttons back in our ui space so it gets destroyed properly.
function OnShutdown()
  local buttonsHolder = Controls.AdditionalButtons;
  buttonsHolder:ChangeParent(ContextPtr);

  UpdateMinimapWoodBackgroundSize();
end

-- ===========================================================================
function Initialize()
  ContextPtr:SetInitHandler(OnInit);
  ContextPtr:SetShutdown(OnShutdown);

  LuaEvents.MinimapBar_AddButton.Add(OnAddMinimapBarButton);

  Events.LoadScreenClose.Add(InitializeUI);
end

Initialize();