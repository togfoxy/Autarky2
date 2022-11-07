module(...,package.seeall)

function round(num, idp)
	--Input: number to round; decimal places required
	assert(num ~= nil, "Can't ROUND a nil value")
	return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function AddVectorToPoint(x,y,headingdegrees,distance)
	-- x/y = a point in space
	-- heading is the angle in degrees where 0 = NORTH
	-- distance = distance
	-- returns x and y (whole numbers)
	-- Note: a negative distance (< 0) will provide a point that is behind or backwards.

	local convertedheading = headingdegrees - 90
	if convertedheading < 0 then convertedheading = 360 + convertedheading end
	if convertedheading > 359 then convertedheading = convertedheading - 360 end
	local rads = math.rad(convertedheading)
	local xdelta = cf.round(distance * math.cos(rads))
	local ydelta = cf.round(distance * math.sin(rads))
	return (x + xdelta), (y + ydelta)		-- 0 = NORTH!
end

function GetDistance(x1, y1, x2, y2)
	-- this is real distance in pixels
	-- receives two coordinate pairs (not vectors)
	-- returns a single number

	if (x1 == nil) or (y1 == nil) or (x2 == nil) or (y2 == nil) then return 0 end

    local horizontal_distance = x1 - x2
    local vertical_distance = y1 - y2
    --Both of these work
    local a = horizontal_distance * horizontal_distance
    local b = vertical_distance ^2

    local c = a + b
    local distance = math.sqrt(c)
    return distance
end
function SubtractVectors(x1,y1,x2,y2)
	-- subtracts vector2 from vector1 i.e. v1 - v2
	-- returns a vector (an x/y pair)
	return (x1-x2),(y1-y2)
