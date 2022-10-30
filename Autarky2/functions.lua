functions = {}

function functions.loadImages()
	-- terrain tiles
    IMAGES[enum.well] = love.graphics.newImage("assets/images/well_50x45.png")



end

function functions.initialiseMap()

    -- set up some perlin noise for later
    local terrainheightperlinseed
    local terraintypeperlinseed = love.math.random(0,20) / 20
    repeat
        terrainheightperlinseed = love.math.random(0,20) / 20
    until terrainheightperlinseed ~= terraintypeperlinseed

    -- establish the map
    for row = 1, NUMBER_OF_ROWS do
		MAP[row] = {}
	end
	for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
			MAP[row][col] = {}
            MAP[row][col].row = row
            MAP[row][col].col = col
            -- MAP[row][col].centrex = col     -- convenient to store here for drawing purposes
            -- MAP[row][col].centrey = col

            MAP[row][col].structure = nil

            -- create terrain with perlin noise
            -- the noise function only works with numbers between 0 and 1
            local rowvalue = row / NUMBER_OF_ROWS       -- an arbitrary fraction
            local colvalue = col / NUMBER_OF_COLS

            MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            MAP[row][col].tileType = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)
		end
	end

    -- add a well to the map (but not on the edge of the map)
    local minrow = 3
    local mincol = 3
    local maxrow = NUMBER_OF_ROWS - 3
    local maxcol = NUMBER_OF_COLS - 3
    local wellrow = love.math.random(minrow, maxrow)
    local wellcol = love.math.random(mincol, maxcol)
    MAP[wellrow][wellcol].structure = enum.well
    -- store globals for easy recall
    WELLROW = wellrow
    WELLCOL = wellcol
end

function functions.getTileXY(row, col)
    -- returns the top left corner
    local drawx = LEFT_MARGIN + (col -1) * TILE_SIZE
    local drawy = TOP_MARGIN + (row - 1) * TILE_SIZE
    return drawx, drawy
end



return functions
