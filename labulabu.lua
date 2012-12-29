-- Create the window
screenWidth = MOAIEnvironment.horizontalResolution
screenHeight = MOAIEnvironment.verticalResolution
if screenWidth == nil then screenWidth =320 end
if screenHeight == nil then screenHeight = 480 end
MOAISim.openWindow ( "LabuLabu", screenWidth, screenHeight )

-- Create the viewport
viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth , screenHeight )
viewport:setScale ( 320 , 480 )

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

-- Load DrawClean polygon library
require "DrawClean/utils/lang"
-- Load meshes file
Meshes2D = require "DrawClean/draw/meshes2D"

Player = require "player"

-- Load the touch dispatcher
TouchDispatcher = require "LLTouchDispatcher"
TouchDispatcher.beginListening()

conversation = require "conversation"
--goToConversation("steve001")
thread = MOAIThread.new ()
thread:run ( conversation.goToConversation, "steve001" )
