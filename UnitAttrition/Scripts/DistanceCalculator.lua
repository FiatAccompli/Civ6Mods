-- Search utiltiies for finding shortest path distances on civ 6 maps using Djikstra's algorithm.

include("BinaryHeap")
include("SupportFunctions")
include("PlotIterators2")

local UNREACHABLE_DISTANCE = 100000;
local NO_PREVIOUS_PLOT = -1;

local ADJACENT_PLOT_DIRECTIONS = {
  DirectionTypes.DIRECTION_WEST,
  DirectionTypes.DIRECTION_EAST,
  DirectionTypes.DIRECTION_NORTHWEST,
  DirectionTypes.DIRECTION_NORTHEAST,
  DirectionTypes.DIRECTION_SOUTHWEST,
  DirectionTypes.DIRECTION_SOUTHEAST,
};

DistanceCalculator = { UNREACHABLE_DISTANCE = UNREACHABLE_DISTANCE, NO_PREVIOUS_PLOT = NO_PREVIOUS_PLOT };
DistanceCalculator.__index = DistanceCalculator;

local CONSTANT_PLOT_DISTANCE_CALCULATOR = function(plot, direction)
  return 1;
end

function DistanceCalculator:new(plotDistanceCalculator)
  local distances = {};
  local previousPlots = {};
  local plotCount = Map.GetPlotCount();
  for i = 0, plotCount - 1 do
    distances[i] = UNREACHABLE_DISTANCE;
    previousPlots[i] = NO_PREVIOUS_PLOT;
  end
  return setmetatable({plotDistanceCalculator = plotDistanceCalculator or CONSTANT_PLOT_DISTANCE_CALCULATOR,
                       distances = distances,
                       previousPlots = previousPlots,
                       startedDistanceCalculations = false,
                       plotQueue = heap:new()}, 
                      DistanceCalculator)
end

function DistanceCalculator:AddStartPlot(plot, initialDistance)
  assert(not startedDistanceCalculations, "Can not add plot after starting to compute distances");

  local plotIndex = plot:GetIndex();

  if initialDistance < self.distances[plotIndex] then
    self.distances[plotIndex] = initialDistance;
    self.previousPlots[plotIndex] = NO_PREVIOUS_PLOT;
    self.plotQueue:Insert(initialDistance, plot);
  end
end

function DistanceCalculator:ComputeForAllPlots()
  self.startedDistanceCalculations = true;

  while not self.plotQueue:IsEmpty() do
    local distance, plot = self.plotQueue:Pop();
    local plotIndex = plot:GetIndex();

    -- Don't need to do anything if we're seeing this plot through a non-shortest path since we will
    -- have already processed it through a shorter path.
    if distance <= self.distances[plotIndex] then
      local x = plot:GetX();
      local y = plot:GetY();

      for _, direction in ipairs(ADJACENT_PLOT_DIRECTIONS) do
        local nextPlot = Map.GetAdjacentPlot(x, y, direction);
        -- Skip plots that fall off the edge of the world.
        if nextPlot ~= nil then
          local nextPlotIndex = nextPlot:GetIndex();
          local increment = self.plotDistanceCalculator(plot, nextPlot, direction);
          assert(increment >= 0, "calculated plot distance is negative");
          local nextPlotDistance = distance + increment;
          -- As well as skipping the plot if it is unreachable from here.
          if nextPlotDistance < UNREACHABLE_DISTANCE then
            if nextPlotDistance < self.distances[nextPlotIndex] then
              self.distances[nextPlotIndex] = nextPlotDistance;
              self.previousPlots[nextPlotIndex] = plotIndex;
              self.plotQueue:Insert(nextPlotDistance, nextPlot);
            end
          end 
        end
      end
    end
  end
end

function DistanceCalculator:DebugShowOnWorldMap(distanceMultiplier)
  -- Since numbers on the world map are always whole numbers, multiply each distance so that fractional parts are 
  -- visible (e.g. roads use a fraction of a movement point in later eras).
  distanceMultiplier = distanceMultiplier or 10;

  UILens.SetActive(LensLayers.TRADE_ROUTE);
  UILens.SetActive(LensLayers.NUMBERS);
  UILens.ClearLayerHexes(LensLayers.TRADE_ROUTE);
  UILens.ClearLayerHexes(LensLayers.NUMBERS);

  local color = RGBAValuesToABGRHex(0.088,0.043,0.168,1.0)

  -- Why not just draw the previous plot (e.g. shortest path) mapping for every plot and let the core game engine
  -- handle what shows up on screen like it does for everything else.  Because bad stuff happens when you exceed ~1000 
  -- trade route or movement path segments.  First the game simply will not display more than ~1000 paths (it actually seems to 
  -- be 963, but why that number would be a limit I have no idea) (or maybe it's path segments that are the limit, but this use 
  -- has a one to one correspondence between them, so it doesn't really matter which it is).  Second, once you've exceeded this
  -- limit the game has a nasty habit of crashing when trying to end the game (either through a reload, or exit to menu/desktop).
  for plotIndex in PlotIterators.AndAdjacentIndexIterator(PlotIterators.OnScreenIndexIterator()) do
    local plot = Map.GetPlotByIndex(plotIndex); --= Map.GetPlot(x, y);
    if self.distances[plotIndex] < UNREACHABLE_DISTANCE then 
      UI.AddNumberToPath(self.distances[plotIndex] * distanceMultiplier, plotIndex);
      if self.previousPlots[plotIndex] ~= NO_PREVIOUS_PLOT then
        UILens.SetLayerHexesPath(LensLayers.TRADE_ROUTE, Game.GetLocalPlayer(), {self.previousPlots[plotIndex], plotIndex}, {}, color);
      end
    end
  end
end