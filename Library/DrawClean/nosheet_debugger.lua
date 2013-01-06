
--[[
------------------------------------------------------------------------------
						NO SHEET DEBUGGER CLASS
--============================================================================

                                    !!                                    !!
                                    !!                                    !!	
!!!!!!!!      !!!!!!      !!!!!!    !!!!!!!!      !!!!!!      !!!!!!    !!!!!!
!!      !!  !!!!    !!  !!     	    !!      !!  !!      !!	!!	    !!    !!
!!      !!  !!  !!  !!	  !!!!!!!!  !!      !!	!!!!!!!!    !!!!!!!!	  !!
!!      !!  !!	  !!!!          !!  !!      !!	!!          !!            !!
!!      !!    !!!!!!	!!!!!!!!    !!      !!	  !!!!!!      !!!!!!	  !!

------------------------------------------------------------------------------
					   Copyright (C)2012, No Sheet
					   Platform: MOAI 1.01
--============================================================================

BRIEF.
This is a singleton class containing various useful debugging tools
]]


local SHOULD_DEBUG = true
local DEBUG_PREFIX = "@Debug: "
local DEBUG_INDENT = "    "


local NSD = {}


local timers = {}



local function debugPrint( text, indent )
	
	if indent then
		for i=1, indent do
			text = DEBUG_INDENT..text
		end
	end
	text = DEBUG_PREFIX.." "..text
	print( text )
end

local function debugPrintLine()
	print( "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #")
end




local function printTableInterval( event )
	local eventData = event.source
	local recursiveLevels = 0
	local tableString
	if eventData.sourceTable and type( eventData.sourceTable ) == "table" then
		tableString, recursiveLevels = NSD.printTable( eventData.sourceTable, eventData.title )
	else
		debugPrint( "Table "..eventData.title.." no longer exist. Stopping the dump")
		NSD.stop()
		timer.cancel( timers[ eventData.timerIndex ] )
	end

	if recursiveLevels > eventData.maxLevel then
		NSD.stop( "dumping table "..eventData.title.." reached max recursive index!" )
		timer.cancel( timers[ eventData.timerIndex ] )
	end
end


------------------------------------------------------------------------------------
--
--						INTERFACE / SIMULATOR 
--
--==================================================================================


function NSD.stop( reason )
	debugPrintLine()
	debugPrint( "NO SHEET DEBBUGER HAS STOPPED APPLICATION! REASON:" )
	debugPrint( reason )
	print( " "..nil ) -- this will throw exception
end


function NSD.startPrintingTable( t, params )
	
	-- Max level: if table gets too recursive, stop function
	-- Currently TOP level is 20, and nothing else works
	if NSD.isActive then
		if type(t) == "table" then
			if not params then params = {} end
			local maxLevel = params.maxLevel or 19
			local repeatTimes = params.repeatTimes or 0
			local delay = params.delay or 2500
			local title = params.title or "Table Dump"

			timers[ #timers + 1 ] = timer.performWithDelay( delay, printTableInterval, repeatTimes )
			timers[ #timers ].timerIndex = #timers
			timers[ #timers ].sourceTable = t
			timers[ #timers ].title = title
			timers[ #timers ].maxLevel = maxLevel
		else

		end
	end
end

function NSD.printMemory()
	debugPrintLine()
	local usage = MOAISim.getMemoryUsage()
	--[[
	debugPrint( "Texture Memory: "..( .000001 * system.getInfo( "textureMemoryUsed" )).."Mb", 4 )
	debugPrint( "Lua Memory: "..math.ceil( collectgarbage("count")).."Kb", 4)
	]]
	debugPrintLine()
end

function NSD.printTable( t, title, maxLevels )
	if NSD.isActive then
		local str, lev = table.toString( t, title, maxLevels )
		print(str)
		return str, lev
	end
end

function NSD.printFatLine( n )
	n = n or 5
	for i=1, n do
		debugPrintLine()
	end
end

function NSD.activate( onOff )
	NSD.isActive = onOff
end



NSD.isActive = SHOULD_DEBUG

------------------------------------------------------------------------------------
--
--						INTERFACE / DEVICE
--
--==================================================================================

--if system.getInfo( "environment" ) ~= "simulator" then
-- Do not debug on mobile devices


local brand = MOAIEnvironment.osBrand
if bland == MOAIEnvironment.OS_BRAND_ANDROID or bland == MOAIEnvironment.OS_BRAND_IOS then

	NSD = nil
	NSD = {}
	NSD.printTable         = function() end
	NSD.stop               = function() end
	NSD.startPrintingTable = function() end
	NSD.printMemory        = function() end
	NSD.activate           = function() end
	NSD.printFatLine	   = function() end
end


return NSD














