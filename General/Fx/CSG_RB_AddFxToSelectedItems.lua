--[[
* ReaScript Name: CSG_RB_AddFxToSelectedItems
* Description: 
* Instructions: 
* Author: Rob Blake
* Version: 1.02
* Provides: [main] .
--]]


all_items = reaper.CountSelectedMediaItems(0)
  for i = 0, all_items-1 do
    item =  reaper.GetSelectedMediaItem(0,i)
    MediaItem_Take = reaper.GetTake(item, 0)
    reaper.TakeFX_AddByName(MediaItem_Take, "ReaComp (Cockos)", 1) -- Enter plugin name here
  end
