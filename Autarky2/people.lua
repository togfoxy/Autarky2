people = {}

function people.initialise()

    local numofppl = 2

    for i = 1, numofppl do
        PERSONS[i] = {}
        PERSONS[i].guid = cf.getGUID()
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
        PERSONS[i].isSelected = false

        PERSONS[i].occupation = nil
        PERSONS[i].stock = {}
        PERSONS[i].stock[enum.stockFood] = love.math.random(0,10)                 -- days
        PERSONS[i].stock[enum.stockHealth] = 100
        PERSONS[i].stock[enum.stockWealth] = 100

        PERSONS[i].beliefRange = {}     -- eg PERSONS[i].beliefRange[enum.stockFood] = {1,10}
        PERSONS[i].beliefRange[enum.stockFood] = {}
        PERSONS[i].beliefRange[enum.stockFood] = {1, 10}    --! will need to do this for all stock types

        PERSONS[i].beliefRangeHistory = {}          --  .beliefRangeHistory[enum.stockFood][1] = (1,10})

        PERSONS[i].stockHistory = {}    -- this is the stock price history known to this agent (not global)
        PERSONS[i].stockHistory[enum.stockFood] = {}     --! need to repeat this for all stock

    end
end

local function drawDebug(person)
    local drawx, drawy = fun.getTileXY(person.row, person.col)
    drawx = drawx + person.x + 7
    drawy = drawy + person.y - 17

    local txt = ""
    txt = txt .. "Food: " .. person.stock[enum.stockFood] .. "\n"
    txt = txt .. "Health: " .. person.stock[enum.stockHealth] .. "\n"
    txt = txt .. "Wealth: " .. person.stock[enum.stockWealth] .. "\n"

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(txt, drawx, drawy, 0, 1, 1, 0, 0)
end

function people.draw()

    local alpha
    if SHOW_GRAPH then
         alpha = 0.25       -- a modifier (not the actual alpha)
    else
        alpha = 1
    end

    for k, person in pairs(PERSONS) do
        local drawx, drawy = fun.getTileXY(person.row, person.col)
        drawx = drawx + person.x
        drawy = drawy + person.y

        love.graphics.setColor(1,1,1,1 * alpha)

        -- determine which quad to display
        local quad
        local spritenumber
        if person.isSelected then
            quad = QUADS[enum.spriteRedWoman][2]
            spritenumber = enum.spriteRedWoman
        else
            quad = QUADS[enum.spriteBlueWoman][2]
            spritenumber = enum.spriteBlueWoman
        end

        love.graphics.draw(SPRITES[spritenumber], quad, drawx, drawy, 0, 1, 1, 7, 20)
        -- circle for debugging
        -- love.graphics.circle("fill", drawx, drawy, PERSONS_RADIUS)

        -- draw occupation icon
        if person.occupation ~= nil then
            local imagenumber = person.occupation + 100     -- +100 gives the correct offset to avoid image clashes
            love.graphics.draw(IMAGES[imagenumber], drawx, drawy, 0, 0.30, 0.30, 0, 80)
        end

        -- draw debug information
        if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
            drawDebug(person)
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
                person.destrow = person.workrow
                person.destcol = person.workcol
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

function people.eat()
    for k, person in pairs(PERSONS) do
        person.stock[enum.stockFood] = person.stock[enum.stockFood] - 1
        if person.stock[enum.stockFood] < 0 then
            person.stock[enum.stockFood] = 0
            person.stock[enum.stockHealth] = person.stock[enum.stockHealth] - 15      -- %
            if person.stock[enum.stockHealth] <= 0 then
                people.dies(person)
            end
        end
    end
end

function people.dies(person)
    for i = #PERSONS, 1, -1 do
        if PERSONS[i] == person then
            table.remove(PERSONS, i)
            print("Person died. Check for errors.")
        end
    end
end

