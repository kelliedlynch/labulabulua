--------------------------------------------------------------------
-- Load Libraries
--------------------------------------------------------------------
-- DrawClean polygon library
require "Library/DrawClean/utils/lang"
Meshes2D = require "Library/DrawClean/draw/meshes2D"
-- Flower library (general-purpose functions)
Flower = require "Library/flower"

-- Create the window
local deviceWidth = MOAIEnvironment.horizontalResolution
local deviceHeight = MOAIEnvironment.verticalResolution
if deviceWidth == nil then deviceWidth =320 end
if deviceHeight == nil then deviceHeight = 480 end
MOAISim.openWindow ( "LabuLabu", deviceWidth, deviceHeight )

--MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 5, 1, 0, 0 )
--MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 3, 0, 0, 1 )


-- Create the viewport
viewport = MOAIViewport.new ()
viewport:setSize ( deviceWidth , deviceHeight )
screenWidth, screenHeight = 320, 480
viewport:setScale ( 320, 480 ) -- use negative Y axis
viewport:setOffset ( -1, -1 ) -- offset projection origin by -1, 1 in OpenGL projection space

--------------------------------------------------------------------
-- Sounds and stuff
--------------------------------------------------------------------

MOAIUntzSystem.initialize()
MOAIUntzSystem.setVolume(1)

--------------------------------------------------------------------
-- Macros for Dialogue Actions
--------------------------------------------------------------------

LLMacros = require "LLMacros"

--------------------------------------------------------------------
-- Initialize Game Layers
--------------------------------------------------------------------

-- Layer for background images
BackgroundLayer = MOAILayer.new()
BackgroundLayer:setViewport(viewport)
MOAISim.pushRenderPass(BackgroundLayer)

-- Layer for character sprites and animations
SpriteLayer = MOAILayer.new()
SpriteLayer:setViewport(viewport)
MOAISim.pushRenderPass(SpriteLayer)

-- Layer for conversation and hub windows
WindowLayer = MOAILayer.new()
WindowLayer:setViewport(viewport)
MOAISim.pushRenderPass(WindowLayer)

-- Layer for conversation menus
MenuLayer = MOAILayer.new()
MenuLayer:setViewport(viewport)
MOAISim.pushRenderPass(MenuLayer)

-- Layer for popup notifications in conversations and hub
PopupLayer = MOAILayer.new()
PopupLayer:setViewport(viewport)
MOAISim.pushRenderPass(PopupLayer)

--------------------------------------------------------------------
-- Text Handling Stuff
--------------------------------------------------------------------
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

--require "LLTextbox"
LLTextbox = require "LLTextbox"
--LLTextbox = LLT.make()

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

Player = require "player"

-- Load combined dispatcher
LLDispatcher = require "LLDispatch"
LLDispatcher.beginListeningForTouches()

LLMenu = require "LLMenu"

LLConversation = require "LLConversation"

--require "test"

conversation = LLConversation.new("steve001" )

--goToConversation("steve001")
thread = MOAIThread.new()
thread:run ( LLDispatcher.triggerEvent, "startConversation" )
--thread:run ( runTest )
