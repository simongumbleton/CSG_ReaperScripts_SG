--[[
* ReaScript Name: CSG_SG_Rename Selected Regions - Find and Replace
* Description: 
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.2
* Provides: [main] .
--]]

function main()
  local time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  if time_sel_start == time_sel_end then return end
  local retval, retvals_csv = reaper.GetUserInputs("Rename markers/regions", 2, "Find,Replace", "")
  if not retval or retvals_csv == "" then return end
  local inputs = retvals_csv
  local FindReplace ={"",""}
  x = 0
  reaper.ShowConsoleMsg(inputs)
  for word in inputs:gmatch("([^,]+),?") do
    FindReplace[x] = word
    --reaper.ShowConsoleMsg(word)
    x= x+1
  end
  
  local i=0
  while true do
    local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if ret == 0 then
      break
    end
    if pos >= time_sel_start then
      if isrgn and rgnend <= time_sel_end or not isrgn and pos <= time_sel_end then
    
        oldName = name
    
        newName = oldName:gsub(FindReplace[0],FindReplace[1])
    
        reaper.SetProjectMarkerByIndex(0, i, isrgn, pos, rgnend, markrgnindexnumber, newName, 0)
      end
    end
    i = i + 1
  end
  reaper.Undo_OnStateChangeEx("Rename markers and regions", -1, -1)
end

reaper.defer(main)
