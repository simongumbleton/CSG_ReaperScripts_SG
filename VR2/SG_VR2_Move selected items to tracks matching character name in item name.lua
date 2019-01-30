-- @description Move selected items to tracks on same name as items
-- @version 1.03
-- @author MPL
-- @website http://forum.cockos.com/showthread.php?t=188335
-- @changelog
--   - disable moving items to zero position
  
  for key in pairs(reaper) do _G[key]=reaper[key]  end  
  function main()
    TR_names_t = {}
    for i = 1, CountTracks(0) do 
      local tr = GetTrack(0,i-1)
      local tr_name = ({GetSetMediaTrackInfo_String(tr, 'P_NAME', '', false)})[2]
      if tr_name ~= '' then TR_names_t[#TR_names_t+1] = {tr=tr, tr_name=tr_name}  end
    end
    if #TR_names_t ==0 then return end
    
    local items = {}
    for i = 1, CountSelectedMediaItems(0) do items[#items+1] = BR_GetMediaItemGUID(GetSelectedMediaItem(0,i-1)) end
    if #items == 0 then return end
    
    for i = 1, #items do
      local item = reaper.BR_GetMediaItemByGUID(0,items[i])
      local take = GetActiveTake(item)
      take_name = GetTakeName(take)
      if take_name:find('.wav')then
        ext = take_name:reverse():match('(.-)%.'):reverse()
        if ext~= nil then take_name = take_name:gsub('.'..ext, '') end
      end
      
      take_nameRev = take_name:reverse()
      
      for w in take_name:lower():gmatch("([^_]*)") do
        for k = 1, #TR_names_t do
          print(w)
          print(TR_names_t[k].tr_name:lower())
          if w:match(TR_names_t[k].tr_name:lower()) then
            MoveMediaItemToTrack(item, TR_names_t[k].tr)
          end
        end
      end
      
      
    --  for k = 1, #TR_names_t do
     --   local last
     --   for w in take_name:lower():gmatch(TR_names_t[k].tr_name:lower()) do
     --     last = w
      --    MoveMediaItemToTrack(item, TR_names_t[k].tr)
     --   end      
      --  if take_name:lower():find(TR_names_t[k].tr_name:lower()) then        --and  GetMediaItem_Track( item ) ~= TR_names_t[k].tr  
       --   MoveMediaItemToTrack(item, TR_names_t[k].tr)
       -- end
     -- end
    end
    UpdateArrange()
  end
  
  Undo_BeginBlock()
  main()  
  Undo_EndBlock('Move items to tracks on same name as items', 0)
