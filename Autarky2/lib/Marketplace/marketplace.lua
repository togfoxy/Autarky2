marketplace = {}

local bidtable = {}
local asktable = {}
local outcometable = {}

function marketplace.determineCommodityPrice(beliefRange)
    -- this is called by buyers and sellers

    print("belief table")
    print(inspect(beliefRange))

    local min, max
    if beliefRange == nil then
        min = 1
        max = 10
    else
        min = beliefRange[1]
        max = beliefRange[2]
    end
    assert(min <= max)
    return love.math.random(min, max)       --! only does whole numbers
end

local function determineMeanPrice(commodityKnowledge)
    -- returns three values
    -- commodityKnowledge = a table of previous prices for the given commodity

    local countprice
    local minprice
    local maxprice
    local meanprice
    local sumprice = 0

    countprice = #commodityKnowledge
    for i = 1, #commodityKnowledge do
        local historicprice = commodityKnowledge[i]
        if minprice == nil or historicprice < minprice then
            minprice = historicprice
        end
        if maxprice == nil or historicprice > maxprice then
            maxprice = historicprice
        end
        sumprice = sumprice + historicprice
    end
    local meanprice
    if countprice == 0 then
        meanprice = 5       --! might need to build in a default average at some point
    else
        meanprice = sumprice / countprice
    end
    return minprice, maxprice, meanprice
end

local function determineMeanWithinPriceRange(minprice, maxprice, meanprice)
    -- determine where the mean sits in the observed range
    local observedmeanrange
    observedmeanrange = maxprice - minprice
    if observedmeanrange == 0 then observedmeanrange = 1 end
    local abovefloor = meanprice - minprice
    return (abovefloor / observedmeanrange)
end

function marketplace.determineQty(maxQty, commodityKnowledge)
    -- given commodity knowledge return the bid qty for stated commodity
    -- maxQty = maximum to buy, usually based on inventory space
    -- commodityKnowledge = a table that lists previous transactions known to the agent
    -- returns a number indicating best qty to bid for. ## does not round off. Do that in parent function if necessary

    local minprice = nil
    local maxprice = nil
    local meanprice = nil
    local sumprice = 0      -- to determine average
    local countprice = 0
    if commodityKnowledge == nil then
        -- No knowledge of this commodity. Play safe and just ask for half qty.
        return maxQty / 2
    end

    -- determine key prices for this commodity
    minprice, maxprice, meanprice = determineMeanPrice(commodityKnowledge)
    if maxprice == nil then maxprice = 10 end   --! need to treat mean price the same as min/max price
    if minprice == nil then minprice = 1 end

    -- determine where the mean sits in the observed range
    local percent = determineMeanWithinPriceRange(minprice, maxprice, meanprice)

    -- flip the percent to get favourability
    local favourability = 1 - percent
    return favourability * maxQty
end

function marketplace.createBid(commodity,buyAtMostQty,bidPrice,playerID)
    -- creates a bid (request to buy) for the stated commodity
    -- ensure price is in correct currency and units

    -- commodity = item to buy
    -- buyAtMostQty = how many items to buy. Seller might have less!
    -- bidPrice = how much buyer is prepared to pay PER ITEM
    -- playerID = guid, id, obect or similar

    local bid = {buyAtMostQty, bidPrice, playerID}

    if bidtable[commodity] == nil then
        bidtable[commodity] = {}
    end
    table.insert(bidtable[commodity], bid)

    -- print(inspect(bidtable))
end

function marketplace.createAsk(commodity, sellAtMostQty, askPrice, playerID)
    -- creates an ask fro the stated commodity
    -- ensure price is in correct currency and units

    -- commodity = item to sell
    -- sellAtMostQty = how many items to buy. Buyer might want more or less!
    -- askPrice = how much seller is prepared to sell PER ITEM
    -- playerID = guid, id, obect or similar

    local ask = {sellAtMostQty, askPrice, playerID}
    if asktable[commodity] == nil then
        asktable[commodity] = {}
    end
    table.insert(asktable[commodity], ask)
end

