-- ============================= --
--	Copyright 2019 FiatAccompli  --
-- ============================= --

--------------------------------------------------------------------------------
-- Example screen that lives under the LaunchBar in UI z-order.
-- Demonstrates plugin functionality for adding a launchbar button and handling 
-- launchbar custom button events.
--------------------------------------------------------------------------------

-----------------------------------
-- Minimap bar registration stuff
-----------------------------------
local MINIMAP_BAR_BUTTON_ID = "MinimapButtonExample";
local MINIMAP_BAR_BUTTON_2_ID = "MinimapButtonExample2";

function OnRegisterMinimapBarAdditions()
  local buttonInfo = {
    Icon = "ICON_UNIT_JAPANESE_SAMURAI",
    --Texture = "LaunchBar_Hook_GreatPeople";
    Color = UI.GetColorValue("COLOR_PLAYER_BARBARIAN_PRIMARY");
    Tooltip = "Minimap button tooltip";
    Id = MINIMAP_BAR_BUTTON_ID;
  };
  LuaEvents.MinimapBar_AddButton(buttonInfo);

  local buttonInfo2 = {
    Texture = "LaunchBar_Hook_GreatPeople";
    Tooltip = "Minimap button 2 tooltip";
    Id = MINIMAP_BAR_BUTTON_2_ID;
  };
  LuaEvents.MinimapBar_AddButton(buttonInfo2);
end

function OnMinimapBarCustomButtonClicked(id:string)
  if id == MINIMAP_BAR_BUTTON_ID then
    print("Minimap button clicked");
  end
  if id == MINIMAP_BAR_BUTTON_2_ID then
    print("Minimap button 2 clicked");
  end
end

function Initialize()
  -- Minimap bar registration stuff
  LuaEvents.MinimapBar_RegisterAdditions.Add(OnRegisterMinimapBarAdditions);
  LuaEvents.MinimapBar_CustomButtonClicked.Add(OnMinimapBarCustomButtonClicked);

  -- Register button (if this is a reload of this context the MinimapBar_RegisterAdditions
  -- event will not be forthcoming).
  OnRegisterMinimapBarAdditions();

  print("****** minimap_toolbar_example is live! *******");
end

Initialize();