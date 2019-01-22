-- ============================= --
--	Copyright 2019 FiatAccompli  --
-- ============================= --

--------------------------------------------------------------------------------
-- Example screen that lives under the partial screen hooks bar in UI z-order.
-- Demonstrates plugin functionality for adding a partial screen hook button and
-- handling partial screen hook custom button events.
--------------------------------------------------------------------------------

------------------------------------------
-- Standard partial screen behavior support
------------------------------------------
include("AnimSidePanelSupport");

local screenSlideAnim;

------------------------------------------
-- Partial screen hook registration stuff
------------------------------------------
local PARTIAL_SCREEN_BUTTON_ID = "PartialScreenHookButtonExample";

function OnRegisterPartialScreenHookAdditions()
  local buttonInfo = {
    Icon = "ICON_UNIT_JAPANESE_SAMURAI",
    --Texture = "LaunchBar_Hook_GreatPeople";
    Color = UI.GetColorValue("COLOR_PLAYER_BARBARIAN_PRIMARY");
    Tooltip = "Partial screen button tooltip";
    Id = PARTIAL_SCREEN_BUTTON_ID;
  };

  LuaEvents.PartialScreenHooks_AddButton(buttonInfo);
end

function OnPartialScreenButtonClicked(id:string)
  if id == PARTIAL_SCREEN_BUTTON_ID then
    if screenSlideAnim.IsVisible() then
      screenSlideAnim.Hide();
    else
      screenSlideAnim.Show();
    end
  end
end

function OnPartialScreenHooksClose(id:string)
  if id ~= PARTIAL_SCREEN_BUTTON_ID then
    screenSlideAnim.Hide();
  end
end

function Initialize()
  -- Standard screen handling stuff
  screenSlideAnim = CreateScreenAnimation(Controls.SlideAnim);
	Controls.CloseListButton:RegisterCallback( Mouse.eLClick, screenSlideAnim.Hide );	

  -- Partial screen hook registration stuff
  LuaEvents.PartialScreenHooks_RegisterAdditions.Add(OnRegisterPartialScreenHookAdditions);
  LuaEvents.PartialScreenHooks_CustomButtonClicked.Add(OnPartialScreenButtonClicked);
  LuaEvents.PartialScreenHooks_CloseAllExcept.Add(OnPartialScreenHooksClose);

  -- Register button (if this is a reload of this context the PartialScreenHooks_RegisterAdditions
  -- event will not be forthcoming).
  OnRegisterPartialScreenHookAdditions();

  print("****** partial_screen_example is live! *******");
end

Initialize();