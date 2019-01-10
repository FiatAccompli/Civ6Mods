-- Add new command for melee attack
INSERT INTO UnitCommands 
    (CommandType, Description, 
     Help, DisabledHelp, Icon, Sound, VisibleInUI, HoldCycling, CategoryInUI, InterfaceMode, PrereqTech, PrereqCivic, MaxEra, HotkeyId, IsModCommand)
VALUES ('MOD_KEYBOARD_NAVIGATION_UNITCOMMAND_MELEE_ATTACK', 'LOC_MORE_KEY_BINDINGS_UNITCOMMAND_MELEE_ATTACK_DESCRIPTION', 
        null, null, 'ICON_NOTIFICATION_DECLARE_WAR', null, 1, 1, 'ATTACK', 'INTERFACEMODE_MELEE_ATTACK', null, null, -1, 'Attack', 1);

-- Main attack for air units.
UPDATE UnitOperations
SET HotkeyId = 'Attack'
WHERE OperationType = 'UNITOPERATION_AIR_ATTACK';

-- Alternate "attacks"
UPDATE UnitCommands
SET ModHotkeyDescription = 'LOC_MORE_KEY_BINDINGS_UNIT_ACTION_ALTERNATE_ATTACK',  ModHotkey = 'S--+A'
WHERE CommandType = 'UNITCOMMAND_PRIORITY_TARGET';

UPDATE UnitOperations
SET ModHotkeyDescription = 'LOC_MORE_KEY_BINDINGS_UNIT_ACTION_ALTERNATE_ATTACK',  ModHotkey = 'S--+A'
WHERE OperationType = 'UNITOPERATION_COASTAL_RAID';

-- Heals

UPDATE UnitOperations
SET ModHotkeyDescription = 'LOC_MORE_KEY_BINDINGS_UNIT_ACTION_HEAL',  ModHotkey = 'S--+A'
WHERE OperationType = 'UNITOPERATION_HEAL';

-- Cancel
UPDATE UnitCommands
SET ModHotkeyDescription = 'LOC_MORE_KEY_BINDINGS_UNIT_ACTION_CANCEL',  ModHotkey = 'S--+Z'
WHERE CommandType = 'UNITCOMMAND_CANCEL';

-- Pillage/plunder
UPDATE UnitOperations
SET ModHotkeyDescription = 'LOC_UNITOPERATION_PILLAGE_DESCRIPTION',  ModHotkey = '---+X'
WHERE OperationType = 'UNITOPERATION_PILLAGE';

UPDATE UnitOperations
SET ModHotkeyDescription = 'LOC_UNITOPERATION_PILLAGE_ROUTE_DESCRIPTION',  ModHotkey = 'S--+X'
WHERE OperationType = 'UNITOPERATION_PILLAGE_ROUTE';

UPDATE UnitCommands
SET ModHotkeyDescription = 'LOC_UNITCOMMAND_PLUNDER_TRADE_ROUTE_DESCRIPTION',  ModHotkey = '-C-+X'
WHERE CommandType = 'UNITCOMMAND_PLUNDER_TRADE_ROUTE';

UPDATE UnitOperations
SET ModHotkeyDescription = 'LOC_UNITOPERATION_REBASE_DESCRIPTION',  ModHotkey = '---+S'
WHERE OperationType = 'UNITOPERATION_REBASE';

