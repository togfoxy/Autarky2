draw = {}

function draw.world()
    for col = 1, NUMBER_OF_COLS do
		for row = 1, NUMBER_OF_ROWS do
            drawx = LEFT_MARGIN + (col -1) * TILE_SIZE
            drawy = TOP_MARGIN + (row - 1) * TILE_SIZE

            if MAP[row][col].tileType == 1 then
                -- dry grass
                love.graphics.setColor(220/255, 175/255, 26/255,0.5)
            elseif MAP[row][col].tileType == 2 then
                -- green grass
                love.graphics.setColor(38/255, 168/255, 38/255,0.5)
            elseif MAP[row][col].tileType == 3 then
                -- teal grass (?)
                love.graphics.setColor(89/255, 232/255, 89/255,0.5)
            else
                error("Unexpected else statement.")
            end
            love.graphics.rectangle("fill", drawx, drawy, TILE_SIZE, TILE_SIZE)
            -- love.graphics.print(MAP[row][col].tileType, drawx + 7, drawy + 7)
        end
    end

    -- draw world hours
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Time: " .. WORLD_HOURS .. " Day: " .. WORLD_DAYS, 10, 10)

end

function draw.people()

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

return draw
