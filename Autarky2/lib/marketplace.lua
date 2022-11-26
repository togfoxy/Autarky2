marketplace = {}

local bidtable = {}
local asktable = {}
local outcometable = {}

function marketplace.determineCommodityPrice(beliefRange)
    -- this is called by buyers and sellers

    -- print("belief table")
    -- print(inspect(beliefRange))

    local min, max
    if beliefRange == nil then
        min = 1
        max = 10
    else
        min = beliefRange[1]
        max = beliefRange[2]
    end

    if min > max then
        local str = "Assert failed: " .. min, max
        error(str)
    end
    local result = love.math.random(min, max)   -- only does whole numbers
    if result < 0.5 then result = 0.5 end
    return result
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
        meanprice = 5       -- might need to build in a default average at some point
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
    if maxprice == nil then maxprice = 10 end
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
    local beliefRange = buyer.beliefRange[commodity]        -- because the commodity is used as an input, this becomes beliefRange = {1,10}
    local highestbelief = buyer.beliefRange[commodity][2]
    local transactionqty = summary.transactionqty
    local bidqty = summary.bidqty or 0
    local askqty = summary.askqty
    local stockqty = summary.currentInventory
    local transactionprice = summary.transactionprice
    local bidprice = summary.bidprice
    local askprice = summary.askprice
    local avgprice = fun.getAvgPrice(buyer.stockPriceHistory[commodity])

    if bidqty == nil then bidqty = 0 end
    if askqty == nil then askqty = 0 end

    -- begin algorithm
    if transactionqty >= (bidqty / 2) then
        local adjustamt = highestbelief * 0.10
        beliefRange[1] = beliefRange[1] + adjustamt
        beliefRange[2] = beliefRange[2] - adjustamt
    else
        local adjustamt = highestbelief * 1.1
        beliefRange[2] = beliefRange[2] + adjustamt
    end

    if transactionqty < bidqty then
        if stockqty < 3 then
            local adjustamt = math.abs((bidprice - avgprice))
            beliefRange[1] = beliefRange[1] + adjustamt
            beliefRange[2] = beliefRange[2] + adjustamt
        else
            if bidprice > transactionprice then
                local adjustamt = (bidprice - transactionprice) * 1.1
                beliefRange[1] = beliefRange[1] - adjustamt
                beliefRange[2] = beliefRange[2] - adjustamt
            else
                if bidqty < askqty and bidprice > avgprice then
                    local adjustamt = (bidprice - avgprice) * 1.1
                    beliefRange[1] = beliefRange[1] - adjustamt
                    beliefRange[2] = beliefRange[2] - adjustamt
                else
                    if bidqty > askqty then
                        local adjustamt = avgprice * 0.20
                        beliefRange[1] = beliefRange[1] + adjustamt
                        beliefRange[2] = beliefRange[2] + adjustamt
                    else
                        local adjustamt = avgprice * 0.20
                        beliefRange[1] = beliefRange[1] - adjustamt
                        beliefRange[2] = beliefRange[2] - adjustamt
                    end
                end
            end
        end
    else
        if bidprice > transactionprice then
            local adjustamt = (bidprice - transactionprice) * 1.1
            beliefRange[1] = beliefRange[1] - adjustamt
            beliefRange[2] = beliefRange[2] - adjustamt
        else
            if bidqty < askqty and bidprice > avgprice then
                local adjustamt = (bidprice - avgprice) * 1.1
                beliefRange[1] = beliefRange[1] - adjustamt
                beliefRange[2] = beliefRange[2] - adjustamt
            else
                if bidqty > askqty then
                    local adjustamt = avgprice * 0.20
                    beliefRange[1] = beliefRange[1] + adjustamt
                    beliefRange[2] = beliefRange[2] + adjustamt
                else
                    local adjustamt = avgprice * 0.20
                    beliefRange[1] = beliefRange[1] - adjustamt
                    beliefRange[2] = beliefRange[2] - adjustamt
                end
            end
        end
    end

    beliefRange[1] = cf.round(beliefRange[1], 1)
    beliefRange[2] = cf.round(beliefRange[2], 1)

    if beliefRange[1] < 0.5 then beliefRange[1] = 0.5 end
    if beliefRange[2] < beliefRange[1] then beliefRange[2] = beliefRange[1] end

    table.insert(buyer.beliefRangeHistory[commodity], {beliefRange[1], beliefRange[2]})

    assert(beliefRange[1] > 0)
    assert(beliefRange[2] > 0)
end

