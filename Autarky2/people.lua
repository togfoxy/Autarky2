people = {}

function people.initialise()

    local numofppl = 4

    for i = 1, numofppl do
        people.createPerson()
     end
end

function people.createPerson()
    -- create one person, give it a random location and initial all tables

    local thisperson = {}
    thisperson = {}
    thisperson.guid = cf.getGUID()
    thisperson.row = love.math.random(1, NUMBER_OF_ROWS)
    thisperson.col = love.math.random(1, NUMBER_OF_COLS)
    thisperson.destrow = thisperson.row
    thisperson.destcol = thisperson.col

    -- add a bit of a border to ensure the person stays inside the tile
    local min = 0 + (PERSONS_RADIUS * 2)
    local max = TILE_SIZE - (PERSONS_RADIUS * 2)
    thisperson.x = love.math.random(min, max)
    thisperson.y = love.math.random(min, max)
    thisperson.destx = thisperson.x
    thisperson.desty = thisperson.y
    thisperson.isSelected = false

    thisperson.occupation = nil
    thisperson.houserow = nil
    thisperson.housecol = nil

    thisperson.stock = {}
    thisperson.beliefRange = {}                 -- eg PERSONS[i].beliefRange[enum.stockFood] = {1,10}
    thisperson.beliefRangeHistory = {}          --  .beliefRangeHistory[enum.stockFood][1] = (1,10})
    thisperson.stockPriceHistory = {}           -- this is the stock price history known to this agent (not global)
    for j = 1, NUMBER_OF_STOCK_TYPES do
        thisperson.stock[j] = 0

        thisperson.beliefRange[j] = {}
        thisperson.beliefRange[j] = {1,10}

        thisperson.beliefRangeHistory[j] = {}
        thisperson.beliefRangeHistory[j] = {1, 10}

        thisperson.stockPriceHistory[j] = {}        -- the price this agent paid for each stock and every transaction
        thisperson.stockPriceHistory[j] = {5}
    end
    -- this happens AFTER the above loop to override and set correct initial values
    thisperson.stock[enum.stockFood] = love.math.random(7,7)                 -- days
    thisperson.stock[enum.stockHealth] = 100
    thisperson.stock[enum.stockWealth] = 20

    -- set meaningful beliefs and stock history
    local avgprice = fun.getHistoricAvgPrice(enum.stockFood)
    if avgprice >= 0 then
        thisperson.beliefRange[enum.stockFood] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.beliefRangeHistory[enum.stockFood] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.stockPriceHistory[enum.stockFood] = {avgprice}
    else
        thisperson.beliefRange[enum.stockFood] = {1,5}
        thisperson.beliefRangeHistory[enum.stockFood] = {1, 5}
        thisperson.stockPriceHistory[enum.stockFood] = {3}
    end

    avgprice = fun.getHistoricAvgPrice(enum.stockLogs)
    if avgprice >= 0 then
        thisperson.beliefRange[enum.stockLogs] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.beliefRangeHistory[enum.stockLogs] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.stockPriceHistory[enum.stockLogs] = {avgprice}
    else
        thisperson.beliefRange[enum.stockLogs] = {9,11}
        thisperson.beliefRangeHistory[enum.stockLogs] = {7.2, 10.8}
        thisperson.stockPriceHistory[enum.stockLogs] = {9}
    end

    avgprice = fun.getHistoricAvgPrice(enum.stockHouse)
    if avgprice >= 0 then
        thisperson.beliefRange[enum.stockHouse] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.beliefRangeHistory[enum.stockHouse] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.stockPriceHistory[enum.stockHouse] = {avgprice}
    else
        thisperson.beliefRange[enum.stockHouse] = {28,42}
        thisperson.beliefRangeHistory[enum.stockHouse] = {28, 42}
        thisperson.stockPriceHistory[enum.stockHouse] = {35}
    end

    avgprice = fun.getHistoricAvgPrice(enum.stockHerbs)
    if avgprice >= 0 then
        thisperson.beliefRange[enum.stockHerbs] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.beliefRangeHistory[enum.stockHerbs] = {avgprice * 0.8, avgprice * 1.2}
        thisperson.stockPriceHistory[enum.stockHerbs] = {avgprice}
    else
        thisperson.beliefRange[enum.stockHerbs] = {0.8, 1.2}
        thisperson.beliefRangeHistory[enum.stockHerbs] = {0.8, 1.2}
        thisperson.stockPriceHistory[enum.stockHerbs] = {1}
    end

    table.insert(PERSONS, thisperson)
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
    txt = txt .. "Loans owed: " .. person.stock[enum.stockWealthOwed] .. "\n"

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(txt, drawx, drawy, 0, 1, 1, 0, 0)
end

