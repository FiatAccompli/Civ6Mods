include("DistanceCalculator")

local UNREACHABLE_DISTANCE = DistanceCalculator.UNREACHABLE_DISTANCE;

-- Helper functions for determining plot to plot move distance.  In UI context the only data we have on each plot is 
-- whether it has a river/cliff on its east, southeast or southwest edge so define some helpers functions to treat 
-- moving in all directions identically.
local ADJACENT_PLOT_CALCULATIONS = {};

ADJACENT_PLOT_CALCULATIONS[DirectionTypes.DIRECTION_WEST] = {
  IsRiverCrossing = function(plot, nextPlot) return nextPlot:IsWOfRiver() end,
  IsCliffCrossing = function(plot, nextPlot) return nextPlot:IsWOfCliff() end
};
ADJACENT_PLOT_CALCULATIONS[DirectionTypes.DIRECTION_EAST] = {
  IsRiverCrossing = function(plot, nextPlot) return plot:IsWOfRiver() end,
  IsCliffCrossing = function(plot, nextPlot) return plot:IsWOfCliff() end
};
ADJACENT_PLOT_CALCULATIONS[DirectionTypes.DIRECTION_NORTHWEST] = {
  IsRiverCrossing = function(plot, nextPlot) return nextPlot:IsNWOfRiver() end,
  IsCliffCrossing = function(plot, nextPlot) return nextPlot:IsNWOfCliff() end
};
ADJACENT_PLOT_CALCULATIONS[DirectionTypes.DIRECTION_NORTHEAST] = {
  IsRiverCrossing = function(plot, nextPlot) return nextPlot:IsNEOfRiver() end,
  IsCliffCrossing = function(plot, nextPlot) return nextPlot:IsNEOfCliff() end
};
ADJACENT_PLOT_CALCULATIONS[DirectionTypes.DIRECTION_SOUTHWEST] = {
  IsRiverCrossing = function(plot, nextPlot) return plot:IsNEOfRiver() end,
  IsCliffCrossing = function(plot, nextPlot) return plot:IsNEOfCliff() end
};
ADJACENT_PLOT_CALCULATIONS[DirectionTypes.DIRECTION_SOUTHEAST] = {
  IsRiverCrossing = function(plot, nextPlot) return plot:IsNWOfRiver() end,
  IsCliffCrossing = function(plot, nextPlot) return nextPlot:IsNWOfCliff() end
};

-- Local caches for movement costs from db values.
local RIVER_CROSSING_COST = tonumber(GameInfo.GlobalParameters['MOVEMENT_RIVER_COST'].Value);

local FEATURE_MOVEMENT_COSTS = {}
for feature in GameInfo.Features() do
  FEATURE_MOVEMENT_COSTS[feature.Index] = feature.MovementChange;
end

local TERRAIN_MOVEMENT_COSTS = {}
for terrain in GameInfo.Terrains() do
  TERRAIN_MOVEMENT_COSTS[terrain.Index] = terrain.MovementCost;
end

local ROUTE_MOVEMENT_COSTS = {}
local ROUTE_SUPPORTS_BRIDGES = {}
for route in GameInfo.Routes() do
  ROUTE_MOVEMENT_COSTS[route.Index] = route.MovementCost;
  ROUTE_SUPPORTS_BRIDGES[route.Index] = route.SupportsBridges;
end

-- Only polders in the base game have an extra cost as an improvment.
local IMPROVEMENT_MOVEMENT_COSTS = {}
for improvement in GameInfo.Improvements() do
  IMPROVEMENT_MOVEMENT_COSTS[improvement.Index] = improvement.MovementChange;
end

