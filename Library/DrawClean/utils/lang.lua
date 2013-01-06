
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
        Date:               12/05/29
--============================================================================

BRIEF.
This module expands lua language with some useful methods.
Expands:
    - table
    - string
    - math

]]







------------------------------------------------------------------------------
--============================================================================
--
--                          table
--
------------------------------------------------------------------------------
--============================================================================

------------------------------------------------------------------------------
--  Table decorate is useful for decorating objects
--  when using tables as classes.
--  @param: arg1 - string=new key when string, needs arg2
--               - table=will extend all key/values
--          arg2(optional)        
--============================================================================

-- Note: table.decorate is useful to decorate objects in RUNTIME,
-- that's why we don't use it for the rest of the functions below.

function table.decorate( src, arg1, arg2 )
    if not arg2 then
        if type(arg1)=="table" then
            for k,v in pairs( arg1 ) do
                if not src[k] then
                    src[k] = v
                elseif src[ k ] ~= v then
                    print( "ERROR (table.decorate): Extension failed because key "..k.." exists.") 
                end   
            end
        end
    elseif type(arg1)=="string" and type(arg2)=="function" then
        if not src[arg1] then
            src[arg1] = arg2
        elseif src[ arg1 ] ~= arg2 then
            print( "ERROR (table.decorate): Extension failed because key "..arg1.." exists.") 
        end      
    end
end

------------------------------------------------------------------------------
--  table.override and table.extend are very similar, but are made different
--  routines so that they wouldn't be confused
--============================================================================
-- Copies properties from src to dest without overriding anything
function table.extend( src, dest )
    for k,v in pairs( src) do
        if not dest[k] then
            dest[k] = v
        end
    end
end

-- Copies and overrides properties from src to dest.
-- If onlyExistingKeys is true, it *only* overrides the properties.
function table.override( src, dest, onlyExistingKeys )
    for k,v in pairs( src ) do
        if not onlyExistingKeys then
            dest[k] = v
        elseif dest[k] then
            -- override only existing keys if asked for
            dest[k] = v
        end
    end
end

------------------------------------------------------------------------------
--  Shallow copy of the table, copies all properties
--  If a property is a table, no new table is generated,
--  the reference to existing table is used.
--  Table copy is similar to table.override, but it's made a different method
--  to make the code more comprehensive.
--============================================================================
-- Usage: b = table.copy(a), or table.copy(a, b) if b already defined

function table.copy( src, dest )
    dest = dest or {}
    for k,v in pairs( src ) do
        dest[k] = v
    end
    return dest
end

------------------------------------------------------------------------------
--  Deep copy of the table, copies all properties
--  If a property is a table, will copy recursively
--============================================================================

function table.deepCopy( src, dest )
    dest = dest or {}
    for k,v in pairs( src ) do
        if type(v) == "table" then
            dest[k] = table.deepCopy( v )
        else
            dest[k] = v
        end
    end
    return dest
end

------------------------------------------------------------------------------
--  Finds the value if exists in ARRAY table ("int" keys)
--  Doesn't work if table has "string" keys
--  Returns nil if not found
--============================================================================

function table.indexOf( src, val )
    for k,v in ipairs( src ) do
        if v == val then
            return v
        end
    end
    return nil
end

------------------------------------------------------------------------------
--  Same as indexOf, only for key values (slower)
--============================================================================

function table.keyOf( src, val )
    for k,v in pairs( src ) do
        if v == val then
            return v
        end
    end
    return nil
end

------------------------------------------------------------------------------
--  Removes the key/value from the table and returns the value
--============================================================================
function table.removeKey( src, key )
    local el = src[key]
    if el then
        src[key] = nil
    end
    return el
end

------------------------------------------------------------------------------
--  Dumps the table into string, for print function (returns string)
--============================================================================

-- Local temp variables needed for this recursive routine to work

local tableToStringLevel, tableToStringMaxLevel, tableToStringResult
local MAX_RECURSION_LEVELS = 20 -- const

function table.toString( self, prefix, maxLevels, isRecursiveCall )
 
    if not isRecursiveCall then
        -- first time entering the routine
        prefix = prefix or ""
        tableToStringResult = "- - - - - - - - - - - - - - - - - - - Table:"..prefix.."\n"
        tableToStringLevel = 1
        tableToStringMaxLevel = 1
    else
        tableToStringLevel = tableToStringLevel + 1
        if tableToStringMaxLevel < tableToStringLevel then
            tableToStringMaxLevel = tableToStringLevel
        end
        if tableToStringLevel > MAX_RECURSION_LEVELS then
            print("ERROR( table.toString ). Table seems endlessly recursive, aborting!")
            return tableToStringResult, tableToStringLevel
        end
    
        if maxLevels and tableToStringLevel > maxLevels then    
            return tableToStringResult, tableToStringLevel
        end
    end

    local indent = ""
    for i=1, tableToStringLevel do indent = indent..".  " end

    for k,v in pairs( self ) do
        -- skip these temporary values
        if type(v) ~= "table" then
            tableToStringResult = tableToStringResult..indent..k.." : "..tostring( v ).."\n"
        else
            tableToStringResult = tableToStringResult..indent..k.." : "..tostring( v ).."\n"
           -- if tableToStringLevel < 1 then
                local addStr, level = table.toString( v, "", maxLevels, true )
                 if level < 1  then
                    break
                end
           -- end
           
        end
    end

    tableToStringLevel = tableToStringLevel-1

    return tableToStringResult, tableToStringLevel


end



------------------------------------------------------------------------------
--============================================================================
--
--                          string
--
------------------------------------------------------------------------------
--============================================================================


