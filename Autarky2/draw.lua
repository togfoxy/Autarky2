draw = {}

function draw.world()
    -- draw the map including structures

    local alpha
    if SHOW_GRAPH then
         alpha = 0.25       -- a modifier (not the actual alpha)
    else
        alpha = 1
    end

    for col = 1, NUMBER_OF_COLS do
		for row = 1, NUMBER_OF_ROWS do
            -- drawx = LEFT_MARGIN + (col -1) * TILE_SIZE
            -- drawy = TOP_MARGIN + (row - 1) * TILE_SIZE
            local drawx, drawy = fun.getTileXY(row, col)

            -- the grid border/outline
            love.graphics.setColor(1,1,1,0.25)
            love.graphics.rectangle("line", drawx, drawy, TILE_SIZE, TILE_SIZE)

            if MAP[row][col].tileType == 1 then
                -- dry grass
                love.graphics.setColor(220/255, 175/255, 26/255,0.5 * alpha)
            elseif MAP[row][col].tileType == 2 then
                -- green grass
                love.graphics.setColor(38/255, 168/255, 38/255,0.5 * alpha)
            elseif MAP[row][col].tileType == 3 then
                -- teal grass (?)
                love.graphics.setColor(89/255, 232/255, 89/255,0.5 * alpha)
            else
                error("Unexpected else statement.")
            end
            love.graphics.rectangle("fill", drawx, drawy, TILE_SIZE, TILE_SIZE)
            --! need to draw tiles one day
            -- love.graphics.print(MAP[row][col].tileType, drawx + 7, drawy + 7)

            if MAP[row][col].structure ~= nil then
                local structureid = MAP[row][col].structure
                love.graphics.setColor(1,1,1,1 * alpha)
                love.graphics.draw(IMAGES[structureid], drawx, drawy, 0, 1, 1)
            end

        end
    end

    -- draw world hours
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Time: " .. WORLD_HOURS .. " Day: " .. WORLD_DAYS, 10, 10)

end

function draw.graphs()

    love.graphics.setColor(1,1,1,1)

    -- *************** first row ****************
    -- food
    local drawx = 50
    local drawy = 50
    love.graphics.print("Avg food owned", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    for i = 1, #HISTORY_STOCK[enum.stockFood] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_STOCK[enum.stockFood][i]
        love.graphics.points(drawx, yvalue)
    end

    -- health
    drawx = drawx + 125
    drawy = 50
    love.graphics.print("Avg health owned", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    for i = 1, #HISTORY_STOCK[enum.stockHealth] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_STOCK[enum.stockHealth][i]
        love.graphics.points(drawx, yvalue)
    end

    -- wealth
    drawx = drawx + 125
    drawy = 50
    love.graphics.print("Avg wealth owned", drawx, drawy)
    drawy = drawy + 25
    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100
    for i = 1, #HISTORY_STOCK[enum.stockWealth] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_STOCK[enum.stockWealth][i]
        love.graphics.points(drawx, yvalue)
    end

    -- *************** second row ****************
    -- food price
    drawx = 50
    drawy = 200
    love.graphics.print("Food prices", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    for i = 1, #HISTORY_PRICE[enum.stockFood] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_PRICE[enum.stockFood][i]
        love.graphics.points(drawx, yvalue)
    end

    -- log prices
    drawx = drawx + 125
    drawy = 200
    love.graphics.print("Log prices", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    for i = 1, #HISTORY_PRICE[enum.stockLogs] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_PRICE[enum.stockLogs][i]
        love.graphics.points(drawx, yvalue)
    end

    -- herb prices
    drawx = drawx + 125
    drawy = 200
    love.graphics.print("Herb prices", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    for i = 1, #HISTORY_PRICE[enum.stockHerbs] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_PRICE[enum.stockHerbs][i]
        love.graphics.points(drawx, yvalue)
    end

end

return draw
