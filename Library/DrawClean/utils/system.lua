--[[
                                    %%                                    %%
                                    %%                                    %%    
%%%%%%%%      %%%%%%      %%%%%%%%  %%%%%%%%      %%%%%%      %%%%%%    %%%%%%
%%      %%  %%%%    %%  %%          %%      %%  %%      %%  %%      %%    %%
%%      %%  %%  %%  %%    %%%%%%    %%      %%  %%%%%%%%    %%%%%%%%      %%
%%      %%  %%    %%%%          %%  %%      %%  %%          %%            %%
%%      %%    %%%%%%    %%%%%%%%    %%      %%    %%%%%%%%    %%%%%%%%    %%

------------------------------------------------------------------------------
        Module:             lang.lua
        Version:            1.0
        Date:               12/06/01
        Platform:			MOAI 1.01
--============================================================================

BRIEF.
This module retreives information about the system the host is running on.

]]

local system = {}

------------------------------------------------------------------------------
--			STATIC
--============================================================================

SYSTEM_RESOURCE_DIRECTORY  = "resource"
SYSTEM_DOCUMENTS_DIRECTORY = "documents"
SYSTEM_TEMP_DIRECTORY      = "temp"


local isMobile =	MOAIEnvironment.osBrand == MOAIEnvironment.OS_BRAND_ANDROID or
					MOAIEnvironment.osBrand == MOAIEnvironment.OS_BRAND_IOS


local workingDirectory


------------------------------------------------------------------------------
--			Return directories
--============================================================================
function system.getDocumentDirectory()
	
	if MOAIEnvironment.documentDirectory then
		return MOAIEnvironment.documentsDirectory
	else
		-- check if there is a documents directory
		local relativepath = "./../_documentsDirectory/"
		MOAIFileSystem.affirmPath( relativepath )
		return relativepath
		
	end

end

------------------------------------------------------------------------------
--			Is host on mobile?
--============================================================================

function system.isMobile()
	return isMobile
end

------------------------------------------------------------------------------
--			Working directory
--============================================================================
function system.setWorkingDirectory( dir )
	print("work dir is now:",dir)
	workingDirectory = dir
end

function system.getWorkingDirectory()
	if workingDirectory == SYSTEM_DOCUMENTS_DIRECTORY then
		return system.getDocumentDirectory()
	elseif workingDirectory == SYSTEM_RESOURCE_DIRECTORY then
		return "./"
	end
end

--system.setWorkingDirectory( SYSTEM_RESOURCE_DIRECTORY )

return system


 

