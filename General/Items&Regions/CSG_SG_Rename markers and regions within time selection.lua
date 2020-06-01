--[[
* ReaScript Name: CSG_SG_Rename markers and regions within time selection
* Description: 
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.1
* Provides: main
--]]

function main()
  local time_sel_start, time_sel_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  if time_sel_start == time_sel_end then return end
  local retval, retvals_csv = reaper.GetUserInputs("Rename markers/regions", 1, "Rename markers/regions", "")
  if not retval or retvals_csv == "" then return end
  local new_name = retvals_csv
  local i=0
  while true do
    local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if ret == 0 then
      break
    end
    if pos >= time_sel_start then
      if isrgn and rgnend <= time_sel_end or not isrgn and pos <= time_sel_end then
        reaper.SetProjectMarkerByIndex(0, i, isrgn, pos, rgnend, markrgnindexnumber, new_name, 0)
      end
    end
    i = i + 1
  end
  reaper.Undo_OnStateChangeEx("Rename markers and regions", -1, -1)
end

reaper.defer(main)