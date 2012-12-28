--[[
                                    %%                                    %%
                                    %%                                    %%    
%%%%%%%%      %%%%%%      %%%%%%%%  %%%%%%%%      %%%%%%      %%%%%%    %%%%%%
%%      %%  %%%%    %%  %%          %%      %%  %%      %%  %%      %%    %%
%%      %%  %%  %%  %%    %%%%%%    %%      %%  %%%%%%%%    %%%%%%%%      %%
%%      %%  %%    %%%%          %%  %%      %%  %%          %%            %%
%%      %%    %%%%%%    %%%%%%%%    %%      %%    %%%%%%%%    %%%%%%%%    %%

------------------------------------------------------------------------------
        
        			DRAWING 2D MESHES: EXAMPLES
        			Copyright (c)2012, Nenad Katic
        			
--============================================================================

BRIEF.

]]

--------------------------------------------------
-- Extending Lua's table, math and string
-- Check out more helper routines in utils folder
--================================================
require "DrawClean/utils/lang"

-- If things go wrong, this simple module can help
-- figuring out where the error is:
-- debugger = require "DrawClean/nosheet_debugger"

-- Load our meshes file
local Meshes2D = require "DrawClean/draw/meshes2D"

--------------------------------------------------
-- Open window, viewport and make layer
--================================================

-- Set screen size
local sw, sh = 960, 640

MOAISim.openWindow ( "MOAI 2D Draw Polygons", sw, sh )

viewport = MOAIViewport.new ()
viewport:setSize ( sw, sh )
viewport:setScale ( sw, sh )
--viewport:setOffset( -1, 1 )

layer = MOAILayer.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )



--------------------------------------------------
-- Letter: "O": Create a circle using solid color
--================================================

-- Create new circle: ( centerX, centerY, radius, colorHex )
local letterO = Meshes2D.newCircle( -75, 0, 100, "#FFCC00")
layer:insertProp( letterO )


------------------------------------------------------------------
-- Letter: "A": Simple polygon using circle with defined segments
--================================================================

-- Create gradient from dark to bright blue with an angle of 0
local gradient1 = Meshes2D.newGradient( "#00CC00", "#0099FF", 0 )

-- Now we are sending gradient as a paremeter, and number 3 = 3 segments only
local letterA = Meshes2D.newCircle( 120, -34, 132, gradient1, 3 )
layer:insertProp( letterA )
-- rotate in place so it looks like an "A"
letterA:moveRot( 450, 3 )


------------------------------------------------------------------
-- Letter: "I": Let's draw a rectangle, each vertex different color
--================================================================

local colors = { "#FF0000", "#FFCC00", "#009900", "#0099CC" }

-- Parameters: left, top, width, height, colors
local letterI = Meshes2D.newRect( 250, -100, 100, 200, colors )
layer:insertProp( letterI )

------------------------------------------------------------------
-- Letter: "M": Finally, let's draw a real polygon
--================================================================

local verticesForM = {
	{ x = 0, y = 0 },
	{ x = 50, y = 0 },
	{ x = 50, y = 75 },
	{ x = 100, y = 25 },
	{ x = 150, y = 75 },
	{ x = 150, y = 0 },
	{ x = 200, y = 0 },
	{ x = 200, y = 200 },
	{ x = 100, y = 100},
	{ x = 0, y = 200 }
}
-- Crate another gradient from red to yellow, diagonally
local gradient2 = Meshes2D.newGradient( "#990000", "#FFFF00", 45 )

local poly =  Meshes2D.createPolygon( verticesForM, gradient2 )
layer:insertProp( poly )
poly:seekLoc( -395, -100, 2 )