function people.draw()

    local alpha
    if cf.CurrentScreenName(SCREEN_STACK) == "Graphs" then
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

            love.graphics.circle("line", drawx, drawy + 7, PERSONS_RADIUS + 5)

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
            PERSONS_LEFT = PERSONS_LEFT + 1
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

    if bidqty > 0 then
        -- register the bid
        marketplace.createBid(stocknumber, bidqty, bidprice, person.guid)

        -- set destination = market
        fun.getRandomMarketXY(person)
    end
end

local function bidForFood(person)
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

    if bidqty > 0 then
    	-- register the bid
    	marketplace.createBid(enum.stockFood, bidqty, bidprice, person.guid)

    	-- set destination = market
    	fun.getRandomMarketXY(person)
    end
end

local function genericSellOutputStock(person, stockoutput)
    -- stockoutput = the stock the person needs to sell
	local maxqtytosell = person.stock[stockoutput]
	local askqty = marketplace.determineQty(maxqtytosell, person.stockPriceHistory[stockoutput]) -- commodity, maxQty, commodityKnowledge
	askqty = cf.round(askqty)

    if askqty > 0 then
    	-- determine ask price
    	local askprice = marketplace.determineCommodityPrice(person.beliefRange[stockoutput])
    	askprice = cf.round(askprice)

        -- get an approximate cost price and ensure the ask price is at least that much
        local costprice
        local stockinput = person.occupationstockinput

        if stockinput == nil then   -- will happen with primary producers
            -- work out producers productivity and divide buy average income for that productiviy

            -- cost price for primary producers = how much food consumed per item
            costprice = 1 / person.occupationstockgain * fun.getAvgPrice(person.stockPriceHistory[enum.stockFood])
        else    -- not a primary producer
            costprice = fun.getAvgPrice(person.stockPriceHistory[stockinput])
        end

        costprice = cf.round(costprice * 1.30, 2)       -- add a 30% profit margin
        if costprice == nil then costprice = 0 end  -- happens at start of game

        if stockinput ~= nil then
            print("Trying to sell stock type " .. stockoutput .. ". Agent thinks cost price for stock type " .. stockinput .. " is $" .. costprice .. " and ask price is $" .. askprice)
        else
            print("Primary producer trying to sell stock type " .. stockoutput .. ". Agent thinks cost price is $" .. costprice .. " and ask price is $" .. askprice)
        end

        askprice = math.max(askprice, costprice)

    	-- register the ask
    	marketplace.createAsk(stockoutput, askqty, askprice, person.guid)

    	-- set destination = market
    	fun.getRandomMarketXY(person)
    end
end

function people.doMarketplace()
    -- determine if they need to buy/sell

    local avgHousePrice = fun.getHistoricAvgPrice(enum.stockHouse)
    for k, person in pairs(PERSONS) do
        -- buy food
        if person.stock[enum.stockFood] < 7 and person.occupation ~= enum.jobFarmer then
            -- try to buy food
			bidForFood(person)
        end

        -- buy herbs
        if person.stock[enum.stockHealth] < 90 and person.occupation ~= enum.jobHealer then
            makeBid(person, enum.stockHerbs)    -- optional 3rd param. Also sets destination = market
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
        if stockinput ~= nil and person.stock[stockinput] < 7 then
			makeBid(person, stockinput)		--! need to test this
        end

        -- generic stock sell
        -- make an ask (sell)
        local stockoutput = person.occupationstockoutput        -- stock type
        if stockoutput ~= nil and person.stock[stockoutput] >= STOCK_QTY_SELLPOINT[stockoutput] then
			genericSellOutputStock(person, stockoutput)
        end

        --! need something about buying luxuries (wants/comfort)
    end

    -- resolve bids/asks after all persons have had a chance to update orders
    results = {}        --! should this be local?
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

        if buyer.stock[enum.stockWealth] >= outcome.transactionTotalPrice then
            -- funding assured - finalise the transaction
            buyer.stock[enum.stockWealth] = buyer.stock[enum.stockWealth] - outcome.transactionTotalPrice
            seller.stock[enum.stockWealth] = seller.stock[enum.stockWealth] + outcome.transactionTotalPrice

            buyer.stock[outcome.commodityID] = buyer.stock[outcome.commodityID] + outcome.transactionTotalQty
            seller.stock[outcome.commodityID] = seller.stock[outcome.commodityID] - outcome.transactionTotalQty

            -- record tax owed. It won't be paid until later
            buyer.stock[enum.stockTaxOwed] = cf.round(buyer.stock[enum.stockTaxOwed] + (outcome.transactionTotalPrice * SALES_TAX),2)
        end
    end

    if #results > 0 then
        -- EMOTICONS
        local myemote = {}
        local x, y = fun.getTileXY(MARKETROW, MARKETCOL)
        myemote.x = x
        myemote.y = y
        myemote.imagenumber = enum.emoticonCash
        myemote.time = 5
        myemote.imagetype = "emoticon"
        table.insert(IMAGE_QUEUE, myemote)
    else
        --! need to make a sad face if and only if a bid/ask was not satisfied
        -- local myemote = {}
        -- local x, y = fun.getTileXY(MARKETROW, MARKETCOL)
        -- myemote.x = x
        -- myemote.y = y
        -- myemote.imagenumber = enum.emoticonSad
        -- myemote.time = 5
        -- myemote.imagetype = "emoticon"
        -- table.insert(IMAGE_QUEUE, myemote)
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

