--[[
 * ReaScript Name: Rename selected takes from CSV input
 * Description: See title.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166689
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-02-29)
  + Initial Release
--]]

-- Consider transposing the table if you have your list in several rows
-- http://www.convertcsv.com/transpose-csv.htm

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
sep = "," -- default sep
names_csv = "" -- default name

------------------------------------------------------- END OF USER CONFIG AREA


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


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do
    take = reaper.GetActiveTake(item)
    if take then
        currentName = reaper.GetTakeName(take)
        currentName = currentName:gsub(newRemoveString,"")
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", currentName, true)
      else
        break
      end
  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  retval, removeString = reaper.GetUserInputs("String to remove", 1, 'String to remove from item names', "")
  
  newRemoveString = removeString..".wav"
  
  if retval then
  
    reaper.PreventUIRefresh(1)
  
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    init_sel_items =  {}
    SaveSelectedItems(init_sel_items)
  
    main()
  
    reaper.Undo_EndBlock("Rename selected items from CSV input", -1) -- End of the undo block. Leave it at the bottom of your main function.
  
    reaper.UpdateArrange()
  
    reaper.PreventUIRefresh(-1)
    
  end
  
end
