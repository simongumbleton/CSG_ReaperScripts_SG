--[[
* ReaScript Name: CSG_SG_ImportAnimationTimecodes_fromExcel
* Description: 
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.2
* Provides: [main] .
--]]



require("LuaXML/xml")
require("LuaXML/handler")


 -- MAGIC NUMBERS
 -- Change in case Excel file formatting changes
 workSheetNumber = 2        -- The page number of the Excel work sheet
 timeCodeStartColumn = 2   -- The column number of the Time Code Start cells
 timeCodeEndColumn = 3     -- The column number of the Time Code End cells
 startRowIndex = 1          -- The row number of the first valid entry of mocap files
 animationEditName = 1		--The name of the animation clip


 --User input variables
 inputs = ""
 useNonDropConversion = false
 useND = ""
 wrksht = 1
 existingRegionsToDelete = {}
 

frameRate = reaper.TimeMap_curFrameRate(-1)

-- testregions = {
--  {1., 2., "Test region 1"},
--  {3., 5., "Foo"},
--  {7., 9., "Bar"},
--  {12., 15.0, "Pizza"}
-- }


function GetDataFromCell(cell)    
  if cell == nil or cell["Data"] == nil then 
    return nil
  end
  
  data =  cell["Data"]
  return data[1]  
end


function GetTimeFromTimeCodeString(timeCode)
  if timeCode == nil then
    return nil
  end

  hh = tonumber(timeCode:sub(1, 2))
  mm = tonumber(timeCode:sub(4, 5))
  ss = tonumber(timeCode:sub(7, 8))
  ff = tonumber(timeCode:sub(10, 11))  
  
  if useNonDropConversion then
	-- For Non Drop Frame imports:
	return (hh * 60 * 60 + mm * 60 + ss + ff / frameRate) * (30 / 29.97)
  else
    -- For Drop Frame imports:
    return hh * 60 * 60 + mm * 60 + ss + ff / frameRate
  end

end


function ImportTimeCodes(testregions)  
  reaper.Undo_BeginBlock()
  
  -- Remove all current region markers:
--  n = reaper.CountProjectMarkers(-1)  
--  for ii = n, 1, -1 do
--    result = reaper.DeleteProjectMarker(-1, ii, true)
--  end  
  
  -- Add the new project markers  
  for ii = 1, #testregions do  
  
     startTime = GetTimeFromTimeCodeString(testregions[ii][1])     
     endTime   = GetTimeFromTimeCodeString(testregions[ii][2])
     text = testregions[ii][3]
  
     if startTime ~= nil and endTime ~= nil and text ~= nil then
       reaper.AddProjectMarker( -1, true, startTime, endTime, text, ii)                                
    end
  end

  reaper.Undo_EndBlock("London Studio: Set regions from animation time code file", -1)
end


function ReadFile(fileName)
    local f, e = io.open(fileName, "r")
    local xmltext
    if f then
      --Gets the entire file content and stores into a string
       xmltext = f:read("*a")    
       return xmltext
    else
      error(e)
      return nil
    end
end    

function GetRegionsFromReaperDocument()
    local nTotal, nMarkers, nRegions = reaper.CountProjectMarkers(-1)  
    currentRegions = {}
    counter = 1
    
    for ii = 1, nTotal do
        local dummy, isRegion, position, regionEnd, regionName, markerNumber = reaper.EnumProjectMarkers(ii)
        if isRegion then
            currentRegions[counter] = {position, regionEnd, regionName, ii }
            counter = counter + 1
        end
    end
    
    return currentRegions
end

function MergeRegions(regionsFromXML, currentRegions)
	
	todelete = {}
	
    -- Copy current times into the ones from the document (i.e. keep current Reaper edits)
    for ii = #regionsFromXML, 1, -1 do 
        local name = regionsFromXML[ii][3]       
        for jj, currentRegion in pairs(currentRegions) do
            if currentRegion[3] == name then
                --regionsFromXML[ii][1] = currentRegion[1]
                --regionsFromXML[ii][2] = currentRegion[2]
                --table.remove(currentRegions, jj)
				table.insert(todelete, currentRegion)
                break
            end
        end   
    end
    
    -- Append existing regions to list
