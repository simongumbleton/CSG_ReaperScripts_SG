--[[
* ReaScript Name: CSG_SG_RenameTracksUsingEnumeration
* Description: rename selected tracks with a string + enumerator (number or letter)
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.0
--]]
 

function main()
  
  reaper.Undo_BeginBlock() -- Begin undo group
  
  for i = 0, count_tracks - 1 do
  
    track = reaper.GetTrack(0, i)
    
    track_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    
    retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    
    if track_depth == 1 then
      
      track_name = utf8upper(track_name)
  
    else
  
      track_name = utf8upper( utf8.sub(track_name, 0, 1) ) .. utf8lower( utf8.sub(track_name, 2, utf8.len(track_name) ) )
    
    end
    
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true)
  
  end
  
  reaper.Undo_EndBlock("Set parents tracks names to uppercase and childs ones to camelcase", -1) -- End undo group

end

-- RUN
count_tracks = reaper.CountTracks()

if count_tracks > 0 then
  
  reaper.PreventUIRefresh(1)
  
  main()
  
  reaper.TrackList_AdjustWindows(false)
  
  reaper.PreventUIRefresh(-1)

end