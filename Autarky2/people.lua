people = {}

function people.initialise()

    local numofppl = 5

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
        PERSONS[i].houserow = nil
        PERSONS[i].housecol = nil

        PERSONS[i].stock = {}
        PERSONS[i].beliefRange = {}                 -- eg PERSONS[i].beliefRange[enum.stockFood] = {1,10}
        PERSONS[i].beliefRangeHistory = {}          --  .beliefRangeHistory[enum.stockFood][1] = (1,10})
        PERSONS[i].stockPriceHistory = {}           -- this is the stock price history known to this agent (not global)
        for j = 1, NUMBER_OF_STOCK_TYPES do
            PERSONS[i].stock[j] = 0

            PERSONS[i].beliefRange[j] = {}
            PERSONS[i].beliefRange[j] = {1,10}

            PERSONS[i].beliefRangeHistory[j] = {}
            PERSONS[i].beliefRangeHistory[j] = {1, 10}

            PERSONS[i].stockPriceHistory[j] = {}
            PERSONS[i].stockPriceHistory[j] = {5}

        end
        -- this happens AFTER the above loop to override and set correct initial values
        PERSONS[i].stock[enum.stockFood] = love.math.random(7,7)                 -- days
        PERSONS[i].stock[enum.stockHealth] = 100
        PERSONS[i].stock[enum.stockWealth] = 20
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
    txt = txt .. "Logs: " .. person.stock[enum.stockLogs] .. "\n"
    txt = txt .. "Herbs: " .. person.stock[enum.stockHerbs] .. "\n"
    txt = txt .. "Houses: " .. person.stock[enum.stockHouse] .. "\n"
    txt = txt .. "Tax owed: " .. person.stock[enum.stockTaxOwed] .. "\n"

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
        elseif hour == 20 then
            -- go to house if have one
            if person.houserow ~= nil and person.housecol ~= nil then
                person.destrow = person.houserow
                person.destcol = person.housecol
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

function people.eat()
    for k, person in pairs(PERSONS) do
        person.stock[enum.stockFood] = person.stock[enum.stockFood] - 1
        if person.stock[enum.stockFood] < 0 then
            person.stock[enum.stockFood] = 0
            person.stock[enum.stockHealth] = person.stock[enum.stockHealth] - 15      -- %
            -- check NUMBER_OF_STOCK_TYPES is correct if next line fails
            if person.stock[enum.stockHealth] <= 0 then
                people.dies(person, "starvation")
            end
        end
    end
end

function people.dies(person, reason)
    -- removes the person and their structure (if applicable)
    -- input: person, singular
    -- input: reason = text string for reason for death

    for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
            if MAP[row][col].owner == person.guid then
                structures.kill(row, col)
            end
        end
    end

    for i = #PERSONS, 1, -1 do
        if PERSONS[i] == person then
            table.remove(PERSONS, i)
            print("Person died. Reason = " .. reason)
        end
    end
end

function people.pay()
    -- pay ppl in stock for hard labour
    for k, person in pairs(PERSONS) do
        if person.occupation ~= nil then
            if person.occupationstockoutput ~= nil then
                if person.occupationstockinput == nil then    -- primary producer
                    local stocktype = person.occupationstockoutput
                    local stockgain = person.occupationstockgain
                    person.stock[stocktype] = person.stock[stocktype] + stockgain

                elseif person.occupationstockinput ~= nil then
                    -- a service provider that converts stock from one type to another
                    local stockinputtype = person.occupationstockinput
                    local stockoutputtype = person.occupationstockoutput
                    local stockconversionrate = person.occupationconversionrate
                    if person.stock[stockinputtype] >= stockconversionrate then
                        -- convert stock
                        person.stock[stockinputtype] = person.stock[stockinputtype] - stockconversionrate
                        person.stock[stockoutputtype] = person.stock[stockoutputtype] + 1
                    end
                end

                if love.math.random(1,7) == 1 then
                    -- person is hurt while working
                    person.stock[enum.stockHealth] = person.stock[enum.stockHealth] - love.math.random(15,25)
                    if person.stock[enum.stockHealth] <= 0 then
                        people.dies(person, "no health")
                    end
                end

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

