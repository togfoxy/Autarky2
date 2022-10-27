functions = {}

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

            -- create terrain with perlin noise
            -- the noise function only works with numbers between 0 and 1
            local rowvalue = row / NUMBER_OF_ROWS       -- an arbitrary fraction
            local colvalue = col / NUMBER_OF_COLS

            MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            MAP[row][col].tileType = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)
		end
	end

end

function functions.initialisePeople()

    local numofppl = 50

    for i = 1, numofppl do
        PERSONS[i] = {}
        PERSONS[i].row = love.math.random(1, NUMBER_OF_ROWS)
        PERSONS[i].col = love.math.random(1, NUMBER_OF_COLS)

        -- add a bit of a border to ensure the person stays inside the tile
        local min = 0 + (PERSONS_RADIUS * 2)
        local max = TILE_SIZE - (PERSONS_RADIUS * 2)
        PERSONS[i].x = love.math.random(min, max)
        PERSONS[i].y = love.math.random(min, max)
    end
end

return functions