function people.payTaxes()
    -- collect owed taxes
    -- this might put the agent into debt
    local taxcollected = 0
    for _, person in pairs(PERSONS) do
        taxcollected = taxcollected + person.stock[enum.stockTaxOwed]

        TREASURY = TREASURY + person.stock[enum.stockTaxOwed]
        person.stock[enum.stockWealth] = person.stock[enum.stockWealth] - person.stock[enum.stockTaxOwed]
        person.stock[enum.stockTaxOwed] = 0
    end
    if taxcollected > 0 then
        taxcollected = cf.strFormatCurrency(taxcollected)
        local x = SCREEN_WIDTH - 200
        local y = love.math.random(100 ,SCREEN_HEIGHT - 100)
        local str = "$" .. taxcollected .. " tax collected"
        lovelyToasts.show(str, 10, nil, x, y)
    end
end

function people.claimSocialSecurity()
    -- if wealth == 0 and food == 0 then pay the average price of food
    --! there is a chance that the avg price of food is not enough to actually buy food. Check for balance
    --! might be better to pay the agent food then pay the farmer the avg price
    local avgfoodprice = fun.getHistoricAvgPrice(enum.stockFood)

    for _, person in pairs(PERSONS) do
        if person.stock[enum.stockWealth] < avgfoodprice and person.stock[enum.stockFood] <= 0 then
            if TREASURY >= avgfoodprice then
                TREASURY = TREASURY - avgfoodprice
                person.stock[enum.stockWealth] = person.stock[enum.stockWealth] + avgfoodprice
                print("Paid social security benefits: " .. avgfoodprice)
            end
        end
    end
end

function people.getOccupationCount()

    local result = {}
    result[enum.jobFarmer] = 0
    result[enum.jobHealer] = 0
    result[enum.jobBuilder] = 0
    result[enum.jobWoodsman] = 0

    for _, person in pairs(PERSONS) do
        local occupation = person.occupation        -- e.g enum.jobFarmer
        if occupation ~= nil then
            result[occupation] = result[occupation] + 1
        end
    end
    return result
end

function people.unselectAll()
	-- ensure all persons are unselected
	for _, person in pairs(PERSONS) do
		person.isSelected = false
	end
end

function people.getLoan()

    for _, person in pairs(PERSONS) do
        -- if person is a producer and has no output to sell and has no money to buy inputs then get loan
        local stockoutput = person.occupationstockoutput
        local stockinput = person.occupationstockinput
        if stockoutput ~= nil and stockinput ~= nil then
            if person.stock[stockoutput] == 0 then
                local avgprice = fun.getAvgPrice(HISTORY_PRICE[stockinput])
                local numberofinputsneeded = person.occupationconversionrate
                local totalwealthneeded = avgprice * numberofinputsneeded
                if person.stock[enum.stockWealth] < totalwealthneeded then
                    -- person qualifies for loan
                    -- see if treasury can fund a loan
                    local loanneeded = cf.round(totalwealthneeded - person.stock[enum.stockWealth],2)
                    print("Loan needed = $" .. loanneeded)
                    if TREASURY >= loanneeded then
                        -- loan approved
                        TREASURY = TREASURY - loanneeded
                        TREASURY_OWED = TREASURY_OWED + loanneeded
                        person.stock[enum.stockWealthOwed] = person.stock[enum.stockWealthOwed] + loanneeded
                        person.stock[enum.stockWealth] = person.stock[enum.stockWealth] + loanneeded
                    end
                end
            end
        end
    end
end

function people.repayLoan()
    for _, person in pairs(PERSONS) do
        if person.stock[enum.stockWealthOwed] > 0 then
            local stockoutput = person.occupationstockoutput
            if person.stock[stockoutput] ~= nil and person.stock[stockoutput] > 0 then
                -- repay loan
                local repayment = 0
                if person.stock[enum.stockWealthOwed] <= 1 and person.stock[enum.stockWealth] > person.stock[enum.stockWealthOwed] then
                    -- pay off whole loan
                    repayment = person.stock[enum.stockWealthOwed]
                else
                    repayment = person.stock[enum.stockWealthOwed] * 0.10     -- 10%
                    repayment = math.min(repayment, person.stock[enum.stockWealth])
                end

                repayment = cf.round(repayment, 2)
                person.stock[enum.stockWealth] = person.stock[enum.stockWealth] - repayment
                person.stock[enum.stockWealthOwed] = person.stock[enum.stockWealthOwed] - repayment
                TREASURY = TREASURY + repayment
                TREASURY_OWED = TREASURY_OWED - repayment
            end
        end
    end
end


return people