end
function dotVectors(x1,y1,x2,y2)
	-- receives two vectors (deltas) and assumes same origin
	-- x1/y1 vector is facing/looking
	-- x2/y2 is the position relative to the object doing the looking
	-- eg: guard is looking in direction x1/y1. His looking vector is 1,1
	-- thief vector from guard is 2,-1  (he's on the right side of the guard)
	-- dot product is 1. This is positive so thief is in front of guard (assuming 180 deg viewing angle)
	-- http://blog.wolfire.com/2009/07/linear-algebra-for-game-developers-part-2/
	return (x1*x2)+(y1*y2)
end
function ScaleVector(x,y,fctor)
	-- Receive a vector (0,0, -> x,y) and scale/multiply it by factor
	-- returns a new vector (assuming origin)
	return x * fctor, y * fctor
	--! should create a vector module
end

function getUUID()
	local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function DeDupeArray(myarray)
	-- dedupes myarray and returns same array (not a new array)
	local seen = {}
	for index,item in ipairs(myarray) do
		if seen[item] then
			table.remove(myarray, index)
		else
			seen[item] = true
		end
	end
end

function fltAbsoluteTileDistance(x1,y1,x2,y2)
	-- given two tiles, determine the distance between those tiles
	-- this returns the number of steps or tiles in whole numbers and not in diagonals

	return math.max (math.abs(x2-x1), math.abs(y2-y1))
end

function strFormatThousand(v)
    local s = string.format("%d", math.floor(math.abs(v)))
	local sign = ""

	local pos = string.len(s) % 3
	if pos == 0 then pos = 3 end

	-- special case for negative numbers
	if v < 0 then sign = "-" end

    return sign .. string.sub(s, 1, pos) .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end

function findPath(map, walkable, startx, starty, endx, endy, debug)
	-- jumper algorithm, example use:

	-- local cmap = convertToCollisionMap(MAP)		-- < write your own conversion function
	-- -- jumper uses x and y which is really col and row
	-- local startx = object.col
	-- local starty = object.row
	-- local endx = col
	-- local endy = row
	-- local path = cf.findPath(cmap, 0, startx, starty, endx, endy)        -- startx, starty, endx, endy

	-- Library setup
	local Grid = require ("lib.jumper.grid") -- The grid class
	local Pathfinder = require ("lib.jumper.pathfinder") -- The pathfinder class
	-- Create a grid object
	local grid = Grid(map)
	-- Create a pathfinder object using Jump Point Search
	local myFinder = Pathfinder(grid, 'JPS', walkable)
	-- Calculate the path, and its length
	local path, length = myFinder:getPath(startx, starty, endx, endy)

	-- printing code for debugging
	-- path.x and path.y
	if debug then
		if path then
			print("#### jumper debug ####")
			print(('Path found! Length: %.2f'):format(length))
			for node, count in path:iter() do
				print(('Step: %d - x: %d - y: %d'):format(count, node.x, node.y))
			end
			print("####")
		else
			print("No path found.")
		end
	end
	return path, length
end

function bolTableHasValue (tab, val)
	-- returns true if tab contains val
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function beep()
	--** doesn't seem to work

	local samplerate = 44100 -- Hz
	local duration = 1 -- second
	local frequency = 440.00 -- Hz
	local data = love.sound.newSoundData(math.floor(samplerate/duration), samplerate, 16, 1) -- duration, sampling rate, bit depth, channel count
	for i=0, data:getSampleCount()-1 do
	  data:setSample(i, math.sin(i * frequency * math.pi * 2)) -- sine wave
	end
	local source = love.audio.newSource(data)
	source:play()
end

function fromImageToQuads(spritesheet, spritewidth, spriteheight)
	-- Where spritesheet is an image and spritewidth is the width
	-- and height of your textures
	-- returns a 1d table/array (sequence) that reads left to right across the image and then down
	-- i.e. row 1 then row 2 etc
	local quadtiles = {} -- A table containing the quads to return
	local imageWidth = spritesheet:getWidth()
	local imageHeight = spritesheet:getHeight()
	-- Loop trough the image and extract the quads
	for i = 0, imageHeight - 1, spriteheight do
	for j = 0, imageWidth - 1, spritewidth do
	  table.insert(quadtiles,love.graphics.newQuad(j, i, spritewidth, spriteheight, imageWidth, imageHeight))
	end
	end
	-- Return the table of quads
	return quadtiles
end

function AddScreen(newScreen, screenStack)
	table.insert(screenStack, newScreen)
end

function RemoveScreen(screenStack)
	table.remove(screenStack)
	if #screenStack < 1 then
		love.event.quit()
	end
end

function currentScreenName(screenStack)
	-- returns the current active screen
	-- input: the screen stack array
	-- output: string
	return screenStack[#screenStack]
end

function SwapScreen(newScreen, screenStack)
	-- swaps screens so that the old screen is removed from the stack
	-- this adds the new screen then removes the 2nd last screen.

    AddScreen(newScreen, screenStack)
    table.remove(screenStack, #screenStack - 1)
end

function getBearing(x1,y1,x2,y2)
	-- returns the bearing between two points assuming straight up (north) is zero degrees
	-- Straight down (below/south) is 180 degrees
	-- another way to think of this is the first point is a vector from 0,0 to 0,inf (y axis/north)
	-- and the other vector is from 0,0 to x2,y2. Function returns the angle between those two vectors
	-- input: x1, y1 - the anchor or origin to determine the bearing
	-- output: number - 0 -> 359. Degrees. 0 = north/up/above

    -- if there is an imaginary triangle from the positionx/y to the correctx/y then calculate opp/adj/hyp
	if x1 == x2 and y1 == y2 then targetqudrant = 0 end
    if x2 >= x1 and y2 <= y1 then targetqudrant = 1 end
    if x2 > x1 and y2 > y1 then targetqudrant = 2 end
    if x2 <= x1 and y2 >= y1 then targetqudrant = 3 end
    if x2 < x1 and y2 < y1 then targetqudrant = 4 end

    if targetqudrant == 0 then
        return 0    -- just face north I guess
    elseif targetqudrant == 1 then
        -- tan(angle) = opp / adj
        -- angle = atan(opp/adj)
        local adj = x2 - x1
        local opp = y1 - y2
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(90 - angletocorrectposition)
    elseif targetqudrant == 2 then
        local adj = x2 - x1
        local opp = y2 - y1
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(90 + angletocorrectposition)
    elseif targetqudrant == 3 then
        local adj = x1 - x2
        local opp = y2 - y1
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(270 - angletocorrectposition)
    elseif targetqudrant == 4 then
        local adj = x1 - x2
        local opp = y1 - y2
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(270 + angletocorrectposition)
    end
end

function adjustHeading(heading, amount)
    -- adjusts HEADING by AMOUNT. A positive moves the heading right/clockwise. A negative value moves left/anti-clockwise
    -- will adjust if moves past north/zero/360
	-- input: original heading, amount to adjust
    -- output: new heading
    local newheading = heading + amount
    if newheading > 359 then newheading = newheading - 360 end
    if newheading < 0 then newheading = 360 + newheading end     -- heading is a negative value so '+' it and 360
    return newheading
end

function printAllPhysicsObjects(world, BOX2D_SCALE)
	-- world = physics world
	-- call this in love.draw

	love.graphics.setColor(1, 0, 0, 1)
	for _, body in pairs(PHYSICSWORLD:getBodies()) do
		for _, fixture in pairs(body:getFixtures()) do
			local shape = fixture:getShape()

			if shape:typeOf("CircleShape") then
				local drawx, drawy = body:getWorldPoints(shape:getPoint())
				drawx = drawx * BOX2D_SCALE
				drawy = drawy * BOX2D_SCALE
				local radius = shape:getRadius()
				radius = radius * BOX2D_SCALE
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.circle("line", drawx, drawy, radius)
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.print("r:" .. cf.round(radius,2), drawx + 7, drawy - 3)
			elseif shape:typeOf("PolygonShape") then
				local points = {body:getWorldPoints(shape:getPoints())}
				for i = 1, #points do
					points[i] = points[i] * BOX2D_SCALE
				end
				love.graphics.polygon("fill", points)
			else
				love.graphics.line(body:getWorldPoints(shape:getPoints()))
				error("This physics object needs to be scaled before drawing")
			end
		end
	end
end

function getPerpendicularVector(x1,y1,x2,y2)
	-- returns a vector 90 degrees to the provided vector
	-- vector originates halfway from provided sector
	-- think returned vector is clockwise (splitting to the right)

	-- get the mid point by halving the xy deltas
	-- this serves as the third point/origin of new vector
	local x3 = x1 + (x2 - x1) / 2
	local y3 = y1 + (y2 - y1) / 2

	-- determine the fourth point
	-- use the y delta for the x axis and they x delta for the y axis
	-- negify the x axis
	local x4 = x3 + ((y2 - y1) / 2) * -1
	local y4 = y3 + (x2 - x1) / 2

	-- determine heading
	local distance = math.sqrt( ( (x4-x3)^2 + (y4-y3)^2 ) )
	--! do some trig function when I have energy

	-- for debugging
	-- love.graphics.setColor(1, 1 ,1, 1)
	-- love.graphics.line(x1, y1, x2, y2)
	-- love.graphics.circle("fill", x3, y3, 5)
	-- love.graphics.setColor(0, 1 ,0, 1)
	-- love.graphics.line(x3, y3, x4, y4)

	return x3,y3,x4,y4

end

function deepcopy(orig, copies)
	-- copies one array to another array
	-- ** important **
	-- copies parameter is not meant to be passed in. Just send in orig as a single parameter
	-- returns a new array/table

    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- rotate 2D tables
function rotate_CCW_90(m)
   local rotated = {}
   for c, m_1_c in ipairs(m[1]) do
      local col = {m_1_c}
      for r = 2, #m do
         col[r] = m[r][c]
      end
      table.insert(rotated, 1, col)
   end
   return rotated
end
function rotate_CW_90(m)
   return rotate_CCW_90(rotate_CCW_90(rotate_CCW_90(m)))
end
function rotate_180(m)
   return rotate_CCW_90(rotate_CCW_90(m))
end

function isInFront(x, y, facing, x2, y2)
    -- x,y is the object that is looking (real coordinates, i.e. not normalised and not translated to origin)
    -- facing is the facing of the object at x, y
    -- x2, y2 is the target that the first object is looking for
	-- returns true/false

    -- get a vector in the direction of facing
    local x1, y1 = cf.AddVectorToPoint(x,y,facing,5)        -- 5 is an arbitrary value that doesn't matter
    -- reduce the real vector down to a delta vector
    local deltax1 = x1 - x
    local deltay1 = y1 - y

    -- reduce the vector from object to target down to a delta vector
    local deltax2 = x2 - x	-- the dot product assumes the same origin so need to translate
    local deltay2 = y2 - y

    -- can now do a dot product
    local dotv = cf.dotVectors(deltax1, deltay1, deltax2, deltay2)

    if dotv > 0 then
        -- target is in front of entity
        return true
    else
        return false
    end
end

function convRadToCompass(rad)
	-- converts radian to compass bearing
	local deg = math.deg (rad)

	if deg < 0 then deg = 360 + deg end
	if deg > 359 then deg = deg - 360 end
	return deg
end

function convCompassToRad(compass)
	local rad = math.rad(compass)
	return rad
end

function getTurnDirection(currentheading, desiredheading)
    -- returns a string: "left" or "right" or "none"
    local result
    local angledelta = desiredheading - currentheading

    -- determine if cheaper to turn left or right
    local leftdistance = currentheading - desiredheading
    if leftdistance < 0 then leftdistance = 360 + leftdistance end      -- this is '+' because leftdistance is a negative value

    local rightdistance = desiredheading - currentheading
    if rightdistance < 0 then rightdistance = 360 + rightdistance end   -- this is '+' because leftdistance is a negative value

    if leftdistance < rightdistance then
        result = "left"
    elseif rightdistance < leftdistance then
        result = "right"
    else
        result = "none"     -- no turning required
    end
    return result
end
