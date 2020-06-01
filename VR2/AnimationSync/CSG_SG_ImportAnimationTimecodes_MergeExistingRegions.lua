--[[
* ReaScript Name: CSG_SG_ImportAnimationTimecodes_MergeExistingRegions
* Description: 
* Instructions: 
* Author: Simon Gumbleton
* Version: 1.1
* Provides: [main=main]
--]]


require("LuaXML/xml")
require("LuaXML/handler")


frameRate = 30 -- Lock frame rate to 30. Alternative: reaper.TimeMap_curFrameRate(-1)

-- testregions = {
--  {1., 2., "Test region 1"},
--  {3., 5., "Foo"},
--  {7., 9., "Bar"},
--  {12., 15.0, "Pizza"}
-- }

 inputs = ""
 useNonDropConversion = false
 useND = ""


 

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

function GetRegionsFromReaperDocument()
    local nTotal, nMarkers, nRegions = reaper.CountProjectMarkers(-1)  
    currentRegionsinReaper = {}
    counter = 0	
    
    for ii = 0, nTotal do
        local dummy, isRegion, position, regionEnd, regionName, markerNumber = reaper.EnumProjectMarkers(ii)
		
        if isRegion then
            currentRegionsinReaper[counter+1] = {position, regionEnd, regionName, markerNumber}
            counter = counter + 1
        end
    end
    
    return currentRegionsinReaper
end

