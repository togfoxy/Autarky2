people = {}

function people.initialise()

    local numofppl = 50

    for i = 1, numofppl do
        PERSONS[i] = {}
        PERSONS[i].row = love.math.random(1, NUMBER_OF_ROWS)
        PERSONS[i].col = love.math.random(1, NUMBER_OF_COLS)
        PERSONS[i].destrow = nil
        PERSONS[i].destcol = nil
        PERSONS[i].destx = nil
        PERSONS[i].desty = nil

        -- add a bit of a border to ensure the person stays inside the tile
        local min = 0 + (PERSONS_RADIUS * 2)
        local max = TILE_SIZE - (PERSONS_RADIUS * 2)
        PERSONS[i].x = love.math.random(min, max)
        PERSONS[i].y = love.math.random(min, max)
        PERSONS[i].destx = nil
        PERSONS[i].desty = nil

    end
end

function people.draw()

    for k, person in pairs(PERSONS) do
        local drawy = ((person.row - 1) * TILE_SIZE) + person.y + TOP_MARGIN
        local drawx = ((person.col - 1) * TILE_SIZE) + person.x + LEFT_MARGIN

        assert(drawx > LEFT_MARGIN)
        assert(drawy > TOP_MARGIN)

        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill", drawx, drawy, PERSONS_RADIUS)

        -- print(drawx, drawy, person.col, person.row, person.x, person.y, TILE_SIZE, TOP_MARGIN)
    end
end

function people.assignDestination(hour)
    -- assign target row, col, x, y based on the hour of the day

    for k, person in pairs(PERSONS) do
        if hour == 8 then
            --! currently random
            person.destrow = love.math.random(1, NUMBER_OF_ROWS)
            person.destcol = love.math.random(1, NUMBER_OF_COLS)
            local min = 0 + (PERSONS_RADIUS * 2)
            local max = TILE_SIZE - (PERSONS_RADIUS * 2)
            person.destx = love.math.random(min, max)
            person.desty = love.math.random(min, max)
        end
    end
end

function people.moveToDestination(dt)
    -- moves people to their destination

    local result = false        -- return true if at least one person moved

    for k, person in pairs(PERSONS) do
        if person.destx ~= nil and person.desty ~= nil then
            result = true

            -- get absolute screen coordinates
            local currentx = ((person.col - 1) * TILE_SIZE) + person.x + LEFT_MARGIN
            local currenty = ((person.row - 1) * TILE_SIZE) + person.y + TOP_MARGIN
            local screenx = ((person.destcol - 1) * TILE_SIZE) + person.destx + LEFT_MARGIN
            local screeny = ((person.destrow - 1) * TILE_SIZE) + person.desty + LEFT_MARGIN

            if currentx ~= screenx then -- or currenty ~= screeny then
                -- move towards destination
                -- move right
                if screenx > currentx then
                    local disttodest = screenx - currentx
                    local distdt = MOVEMENT_RATE * dt
                    local adjustment = math.min(disttodest, distdt)
                    person.x = person.x + adjustment
                    person.x = cf.round(person.x)
                    if person.x > TILE_SIZE then
                        person.col = person.col + 1
                        person.x = 1
                    end
                    -- recalc current x
                    currentx = ((person.col - 1) * TILE_SIZE) + person.x + LEFT_MARGIN
                    if currentx == screenx then
                        person.destx = nil
                    end
                elseif screenx < currentx then
                    -- move left
                    local disttodest = currentx - screenx
                    local distdt = MOVEMENT_RATE * dt
                    local adjustment = math.min(disttodest, distdt)
                    person.x = person.x - adjustment
                    person.x = cf.round(person.x)
                    if person.x < 0 then
                        person.col = person.col - 1
                        person.x = TILE_SIZE
                    end
                    -- recalc current x
                    currentx = ((person.col - 1) * TILE_SIZE) + person.x + LEFT_MARGIN
                    if currentx == screenx then
                        person.destx = nil
                    end
                end

            end
        end
    end
    return result
end

return people
