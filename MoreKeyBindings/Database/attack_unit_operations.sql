-- Add new command for melee attack
INSERT INTO UnitCommands 
    (CommandType, Description, 
     Help, DisabledHelp, Icon, Sound, VisibleInUI, HoldCycling, CategoryInUI, InterfaceMode, PrereqTech, PrereqCivic, MaxEra, HotkeyId)
VALUES ('MORE_KEYBINDING_UNITCOMMAND_MELEE_ATTACK', 'LOC_MORE_KEY_BINDINGS_UNITCOMMAND_MELEE_ATTACK_DESCRIPTION', 
        null, null, 'ICON_NOTIFICATION_DECLARE_WAR', null, 1, 1, 'ATTACK', 'INTERFACEMODE_ATTACK', null, null, -1, 'Attack');

-- Also assign attack hotkey to air attack.  Will not conflict with attack since they're never both true for 
-- any particular unit.
UPDATE UnitOperations
SET HotkeyId = 'Attack'
WHERE OperationType = 'UNITOPERATION_AIR_ATTACK';