function MergeRegions(regionsFromXML, currentRegions)

	DuplicateRegions = {}

    -- Copy current times into the ones from the document (i.e. keep current Reaper edits)
    for ii = #regionsFromXML, 1, -1 do 
        local name = regionsFromXML[ii][3]
		--reaper.ShowConsoleMsg(name)		
        for jj, currentRegion in pairs(currentRegions) do
			--reaper.ShowConsoleMsg(currentRegion[3])	
            if currentRegion[3] == name then 
            -- name matches. We have a region in Reaper with the same name as the xml
				--reaper.ShowConsoleMsg(name)
                
                local regNum = currentRegion[4]
                local pos = regionsFromXML[ii][1]     
     			local rgnEnd   = regionsFromXML[ii][2]
     			local name = regionsFromXML[ii][3]
     					
                -- Set Project region with new timecode
                reaper.SetProjectMarker(regNum,true, pos, rgnEnd, name);
                
                -- Remove region from current region list and add to duplicate list               
                table.remove(currentRegions, jj)
                table.insert(DuplicateRegions, regionsFromXML[ii])
                --table.remove(regionsFromXML, ii)
                            
                break
            end
        end   
    end
    
    reaper.ShowConsoleMsg("Updated "..tostring(#DuplicateRegions).." Regions from XML\n")
    
    --remove duplicate regions once they've been updated in Reaper
    for ii = #DuplicateRegions, 1, -1 do 
        local name = DuplicateRegions[ii][3]       
        for jj, currentRegion in pairs(regionsFromXML) do
            if currentRegion[3] == name then
            	--reaper.ShowConsoleMsg(name)
            	table.remove(regionsFromXML, jj)
            end
        end
    end
    
    -- regionsFromXML should now only contain new regions from animation sheet
    lengthOfXmlRegions = tostring(#regionsFromXML)
    --reaper.ShowConsoleMsg("____"..lengthOfXmlRegions.."______")
    
    return regionsFromXML
end


function SetRegionsFromArray(testregions)  
  
  -- Add the new project markers  
  for ii = 1, #testregions do  
  
     local startTime = testregions[ii][1]     
     local endTime   = testregions[ii][2]
     local text = testregions[ii][3]
  
     if startTime ~= nil and endTime ~= nil and text ~= nil then
       reaper.AddProjectMarker2( -1, true, startTime, endTime, text, ii, RandRegionColour)
    end
  end
  
  reaper.ShowConsoleMsg("Inserted "..tostring(#testregions).." New Regions from XML\n")
  
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

 
function ConstructTimeCodeTableFromXmlData(xmlRoot)  
    local testregions = {}
    
    local sheet = xmlRoot["ShotManagerAudioProductionSheet"]
    if sheet == nil then return testregions end
    local anims = sheet["AnimTake"]  
    if anims == nil then return testregions end
    
	--reaper.ShowConsoleMsg("_anim take".." = "..tostring(#anims))
	
	if (#anims) == 0 then	-- Only one anim take in the table
	
		local counter = 1
		for i, animSpec in pairs(anims) do  
		animspec_test = animSpec
	  
			for key, value in pairs(animSpec) do
				--reaper.ShowConsoleMsg("_anim spec_".." = "..tostring(animSpec).." Key values = "..tostring(key).."_"..tostring(value))
			end
	  
			if animSpec ~= nil and animSpec["audioignore"] ~= "yes" then
				local tableEntry = {"", "", "", -1 }
				local a = animSpec["name"]
				tableEntry[1] = animSpec["timecodestart"]
				tableEntry[2] = animSpec["timecodeend"]
				tableEntry[3] = animSpec["name"]
				
				--- Animations renamed after rig changes. Handle changes to the rig name for Michelle Jacket animations---
				-----------------------------------------------------------------------------------------------------------
				animName = tableEntry[3]
				if string.find(animName,"michelle_jacket") then
					tableEntry[3] = string.gsub(animName,"michelle_jacket", "michelle")
				end		
               
			   -------------------------------------------------------------------------------------------------------------
			   -------------------------------------------------------------------------------------------------------------
			   
				if  tableEntry[1] ~= nil and 
				tableEntry[1] ~= "" and
				tableEntry[2] ~= nil and
				tableEntry[2] ~= "" and 
				tableEntry[3] ~= nil and
				tableEntry[3] ~= "" then      
					tableEntry[1] = GetTimeFromTimeCodeString(tableEntry[1])
					tableEntry[2] = GetTimeFromTimeCodeString(tableEntry[2])          
					testregions[counter] = tableEntry    
					counter = counter + 1
				end        
			end
		end
    else		--- More than one anim take in the XML
		local counter = 1
		for i, animSpec in pairs(anims) do  
			animspec_test = animSpec
	  
			for key, value in pairs(animSpec) do
				reaper.ShowConsoleMsg("_anim spec_".." = "..tostring(animSpec).." Key values = "..tostring(key).."_"..tostring(value))
			end
	  
			if animSpec ~= nil and animSpec._attr["audioignore"] ~= "yes" then
				local tableEntry = {"", "", "", -1 }
				local a = animSpec._attr["name"]
				tableEntry[1] = animSpec._attr["timecodestart"]
				tableEntry[2] = animSpec._attr["timecodeend"]
				tableEntry[3] = animSpec._attr["name"]  
				
				--- Animations renamed after rig changes. Handle changes to the rig name for Michelle Jacket animations--
				-----------------------------------------------------------------------------------------------------------
				animName = tableEntry[3]
				if string.find(animName,"michelle_jacket") then
					tableEntry[3] = string.gsub(animName,"michelle_jacket", "michelle")
				end
				-------------------------------------------------------------------------------------------------------------
			   -------------------------------------------------------------------------------------------------------------
				   
				if  tableEntry[1] ~= nil and 
					tableEntry[1] ~= "" and
					tableEntry[2] ~= nil and
					tableEntry[2] ~= "" and 
					tableEntry[3] ~= nil and
					tableEntry[3] ~= "" then      
				  tableEntry[1] = GetTimeFromTimeCodeString(tableEntry[1])
				  tableEntry[2] = GetTimeFromTimeCodeString(tableEntry[2])          
				  testregions[counter] = tableEntry    
				  counter = counter + 1
				end        
			end
		end
    end
	
    return testregions
end

-------------------------
--       Main          --
-------------------------

--pick a random colour to assign to newly imported regions
r = math.random(255)	
g = math.random(255)
b = math.random(255)

RandRegionColour = reaper.ColorToNative(r,g,b)|0x1000000

reaper.ShowConsoleMsg(RandRegionColour)  
          
reaper.ShowConsoleMsg("Importing...\n")        

returnValue, fileName = reaper.GetUserFileNameForRead("", "Import animation time code .xml file", "")        
if returnValue == false then return end

--reaper.ShowConsoleMsg(fileName)  

xmlText = ReadFile(fileName)
if xmlText == nil then return end

retval, inputs = reaper.GetUserInputs("Import timecode markers. User options", 1, "Use Non-drop rate? y/n", inputs)
--reaper.ShowConsoleMsg(inputs)

useND = inputs

if string.lower(tostring(useND)) == "y" then
	useNonDropConversion = true
end

  
----Instantiate the object the states the XML file as a Lua table
local xmlhandler = simpleTreeHandler()
reaper.ShowConsoleMsg("\nFile read. Parsing...\n")  
  
----Instantiate the object that parses the XML to a Lua table
local xmlparser = xmlParser(xmlhandler)
xmlparser:parse(xmlText)

reaper.ShowConsoleMsg("Constructing time code table...\n")

regionsFromXML = ConstructTimeCodeTableFromXmlData(xmlhandler.root)
currentRegions = GetRegionsFromReaperDocument()
mergedRegions = MergeRegions(regionsFromXML, currentRegions)

reaper.Undo_BeginBlock()

SetRegionsFromArray(mergedRegions)  

reaper.Undo_EndBlock("London Studio: Set regions from animation time code file", -1)