/*CreateActionBinding({"UNITOPERATION_DEPLOY"}, "DEPLOY", ModSettings.KeyBinding.MakeValue(Keys.D, {Ctrl=true}));
CreateActionBinding({"UNITOPERATION_HEAL", "UNITOPERATION_RELIGIOUS_HEAL", "UNITOPERATION_REST_REPAIR"}, "HEAL", ModSettings.KeyBinding.MakeValue(Keys.F, {Shift=true}));
CreateActionBinding({"UNITOPERATION_WMD_STRIKE_0"}, "WMD_STRIKE_0", ModSettings.KeyBinding.MakeValue(Keys.W, {Shift=true}));
CreateActionBinding({"UNITOPERATION_WMD_STRIKE_1"}, "WMD_STRIKE_1", ModSettings.KeyBinding.MakeValue(Keys.W, {Alt=true}));
CreateActionBinding({"UNITOPERATION_SPY_COUNTERSPY"}, "SPY_COUNTERSPY", ModSettings.KeyBinding.MakeValue(Keys.S, {Alt=true}));
CreateActionBinding({"UNITCOMMAND_ACTIVATE_GREAT_PERSON"}, "ACTIVATE_GREAT_PERSON", ModSettings.KeyBinding.MakeValue(Keys.A, {Ctrl=true, Alt=true}));

CreateActionBinding({"UNITOPERATION_MAKE_TRADE_ROUTE"}, "MAKE_TRADE_ROUTE", ModSettings.KeyBinding.MakeValue(Keys.T, {Shift=true}));
CreateActionBinding({"UNITOPERATION_BUILD_ROUTE"}, "BUILD_ROUTE", ModSettings.KeyBinding.MakeValue(Keys.R, {Shift=true}));
CreateActionBinding({"UNITOPERATION_CLEAR_CONTAMINATION"}, "CLEAR_CONTAMINATION", ModSettings.KeyBinding.MakeValue(Keys.C, {Shift=true}));
CreateActionBinding({"UNITOPERATION_DESIGNATE_PARK"}, "DESIGNATE_PARK", ModSettings.KeyBinding.MakeValue(Keys.P, {Shift=true}));
CreateActionBinding({"UNITOPERATION_EXCAVATE"}, "EXCAVATE", ModSettings.KeyBinding.MakeValue(Keys.E, {Shift=true}));
CreateActionBinding({"UNITOPERATION_HARVEST_RESOURCE"}, "HARVEST_RESOURCE", ModSettings.KeyBinding.MakeValue(Keys.Q, {Shift=true}));
CreateActionBinding({"UNITOPERATION_PLANT_FOREST"}, "PLANT_FOREST", ModSettings.KeyBinding.MakeValue(Keys.Q, {Alt=true}));
CreateActionBinding({"UNITOPERATION_REMOVE_FEATURE"}, "REMOVE_FEATURE", ModSettings.KeyBinding.MakeValue(Keys.Q, {Ctrl=true}));
CreateActionBinding({"UNITOPERATION_REMOVE_IMPROVEMENT"}, "REMOVE_IMPROVEMENT", ModSettings.KeyBinding.MakeValue(Keys.W, {Ctrl=true}));
CreateActionBinding({"UNITOPERATION_REPAIR"}, "REPAIR", ModSettings.KeyBinding.MakeValue(Keys.D, {Shift=true}));
CreateActionBinding({"UNITOPERATION_REPAIR_ROUTE"}, "REPAIR_ROUTE", ModSettings.KeyBinding.MakeValue(Keys.D, {Alt=true}));

-- Untested
CreateActionBinding({"UNITOPERATION_CONVERT_BARBARIANS"}, "CONVERT_BARBARIANS", ModSettings.KeyBinding.MakeValue(Keys.J, {Shift=true}));
CreateActionBinding({"UNITOPERATION_FOUND_RELIGION", "UNITOPERATION_EVANGELIZE_BELIEF"}, "FOUND_RELIGION", ModSettings.KeyBinding.MakeValue(Keys.I, {Shift=true}));
CreateActionBinding({"UNITOPERATION_REMOVE_HERESY", "UNITOPERATION_LAUNCH_INQUISITION"}, "LAUNCH_INQUISITION", ModSettings.KeyBinding.MakeValue(Keys.O, {Shift=true}));
CreateActionBinding({"UNITOPERATION_SPREAD_RELIGION"}, "SPREAD_RELIGION", ModSettings.KeyBinding.MakeValue(Keys.L, {Shift=true}));
CreateActionBinding({"UNITCOMMAND_CONDEMN_HERETIC"}, "CONDEMN_HERETIC", ModSettings.KeyBinding.MakeValue(Keys.U, {Alt=true}));

CreateActionBinding({"UNITCOMMAND_UPGRADE", "UNITCOMMAND_PROMOTE"}, "UPGRADE", ModSettings.KeyBinding.MakeValue(Keys.U));
CreateActionBinding({"UNITCOMMAND_WAKE"}, "WAKE", ModSettings.KeyBinding.MakeValue(Keys.Z, {Shift=true}));

CreateActionBinding({"UNITCOMMAND_FORM_CORPS"}, "FORM_CORPS", ModSettings.KeyBinding.MakeValue(Keys.F, {Shift=true}));
CreateActionBinding({"UNITCOMMAND_FORM_ARMY"}, "FORM_ARMY", ModSettings.KeyBinding.MakeValue(Keys.F, {Ctrl=true}));
CreateActionBinding({"UNITCOMMAND_NAME_UNIT"}, "NAME_UNIT", ModSettings.KeyBinding.MakeValue(Keys.N, {Shift=true}));
CreateActionBinding({"UNITCOMMAND_ENTER_FORMATION", "UNITCOMMAND_EXIT_FORMATION"}, "ENTER_FORMATION", ModSettings.KeyBinding.MakeValue(Keys.Y, {Shift=true}));
CreateActionBinding({"UNITCOMMAND_PARADROP"}, "PARADROP", ModSettings.KeyBinding.MakeValue(Keys.L, {Shift=true}));

CreateActionBinding({"UNITCOMMAND_DISTRICT_PRODUCTION", "UNITCOMMAND_WONDER_PRODUCTION", "UNITCOMMAND_PROJECT_PRODUCTION"},
                    "PRODUCTION", ModSettings.KeyBinding.MakeValue(Keys.L, {Ctrl=true}));

-- Everything that behaves like a rebase action
CreateActionBinding({"UNITOPERATION_REBASE", "UNITOPERATION_SPY_TRAVEL_NEW_CITY", "UNITOPERATION_TELEPORT_TO_CITY", "UNITCOMMAND_AIRLIFT"}, 
                    "REBASE", ModSettings.KeyBinding.MakeValue(Keys.X));*/