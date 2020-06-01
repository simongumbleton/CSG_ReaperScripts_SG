--[[
* ReaScript Name: CSG_SG_Crop_Region_To_Selected_Items
* Description: 
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.1
* Provides: [main] .
--]]
 

local item= reaper.GetSelectedMediaItem(0,0)
if item then 
  local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local itemDuration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local itemEnd = itemStart + itemDuration

  local markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0, reaper.GetCursorPosition())
  
  --reaper.ShowConsoleMsg(regionidx)
  
  if regionidx == -1 then --- No region at start of item
   -- reaper.ShowConsoleMsg("\n No region at start of item\n") 
    reaper.MoveEditCursor(itemDuration/2,false)
    markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0,reaper.GetCursorPosition())
   -- reaper.ShowConsoleMsg(regionidx)
    
    if regionidx == -1 then -- No region in middle of item
     -- reaper.ShowConsoleMsg("\n No region at middle of item\n")
      reaper.MoveEditCursor(itemDuration/2,false)
      markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0,reaper.GetCursorPosition())
      --reaper.ShowConsoleMsg(regionidx)
    end
  end
  
  local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut, colorOut = reaper.EnumProjectMarkers3(0, regionidx)
  if retval>0 then 
    reaper.SetProjectMarkerByIndex2(0, regionidx, true, itemStart, itemEnd, markrgnindexnumberOut , "", colorOut, 0)
  else
    reaper.ShowConsoleMsg("\nNo region was found at edit cursor time")
  end
  
else
  reaper.ShowMessageBox("Select the item", "Please",0)
end