-- Cost to embark/disembark.  
local LAKE_EMBARK_COST = tonumber(GameInfo.GlobalParameters['MOVEMENT_EMBARK_COST'].Value);
-- In game the cost to embark at a city is 0 and at a harbor is 1, but these values seem to be 
-- hardcoded into the game binary and not exposed (or even documented) in the gameplay database.
-- So use the default embarkment cost.  Plus it doesn't make sense that you can move a bunch of 
-- oranges from a cart onto a boat for free just because you're in a city center.
local CITY_EMBARK_COST = tonumber(GameInfo.GlobalParameters['MOVEMENT_EMBARK_COST'].Value);
local HARBOR_EMBARK_COST = tonumber(GameInfo.GlobalParameters['MOVEMENT_EMBARK_COST'].Value);

-- Cached constants for the diplo states we care about
local ALLIED_DIPLO_STATE_INDEX = GameInfo.DiplomaticStates['DIPLO_STATE_ALLIED'].Index;
local FRIEND_DIPLO_STATE_INDEX = GameInfo.DiplomaticStates['DIPLO_STATE_DECLARED_FRIEND'].Index;
local WAR_DIPLO_STATE_INDEX = GameInfo.DiplomaticStates['DIPLO_STATE_WAR'].Index;
local WAR_WITH_MINOR_DIPLO_STATE_INDEX = GameInfo.DiplomaticStates['DIPLO_STATE_WAR_WITH_MINOR'].Index;
local SUZERAIN_DIPLO_STATE_INDEX = GameInfo.DiplomaticStates['DIPLO_STATE_MAX_INFLUENCE'].Index;

-- District type ids of harbors and replacements (e.g. royal navy dockyard)
local HARBOR_DISTRICT_TYPE_INDEXES = {};
local NOT_A_DISTRICT_TYPE = -1;
table.insert(HARBOR_DISTRICT_TYPE_INDEXES, GameInfo.Districts['DISTRICT_HARBOR'].Index)
for _, harborReplacement in ipairs(GameInfo.Districts['DISTRICT_HARBOR'].ReplacedByCollection) do
  table.insert(HARBOR_DISTRICT_TYPE_INDEXES, harborReplacement.ReplacementDistrictReference.Index);
end

local function IsHarbor(plot:table)
  type = plot:GetDistrictType();
  if type == NOT_A_DISTRICT_TYPE then 
    return false;
  end

  local isHarbor = false;
  for _, harborType in ipairs(HARBOR_DISTRICT_TYPE_INDEXES) do
    if type == harborType then 
      isHarbor = true;
    end
  end
  -- Don't forget to check that the district is complete or you can embark as soon as the architects make 
  -- the most cursory of surveys.
  if isHarbor then
    return CityManager.GetDistrictAt(plot):IsComplete();
  end
  return false;
end

