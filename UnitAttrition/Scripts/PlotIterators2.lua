-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

-- Helper functions for iterating over certain types of plots.

-- Not calling this file PlotIterators because other mods already have a file named that with 
-- whoward's border and area plot iterators.

if not PlotIterators then 
  PlotIterators = {};
end

local ADJACENT_PLOT_DIRECTIONS = {
  DirectionTypes.DIRECTION_WEST,
  DirectionTypes.DIRECTION_EAST,
  DirectionTypes.DIRECTION_NORTHWEST,
  DirectionTypes.DIRECTION_NORTHEAST,
  DirectionTypes.DIRECTION_SOUTHWEST,
  DirectionTypes.DIRECTION_SOUTHEAST,
};

-- Creates an iterator for plot indices from a coroutine enumerator of plot indices.
local function IndexIteratorFromEnumerator(func:ifunction)
  local next = coroutine.create(func);
  return function() 
    local success, plotIndex = coroutine.resume(next);
    if success then 
      return plotIndex;
    else
      return nil;
    end
  end
end

-- Wrap an iterator of plot indices to return all the wrapped plot indices as well as the indices for 
-- all plots that are adjacent to any returned by the wrapped iterator.
function PlotIterators.AndAdjacentIndexIterator(inputPlotIterator:ifunction)
  return IndexIteratorFromEnumerator(
    function() 
      local emitted = {}

      function emit(index)
        if not emitted[index] then
          emitted[index] = true;
          coroutine.yield(index);
        end
      end

      for plotIndex in inputPlotIterator do
        emit(plotIndex);
        local x, y = Map.GetPlotLocation(plotIndex);
        for _, direction in ipairs(ADJACENT_PLOT_DIRECTIONS) do
          local nextPlot = Map.GetAdjacentPlot(x, y, direction);
          if nextPlot ~= nil then
            emit(nextPlot:GetIndex());
          end
        end
      end
    end);  
end

-- True if x,y is left of the line defined by (startX, startY) (endX, endY)
-- and looking from start to end.
local function IsLeftOf(startX:number, startY:number, endX:number, endY:number, x:number, y:number)
  return ((endX - startX) * (y - startY)) > ((endY - startY) * (x - startX));
end

-- Get an iterator of all plots whose center (from what I can tell it is the center of the hex that is 
-- referenced when using UI.GridToWorld()) lies within the current screen view.
function PlotIterators.OnScreenIndexIterator()
  return IndexIteratorFromEnumerator(
    function()
      -- Normalized screen pos is from [-1, -1] at bottom left to [1, 1] at top right with [0,0]
      -- being in the center of the window.
      local worldBLX, worldBLY = UI.GetWorldFromNormalizedScreenPos_NoWrap(-1, -1);
      local worldTLX, worldTLY = UI.GetWorldFromNormalizedScreenPos_NoWrap(-1, 1);
      local worldBRX, worldBRY = UI.GetWorldFromNormalizedScreenPos_NoWrap(1, -1);
      local worldTRX, worldTRY = UI.GetWorldFromNormalizedScreenPos_NoWrap(1, 1);
      local width, height = Map.GetGridSize();

      function inBounds(plotX, plotY)
        local worldX, worldY = UI.GridToWorld(plotX, plotY);
        return IsLeftOf(worldTLX, worldTLY, worldBLX, worldBLY, worldX, worldY) and 
               IsLeftOf(worldBLX, worldBLY, worldBRX, worldBRY, worldX, worldY) and
               IsLeftOf(worldBRX, worldBRY, worldTRX, worldTRY, worldX, worldY) and
               IsLeftOf(worldTRX, worldTRY, worldTLX, worldTRY, worldX, worldY);
      end

      -- Iterate over all plots and see if they fall in the screen bounds.  Probably some more efficient way to quickly 
      -- preprune the entire map to something more reasonable if I wanted to think about it.  Which I don't.
      local wrapX = Map.IsWrapX();

      for y = 0, height - 1 do
        for x = 0, width - 1 do
          -- When the world wraps we need to consider whether either of the points shifted once around the 
          -- globe are within bounds since the game can shift world representation on wrap up to one revolution away.  
          -- (I guess it could maintain the representation as any multiple of globe revolutions, but it appears to 
          -- normalize it to always be in the range [-1, 1].)  (Which leads to an interesting question of what happens
          -- if you have a super small map or zoom out far enough so that the screen shows more than once around the world.)
          if inBounds(x, y) or (wrapX and inBounds(x - width, y)) or (wrapX and inBounds(x + width, y)) then
            coroutine.yield(width * y + x);
          end
        end
      end
    end);
end