local function makeBid(person, stocknumber, maxqty)
    -- convenient sub-procedure to help doMarketplace()
    -- input: a single person
    -- input: stocknumber (e.g enum.stockFood)
    -- input: maxqty - optional - to override the default algorithm
    -- output: none

    -- default the optional parameter
    if maxqty == nil then maxqty = 9999 end

    local wealth = person.stock[enum.stockWealth]
    --! should rename stocknumber to commodity for consistency
    -- determine bid price
    local bidprice = marketplace.determineCommodityPrice(person.beliefRange[stocknumber])

    -- determine bid qty
    local maxqtycanafford = cf.round(wealth / bidprice)
    local maxqtycanhold = 14 - person.stock[stocknumber]
    local maxqtytobuy = math.min(maxqtycanafford, maxqtycanhold, maxqty)
    local bidqty = marketplace.determineQty(maxqtytobuy, person.stockPriceHistory[stocknumber])       -- accepts nil history
    bidqty = cf.round(bidqty)

    -- register the bid
    marketplace.createBid(stocknumber, bidqty, bidprice, person.guid)

    -- set destination = market
    fun.getRandomMarketXY(person)
end

function people.doMarketplace()
    -- determine if they need to buy/sell

    local avgHousePrice = fun.getHistoricAvgPrice(enum.stockHouse)
    for k, person in pairs(PERSONS) do
        -- food
        if person.stock[enum.stockFood] < 7 and person.occupation ~= enum.jobFarmer then
            -- try to buy food
            local wealth = person.stock[enum.stockWealth]

            -- determine bid price
            local bidprice = marketplace.determineCommodityPrice(person.beliefRange[enum.stockFood])
            bidprice = cf.round(bidprice, 2)

            -- determine bid qty
            local maxqtycanafford = wealth / bidprice
            local maxqtycanhold = 14 - person.stock[enum.stockFood]
            local maxqtytobuy = math.min(maxqtycanafford, maxqtycanhold)
            local bidqty = marketplace.determineQty(maxqtytobuy, person.stockPriceHistory[enum.stockFood])       -- accepts nil history
            bidqty = cf.round(bidqty)

            -- register the bid
            marketplace.createBid(enum.stockFood, bidqty, bidprice, person.guid)

            -- set destination = market
            fun.getRandomMarketXY(person)
        end

        -- buy herbs
        if person.stock[enum.stockHealth] < 90 and person.occupation ~= enum.jobHealer then
            makeBid(person, enum.stockHerbs)    -- also sets destination = market
        end

        -- buy house
        if person.houserow == nil and person.housecol == nil then
            if person.stock[enum.stockHouse] < 1 then
                -- try to buy house
                makeBid(person, enum.stockHouse, 1)
            end
        end

        -- generic stock input (if relevant)
        -- make a bid (buy)     -- if there are lots of bids and they are all succesful then agent could be in debt
        local stockinput = person.occupationstockinput      -- stock type
        local wealth = person.stock[enum.stockWealth]
        if stockinput ~= nil and stockinput < 7 then
            local bidprice = marketplace.determineCommodityPrice(person.beliefRange[stockinput])
            bidprice = cf.round(bidprice)
            local maxqtycanafford = wealth / bidprice
            local maxqtycanhold = 14 - person.stock[stockinput]
            local maxqtytobuy = math.min(maxqtycanafford, maxqtycanhold)
            local bidqty = marketplace.determineQty(maxqtytobuy, person.stockPriceHistory[stockinput])       -- accepts nil history
            bidqty = cf.round(bidqty)
            marketplace.createBid(stockinput, bidqty, bidprice, person.guid)

            -- set destination = market
            fun.getRandomMarketXY(person)
        end

        -- generic stock sell
        -- make an ask (sell)
        local stockoutput = person.occupationstockoutput        -- stock type
        if stockoutput ~= nil and person.stock[stockoutput] >= STOCK_QTY_SELLPOINT[stockoutput] then
           local maxqtytosell = person.stock[stockoutput]
           local askqty = marketplace.determineQty(maxqtytosell, person.stockPriceHistory[stockoutput]) -- commodity, maxQty, commodityKnowledge
           askqty = cf.round(askqty)

           -- determine ask price
           local askprice = marketplace.determineCommodityPrice(person.beliefRange[stockoutput])
           askprice = cf.round(askprice)
           -- register the ask
           marketplace.createAsk(stockoutput, askqty, askprice, person.guid)

           -- set destination = market
           fun.getRandomMarketXY(person)

           -- if stockoutput == enum.stockHerbs then
           --     print("Tried to sell herbs for $" .. askprice)
           -- end
        end

        --! need something about buying luxuries (wants)
    end

    -- resolve bids/asks after all persons have had a chance to update orders
    results = {}
    results = marketplace.resolveOrders()

    print("----------------------")
    print("Market results")
    print(inspect(results))
    print("----------------------")

    for k, outcome in pairs(results) do
        -- charge the buyer and ensure that succeeds
        local buyer = people.get(outcome.buyerguid)
        local seller = people.get(outcome.sellerguid)
        -- capture the agreed price for stat purposes
        table.insert(HISTORY_PRICE[outcome.commodityID], outcome.agreedprice)

        if buyer.stock[enum.stockWealth] - buyer.stock[enum.stockTaxOwed] >= outcome.transactionTotalPrice then
            -- funding assured - finalise the transaction
            buyer.stock[enum.stockWealth] = buyer.stock[enum.stockWealth] - outcome.transactionTotalPrice
            seller.stock[enum.stockWealth] = seller.stock[enum.stockWealth] + outcome.transactionTotalPrice

            buyer.stock[outcome.commodityID] = buyer.stock[outcome.commodityID] + outcome.transactionTotalQty
            seller.stock[outcome.commodityID] = seller.stock[outcome.commodityID] - outcome.transactionTotalQty

            -- apply tax. It might put the agent into debt
            buyer.stock[enum.stockTaxOwed] = cf.round(buyer.stock[enum.stockTaxOwed] + (outcome.transactionTotalPrice * SALES_TAX),2)
        end
    end
