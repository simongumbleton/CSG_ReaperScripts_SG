--[[
* ReaScript Name: CSG_SG_Rename Selected Regions - Find and Replace
* Description: 
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.1
* Provides: main
--]]

-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


function main()
  local time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  if time_sel_start == time_sel_end then return end
  
  local retval, retvals_csv = reaper.GetUserInputs("Rename items", 2, "Find,Replace", "")
  if not retval or retvals_csv == "" then return end
  local inputs = retvals_csv
  local FindReplace ={"",""}
  x = 0
  --reaper.ShowConsoleMsg(inputs)
  for word in inputs:gmatch("([^,]+),?") do
    FindReplace[x] = word
    --reaper.ShowConsoleMsg(word)
    x= x+1
  end
  
  reaper.PreventUIRefresh(1)
  
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)
  

  for i, item in ipairs(init_sel_items) do
    take = reaper.GetActiveTake(item)
    if take then
        currentName = reaper.GetTakeName(take)
        currentName = currentName:gsub(FindReplace[0],FindReplace[1])
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", currentName, true)
      else
        break
      end
  end
	
  reaper.Undo_EndBlock("Rename selected items from CSV input", -1) -- End of the undo block. Leave it at the bottom of your main function.
  
  reaper.UpdateArrange()
  
  reaper.PreventUIRefresh(-1)
  
end

reaper.defer(main)