-- Returns a table from playerId to whether road use is allowed in plots owned by that player.
-- Arguments:
--  player: A Player object for whom route use is to be calculated.
--  spec: Specification for distance calculations in the form of an entry from GameInfo.UA_UnitAttritionSets
local function GetRouteUseMap(player:table, attritionSpec:table)
  local diploInfo = ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(player:GetID());
  local canUseRoutesByOwner = {};

  for _, minor in ipairs(PlayerManager.GetAliveMinors()) do
    local minorId = minor:GetID();
    canUseRoutesByOwner[minorId] = false;
    local diplomaticState = diploInfo:GetDiplomaticState(minorId);
    if attritionSpec.RoutesInCityStateSuzerain and diploInfo:IsSuzerain(minorId) then
    end
    if attritionSpec.RoutesInOpenBordersTerritory and diploInfo:HasOpenBordersFrom(minorId) then
      canUseRoutesByOwner[minorId] = true;
    end
    -- I think it's actually always WAR_WITH_MINOR, but I'm not sure so include both just to be safe.
    if attritionSpec.RoutesInEnemyTerritory and 
       (diplomaticState == WAR_DIPLO_STATE_INDEX or 
        diplomaticState == WAR_WITH_MINOR_DIPLO_STATE_INDEX) then
      canUseRoutesByOwner[minorId] = true;
    end
  end

  for _, major in ipairs(PlayerManager.GetAliveMajors()) do
    local majorId = major:GetID();
    local diplomaticState = diploInfo:GetDiplomaticState(majorId);

    canUseRoutesByOwner[majorId] = false;
    if attritionSpec.RoutesInFriendTerritory and diplomaticState == FRIEND_DIPLO_STATE_INDEX then
      canUseRoutesByOwner[majorId] = true;  
    end
    if attritionSpec.RoutesInEnemyTerritory and diplomaticState == WAR_DIPLO_STATE_INDEX then
      canUseRoutesByOwner[majorId] = true;
    end 
    if attritionSpec.RoutesInAllianceTerritory and diplomaticState == ALLIED_DIPLO_STATE_INDEX then
      canUseRoutesByOwner[majorId] = true;  
    end
    if (attritionSpec.RoutesInMiliaryAllianceTerritory and diplomaticState == ALLIED_DIPLO_STATE_INDEX and 
        diploInfo:GetAllianceType(majorId) == MILITARY_ALLIANCE_INDEX) then
      canUseRoutesByOwner[majorId] = true;
    end
    if attritionSpec.RoutesInOpenBordersTerritory and diploInfo:HasOpenBordersFrom(majorId) then
      canUseRoutesByOwner[majorId] = true;
    end
    if attritionSpec.RoutesInEnemyTerritory and diplomaticState == WAR_DIPLO_STATE_INDEX then
      canUseRoutesByOwner[majorId] = true;
    end
  end
  canUseRoutesByOwner[player:GetID()] = attritionSpec.RoutesInOwnTerritory;
  canUseRoutesByOwner[-1] = attritionSpec.RoutesInNeutralTerritory;

  return canUseRoutesByOwner;
end

AttritionMaps = {};
AttritionMaps.__index = AttritionMaps;

-- Construct an AttritionMaps instance for attrition calcuations for the given player using the settings in a UA_UnitAttritionSets.
-- Distances calculated for attrition roughly correspond to unit movement distance in the base game, but differ in some ways:
--   Dis/embarkation is allowed everywhere only for lakes.  Entering\leaving an ocean must be done at a city or harbor.
--   Movement is never considered to be blocked by other players.  Movement in the actual game is blocked by other player's units
--     in the same layer (military/civilian) as well as other player's cities (you can never move onto the city tile of another civ,
--     except when capturing it).  For attrition distance the supply train can, in a sense, move through other player's units and 
--     cities.
--   The full cost of moving between hexes is always considered.  In game you can  move a unit that starts with full movements
--   to an adjacent hex, even if the total cost of moving there is greater than the number of movement points the unit has per turn 
--   (e.g. crossing a river onto a forested hill takes 5 movement points, but you can always do it).
--   Similar to the above, there is no idea of turns and having insufficient movement points to make a particular move this turn.
-- Arguments:
--  player: A Player object
--  spec: Specification for distance calculations in the form of an entry from GameInfo.UA_UnitAttritionSets