end

function people.heal()
    -- cycle through each person and heal if they are wounded and have Herbs
    for _, person in pairs(PERSONS) do
        -- people with houses heal faster
        if person.houserow ~= nil and person.housecol ~= nil then
            person.stock[enum.stockHealth] = person.stock[enum.stockHealth] + 1
        else
            person.stock[enum.stockHealth] = person.stock[enum.stockHealth] + 0.5
        end

        if person.stock[enum.stockHealth] < 100 and person.stock[enum.stockHerbs] > 0 then
            -- heal
            local damage = 100 - person.stock[enum.stockHealth]
            local healamt = math.min(damage, person.stock[enum.stockHerbs])
            person.stock[enum.stockHealth] = person.stock[enum.stockHealth] + healamt
            person.stock[enum.stockHerbs] = person.stock[enum.stockHerbs] - healamt
        end
        if person.stock[enum.stockHealth] > 100 then person.stock[enum.stockHealth] = 100 end
    end
end

function people.buildHouse()
    -- checks if has house structure
    -- if not, checks for house stock
    -- if house stock, then build structure

    --! can consolidate with people.heal() for performance gains

    for _, person in pairs(PERSONS) do
        if person.houserow == nil and person.housecol == nil then
            if person.stock[enum.stockHouse] >= 1 then
                local row,col = structures.create(enum.structureHouse, person.guid)
                person.houserow = row
                person.housecol = col

                person.stock[enum.stockHouse] = person.stock[enum.stockHouse] - 1
            end
        end
    end
end


return people
