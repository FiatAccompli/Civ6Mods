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
  local info = setmetatable({playerId = playerId, openBorders = {}, diploStates = {}, allianceTypes = {}, suzerain = -1}, DiplomacyInfo);
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

function DiplomacyInfo:IsSuzerain(minorId)
  return ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(minorId).suzerain == self.playerId;
end

function DiplomacyInfo:Refresh(otherPlayer)
  local otherPlayerId = otherPlayer:GetID();
  local player = Players[self.playerId];
  local diplomacy = player:GetDiplomacy();
  self.openBorders[otherPlayerId] = diplomacy:HasOpenBordersFrom(otherPlayerId);
  self.diploStates[otherPlayerId] = player:GetDiplomaticAI():GetDiplomaticStateIndex(otherPlayerId);
  self.allianceTypes[otherPlayerId] = diplomacy:GetAllianceType(otherPlayerId);
  self.suzerain = player:GetInfluence():GetSuzerain();
end

function DiplomacyInfo:RefreshAll()
  for _, player in ipairs(Game.GetPlayers()) do 
    self:Refresh(player);
  end
end

local function InitializeDiplomacyInfos()
  ExposedMembers.DiplomacyHelper.diploInfos = {}; 
  for _, player in ipairs(Game.GetPlayers()) do 
    ExposedMembers.DiplomacyHelper.diploInfos[player:GetID()] = DiplomacyInfo:new(player:GetID())
  end
end

local function OnPlayerTurnActivated(playerId)
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(playerId):RefreshAll();
end

local function OnDiplomacyRelationshipChanged(player1, player2)
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(player1):Refresh(Players[player2]);
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(player2):Refresh(Players[player1]);
end

local function OnDiplomacyDealEnacted(player1, player2)
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(player1):Refresh(Players[player2]);
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(player2):Refresh(Players[player1]);
end

local function OnInfluenceGiven(cityState, player)
  ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(cityState):Refresh(Players[player]);
end

-- Load up all data when a game is loaded.
Events.LoadGameViewStateDone.Add(InitializeDiplomacyInfos);
-- Refresh data when a turn starts.
Events.PlayerTurnActivated.Add(OnPlayerTurnActivated);
-- And when a deal or relationship changes
Events.DiplomacyDealEnacted.Add(OnDiplomacyRelationshipChanged);
Events.DiplomacyRelationshipChanged.Add(OnDiplomacyRelationshipChanged);
Events.InfluenceGiven.Add(OnInfluenceGiven);

-- Initialize.  Necessary if making edits to this file and having it hotloaded when a game is already running.
-- Otherwise initialization is handled in the LoadGameViewStateDone event.
InitializeDiplomacyInfos();