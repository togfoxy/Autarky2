functions = {}

function functions.loadImages()
	-- terrain tiles
    IMAGES[enum.well] = love.graphics.newImage("assets/images/well_50x45.png")
    IMAGES[enum.market] = love.graphics.newImage("assets/images/market_50x50.png")


    -- quads
    SPRITES[enum.spriteBlueWoman] = love.graphics.newImage("assets/images/Civilian Female Walk Blue.png")
    QUADS[enum.spriteBlueWoman] = cf.fromImageToQuads(SPRITES[enum.spriteBlueWoman], 15, 32)


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

    -- add a marketplace but not too close to the well
    local marketrow
    local marketcol
    repeat
        marketrow = love.math.random(minrow, maxrow)
        marketcol = love.math.random(minrow, maxrow)
    until math.abs(wellrow - marketrow) > 1 or math.abs(wellcol - marketcol) > 1
    MAP[marketrow][marketcol].structure = enum.market
    MARKETROW = marketrow
    MARKETCOL = marketcol

    HISTORY[enum.historyFood] = {}
    HISTORY[enum.historyHealth] = {}
end

function functions.getTileXY(row, col)
    -- returns the top left corner
    local drawx = LEFT_MARGIN + (col -1) * TILE_SIZE
    local drawy = TOP_MARGIN + (row - 1) * TILE_SIZE
    return drawx, drawy
end

function functions.getDrawXY(person)
    local row = person.row
    local col = person.col
    local x = person.x
    local y = person.y

    local drawx, drawy = fun.getTileXY(row, col)
    return drawx + x, drawy + y
end



function functions.RecordHistory(day)

    local personcount = #PERSONS
    local foodsum = 0
    local healthsum = 0

    -- get some stats
    for k, person in pairs(PERSONS) do
        foodsum = foodsum + person.food
        healthsum = healthsum + person.health
    end

    table.insert(HISTORY[enum.historyFood], foodsum/personcount)
    table.insert(HISTORY[enum.historyHealth], healthsum/personcount)
end

return functions
