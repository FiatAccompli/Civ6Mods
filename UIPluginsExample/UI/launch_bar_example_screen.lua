-- ============================= --
--	Copyright 2019 FiatAccompli  --
-- ============================= --

--------------------------------------------------------------------------------
-- Example screen that lives under the LaunchBar in UI z-order.
-- Demonstrates plugin functionality for adding a launchbar button and handling 
-- launchbar custom button events.
--------------------------------------------------------------------------------

-----------------------------------
-- Launch bar registration stuff
-----------------------------------
local LAUNCH_BAR_BUTTON_ID = "LaunchBarButtonExample";

function OnLaunchBarCustomButtonClicked(buttonId:string)
  if buttonId == LAUNCH_BAR_BUTTON_ID then
    print("Launch bar example button clicked!");
    if ContextPtr:IsHidden() then
      Open();
    else
      Close();
    end
  end
end

function OnLaunchBarCloseAllExcept(activeId:string)
  print("Launch bar CloseAll", activeId);
  if activeId ~= LAUNCH_BAR_BUTTON_ID and not ContextPtr:IsHidden() then
    Close();
  end
end

function OnRegisterLaunchBarAdditions()
  textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas("ICON_UNIT_JAPANESE_SAMURAI", 38);
  local launchBarButtonInfo = {
    --ICON TEXTURE
    IconTexture = {
      --OffsetX = textureOffsetX;
      --OffsetY = textureOffsetY+3;
      --Sheet = textureSheet;
      Icon = "ICON_UNIT_JAPANESE_SAMURAI",
      --Sheet = "LaunchBar_Hook_GreatPeople",
      Color = UI.GetColorValue("COLOR_PLAYER_BARBARIAN_PRIMARY");
    };

    -- BASE TEXTURE (Treat it as Button Texture)
    BaseTexture = {
      OffsetX = 0;
      OffsetY = 0;
      Sheet = "LaunchBar_Hook_GreatPeopleButton";
      --Color = UI.GetColorValue("COLOR_BLUE");
      HoverOffsetX = 0;
      HoverOffsetY = 49;
    };

    Tooltip = "Launch bar button tooltip";
    Id = LAUNCH_BAR_BUTTON_ID;
  }

  LuaEvents.LaunchBar_AddButton(launchBarButtonInfo);
end

--
function Close()
  UIManager:DequeuePopup(ContextPtr)
end

function Open()
  if not UIManager:IsInPopupQueue(ContextPtr) then
    LuaEvents.LaunchBar_EnsureExclusive(LAUNCH_BAR_BUTTON_ID);
		-- Queue the screen as a popup, but we want it to render at it's z-order in the hierarchy, not on top of everything.
		local kParameters = {};
		kParameters.RenderAtCurrentParent = true;
		kParameters.InputAtCurrentParent = true;
		kParameters.AlwaysVisibleInQueue = true;
		UIManager:QueuePopup(ContextPtr, PopupPriority.Low, kParameters);
		UI.PlaySound("UI_Screen_Open");
	end
end

function Initialize()
  -- Standard screen handling stuff
  Controls.ModalScreenTitle:SetText(Locale.ToUpper("Sample Plugins Screen"));
	Controls.ModalScreenClose:RegisterCallback(Mouse.eLClick, Close);

  -- Launch bar registration stuff
  LuaEvents.LaunchBar_RegisterAdditions.Add(OnRegisterLaunchBarAdditions);
  LuaEvents.LaunchBar_CustomButtonClicked.Add(OnLaunchBarCustomButtonClicked);
  LuaEvents.LaunchBar_CloseAllExcept.Add(OnLaunchBarCloseAllExcept);

  -- Register button (if this is a reload of this context the LaunchBar_RegisterAdditions
  -- event will not be forthcoming).
  OnRegisterLaunchBarAdditions();

  print("****** launch_bar_example_screen is live! *******");
end

Initialize();