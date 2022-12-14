draw = {}

function draw.topBar()
    -- draw world hours
    love.graphics.setFont(FONT[enum.fontLarge])
    love.graphics.setColor(1,1,1,1)
    local str = "Time: " .. WORLD_HOURS .. ":00 Day: " .. WORLD_DAYS .. "  Treasury: $" .. cf.strFormatCurrency(TREASURY) .. "  "
    str = str .. "Loaned out: $" .. cf.strFormatCurrency(TREASURY_OWED)
    if PAUSED then str = str .. "PAUSED" end
    love.graphics.print(str, 10, 10)

    -- draw villager counts
    local occupationtable = people.getOccupationCount()
    local str = "Farmers: " .. occupationtable[enum.jobFarmer] .. ". "
    str = str .. "Healers: " .. occupationtable[enum.jobHealer] .. ". "
    str = str .. "Woodsmen: " .. occupationtable[enum.jobWoodsman] .. ". "
    str = str .. "Builders: " .. occupationtable[enum.jobBuilder] .. ". "
    str = str .. "# of houses: " .. structures.countStructureType(enum.structureHouse)

    love.graphics.print(str, (SCREEN_WIDTH / 2) - 175, 10)

    -- draw more counts on the far right margin
    local str = "Villagers available: " .. #PERSONS .. " Villagers quit: " .. PERSONS_LEFT
    love.graphics.print(str, SCREEN_WIDTH - 350, 10)

end

function draw.world()
    -- draw the map including structures

    local alpha
    if cf.CurrentScreenName(SCREEN_STACK) == enum.sceneGraphs then
         alpha = 0.25       -- a modifier (not the actual alpha)
    else
        alpha = 1
    end

    for col = 1, NUMBER_OF_COLS do
		for row = 1, NUMBER_OF_ROWS do
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

end

function draw.daynight()
    -- draw night time
    local alpha

    if WORLD_HOURS >= 0 and WORLD_HOURS <= 4 then
        alpha = 0.5
    elseif WORLD_HOURS == 5 then
        alpha = 0.4
    elseif WORLD_HOURS == 6 then
        alpha = 0.3
    elseif WORLD_HOURS == 7 then
        alpha = 0.2
    elseif WORLD_HOURS == 8 then
        alpha = 0.1
    elseif WORLD_HOURS >= 9 and WORLD_HOURS <= 17 then
        alpha = 0.0
    elseif WORLD_HOURS == 18 then
        alpha = 0.1
    elseif WORLD_HOURS == 19 then
        alpha = 0.2
    elseif WORLD_HOURS == 20 then
        alpha = 0.3
    elseif WORLD_HOURS == 21 then
        alpha = 0.4
    elseif WORLD_HOURS >= 22 then   -- make this the same as the >= 0 at the top
        alpha = 0.5
    end

    love.graphics.setColor(0,0,0,alpha)
    love.graphics.rectangle("fill", TILE_SIZE,TILE_SIZE, SCREEN_WIDTH, SCREEN_HEIGHT)

    if alpha > 0 then       --!
        -- draw some lights
        -- love.graphics.setColor(1,1,1,1)
        -- love.graphics.points(100,100,200,200,300,300,400,400)
    end
end

