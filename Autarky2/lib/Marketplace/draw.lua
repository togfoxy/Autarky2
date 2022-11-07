draw = {}


function draw.allInventory(yvalue)

    local drawx = 0
    for i = 1, #persons do  --! should be #persons but only deals with 1 person

        -- print(inspect(persons[i].inventoryHistory))

        for cname, commodity in pairs(persons[i].inventoryHistory) do
            drawx = drawx + 50
            love.graphics.print(cname .. " inv", drawx, yvalue)

            for k, invhistory in pairs(commodity) do
                drawx = drawx + 1
                drawy = yvalue + 100 - invhistory
                love.graphics.points(drawx,drawy)
            end
        end
        drawx = drawx + 20
    end
end

return draw
