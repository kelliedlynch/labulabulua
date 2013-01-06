

local _SH = {}
_SH.shadersList = {}

_SH.SHADERS_DIRECTORY = "Library/DrawClean/draw/shaders/"
_SH.BASIC_COLOR_SHADER = "simpleColor"

function _SH.simpleColor( self )
	if MOAIGfxDevice.isProgrammable () then

		local shader = MOAIShader.new ()

		local file = assert ( io.open ( self.SHADERS_DIRECTORY..'shader_simple.vsh', mode ))
		local vsh = file:read ( '*all' )
		file:close ()

		file = assert ( io.open ( self.SHADERS_DIRECTORY..'shader_simple.fsh', mode ))
		local fsh = file:read ( '*all' )
		file:close ()

		

		shader:reserveUniforms ( 1 )
		shader:declareUniform ( 1, 'transform', MOAIShader.UNIFORM_WORLD_VIEW_PROJ )
		
		shader:setVertexAttribute ( 1, 'position' )
		--shader:setVertexAttribute ( 2, 'uv' )
		shader:setVertexAttribute ( 2, 'color' )

		shader:load ( vsh, fsh )
		
		print("adding shader simple color")
		return shader
	end
end


function _SH:newShader( shaderName )
	if table[ shaderName ] then
		return table[ shaderName ]
	else
		local newShader = self[ shaderName ]( self )
		table[ shaderName ] = newShader
		return newShader
	end
end

return _SH