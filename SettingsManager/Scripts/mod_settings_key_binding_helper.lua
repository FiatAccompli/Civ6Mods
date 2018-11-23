-- Contains the ModSettings.KeyBinding:MatchesInput method.  This can't be defined in the main 
-- mod_settings file because it references some api values in setup that are only available in a 
-- ui context, and it's perfectly valid to have settings in gameplay scripts

include("InputSupport");

local NO_OPTIONS = {};
local inSubScreen = false;

local ONLY_WORLD_INPUT_CONTEXT = { [InputContext.World] = true };
local ONLY_SELECTION_INTERFACE_MODE = { [InterfaceModeTypes.SELECTION] = true };
local ALL_INTERFACE_MODES = {};
for _, mode in pairs(InterfaceModeTypes) do 
  ALL_INTERFACE_MODES[mode] = true;
end

KeyBindingHelper = {};

KeyBindingHelper.ONLY_SELECTION_INTERFACE_MODE = ONLY_SELECTION_INTERFACE_MODE;
KeyBindingHelper.ONLY_WORLD_INPUT_CONTEXT = ONLY_WORLD_INPUT_CONTEXT;
KeyBindingHelper.ALL_INTERFACE_MODES = ALL_INTERFACE_MODES;

function KeyBindingHelper.InputMatches(value:table, input:table, options:table) 
  options = options or NO_OPTIONS;

  if value == nil then
    return false;
  end

  -- Generally bindings should only be active in main game mode.  Not in menus, diplomacy or other input contexts.
  local permittedContext = false;
  local context = Input.GetActiveContext();

  if not (options.InputContexts or ONLY_WORLD_INPUT_CONTEXT)[Input.GetActiveContext()] then
    return false;
  end
  if not (options.InterfaceModes or ONLY_SELECTION_INTERFACE_MODE)[UI.GetInterfaceMode()] then
    return false;
  end
  if not (options.InSubScreen) and inSubScreen then 
    return false;
  end

	if input:GetMessageType() == (options.Event or KeyEvents.KeyUp) then
		return input:GetKey() == value.KeyCode and 
           input:IsShiftDown() == value.IsShift and 
           input:IsControlDown() == value.IsControl and 
           input:IsAltDown() == value.IsAlt;
  end
  return false;
end
