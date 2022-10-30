people = {}

function people.initialise()

    local numofppl = 50

    for i = 1, numofppl do
        PERSONS[i] = {}
        PERSONS[i].row = love.math.random(1, NUMBER_OF_ROWS)
        PERSONS[i].col = love.math.random(1, NUMBER_OF_COLS)
        PERSONS[i].destrow = PERSONS[i].row
        PERSONS[i].destcol = PERSONS[i].col

        -- add a bit of a border to ensure the person stays inside the tile
        local min = 0 + (PERSONS_RADIUS * 2)
        local max = TILE_SIZE - (PERSONS_RADIUS * 2)
        PERSONS[i].x = love.math.random(min, max)
        PERSONS[i].y = love.math.random(min, max)
        PERSONS[i].destx = PERSONS[i].x
        PERSONS[i].desty = PERSONS[i].y

        PERSONS[i].occupation = nil
        PERSONS[i].food = 7                 -- days
    end
end

function people.draw()

    for k, person in pairs(PERSONS) do
        local drawx, drawy = fun.getTileXY(person.row, person.col)
        drawx = drawx + person.x
        drawy = drawy + person.y

        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill", drawx, drawy, PERSONS_RADIUS)

        -- draw debug information
        if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
            local drawx, drawy = fun.getTileXY(person.row, person.col)
            drawx = drawx + person.x + 7
            drawy = drawy + person.y - 17

            local txt = ""
            txt = "Food: " .. person.food
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(txt, drawx, drawy, 0, 1, 1, 0, 0)

        end
    end
end

function people.assignDestination(hour)
    -- assign target row, col, x, y based on the hour of the day

    for k, person in pairs(PERSONS) do
        if hour == 8 then
            if person.occupation == nil then
                -- move to well
                local minrow = math.max(WELLROW - 1, 1)
                local mincol = math.max(WELLCOL - 1, 1)
                local maxrow = math.min(WELLROW + 1, NUMBER_OF_ROWS)
                local maxcol = math.min(WELLCOL + 1, NUMBER_OF_COLS)
                person.destrow = love.math.random(minrow, maxrow)
                person.destcol = love.math.random(mincol, maxcol)
            else
                --! currently random
                person.destrow = love.math.random(1, NUMBER_OF_ROWS)
                person.destcol = love.math.random(1, NUMBER_OF_COLS)
            end
        else
            --! currently random
            person.destrow = love.math.random(1, NUMBER_OF_ROWS)
            person.destcol = love.math.random(1, NUMBER_OF_COLS)
        end
        -- determine a random location inside the destination tile
        -- this happens to every destination regardless of occupaiton or type of activity
        local min = 0 + (PERSONS_RADIUS * 2)
        local max = TILE_SIZE - (PERSONS_RADIUS * 2)
        person.destx = love.math.random(min, max)
        person.desty = love.math.random(min, max)
    end
end

function people.moveToDestination(dt)
    -- moves people to their destination

    local result = false        -- return true if at least one person moved

    for k, person in pairs(PERSONS) do
        if person.row ~= person.destrow or person.col ~= person.destcol or
            person.x ~= person.destx or person.y ~= person.desty then

            result = true   -- true = there is movement

            -- get absolute screen coordinates
            local currentx = ((person.col - 1) * TILE_SIZE) + person.x + LEFT_MARGIN
            local currenty = ((person.row - 1) * TILE_SIZE) + person.y + TOP_MARGIN
            local screenx = ((person.destcol - 1) * TILE_SIZE) + person.destx + LEFT_MARGIN
            local screeny = ((person.destrow - 1) * TILE_SIZE) + person.desty + LEFT_MARGIN

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
            end

            -- move down
            if screeny > currenty then
                local disttodest = screeny - currenty
                local distdt = MOVEMENT_RATE * dt
                local adjustment = math.min(disttodest, distdt)
                person.y = person.y + adjustment
                person.y = cf.round(person.y)
                if person.y > TILE_SIZE then
                    person.row = person.row + 1
                    person.y = 1
                end
            elseif screeny < currenty then
                -- move up
                local disttodest = currenty - screeny
                local distdt = MOVEMENT_RATE * dt
                local adjustment = math.min(disttodest, distdt)
                person.y = person.y - adjustment
                person.y = cf.round(person.y)
                if person.y < 0 then
                    person.row = person.row - 1
                    person.y = TILE_SIZE
                end
            end
        end
    end
    return result
end

return people
