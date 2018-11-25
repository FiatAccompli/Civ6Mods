-- Contains default player-defined values for mod settings that apply to all games (unless overriden with 
-- a value in the individual game save).
CREATE TABLE 'ModSettingsUserDefaults' (
  'StorageName' TEXT NOT NULL,
  'Value' TEXT NOT NULL,
  PRIMARY KEY('StorageName')
);