-- TODO:
-- Can't move through *enemy* cities/units.
function AttritionMaps:new(player:table, attritionSpec:table)
  attritionSpec = attritionSpec or GameInfo.Eras[player:GetEra()].DefaultUnitAttritionSet

  local diploInfo = ExposedMembers.DiplomacyHelper.GetDiplomacyInfo(player:GetID());
  local routeUse = GetRouteUseMap(player, attritionSpec);

  local visibility = PlayerVisibilityManager.GetPlayerVisibility(player:GetID());

  local function plotDistance(plot, nextPlot, direction, initialDistance)
    -- Can't enter hex.
    if nextPlot:IsImpassable() then 
      return UNREACHABLE_DISTANCE; 
    end
    -- Never seen plot.  Then we can't know how to route support through it.
    if not visibility:IsRevealed(nextPlot:GetX(), nextPlot:GetY()) then 
      return UNREACHABLE_DISTANCE; 
    end

    -- Compute distance to next hex considering terrain, feature, and improvement impediments.  This
    -- should be the same as Plot.GetMovementCost, but that is not available in game script context.
    local distance = initialDistance + TERRAIN_MOVEMENT_COSTS[nextPlot:GetTerrainType()];
    if nextPlot:GetFeatureType() >= 0 then
      distance = distance + FEATURE_MOVEMENT_COSTS[nextPlot:GetFeatureType()];
    end
    if nextPlot:GetImprovementType() >= 0 then
      distance = distance + IMPROVEMENT_MOVEMENT_COSTS[nextPlot:GetImprovementType()];
    end
    
    -- Can support units in lakes by embarking on lakeshore.
    if not plot:IsWater() and nextPlot:IsLake() then
      distance = distance + CITY_EMBARK_COST;
      return distance;
    end
    if plot:IsLake() and not nextPlot:IsWater() then 
      distance = distance + CITY_EMBARK_COST;
      return distance;
    end
    -- Embarking can only be done at a city center or a harbor for coast/ocean tiles (and we must
    -- be able to use the roads of the owner.
    if plot:IsWater() ~= nextPlot:IsWater() then 
      if plot:IsCity() and routeUse[plot:GetOwner()] then 
        return distance + CITY_EMBARK_COST;
      elseif nextPlot:IsCity() and routeUse[nextPlot:GetOwner()] then
        return distance + CITY_EMBARK_COST;
      elseif IsHarbor(plot) and routeUse[plot:GetOwner()] then
        return distance + HARBOR_EMBARK_COST;
      elseif IsHarbor(nextPlot)  and routeUse[nextPlot:GetOwner()] then
        return distance + HARBOR_EMBARK_COST;
      else
        return UNREACHABLE_DISTANCE;
      end
    end

    -- Add cost for crossing a river.
    local directionHelper = ADJACENT_PLOT_CALCULATIONS[direction];
    local crossesRiver = directionHelper.IsRiverCrossing(plot, nextPlot);
    if crossesRiver then
      distance = distance + RIVER_CROSSING_COST;
    end

    -- If there are roads in both plots then it may overwrite this calculation with only the cost of movement on the road.
    local routeType = plot:GetRouteType();
    local nextRouteType = nextPlot:GetRouteType();

    if routeType >= 0 and nextRouteType >= 0 then
      -- Not usable road if either side is pillaged.
      if not plot:IsRoutePillaged() and not nextPlot:IsRoutePillaged() then
        -- Can only use it if we're allowed access to roads in the owner territory.
        if routeUse[plot:GetOwner()] and routeUse[nextPlot:GetOwner()] then
          -- Nor if we cross a river and either side does not support bridges.
          if not crossesRiver or (crossesRiver and ROUTE_SUPPORTS_BRIDGES[routeType] and ROUTE_SUPPORTS_BRIDGES[nextRouteType]) then
              distance = initialDistance + math.max(ROUTE_MOVEMENT_COSTS[routeType], ROUTE_MOVEMENT_COSTS[nextRouteType]);
          end
        end
      end
    end
    
    return distance;
  end

  local distanceCalculator = DistanceCalculator:new(plotDistance);

  function addStartingCity(city:table)
    if visibility:IsRevealed(city:GetX(), city:GetY()) then 
      distanceCalculator:AddStartPlot(Map.GetPlot(city:GetX(), city:GetY()), 
                                      math.max(0, attritionSpec.PopulationDistanceCostOffset - city:GetPopulation()));
    end
  end

  for _, city in player:GetCities():Members() do
    addStartingCity(city);
  end

  if attritionSpec.CityStateSuzerainProvidesSupport then
    for _, minor in ipairs(PlayerManager.GetAliveMinors()) do
      if diploInfo:IsSuzerain(minor:GetID()) then
        for __, city in minor:GetCities():Members() do 
          addStartingCity(city);
        end
      end
    end
  end

  for _, major in ipairs(PlayerManager.GetAliveMajors()) do
    local majorId = major:GetID();
    local diplomaticState = diploInfo:GetDiplomaticState(majorId);
    
    if attritionSpec.FriendProvidesSupport and diplomaticState == FRIEND_DIPLO_STATE_INDEX then
      for __, city in major:GetCities():Members() do 
        addStartingCity(city);
      end
    end
    if attritionSpec.AllianceProvidesSupport and diplomaticState == ALLIED_DIPLO_STATE_INDEX then
      for __, city in major:GetCities():Members() do 
        addStartingCity(city);
      end
    end
    if (attritionSpec.MilitaryAllianceProvidesSupport and diplomaticState == ALLIED_DIPLO_STATE_INDEX and 
        diploInfo:GetAllianceType(majorId) == MILITARY_ALLIANCE_INDEX) then
      for __, city in major:GetCities():Members() do 
        addStartingCity(city);
      end
    end
  end

  distanceCalculator:ComputeForAllPlots();

  return setmetatable(
    {distanceCalculator = distanceCalculator,
     formationClassMaps = {},
     player = player,
     attritionSpec = attritionSpec},
    self);
end

function AttritionMaps:GetAttritionRangeRates(formationClass:string) 
  local attritionRates = {};
  for _, rateInfo in ipairs(self.attritionSpec.SettingsCollection) do 
    if rateInfo.FormationClass == formationClass then
      attritionRates[rateInfo.DistanceCostRange] = rateInfo.AttritionRate;
    end
  end
  return attritionRates;
end

-- Returns a map from plot index to per-turn attrition for the given formationClass.
function AttritionMaps:GetAttritionMapForFormationClass(formationClass:string)
  -- Cache these so we don't have to recompute for the same class.
  local map = self.formationClassMaps[formationClass];

  if map == nil then
    map = {};
    local plotCount = Map.GetPlotCount();
    for i = 0, plotCount - 1 do
      map[i] = 0;
    end

    local attritionRates = self:GetAttritionRangeRates(formationClass);
    local navalAttritionRates = attritionRates;
    local maxAttrition = self.attritionSpec.MaxAttritionPerTurn;
    local attritionAlleviatedPerFood = self.attritionSpec.AttritionAlleviatedPerFood;

    local formationClassSetting = GameInfo.UA_UnitAttritionFormationClassSettings[formationClass];
    if formationClassSetting ~= nil then
      if formationClassSetting.UseNavalAttritionWhenAtSea then
        navalAttritionRates = self:GetAttritionRangeRates("FORMATION_CLASS_NAVAL");
      end
    end

    for i = 0, plotCount - 1 do
      local plot = Map.GetPlotByIndex(i);
      local plotAttritionDistance = self.distanceCalculator.distances[i];
      local distanceAttrition = 0;

      if plot:IsWater() and not plot:IsLake() then
        for distance, rate in pairs(navalAttritionRates) do 
          if plotAttritionDistance >= distance then 
            distanceAttrition = distanceAttrition + rate;
          end
        end
      else
        for distance, rate in pairs(attritionRates) do 
          if plotAttritionDistance >= distance then 
            distanceAttrition = distanceAttrition + rate;
          end
        end
      end
      -- Apply food offset and squelch to range [0, maxAttrition]
      map[i] = math.max(0, math.min(maxAttrition, distanceAttrition - plot:GetYield(YieldTypes.YIELD_FOOD) * attritionAlleviatedPerFood));
    end
    self.formationClassMaps[formationClass] = map;
  end
  
  return map;
end

function AttritionMaps:GetAttritionForUnit(unitType, x:number, y:number)
  local formationClass = GameInfo.Units[unitType].FormationClass;
  local width, height = Map.GetGridSize();
  -- Can't use Map methods to convert x, y to index becuase they are not available in gameplay script context.
  local attrition = self:GetAttritionMapForFormationClass(formationClass)[width * y + x];
  return attrition;
end