local function adjustBiddersBeliefs(summary)

    -- belief ranges are stored as following:
    -- persons[i].beliefRange["sugar"] = {1,10}
    -- beliefRange["sugar"][1] = low belief
    -- beliefRange["sugar"][2] = high belief

    -- bidqty = amount hoped to buy
    -- askqty = amount seller asked to sell
    -- transactionqty = amount actually bought
    -- stockqty = actual inventory
    -- avgprice = the average price for this stock according to persons knowledge

    local buyer = summary.buyer
    local commodity = summary.commodity
    local beliefRange = buyer.beliefRange[commodity]
    local highestbelief = beliefRange[commodity][2]
    local transactionqty = summary.transactionqty
    local bidqty = summary.bidqty
    local askqty = summary.askqty
    local stockqty = summary.currentInventory
    local transactionprice = summary.transactiontotal
    local avgprice = summary.history  --! that ain't gunna work!!
    local bidprice = summary.bidprice
    local askprice = summary.askprice
    local avgprice = fun.getAvgPrice(buyer.stockHistory[commodity])

    if transactionqty >= (bidqty / 2) then
        -- move range inwards
        local adjustamt = highestbelief * 0.10
        beliefRange[commodity][1] = beliefRange[commodity][1] + adjustamt
        beliefRange[commodity][2] = beliefRange[commodity][2] - adjustamt
    else
        -- bid not even half satisfied (supply shortage so raise the upper belief range
        local adjustamt = highestbelief * 0.10
        beliefRange[commodity][2] = beliefRange[commodity][2] + adjustamt
    end

    -- if bid not completely filled and low on inventory then raise the range higher
    if transactionqty < (bidqty / 2) and stockqty <= 3 then     --! the 3 is an arbitrary value
        local adjustamt = math.abs(transactionprice - avgprice)
        beliefRange[commodity][1] = beliefRange[commodity][1] + adjustamt
        beliefRange[commodity][2] = beliefRange[commodity][2] + adjustamt
    elseif bidprice > transactionprice then
        -- bid was higher than the transaction price (i.e. trade was successful but paid too much) then move range down
        local adjustamt = (bidprice - transactionprice) * 1.1
        beliefRange[commodity][1] = beliefRange[commodity][1] - adjustamt
        beliefRange[commodity][2] = beliefRange[commodity][2] - adjustamt
    elseif askqty > bidqty and bidprice > avgprice then
        local adjustamt = math.abs(askprice - avgprice) * 1.1
        beliefRange[commodity][1] = beliefRange[commodity][1] - adjustamt
        beliefRange[commodity][2] = beliefRange[commodity][2] - adjustamt
    elseif bidqty > askqty then
        -- bidqty was not satisfied so move range up
        local adjustamt = (avgprice) * 0.20
        beliefRange[commodity][1] = beliefRange[commodity][1] + adjustamt
        beliefRange[commodity][2] = beliefRange[commodity][2] + adjustamt
    else
        local adjustamt = (avgprice) * 0.20
        beliefRange[commodity][1] = beliefRange[commodity][1] - adjustamt
        beliefRange[commodity][2] = beliefRange[commodity][2] - adjustamt
    end

    table.insert(buyer.beliefRangeHistory, {beliefRange[commodity][1], beliefRange[commodity][2]})


--PERSONS[i].beliefRangeHistory = {}          --  .beliefRangeHistory[enum.stockFood][1] = (1,10})


end

local function adjustAskersBeliefs()

end

local function adjustBeliefs()
    adjustBiddersBeliefs()
    adjustAskersBeliefs()
end

