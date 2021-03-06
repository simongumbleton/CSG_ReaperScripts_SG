--[[
* ReaScript Name: Find Replace in Marker Names
* Description: Prompts user to replace part of a marker's name with new text if region name contains search criteria.
* Instructions: 
* Author: Aaron Cendan
* Version: 1.2
* Provides: [main] .
--]]

function findReplace() -- local (i, j, item, take, track)


	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	local retval, num_markers, num_regions = reaper.CountProjectMarkers( 0 )

	if num_markers > 0 then
		-- Store user input for search and replace strings
		local ret,user_input = reaper.GetUserInputs( "Find & Replace in Marker Names",  2,
						   "Text to Search For,Text to Replace With,extrawidth=100","")
		if not ret then return end

		local search_string, replace_string = user_input:match("([^,]+),([^,]+)")
	

		local i = 0
		-- Loop through all markers
		while i < num_markers do
			
			local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, i )

			if string.find(name, search_string) then
				local new_name = string.gsub( name, search_string, replace_string)
				reaper.SetProjectMarkerByIndex( 0, i, isrgn, pos, rgnend, markrgnindexnumber, new_name, color )
			end

			i = i + 1
		end
	else
		reaper.ShowMessageBox("Project has no markers!","Find/Replace", 0)
		
	end

	reaper.Undo_EndBlock("Find and Replace", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

findReplace() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)