-- Add columns for non civ6 built-in hotkeys
ALTER TABLE Improvements ADD ModHotkey TEXT;
ALTER TABLE Improvements ADD ModHotkeyDescription TEXT;

ALTER TABLE UnitCommands ADD ModHotkey TEXT;
ALTER TABLE UnitCommands ADD ModHotkeyDescription TEXT;
ALTER TABLE UnitCommands ADD IsModCommand BOOLEAN DEFAULT 0 NOT NULL CHECK (IsModCommand IN (0,1));

ALTER TABLE UnitOperations ADD ModHotkey TEXT;
ALTER TABLE UnitOperations ADD ModHotkeyDescription TEXT;
ALTER TABLE UnitOperations ADD IsModCommand BOOLEAN DEFAULT 0 NOT NULL CHECK (IsModCommand IN (0,1));
