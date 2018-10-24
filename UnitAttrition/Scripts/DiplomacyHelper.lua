-- Caches information about diplomacy that is only available in UI context.  Open borders and alliance type 
-- information are not to exposed in gameplay script context (that I can find).  And while diplomatic state
-- is available in both contexts, it's exposed in different places.  So cache that too just so it can 
-- be treated consistently.
--
-- Why are these things not available in a gameplay script context?  Because Firaxis are shit and 
-- can't be bothered to do more than half-ass anything.

if ExposedMembers.DiplomacyHelper == nil then
  ExposedMembers.DiplomacyHelper = {}
end

ExposedMembers.DiplomacyHelper.GetDiplomacyInfo = function(playerId) 
  return ExposedMembers.DiplomacyHelper.diploInfos[playerId];
end

DiplomacyInfo = {}
DiplomacyInfo.__index = DiplomacyInfo

function DiplomacyInfo:new(playerId)
  local info = setmetatable({playerId = playerId, openBorders = {}, diploStates = {}, allianceTypes = {}}, DiplomacyInfo);
  info:RefreshAll();
  return info;
end

function DiplomacyInfo:HasOpenBordersFrom(otherPlayerId) 
  return self.openBorders[otherPlayerId];
end

function DiplomacyInfo:GetDiplomaticState(otherPlayerId)
  return self.diploStates[otherPlayerId];
end

function DiplomacyInfo:GetAllianceType(otherPlayerId) 
  return self.allianceTypes[otherPlayerId];
end

function DiplomacyInfo:Refresh(otherPlayer)
  local otherPlayerId = otherPlayer:GetID();
  local player = Players[self.playerId];
  local diplomacy = player:GetDiplomacy();
  self.openBorders[otherPlayerId] = diplomacy:HasOpenBordersFrom(otherPlayerId);
  self.diploStates[otherPlayerId] = player:GetDiplomaticAI():GetDiplomaticStateIndex(otherPlayerId);
  self.allianceTypes[otherPlayerId] = diplomacy:GetAllianceType(otherPlayerId)
end

function DiplomacyInfo:RefreshAll()
  for _, player in ipairs(Game.GetPlayers()) do 
    self:Refresh(player);
  end
end

InitializeDiplomacyInfos = function()
  ExposedMembers.DiplomacyHelper.diploInfos = {}; 
  for _, player in ipairs(Game.GetPlayers()) do 
    ExposedMembers.DiplomacyHelper.diploInfos[player:GetID()] = DiplomacyInfo:new(player:GetID())
  end
end

local function OnPlayerTurnActivated(playerId)
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(playerId):RefreshAll();
end

-- Load up all data when a game is loaded.
Events.LoadGameViewStateDone.Add(InitializeDiplomacyInfos)
-- And refresh it for a player whenever their turn starts.  This is mostly for safety as the data
-- should be in-sync if we're correctly hooked to every event that could update it.
Events.PlayerTurnActivated.Add(OnPlayerTurnActivated)


--Events.AllianceEnded.Add
--Events.CivicCompleted.Add
--Events.DiplomacyDealEnacted.Add
--Events.DiplomacyRelationshipChanged.Add