function marketplace.resolveOrders()
    -- bidtable and asktable are local to this module and are populated by calling
    -- createBid and createAsk before calling this function

    print("**********************")
    print("All bids (qty, price):")
    print(inspect(bidtable))
    print("All asks (qty, price):")
    print(inspect(asktable))
    print("**********************")

    local results = {}

    for k, commodity in pairs(bidtable) do
        -- print(inspect(commodity))
        table.sort(commodity, function(k1, k2) return k1[2] > k2[2] end)
        -- print(inspect(commodity))
        -- print("#############")
    end

    for k, commodity in pairs(asktable) do
        table.sort(commodity, function (k1, k2) return k1[2] < k2[2] end)
        -- print(inspect(commodity))
    end

    -- print(inspect(bidtable))
    -- print(inspect(bidtable["sugar"]))

    for commodity, commoditybook in pairs(bidtable) do
        -- commodity = enum.stockX
        for k, v in pairs(commoditybook) do
            -- print("*******************")
            -- print("* Processing commodity ID: " .. commodity)
            -- print("*******************")

            while bidtable[commodity] ~= nil and asktable[commodity] ~= nil and
            #bidtable[commodity] ~= 0 and #asktable[commodity] ~= 0 do
                local bidprice, askprice, bidqty, askqty, buyer
                local outcome = {}
                local transactionprice, transactionamt = 0,0

                buyer = people.get(bidtable[commodity][1][3])        -- get the person object
                seller = people.get(asktable[commodity][1][3])

                -- the [1] indicates the first item in the table (top of sorted table)
                -- the [2] indicates the bid/ask price (not qty)
                -- the qty traded is determined if and only if a price is agreed
                bidprice = bidtable[commodity][1][2]
                print("Bid price is $" .. bidprice)
                askprice = asktable[commodity][1][2]
                print("Ask price is $" .. askprice)

                if bidprice >= askprice then
                    transactionprice = (bidprice + askprice) / 2      --! this is a float
                    print("Price agreed at $" .. transactionprice)
                    bidqty = bidtable[commodity][1][1]
                    askqty = asktable[commodity][1][1]
                    print("Bid qty = " .. bidqty .. " and ask qty = " .. askqty)
                    if askqty >= bidqty then
                        -- purchase fully satisfied
                        print("Bid qty fully satisified")
                    else
                        print("Bid qty partially satisfied")
                    end

                    -- adjust bidqty/askqty by math.min
                    transactionamt = math.min(bidqty, askqty)
                    bidtable[commodity][1][1] = bidtable[commodity][1][1] - transactionamt
                    asktable[commodity][1][1] = asktable[commodity][1][1] - transactionamt

                    -- record the transaction before we clear the bid/ask table
                    -- [3] is the players guid specifed during createBid/createAsk
                    outcome.buyerguid = bidtable[commodity][1][3]
                    outcome.sellerguid = asktable[commodity][1][3]
                    outcome.commodityID = commodity
                    outcome.transactionTotalPrice = transactionprice * transactionamt
                    outcome.transactionTotalQty = transactionamt
                    table.insert(results, outcome)  -- results is returned to the parent function

                    -- update the memory for the buyer
                    table.insert(buyer.stockHistory[commodity], transactionprice)

                    -- update the memory for the seller

                    -- global history is updated in the love.main()


                    -- remove bid if qty satisfied
                    if bidtable[commodity][1][1] <= 0 then
                        table.remove(bidtable[commodity], 1)
                    end
                    -- remove ask if qty exhausted
                    if asktable[commodity][1][1] <= 0 then
                        table.remove(asktable[commodity], 1)
                    end

                    -- record this in memory for each agent
                    -- buyer is set up above and taken from bid table
                    table.insert(buyer.stockHistory[commodity], transactionprice)

                    table.insert(seller.stockHistory[commodity], transactionprice)

                else
                    print("Price not agreed. Trade fails")
                    -- remove bid as bid price is too low to be satisfied
                    table.remove(bidtable[commodity], 1)
                end

                -- -- adjust beliefs
                -- if transactionamt > 0 then
                --     buyer = people.get(outcome.buyerguid)        -- get the person object
                --     local summary = {}
                --     summary.commodity = commodity
                --     summary.buyer = buyer
                --     summary.bidprice = bidprice
                --     summary.askprice = askprice
                --     summary.bidqty = bidqty
                --     summary.askqty = askqty
                --     summary.transactionqty = transactionamt
                --     summary.transactiontotal = transactionprice * transactionamt
                --     summary.currentInventory = buyer.stock[commodity]
                --     summary.history = buyer.stockHistory[commodity]
                -- else
                --     buyer = people.get(outcome.buyerguid)        -- get the person object
                --     local summary = {}
                --     summary.commodity = commodity
                --     summary.buyer = buyer
                --     summary.bidprice = bidprice
                --     summary.askprice = askprice
                --     summary.bidqty = bidqty
                --     summary.askqty = askqty
                --     summary.transactionqty = transactionamt
                --     summary.transactiontotal = transactionprice * transactionamt
                --     summary.currentInventory = buyer.stock[commodity]
                --     summary.history = buyer.stockHistory[commodity]
                --
                -- end

                --! adjustBiddersBeliefs(summary)

                -- print("**********************")
                -- print("All bids (qty, price):")
                -- print(inspect(bidtable))
                -- print("All asks (qty, price):")
                -- print(inspect(asktable))
                -- print("**********************")
                -- print(asktable[3] == {})
                -- print(asktable[3] == nil)
                -- print(#asktable[3])
                -- print("~~~~~~~~~~~~~~~~~~~~~~")

            end
        end
    end

    -- clear bids and asks so it is ready for next round
    bidtable = {}
    asktable = {}

    return results

end

return marketplace
