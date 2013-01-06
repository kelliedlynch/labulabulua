
--[[
                                    %%                                    %%
                                    %%                                    %%    
%%%%%%%%      %%%%%%      %%%%%%    %%%%%%%%      %%%%%%      %%%%%%    %%%%%%
%%      %%  %%%%    %%  %%          %%      %%  %%      %%  %%      %%    %%
%%      %%  %%  %%  %%    %%%%%%%%  %%      %%  %%%%%%%%    %%%%%%%%      %%
%%      %%  %%    %%%%          %%  %%      %%  %%          %%            %%
%%      %%    %%%%%%    %%%%%%%%    %%      %%    %%%%%%%     %%%%%%%     %%

------------------------------------------------------------------------------
        Module:             json_moai.lua
        Version:            1.0
        Date:               12/05/29
--============================================================================

BRIEF.
Extenrs original Corona's JSON method.


]]



------------------------------------------------------------------------------
--				Loads json from file and returns table.
--============================================================================

-- Usage: local params = json.loadFromFile( "data/params.json", system.ResourceDirectory )





function MOAIJsonParser.loadFromFile( filename, useCustomDirectory )
	
	local data = nil

	if not useCustomDirectory then
		filename = system.getWorkingDirectory()..filename
	end

	
	if MOAIFileSystem.checkFileExists( filename ) then
		-- will hold contents of file
		local contents = nil
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( filename, "r" )
		if file then
		   contents = file:read( "*a" )
		   io.close( file )	-- close the file after using it
		end
		if contents then
			print("contents = ")
			print(contents)
			data = MOAIJsonParser.decode( contents )
			print("data is",data)
		end
	else
		debugger.stop( "ERROR, file doesn't exist: "..filename )
	end
	return data

end


------------------------------------------------------------------------------
--				Save a table to a json file
--============================================================================

-- Important: Can't save in system.ResourceDirectory

function MOAIJsonParser.saveToFile( table, filename, useCustomDirectory )

	if not useCustomDirectory then
		filename = system.getWorkingDirectory()..filename
	end


	local jsonString = MOAIJsonParser.encode( table )

	local file = io.open ( filename, "w+b" )

	file:write ( jsonString )
	io.close ( file )

end


function MOAIJsonParser.decryptFromFile( filename, useCustomDirectory )
	
	local data = nil

	if not useCustomDirectory then
		filename = system.getWorkingDirectory()..filename
	end

	
	if MOAIFileSystem.checkFileExists( filename ) then
		-- will hold contents of file
		local contents = nil
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( filename, "r" )
		if file then
		   contents = file:read( "*a" )
		   io.close( file )	-- close the file after using it
		end
		if contents then
			
			-- first number is encryption code

			contents = contents:decrypt()
			print("contents = ")
			print(contents)
			data = MOAIJsonParser.decode( contents )
			print("data is",data)
		end
	else
		debugger.stop( "ERROR, file doesn't exist: "..filename )
	end
	return data

end



function MOAIJsonParser.encryptToFile( table, filename, useCustomDirectory )

	if not useCustomDirectory then
		filename = system.getWorkingDirectory()..filename
	end


	local jsonString = MOAIJsonParser.encode( table )
	jsonString = jsonString:encrypt()


	local file = io.open ( filename, "w+b" )

	file:write ( jsonString )
	io.close ( file )
end




--[[

-- EXAMPLE: Encrypt jason data

local user_data_path = "_myJasonRootCripted2.json"
local data = {
  name = "John",
  surname = "Gvozden",
  age = 53,
  children = { "Ivana", "Janko", "Katarina", "Zvonkodrag"}
}


system.setWorkingDirectory( SYSTEM_DOCUMENTS_DIRECTORY )
MOAIJsonParser.encryptToFile( data, user_data_path)


local d = MOAIJsonParser.decryptFromFile( user_data_path )

debugger.printTable( d )
]]