function people.pay()
    for k, person in pairs(PERSONS) do
        if person.occupation ~= nil then
            if person.occupationstockoutput ~= nil then
                local stocktype = person.occupationstockoutput
                local stockgain = person.occupationstockgain
                person.stock[stocktype] = person.stock[stocktype] + stockgain
            end
        end
    end
end

function people.get(guid)
    -- given a guid, find and return the correct person
    -- returns nil if not found
    for k, person in pairs(PERSONS) do
        if person.guid == guid then
            return person
        end
    end
    return nil
end

function people.doMarketplace()
    -- determine if they need to buy/sell
    for k, person in pairs(PERSONS) do
        if person.stock[enum.stockFood] < 7 then
            -- try to buy food
            local wealth = person.stock[enum.stockWealth]

            -- determine bid price
            local bidprice = marketplace.determineCommodityPrice(person.beliefRange[enum.stockFood])

            -- determine bid qty
            local maxqtycanafford = wealth / bidprice
            local maxqtycanhold = 14 - person.stock[enum.stockFood]
            local maxqtytobuy = math.min(maxqtycanafford, maxqtycanhold)
            local bidqty = marketplace.determineQty(maxqtytobuy, person.stockHistory[enum.stockFood])       -- accepts nil history
            bidqty = cf.round(bidqty)

            -- register the bid
            marketplace.createBid(enum.stockFood, bidqty, bidprice, person.guid)
        end

        -- make a bid (buy)     -- if there are lots of bids and they are all succesful then agent could be in debt
        local stockinput = person.occupationstockinput      -- stock type
        local wealth = person.stock[enum.stockWealth]
        if stockinput ~= nil and stockinput < 7 then
            local bidprice = marketplace.determineCommodityPrice(person.beliefRange[stockinput])
            local maxqtycanafford = wealth / bidprice
            local maxqtycanhold = 14 - person.stock[stockinput]
            local maxqtytobuy = math.min(maxqtycanafford, maxqtycanhold)
            local bidqty = marketplace.determineQty(maxqtytobuy, person.stockHistory[stockinput])       -- accepts nil history
            bidqty = cf.round(bidqty)
            marketplace.createBid(stockinput, bidqty, bidprice, person.guid)
        end

        -- make an ask (sell)
        local stockoutput = person.occupationstockoutput        -- stock type
        if stockoutput ~= nil and person.stock[stockoutput] > 7 then
           local maxqtytosell = person.stock[stockoutput]
           local askqty = marketplace.determineQty(maxqtytosell, person.stockHistory[stockoutput]) -- commodity, maxQty, commodityKnowledge
           askqty = cf.round(askqty)

           -- determine ask price
           local askprice = marketplace.determineCommodityPrice(person.beliefRange[stockoutput])

           -- register the ask
           marketplace.createAsk(stockoutput, askqty, askprice, person.guid)
        end

        --! need something about buying luxuries (wants)
    end

    -- resolve bids/asks after all persons have had a chance to update orders
    results = {}
    results = marketplace.resolveOrders()

    -- print("----------------------")
    -- print("Market results")
    -- print(inspect(results))
    -- print("----------------------")

    for k, outcome in pairs(results) do
        -- charge the buyer and ensure that succeeds
        local buyer = people.get(outcome.buyerguid)
        local seller = people.get(outcome.sellerguid)
        if buyer.stock[enum.stockWealth] >= outcome.transactionTotalPrice then
            -- funding assured - finalise the transaction
            buyer.stock[enum.stockWealth] = buyer.stock[enum.stockWealth] - outcome.transactionTotalPrice
            seller.stock[enum.stockWealth] = seller.stock[enum.stockWealth] + outcome.transactionTotalPrice

            buyer.stock[outcome.commodityID] = buyer.stock[outcome.commodityID] + outcome.transactionTotalQty
            seller.stock[outcome.commodityID] = seller.stock[outcome.commodityID] - outcome.transactionTotalQty
        end
    end
end

return people