local function adjustAskersBeliefs(summary)

    -- print("Echo")
    -- print(inspect(summary))

    local transactionqty = summary.transactionqty
    local askqty = summary.askqty or 0
    local bidqty = summary.bidqty or 0
    local seller = summary.seller
    local askprice = summary.askprice
    local transactionprice = summary.transactionprice
    local commodity = summary.commodity
    local beliefRange = seller.beliefRange[commodity]        -- because the commodity is used as an input, this becomes beliefRange = {1,10}
    local avgprice = fun.getAvgPrice(seller.stockPriceHistory[commodity])


    -- print("yankee")
    -- print(beliefRange[1])
    -- print(beliefRange[2])

    -- begin algorithm
    local weight = 1 - (transactionqty - askqty)
    local displacement = weight * avgprice
    if weight == nil then weight = 0 end
    if displacement == nil then displacement = 0 end

    if transactionqty == 0 then
        local adjustamt = displacement * (1/6)
        beliefRange[1] = beliefRange[1] - adjustamt
        beliefRange[2] = beliefRange[2] - adjustamt
        -- print("xray")
        -- print(transactionqty, askqty, weight, avgprice, displacement, adjustamt)
        -- print(beliefRange[1])
        -- print(beliefRange[2])
    else
        if transactionqty < (askqty * 0.75) then
            local adjustamt = displacement * (1/7)
            beliefRange[1] = beliefRange[1] - adjustamt
            beliefRange[2] = beliefRange[2] - adjustamt
            -- print("victor")
            -- print(beliefRange[1])
            -- print(beliefRange[2])
        else
            local adjustamt = avgprice * 0.2
            if bidqty > askqty then
                beliefRange[1] = beliefRange[1] + adjustamt
                beliefRange[2] = beliefRange[2] + adjustamt
                -- print("whiskey")
                -- print(beliefRange[1])
                -- print(beliefRange[2])
            else
                beliefRange[1] = beliefRange[1] - adjustamt
                beliefRange[2] = beliefRange[2] - adjustamt
                -- print("lima")
                -- print(beliefRange[1])
                -- print(beliefRange[2])
            end
        end
    end

    beliefRange[1] = cf.round(beliefRange[1], 1)
    beliefRange[2] = cf.round(beliefRange[2], 1)

    if beliefRange[1] < 0.5 then beliefRange[1] = 0.5 end
    if beliefRange[2] < beliefRange[1] then beliefRange[2] = beliefRange[1] end

    table.insert(seller.beliefRangeHistory[commodity], {beliefRange[1], beliefRange[2]})

    -- print("zulu")
    -- print(beliefRange[1])
    -- print(beliefRange[2])

    assert(beliefRange[1] > 0)
    assert(beliefRange[2] > 0)

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
                -- print("Bid price is $" .. bidprice)
                askprice = asktable[commodity][1][2]
                -- print("Ask price is $" .. askprice)

                if bidprice >= askprice then
                    transactionprice = (bidprice + askprice) / 2      -- this is a float
                    transactionprice = cf.round(transactionprice, 1)
                    -- print("Price agreed at $" .. transactionprice)
                    bidqty = bidtable[commodity][1][1]
                    askqty = asktable[commodity][1][1]
                    -- print("Bid qty = " .. bidqty .. " and ask qty = " .. askqty)
                    if askqty >= bidqty then
                        -- purchase fully satisfied
                        -- print("Bid qty fully satisified")
                    else
                        -- print("Bid qty partially satisfied")
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
                    outcome.agreedprice = transactionprice
                    outcome.transactionTotalPrice = transactionprice * transactionamt
                    outcome.transactionTotalQty = transactionamt
                    table.insert(results, outcome)  -- results is returned to the parent function

                    -- update the memory for the buyer
                    table.insert(buyer.stockPriceHistory[commodity], transactionprice)

                    -- print("+++ stock history for agent 1 +++")
                    -- print(inspect((buyer.stockPriceHistory[commodity])))
                    -- print("+++++++++++++++++++++++++++++++++")

                    -- update the memory for the seller
                    table.insert(seller.stockPriceHistory[commodity], transactionprice)

                    -- global history is updated in the love.main()

                    -- remove bid if qty satisfied
                    if bidtable[commodity][1][1] <= 0 then
                        table.remove(bidtable[commodity], 1)
                    end
                    -- remove ask if qty exhausted
                    if asktable[commodity][1][1] <= 0 then
                        table.remove(asktable[commodity], 1)
                    end
                else
                    -- print("Price not agreed. Trade fails")
                    -- remove bid as bid price is too low to be satisfied
                    table.remove(bidtable[commodity], 1)
                end

                -- adjust beliefs
                local summary = {}
                summary.commodity = commodity
                summary.buyer = buyer
                summary.beliefRange = buyer.beliefRange
                summary.bidprice = bidprice
                summary.askprice = askprice
                summary.bidqty = bidqty or 0
                summary.askqty = askqty or 0
                summary.transactionqty = transactionamt
                summary.transactionprice = transactionprice
                summary.currentInventory = buyer.stock[commodity]
                summary.history = buyer.stockPriceHistory[commodity]
                adjustBiddersBeliefs(summary)

                -- print("Bravo: buyer belief range after adjustment")
                -- print(inspect(buyer.beliefRange))

                summary.seller = seller
                adjustAskersBeliefs(summary)
                -- print("delta: seller belief range after adjustment")
                -- print(inspect(seller.beliefRange))


            end
        end
    end

    -- clear bids and asks so it is ready for next round
    bidtable = {}
    asktable = {}

    return results

end

return marketplace