------------------------------------------------------------------------------
--  Converts the string to number, or returns string if fail.
--============================================================================

function string.toNumber( self )
    if type( tonumber( self ) ) =="number" then
        return tonumber( self )
    else
        return self
    end
end


------------------------------------------------------------------------------
--  Converts number to string, filling in zeros at beginning.
--  Technically, this shouldn't really extend string class
--  because it doesn't operate on string (doesn't have a "self" )
--============================================================================

--  Usage:  print( string.fromNumbersWithZeros( 421, 6 ) )
--          000421

function string.fromNumberWithZeros( n, l )
    local s = tostring ( n )
    local sl = string.len ( s )
    if sl < l then
        -- add zeros before
        for i=1, l - sl do
            s = "0"..s
        end
    end
    return s
end

------------------------------------------------------------------------------
--  Converts hex number to rgb (format: #FF00FF)
--============================================================================

function string.hexToRGB( s, returnAsTable )
    if returnAsTable then
        return  { tonumber ( "0x"..string.sub( s, 2, 3 ) )/255.0,
                tonumber ( "0x"..string.sub( s, 4, 5 ) )/255.0,
                tonumber ( "0x"..string.sub( s, 6, 7 ) )/255.0 }
    else
        return  tonumber ( "0x"..string.sub( s, 2, 3 ) )/255.0,
                tonumber ( "0x"..string.sub( s, 4, 5 ) )/255.0,
                tonumber ( "0x"..string.sub( s, 6, 7 ) )/255.0
    end
end


------------------------------------------------------------------------------
--  Splits string into N lines, using default ("#") or custom delimiter
--  Routine separate words by spaces so make sure you have them.
--============================================================================

-- USAGE:   For a string "width:150 height:150", or "width:150_height:150"
--          returns a table { width=150, height=150 }

function string.toTable( self, delimiter )

    local t = {}

    if not delimiter then delimiter = " " end
    local kvPairs = self:split( delimiter )

    local k, v, kvPair

    for i=1, #kvPairs do
        kvPair = kvPairs[i]:split( ":" )

        if #kvPair == 2 then
            t[ kvPair[1] ] = string.toNumber( kvPair[2] )
        end

    end


    return t
end

------------------------------------------------------------------------------
--  Splits string into a table of strings using delimiter
--============================================================================

-- Usage: local table = a:split( ",", false )

function string.split( self, delim, toNumber )
    
    local start = 1
    local t = {}  -- results table
    local newElement
    -- find each instance of a string followed by the delimiter
    while true do
        local pos = string.find (self, delim, start, true) -- plain find
        if not pos then
            break
        end
        -- force to number
        newElement = string.sub (self, start, pos - 1)
        if toNumber then
            newElement = newElement:toNumber()
        end
        table.insert (t, newElement)
        start = pos + string.len (delim)
    end -- while

    -- insert final one (after last delimiter)
    local value =  string.sub (self, start)
    if toNumber then
        value = value:toNumber()
    end
    table.insert (t,value )
    return t
end

------------------------------------------------------------------------------
--  Splits string into N lines, using default ("#") or custom delimiter
--  Routine separate words by spaces so make sure you have them.
--============================================================================

-- Usage: local string = s:splitIntoLines( 3, "\n" )

function string.splitToLines( self, numLines, delim )
    
    local result = ""
    delim = delim or "#"    -- Default delimiter used for display.newText

    numLines = numLines or 2
    -- break into all words.
    local allWords = self:split( " " )
    if #allWords < numLines then
        numLines = #allWords
    end

    -- Words per line
    local wordsPerLine = math.ceil( #allWords/numLines )
    local counter = wordsPerLine

    for i=1, #allWords do
        result = result..allWords[i]
        counter = counter - 1
        if counter == 0 and i<#allWords then
            counter = wordsPerLine
            result = result..delim
        else
            result = result.." "
        end
    end

    return result
end



------------------------------------------------------------------------------
--  String encryption
--============================================================================

function string.encrypt( str, code )
    code = code or math.random(3,8)
    local newString = string.char( 65 + code )
    local newChar
    for i=1, str:len() do
        newChar = str:byte(i) + code
        newString = newString..string.char(newChar)
    end
    return newString
end

function string.decrypt( str )
    local newString = ""
    local code = str:byte(1) - 65
    for i = 2, str:len() do
        newChar = str:byte(i) - code
        newString = newString..string.char(newChar)
    end
    return newString
end

------------------------------------------------------------------------------
--============================================================================
--
--                          math
--
------------------------------------------------------------------------------
--============================================================================


function math.distance( x0, y0, x1, y1 )
    if not x1 then x1 = 0 end
    if not y1 then y1 = 0 end
    
    local dX = x1 - x0
    local dY = y1 - y0
    local dist = math.sqrt((dX * dX) + (dY * dY))
    return dist
end

function math.normalize( x, y )
    local d = math.distance( x, y )
    return x/d, y/d
end

function math.getAngle( a, b, c )
    local result
    if c then
        local ab, bc = { }, { }
        
        ab.x = b.x - a.x;
        ab.y = b.y - a.y;

        bc.x = b.x - c.x;
        bc.y = b.y - c.y;
        
        local angleAB   = math.atan2( ab.y, ab.x )
        local angleBC   = math.atan2( bc.y, bc.x )
        result = angleAB - angleBC
    else
        local ab = { }

        ab.x = b.x - a.x;
        ab.y = b.y - a.y;
        result = math.deg( math.atan2( ab.y, ab.x ) )

    end
    return  result
end

function math.clamp( v, min, max )
    if v < min then
        v = min
    elseif v > max then
        v = max
    end
    return v
end




