function draw.graphs()

    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(FONT[enum.fontDefault])

    -- *************** first row ****************
    -- food
    local drawx = 50
    local drawy = 50
    love.graphics.print("Avg food owned", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    local startindex = (#HISTORY_STOCK[enum.stockFood] - 100)
    if startindex < 1 then startindex = 1 end
    for i = startindex, #HISTORY_STOCK[enum.stockFood] do
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

    local startindex = (#HISTORY_STOCK[enum.stockHealth] - 100)
    if startindex < 1 then startindex = 1 end
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

    local startindex = (#HISTORY_STOCK[enum.stockWealth] - 100)
    if startindex < 1 then startindex = 1 end
    for i = 1, #HISTORY_STOCK[enum.stockWealth] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_STOCK[enum.stockWealth][i]
        love.graphics.points(drawx, yvalue)
    end

    -- treasury
    drawx = drawx + 125
    drawy = 50
    love.graphics.print("Treasury", drawx, drawy)
    drawy = drawy + 25
    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    local startindex = (#HISTORY_TREASURY - 100)
    if startindex < 1 then startindex = 1 end
    for i = 1, #HISTORY_TREASURY do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_TREASURY[i]
        love.graphics.points(drawx, yvalue)
    end

    -- *************** second row ****************
    -- food price
    drawx = 50
    drawy = 200
    love.graphics.print("Food prices (x 10)", drawx, drawy)
    drawy = drawy + 25

    love.graphics.line(drawx, drawy, drawx, drawy + 100)
    love.graphics.line(drawx, drawy + 100, drawx + 100, drawy + 100)
    drawy = drawy + 100

    local startindex = (#HISTORY_PRICE[enum.stockFood] - 100)
    if startindex < 1 then startindex = 1 end
    for i = 1, #HISTORY_PRICE[enum.stockFood] do
        drawx = drawx + 1
        local yvalue = drawy - (HISTORY_PRICE[enum.stockFood][i] * 10)
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

    local startindex = (#HISTORY_PRICE[enum.stockLogs] - 100)
    if startindex < 1 then startindex = 1 end
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

    local startindex = (#HISTORY_PRICE[enum.stockHerbs] - 100)
    if startindex < 1 then startindex = 1 end
    for i = 1, #HISTORY_PRICE[enum.stockHerbs] do
        drawx = drawx + 1
        local yvalue = drawy - HISTORY_PRICE[enum.stockHerbs][i]
        love.graphics.points(drawx, yvalue)
    end

    love.graphics.setFont(FONT[enum.fontLarge])
    love.graphics.print("Press 'g' or ESCAPE to close this screen", (SCREEN_WIDTH / 2) - 100, SCREEN_HEIGHT / 2)
end

function draw.imageQueue()

    love.graphics.setColor(1,1,1,1)

    for k, nextimage in pairs(IMAGE_QUEUE) do
        local drawx = nextimage.x
        local drawy = nextimage.y

        if nextimage.imagetype == "emoticon" then
            local offsetx = (TILE_SIZE * -1) * 0.33
            local offsety = (TILE_SIZE / 2)
            love.graphics.draw(EMOTICONS[nextimage.imagenumber], drawx, drawy, 0, 1, 1, offsetx, offsety)
        else
            error()
        end
    end
end

function draw.optionScreen()

	love.graphics.setColor(1,1,1,1)
	love.graphics.print(SALES_TAX, 150, 125)
    love.graphics.print("Press 'O' or ESCAPE to exit", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2)

	-- draw buttons
	for k, button in pairs(GUI_BUTTONS) do
		if button.scene == enum.sceneOptions and button.visible then
			-- draw the button
            -- draw the bg
            love.graphics.setColor(button.bgcolour)
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)			-- drawx/y is the top left corner of the square

            -- draw the outline
            love.graphics.setColor(button.outlineColour)
            love.graphics.rectangle("line", button.x, button.y, button.width, button.height)			-- drawx/y is the top left corner of the square

			if button.image ~= nil then
                love.graphics.setColor(1,1,1,1)
				love.graphics.draw(button.image, button.x, button.y)
			end

			-- draw the label
			local labelxoffset = button.labelxoffset or 0
            love.graphics.setColor(button.labelcolour)
			love.graphics.setFont(FONT[enum.fontDefault])        --! the font should be a setting and not hardcoded here
			love.graphics.print(button.label, button.x + labelxoffset, button.y + 5)
		end
	end
end

function draw.exitScreen()

  love.graphics.print("Press ENTER to exit the game", (SCREEN_WIDTH / 2) - 100, SCREEN_HEIGHT / 2)

end

return draw