--    for jj, region in pairs(currentRegions) do    
--        table.insert(regionsFromXML, region)
--    end

	--RemoveDoubleRegions(todelete)
	existingRegionsToDelete = todelete
    
    return regionsFromXML
end

function RemoveDoubleRegions(regions)
    local nTotal, nMarkers, nRegions = reaper.CountProjectMarkers(-1)     
    for ii = nRegions, 0, -1 do        
        local dummy, isRegion, position, regionEnd, regionName, markerNumber = reaper.EnumProjectMarkers(ii)
        if isRegion then     
            --reaper.ShowConsoleMsg("\nRegion: " .. regionName)    
            for jj, currentRegion in pairs(regions) do
                if regionName == currentRegion[3] then
                    reaper.DeleteProjectMarker(0, markerNumber, true)
                end
            end
        end
    end
    
end


-----------------------
-- MORE MAGIC NUMBERS

sequenceColumn = 6
animTypeColumn = 7
actionColumn = 8
functionColumn = 9
rigColumn = 10
variationColumn = 11

function ConstructEventNameFromColumns(cells)
  eventName = ""
  eventName = eventName .. GetDataFromCell(cells[sequenceColumn])
  eventName = eventName .. "_" .. GetDataFromCell(cells[animTypeColumn])
  eventName = eventName .. "_" .. GetDataFromCell(cells[actionColumn])
  eventName = eventName .. "_" .. GetDataFromCell(cells[functionColumn])
  eventName = eventName .. "_" .. GetDataFromCell(cells[rigColumn])
  variation = GetDataFromCell(cells[variationColumn]) 
  if variation ~= nil and variation ~= "" and variation ~= "_" then
    eventName = eventName .. "_" .. variation
  end

  return eventName
end
 
 
function ConstructTimeCodeTableFromXmlData(xmlRoot)
  local workBook =  xmlRoot.Workbook
  local workSheets = workBook["Worksheet"]   
  local workSheet = workSheets[workSheetNumber]
  local myTable = workSheet.Table
  local rows = myTable["Row"]

  testregions = {}
  counter = 1
  for ii, row in pairs(rows) do
    tableEntry = {"", "", "" }
    
    if ii >= startRowIndex then
      cells = row["Cell"]
      tableEntry[1] = GetDataFromCell(cells[timeCodeStartColumn])
      tableEntry[2] = GetDataFromCell(cells[timeCodeEndColumn])
      tableEntry[3] = GetDataFromCell(cells[animationEditName])	--ConstructEventNameFromColumns(cells)
    end 
    
    if tableEntry[1] ~= "" and tableEntry[2] ~= "" and tableEntry[3] ~= "" then
      testregions[counter] = tableEntry
      counter = counter + 1
    end
  end
  
  return testregions
end

-------------------------
--       Main          --
-------------------------
     
        
returnValue, fileName = reaper.GetUserFileNameForRead("", "Import animation time code .xml file", "")        
if returnValue == false then return end

xmlText = ReadFile(fileName)
if xmlText == nil then return end
    
 
retval, inputs = reaper.GetUserInputs("Import timecode markers. User options", 2, "Use Non-drop rate? y/n, Worksheet to use", inputs)
--reaper.ShowConsoleMsg(inputs)

useND, wrksht = inputs:match("([^,]+),([^,]+)")

if useND == nil or wrksht == nil then
	reaper.ShowConsoleMsg("Error in user inputs. One or more inputs missing")
	return
end

if string.lower(tostring(useND)) == "y" then
	useNonDropConversion = true
end
workSheetNumber = tonumber(wrksht)



 
----Instantiate the object the states the XML file as a Lua table
local xmlhandler = simpleTreeHandler()

----Instantiate the object that parses the XML to a Lua table
local xmlparser = xmlParser(xmlhandler)
xmlparser:parse(xmlText)

testregions = ConstructTimeCodeTableFromXmlData(xmlhandler.root)

currentProjectRegions = GetRegionsFromReaperDocument()
mergedRegions = MergeRegions(testregions, currentProjectRegions)

RemoveDoubleRegions(existingRegionsToDelete)

--testregions = { {"01:00:00:00", "01:09:05:27", "Test"} }
--RemoveExistingDoubleRegions(mergedRegions)
ImportTimeCodes(mergedRegions)
 

