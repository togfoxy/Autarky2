people = {}

function people.initialise()

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

function people.assignDestination(hour)
    -- assign target row, col, x, y based on the hour of the day

    for k, person in pairs(PERSONS) do

        if hour == 8 then
            --! currently random
            person.row = love.math.random(1, NUMBER_OF_ROWS)
            person.col = love.math.random(1, NUMBER_OF_COLS)
            local min = 0 + (PERSONS_RADIUS * 2)
            local max = TILE_SIZE - (PERSONS_RADIUS * 2)
            person.x = love.math.random(min, max)
            person.y = love.math.random(min, max)
        end
    end
end

return people
