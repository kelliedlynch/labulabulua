-- Create the window
screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth =320 end
if screenHeight == nil then screenHeight = 480 end
MOAISim.openWindow ( "LabuLabu", screenWidth, screenHeight )

-- Create the viewport
viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth , screenHeight )
viewport:setScale ( 320, 480 ) -- use negative Y axis
viewport:setOffset ( -1, -1 ) -- offset projection origin by -1, 1 in OpenGL projection space

--------------------------------------------------------------------
-- Initialize Game Layers
--------------------------------------------------------------------

-- Layer for background images
BackgroundLayer = MOAILayer.new ()
BackgroundLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( BackgroundLayer )

-- Layer for character sprites and animations
SpriteLayer = MOAILayer.new ()
SpriteLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( SpriteLayer )

-- Layer for conversation and hub windows
WindowLayer = MOAILayer.new ()
WindowLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( WindowLayer )

-- Layer for popup notifications in conversations and hub
PopupLayer = MOAILayer.new ()
PopupLayer:setViewport ( viewport )
MOAISim.pushRenderPass ( PopupLayer )


-- Load game fonts
charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
defaultFont = MOAIFont.new ()
defaultFont:load ( 'Resources/Fonts/MarkerFelt.ttc' )
defaultFont:preloadGlyphs ( charcodes, 44 )
defaultFont:preloadGlyphs ( charcodes, 38 )

function newStyle ( font, size, scale )
	local style = MOAITextStyle.new ()
	style:setFont ( font )
	style:setSize ( size )
	if scale == nil then
		style:setScale ( .5 )
	else
		style:setScale ( scale )
	end
	return style;
end


function deepcopy(orig)
	-- deepcopy function from lua-users wiki
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Load DrawClean polygon library
require "DrawClean/utils/lang"
-- Load meshes file
Meshes2D = require "DrawClean/draw/meshes2D"

Player = require "player"

-- -- Load the touch dispatcher
-- TouchDispatcher = require "LLTouchDispatcher"
-- TouchDispatcher.beginListening()

-- -- Load the event dispatcher
-- EventDispatcher = require "LLEventDispatcher"

-- Load combined dispatcher
LLDispatcher = require "LLDispatch"
LLDispatcher.beginListeningForTouches()

LLMenu = require "LLMenu"

LLConversation = require "LLConversation"

--require "test"

conversation = LLConversation.new("joe001")

--goToConversation("steve001")
thread = MOAIThread.new()
thread:run ( LLDispatcher.triggerEvent, "startConversation" )
--thread:run ( runTest )
