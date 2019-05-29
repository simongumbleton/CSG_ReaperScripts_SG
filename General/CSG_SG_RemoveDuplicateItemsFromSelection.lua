-- /**
 -- * ReaScript Name: CSG_SG_RemoveDuplicateItemsFromSelection
 -- * Description: 
 -- * Instructions: 
 -- * Author: Simon Gumbleton
 -- * Version: 1.0
 -- */
  
  script_title = "Remove duplicate items from selection"
  reaper.Undo_BeginBlock()
   
  selectedItems={}
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items ~= nil then
    for i=1, count_sel_items do
      item = reaper.GetSelectedMediaItem(0,i-1)
      if item ~= nil then
        selectedItems[i] = item
      end
      reaper.UpdateItemInProject(item)
    end    
  end
  
  invertSelecteditems={}
  reaper.Main_OnCommand(41115,0)
  
  resetItemID = reaper.NamedCommandLookup("_XENAKIOS_RES")
  reaper.Main_OnCommand(resetItemID,0)
  
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items ~= nil then
     for i=1, count_sel_items do
       item = reaper.GetSelectedMediaItem(0,i-1)
       if item ~= nil then
         invertSelecteditems[i] = item
       end
       reaper.UpdateItemInProject(item)
     end    
  end
  reaper.Main_OnCommand(41115,0)
  
  duplicateItems={}
  count = 1
  for i, item in ipairs(selectedItems) do
    take = reaper.GetActiveTake(item)
    if take ~= nil then
      retval, name = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME','', false)
             
      for i, invitem in ipairs(invertSelecteditems) do
        invtake = reaper.GetActiveTake(invitem)
        if invtake ~= nil then
          retval, invname = reaper.GetSetMediaItemTakeInfo_String(invtake, 'P_NAME','', false)
          
          if name == invname then
            --reaper.ShowConsoleMsg(name)
            --reaper.ShowConsoleMsg(invname)
            table.insert(duplicateItems,item)
          end
        end
      end
    end
    count = count+1
  end
  
  count = 0
  for i, item in ipairs(duplicateItems) do
    take = reaper.GetActiveTake(item)
    retval, name = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME','', false)
    reaper.ShowConsoleMsg(name)
    tr = reaper.GetMediaItem_Track(item)
    reaper.DeleteTrackMediaItem(tr,item)
    count = count + 1  
  end
  reaper.UpdateArrange()
  msg = "Removed " .. tostring(count) .. " duplicate items"
  reaper.ShowConsoleMsg(msg)
  
  reaper.Undo_EndBlock(script_title, 0)
